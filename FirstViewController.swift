//
//  FirstViewController.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 15/11/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController {
    
    let startKey = "start"

    @IBOutlet weak var stopWatchButton: UIButton!
    @IBOutlet weak var stopWatchLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var dayStatsView: CircularDayStats!
    
    var startTime : NSTimeInterval = 0
    var timer : NSTimer = NSTimer()
    var circleTimer : NSTimer = NSTimer()
    var circularDayStats : CircularDayStats!
    var napTimes = [NSManagedObject]()
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWillEnterForeground", name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
        stopWatchButton.backgroundColor = UIColor.init(red: 226/255, green: 222/255, blue: 231/255, alpha: 1.0)
        stopWatchButton.layer.cornerRadius = 75
        stopWatchButton.layer.borderWidth = 0
        
        
        self.startTime = savedStartTime()
        
        if (self.startTime != 0) {
            stopWatchButton.setTitle("Stop", forState: UIControlState.Normal);

            updateStartTimeLabel()
            updateTimeOnStopWatch()
            
            scheduleTimers()
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        refreshCircle()
    }

    
    func handleDidEnterBackground() {
        if timer.valid {
            timer.invalidate()
        }
        
        if circleTimer.valid {
            circleTimer.invalidate()
        }
    }
    
    func handleWillEnterForeground() {
        self.startTime = savedStartTime()
        
        if (self.startTime != 0) {
            updateStartTimeLabel()
            updateTimeOnStopWatch()
            
            scheduleTimers()
        }
        
        fetchData()
        refreshCircle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchData() {
        let fetchRequest = NSFetchRequest(entityName: "NapTime")
        let startOfDayForToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "endTime > %@", startOfDayForToday)
        fetchRequest.fetchLimit = 60;
        
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            
            napTimes = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func refreshCircle() {
        let startOfDayForToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        
        //let angles = [0, M_PI]
        var angles = [Double]()
        
        for napTime in napTimes {
            let startTime = napTime.valueForKey("startTime") as? NSDate
            let endTime = napTime.valueForKey("endTime") as? NSDate
            
            var startTimeTimeInterval : NSTimeInterval = startTime!.timeIntervalSinceDate(startOfDayForToday)
            if (startTimeTimeInterval < 0) {
                startTimeTimeInterval = 0
            }
            
            let endTimeTimeInterval :NSTimeInterval = endTime!.timeIntervalSinceDate(startOfDayForToday)
            
            let startAngle = Double(startTimeTimeInterval / 60 * 2 * M_PI / 1440)
            let angle = Double((endTimeTimeInterval - startTimeTimeInterval) / 60 * 2 * M_PI / 1440)
            
            angles.append(startAngle)
            angles.append(angle)
        }
        
        if self.startTime != 0 {
            var startTimeNsDate = NSDate(timeIntervalSinceReferenceDate: self.startTime)
            var seconds = startTimeNsDate.timeIntervalSinceDate(startOfDayForToday)
            if seconds < 0 {
                seconds = 0
                startTimeNsDate = startOfDayForToday
            }
            let startAngle = Double(seconds  / 60 * 2 * M_PI / 1440)
            let angle = Double(NSDate().timeIntervalSinceDate(startTimeNsDate) / 60 * 2 * M_PI / 1440)
            
            angles.append(startAngle)
            angles.append(angle)
        }
        
        let currentTimeTimeInterval = NSDate().timeIntervalSinceDate(startOfDayForToday)
        
        dayStatsView.currentTimeAngle = Double(currentTimeTimeInterval / 60 * 2 * M_PI / 1440)
        dayStatsView.statsData = angles
    }
    
    func startTapped() {
        stopWatchButton.setTitle("Stop", forState: UIControlState.Normal);
        self.startTime = NSDate.timeIntervalSinceReferenceDate()
        
        scheduleTimers()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(self.startTime, forKey: startKey)
        defaults.synchronize()
        
        updateStartTimeLabel()
        
        refreshCircle()
    }
    
    func stopTapped() {
        if timer.valid {
            timer.invalidate()
        }
        if circleTimer.valid {
            circleTimer.invalidate()
        }
        
        stopWatchButton.setTitle("Start", forState: UIControlState.Normal);
        
        let nap = NSEntityDescription.insertNewObjectForEntityForName("NapTime", inManagedObjectContext: self.managedObjectContext) as! NapTime
        
        nap.startTime = NSDate(timeIntervalSinceReferenceDate: self.startTime)
        nap.endTime = NSDate()
        
        self.startTime = 0
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(0, forKey: startKey)
        defaults.synchronize()

        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func updateTimeOnStopWatch() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - self.startTime
        
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
        
        stopWatchLabel.text = "\(strHours):\(strMinutes):\(strSeconds)"
    }
    
    func savedStartTime() -> NSTimeInterval {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.doubleForKey(startKey)
    }
    
    func scheduleTimers() {
        let aSelector : Selector = "updateTimeOnStopWatch"
        let cSelector : Selector = "refreshCircle"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        circleTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: cSelector, userInfo: nil, repeats: true)
    }
    
    func updateStartTimeLabel() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        self.startTimeLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: self.startTime))
    }

    @IBAction func stopWatchButtonTapped(sender: AnyObject) {
        if (self.startTime == 0) {
            startTapped()
        }
        else {
            stopTapped()
        }
    }
    
}

