//
//  AddViewController.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 06/12/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddViewController: UIViewController {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDateParentView: UIView!
    
    var napTime : NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let napTime = napTime {
            let startTime = napTime.valueForKey("startTime") as? NSDate
            let endTime = napTime.valueForKey("endTime") as? NSDate
            
            startDatePicker.date = startTime!
            endDatePicker.date = endTime!
        }
        
        checkValidDates()
    }
    
    // MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }*/
    
    // This method lets return to list of naps
    func unwind() {
        if presentingViewController == nil {
            navigationController!.popViewControllerAnimated(true)
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: Save and Cancel
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        if presentingViewController == nil {
            navigationController!.popViewControllerAnimated(true)
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        if !checkValidDates() {
            saveButton.enabled = false
            return
        }
        
        let entity =  NSEntityDescription.entityForName("NapTime", inManagedObjectContext:managedObjectContext)
        
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        if napTime == nil {
            napTime = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        }
        else {
            let oldStartDate = napTime!.valueForKey("startTime") as? NSDate
            let oldEndDate = napTime!.valueForKey("endTime") as? NSDate
            
            if oldStartDate?.compare(startDate) == .OrderedSame && oldEndDate?.compare(endDate) == .OrderedSame {
                unwind()
                
                return
            }
        }
        
        if checkCollisions() {
            let alertController = UIAlertController(title: "Error", message:
                "Dates conflict", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        napTime!.setValue(startDate, forKey: "startTime")
        napTime!.setValue(endDate, forKey: "endTime")
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

        unwind()
    }
    
    @IBAction func startDatePickerValueChanged(sender: AnyObject) {
        saveButton.enabled = checkValidDates()
    }
    
    @IBAction func endDatePickerValueChanged(sender: AnyObject) {
        saveButton.enabled = checkValidDates()
    }
    
    // MARK: Validation
    func checkValidDates() -> Bool {
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        if endDate.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            let elapsedTime: NSTimeInterval = endDate.timeIntervalSinceDate(startDate)
            
            if elapsedTime > 0 && elapsedTime < 24 * 60 * 60 {
                return true
            }
        }
        
        return false
    }
    
    func checkCollisions() -> Bool {
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        let fetchRequest = NSFetchRequest(entityName: "NapTime")
        fetchRequest.predicate = NSPredicate(format: "(startTime <= %@ AND endTime > %@) OR (startTime < %@ AND endTime >= %@) ", startDate, startDate, endDate, endDate)
        fetchRequest.fetchLimit = 1;
        
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            
            if results.count > 0 {
                if napTime == nil {
                    return true
                }
                
                let napTimes = results as! [NSManagedObject]
                for fetchedNapTime in napTimes {
                    /*let fetchedStartDate = fetchedNapTime.valueForKey("startTime") as? NSDate
                    let fetchedEndDate = fetchedNapTime.valueForKey("endTime") as? NSDate
                    
                    let modifiedStartDate = napTime!.valueForKey("startTime") as? NSDate
                    let modifiedEndDate = napTime!.valueForKey("endTime") as? NSDate
                    
                    if modifiedStartDate == nil || modifiedEndDate == nil {
                        continue
                    }
                    
                    if modifiedStartDate!.compare(fetchedStartDate) != .OrderedSame || modifiedEndDate!.compare(fetchedEndDate) != .OrderedSame {
                        return true
                    }*/
                    if !fetchedNapTime.isEqual(napTime) {
                        return true
                    }
                }
            }
        } catch let error as NSError  {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return false
    }
}
