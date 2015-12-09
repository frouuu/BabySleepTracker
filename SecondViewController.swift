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

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var napTimes = [NSManagedObject]()
    var page = 1
    var napData = [String : [ChartData]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aSelector : Selector = "segmentedControlTapped"
        self.segmentedControl.addTarget(self, action: aSelector, forControlEvents: .ValueChanged)
        
        self.barChartView.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    func fetchData() {
        let seconds = self.page * 6 * 24 * 60 * 60
        let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        let fromDate = startOfToday.dateByAddingTimeInterval(NSTimeInterval(-seconds))
        
        let fetchRequest = NSFetchRequest(entityName: "NapTime")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "endTime > %@", fromDate)
        fetchRequest.fetchLimit = 100;
        
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            
            napTimes = results as! [NSManagedObject]
            napData.removeAll()
            
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
            
            for dateString in napData.keys {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "E";
                
                let firstData = napData[dateString]![0] as ChartData
                let startDateInFirstData = firstData.startTime
                labels[dateString] = dateFormatter.stringFromDate(startDateInFirstData)
            }
            
            self.barChartView.napDates = self.napData
            self.barChartView.labels = labels
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
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

}

