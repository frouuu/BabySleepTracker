//
//  SecondViewController.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 15/11/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let maxResults = 100
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var olderButton: UIButton!
    @IBOutlet weak var newerButton: UIButton!
    
    var page = 1
    var fromDate = NSDate()
    var toDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aSelector : Selector = "segmentedControlTapped"
        self.segmentedControl.addTarget(self, action: aSelector, forControlEvents: .ValueChanged)
        
        refreshPageButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    func fetchData() {
        let seconds = (self.page * 7 - 1) * 24 * 60 * 60
        let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        fromDate = startOfToday.dateByAddingTimeInterval(NSTimeInterval(-seconds))
        if self.page == 1 {
            toDate = NSDate()
        }
        else {
            toDate = fromDate.dateByAddingTimeInterval(NSTimeInterval(7 * 24 * 60 * 60))
        }
        
        let fetchRequest = NSFetchRequest(entityName: "NapTime")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "endTime > %@ AND startTime < %@", fromDate, toDate)
        fetchRequest.fetchLimit = maxResults;
        
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            refreshBarsWithNapTimes(results)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func refreshBarsWithNapTimes(napTimes: [NSManagedObject]) {
        var napData = [String : [ChartData]]()
        
        var labels = [String:String]()
        
        let currentCalendar = NSCalendar.currentCalendar()
        
        for napTime in napTimes {
            let startDate = napTime.valueForKey("startTime") as? NSDate
            let endDate = napTime.valueForKey("endTime") as? NSDate
            
            if startDate == nil || endDate == nil {
                continue
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd";
            
            let startDateString = dateFormatter.stringFromDate(startDate!)
            let endDateString = dateFormatter.stringFromDate(endDate!)
            
            if startDate!.compare(fromDate) == NSComparisonResult.OrderedDescending {
                let endDate2 : NSDate
                
                if !currentCalendar.isDate(startDate!, inSameDayAsDate: endDate!) {
                    let startOfStartDate = NSCalendar.currentCalendar().startOfDayForDate(startDate!)
                    
                    endDate2 = startOfStartDate.dateByAddingTimeInterval(24 * 60 * 60)
                }
                else {
                    endDate2 = endDate!
                }
                
                let chartData = ChartData(startTime: startDate!, endTime: endDate2)
                
                if napData[startDateString] == nil {
                    napData[startDateString] = [chartData]
                }
                else {
                    (napData[startDateString])!.append(chartData)
                }
            }
            
            if endDate!.compare(toDate) == NSComparisonResult.OrderedAscending {
            if !currentCalendar.isDate(startDate!, inSameDayAsDate: endDate!) {
                let startOfEndDate = NSCalendar.currentCalendar().startOfDayForDate(endDate!)
                
                let chartData = ChartData(startTime: startOfEndDate, endTime: endDate!)
                
                if napData[endDateString] == nil {
                    napData[endDateString] = [chartData]
                }
                else {
                    (napData[endDateString])!.append(chartData)
                }
            }
            }
        }
        
        for dateString in napData.keys {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = self.page == 1 ? "E" : "dd-LLL";
            
            let firstData = napData[dateString]![0] as ChartData
            let startDateInFirstData = firstData.startTime
            labels[dateString] = dateFormatter.stringFromDate(startDateInFirstData)
        }
        
        for i in 0...6
        {
            let interval = NSTimeInterval(60 * 60 * 24 * i)
            let nextDate = fromDate.dateByAddingTimeInterval(interval)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd";
            
            let nextDateString = dateFormatter.stringFromDate(nextDate)
            
            dateFormatter.dateFormat = self.page == 1 ? "E" : "dd-LLL";
            
            if !napData.keys.contains(nextDateString) {
                napData[nextDateString] = []
                labels[nextDateString] = dateFormatter.stringFromDate(nextDate)
            }
        }
        
        self.barChartView.napDates = napData
        self.barChartView.labels = labels
    }
    
    func refreshPageButtons() {
        self.olderButton.hidden = false
        self.newerButton.hidden = (self.page == 1)
    }
    
    func segmentedControlTapped() {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            self.barChartView.chartType = .Details
        default:
            self.barChartView.chartType = .Sum
        }
    }
    
    func elapsedTimeString(startTime : NSDate, end endTime : NSDate) -> String {
        var elapsedTime: NSTimeInterval = endTime.timeIntervalSinceDate(startTime)
        
        //calculate the hours in elapsed time.
        let hours = UInt8(elapsedTime / 3600.0)
        elapsedTime -= (NSTimeInterval(hours) * 3600)
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        return "\(strHours):\(strMinutes):\(strSeconds)"
    }

    @IBAction func olderButtonTapped(sender: AnyObject) {
        self.page++
        
        refreshPageButtons()
        fetchData()
    }
    
    @IBAction func newerButtonTapped(sender: AnyObject) {
        if self.page > 1 {
            self.page--
            
            refreshPageButtons()
            fetchData()
        }
    }
    
}

