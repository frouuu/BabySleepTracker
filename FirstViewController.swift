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
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime: NSTimeInterval = currentTime - self.startTime
            
            if elapsedTime > 24 * 60 * 60 {
                self.startTime = 0
                saveStartTime()
            }
            else {
                stopWatchButton.setTitle("Stop", forState: UIControlState.Normal);

                updateStartTimeLabel()
                updateTimeOnStopWatch()
            
                scheduleTimers()
            }
        }
        
        refreshLabelsVisibility()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchDataAndRefreshCircle()
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
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime: NSTimeInterval = currentTime - self.startTime
            
            if elapsedTime > 24 * 60 * 60 {
                self.startTime = 0
                saveStartTime()
            }
            else {
                updateStartTimeLabel()
                updateTimeOnStopWatch()
            
                scheduleTimers()
            }
        }
        
        refreshLabelsVisibility()
        
        fetchDataAndRefreshCircle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchDataAndRefreshCircle() {
        let fetchRequest = NSFetchRequest(entityName: "NapTime")
        let startOfDayForToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "endTime > %@", startOfDayForToday)
        fetchRequest.fetchLimit = 60;
        
        do {
            let napTimes = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            refreshCircleWithNapTimes(napTimes)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func refreshCircleWithNapTimes(napTimes : [NSManagedObject]) {
        let startOfDayForToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        
        var angles = [Double]()
        
        for napTime in napTimes {
            let startTime = napTime.valueForKey("startTime") as? NSDate
            let endTime = napTime.valueForKey("endTime") as? NSDate
            
            var startTimeTimeInterval : NSTimeInterval = startTime!.timeIntervalSinceDate(startOfDayForToday)
            if (startTimeTimeInterval < 0) {
                startTimeTimeInterval = 0
            }
            
            let endTimeTimeInterval : NSTimeInterval = endTime!.timeIntervalSinceDate(startOfDayForToday)
            
            let elapsedTime = endTimeTimeInterval - startTimeTimeInterval
            
            if elapsedTime > 30 {
                let startAngle = Double(startTimeTimeInterval / 60 * 2 * M_PI / 1440)
                let angle = Double(elapsedTime / 60 * 2 * M_PI / 1440)
            
                angles.append(startAngle)
                angles.append(angle)
            }
        }
        
        if self.startTime != 0 {
            var startTimeNsDate = NSDate(timeIntervalSinceReferenceDate: self.startTime)
            var seconds = startTimeNsDate.timeIntervalSinceDate(startOfDayForToday)
            if seconds < 0 {
                seconds = 0
                startTimeNsDate = startOfDayForToday
            }
            let elapsedTime = NSDate().timeIntervalSinceDate(startTimeNsDate)
            
            if elapsedTime > 30 {
                let startAngle = Double(seconds  / 60 * 2 * M_PI / 1440)
                let angle = Double(elapsedTime / 60 * 2 * M_PI / 1440)
            
                angles.append(startAngle)
                angles.append(angle)
            }
        }
        
        let currentTimeTimeInterval = NSDate().timeIntervalSinceDate(startOfDayForToday)
        
        dayStatsView.currentTimeAngle = Double(currentTimeTimeInterval / 60 * 2 * M_PI / 1440)
        dayStatsView.statsData = angles
    }
    
    func startTapped() {
        stopWatchButton.setTitle("Stop", forState: UIControlState.Normal);
        self.startTime = NSDate.timeIntervalSinceReferenceDate()
        
        refreshLabelsVisibility()
        updateStartTimeLabel()
        
        saveStartTime()
        
        scheduleTimers()
        
        fetchDataAndRefreshCircle()
    }
    
    func stopTapped() {
        if timer.valid {
            timer.invalidate()
        }
        if circleTimer.valid {
            circleTimer.invalidate()
        }
        
        stopWatchButton.setTitle("Start", forState: UIControlState.Normal);
        
        // core data
        let nap = NSEntityDescription.insertNewObjectForEntityForName("NapTime", inManagedObjectContext: self.managedObjectContext) as! NapTime
        
        nap.startTime = NSDate(timeIntervalSinceReferenceDate: self.startTime)
        nap.endTime = NSDate()

        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        self.startTime = 0
        self.refreshLabelsVisibility()
        saveStartTime()
        
        fetchDataAndRefreshCircle()
    }
    
    func saveStartTime() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(self.startTime, forKey: startKey)
        defaults.synchronize()
    }
    
    func updateTimeOnStopWatch() {
        if self.startTime == 0 {
            return
        }
        
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
        let cSelector : Selector = "fetchDataAndRefreshCircle"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        circleTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: cSelector, userInfo: nil, repeats: true)
    }
    
    func updateStartTimeLabel() {
        if self.startTime == 0 {
            self.startTimeLabel.text = ""
            
            return
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        self.startTimeLabel.text = "Started at \(dateFormatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: self.startTime)))"
    }
    
    func refreshLabelsVisibility() {
        if self.startTime == 0 {
            self.startTimeLabel.text = ""
            self.stopWatchLabel.text = "00:00:00"
            self.stopWatchLabel.hidden = true
            self.startTimeLabel.hidden = true
        }
        else {
            self.stopWatchLabel.hidden = false
            self.startTimeLabel.hidden = false
        }
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

