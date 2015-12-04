//
//  ChartData.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 02/12/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import Foundation

class ChartData {
    var startTime: NSDate!
    var endTime: NSDate!
    
    //var startOfTheDay: NSDate
    
    var label: NSString
    
    init(startTime1: NSDate, endTime1: NSDate/*, startOfTheDay1: NSDate*/) {
        startTime = startTime1
        endTime = endTime1
        //startOfTheDay = startOfTheDay1
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E";
        
        label = dateFormatter.stringFromDate(startTime)
    }
}