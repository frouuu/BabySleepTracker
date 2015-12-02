//
//  SecondViewController.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 15/11/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet weak var napTimesTableView: UITableView!
    @IBOutlet weak var barChartView: BarChartView!
    
    var napTimes = [NSManagedObject]()
    var page = 1
    var napData = [String : [NSManagedObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        self.napTimesTableView.reloadData();
        self.barChartView.napDates = self.napData
    }
    
    func fetchData() {
        let seconds = self.page * 7 * 24 * 60 * 60
        let weekEarlier = NSDate().dateByAddingTimeInterval(NSTimeInterval(-seconds))
        let fromDate = NSCalendar.currentCalendar().startOfDayForDate(weekEarlier)
        
        let fetchRequest = NSFetchRequest(entityName: "NapTime")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "endTime > %@", fromDate)
        fetchRequest.fetchLimit = 100;
        
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            
            napTimes = results as! [NSManagedObject]
            napData.removeAll()
            
            for napTime in napTimes {
                let startTime = napTime.valueForKey("startTime") as? NSDate
                let endTime = napTime.valueForKey("endTime") as? NSDate
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd";
                
                let startDateString = dateFormatter.stringFromDate(startTime!)
                let endDateString = dateFormatter.stringFromDate(endTime!)
                
                if startTime!.compare(weekEarlier) == NSComparisonResult.OrderedDescending {
                    if napData[startDateString] == nil {
                        napData[startDateString] = [napTime]
                    }
                    else {
                        (napData[startDateString])!.append(napTime)
                    }
                }
                
                if !startDateString.isEqual(endDateString) || startTime!.compare(weekEarlier) == NSComparisonResult.OrderedAscending {
                    if napData[endDateString] == nil {
                        napData[endDateString] = [napTime]
                    }
                    else {
                        (napData[endDateString])!.append(napTime)
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    
    // UITableViewDataSource protocol
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("NapTimeTableViewCell") as! NapTimeTableViewCell
            
            let napTime = napTimes[indexPath.row]
            let startTime = napTime.valueForKey("startTime") as? NSDate
            let endTime = napTime.valueForKey("endTime") as? NSDate
            
            if startTime == nil || endTime == nil {
                cell.startTimeLabel.text = "Error"
                cell.elapsedTimeLabel.text = "Error"
                return cell
            }

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm";
            
            cell.startTimeLabel.text   = dateFormatter.stringFromDate(startTime!)
            cell.elapsedTimeLabel.text = elapsedTimeString(startTime!, end: endTime!)
            
            return cell
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return napTimes.count;
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

