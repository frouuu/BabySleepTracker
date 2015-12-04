//
//  ListViewController.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 04/12/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var napTimesTableView: UITableView!
    
    var napTimes = [NSManagedObject]()
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.napTimesTableView.backgroundColor = UIColor.clearColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        self.napTimesTableView.reloadData();
    }
    
    func fetchData() {
        let fetchRequest = NSFetchRequest(entityName: "NapTime")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        fetchRequest.fetchLimit = 100;
        
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            
            napTimes = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
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
}


