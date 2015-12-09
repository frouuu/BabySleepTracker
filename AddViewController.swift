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
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var napTime : NSManagedObject?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let napTime = napTime {
            let startTime = napTime.valueForKey("startTime") as? NSDate
            let endTime = napTime.valueForKey("endTime") as? NSDate
            
            startDatePicker.date = startTime!
            endDatePicker.date = endTime!
        }
        
        self.checkValidDates()
    }
    
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
    
    // MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedObjectContext = appDelegate.managedObjectContext
            
            let entity =  NSEntityDescription.entityForName("NapTime", inManagedObjectContext:managedObjectContext)
            
            let startDate = startDatePicker.date
            let endDate = endDatePicker.date
            
            let napTime = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
            
            napTime.setValue(startDate, forKey: "startTime")
            napTime.setValue(endDate, forKey: "endTime")
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }

        }
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        let isPresentingInAddNapMode = presentingViewController is UINavigationController
        
        if isPresentingInAddNapMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func startDatePickerValueChanged(sender: AnyObject) {
        saveButton.enabled = checkValidDates()
    }
    
    @IBAction func endDatePickerValueChanged(sender: AnyObject) {
        saveButton.enabled = checkValidDates()
    }
}
