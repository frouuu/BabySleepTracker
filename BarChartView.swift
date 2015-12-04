//
//  BarChartView.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 28/11/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//
import UIKit
import CoreData

@IBDesignable class BarChartView: UIView {
    
    @IBInspectable var gradient1Color: UIColor = UIColor.whiteColor()
    @IBInspectable var gradient2Color: UIColor = UIColor.purpleColor()
    @IBInspectable var gradient3Color: UIColor = UIColor.redColor()
    @IBInspectable var gradient4Color: UIColor = UIColor.greenColor()
    
    @IBInspectable var fillColor: UIColor = UIColor.whiteColor()
    @IBInspectable var napColor: UIColor = UIColor.purpleColor()
    @IBInspectable var linesColor: UIColor = UIColor.whiteColor()
    
    let margins : [CGFloat] = [5.0, 15.0, 15.0, 15.0]
    let lineWidth : CGFloat = 1.5
    let gapWidth : CGFloat = 10.0
    let maxBarWidth : CGFloat = 100.0
    let wholeDaySeconds = 24 * 60 * 60
    
    var napDates : [String: [ChartData]] = [:] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let graphRect = CGRectMake(rect.minX + margins[3],
            rect.minY + margins[0],
            rect.width - margins[3] - margins[1],
            rect.height - margins[0] - margins[2])
        
        let ctx = UIGraphicsGetCurrentContext()
        
        // lines
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextSetStrokeColorWithColor(ctx, linesColor.CGColor)
        
        CGContextSetAlpha(ctx, 0.3)
        
        // vertical lines
        CGContextMoveToPoint(ctx, graphRect.minX, graphRect.minY)
        CGContextAddLineToPoint(ctx, graphRect.minX, graphRect.maxY)
        CGContextMoveToPoint(ctx, graphRect.maxX, graphRect.minY)
        CGContextAddLineToPoint(ctx, graphRect.maxX, graphRect.maxY)
        
        // horizontal lines
        let unit = graphRect.height / 24.0
        for i in 0...24 {
            CGContextMoveToPoint(ctx, graphRect.minX, graphRect.minY + unit * CGFloat(i))
            CGContextAddLineToPoint(ctx, graphRect.maxX, graphRect.minY + unit * CGFloat(i))
        }
        
        CGContextSetLineCap(ctx, CGLineCap.Butt)
        
        let dashes: [CGFloat] = [0, lineWidth * 2]
        CGContextSetLineDash(ctx, 0, dashes, 2)
        CGContextSetLineCap(ctx, CGLineCap.Round)
        
        CGContextStrokePath(ctx)
        CGContextSetAlpha(ctx, 1.0)

        if (!self.napDates.isEmpty) {
            let dateArray : [String] = [String](self.napDates.keys)
        
            let sortedDateStringArray = dateArray.sort()
            let barWidth = min((graphRect.width - gapWidth) / CGFloat(self.napDates.keys.count) - gapWidth, maxBarWidth)
            
            CGContextSetAlpha(ctx, 0.4)
            for index in 0..<sortedDateStringArray.count {
                drawBackgroundBars(ctx!, graphRect: graphRect, index: index, barWidth: barWidth)
            }
            
            CGContextFillPath(ctx)
            
            CGContextSetAlpha(ctx, 1.0)
            
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
            let imageCtx = UIGraphicsGetCurrentContext()
            UIGraphicsPushContext(imageCtx!)
            
            UIColor.blackColor().setFill()
            
            for (index, dateString) in sortedDateStringArray.enumerate() {
                addRectsForDailyData(imageCtx!, graphRect: graphRect, dateString: dateString, index: index, barWidth: barWidth)
            }
        
            CGContextSetShadowWithColor(imageCtx, CGSizeZero, 4.0, UIColor.blackColor().CGColor)
            
            CGContextFillPath(imageCtx)
            
            let drawMask: CGImageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext())!
            
            UIGraphicsEndImageContext()
            UIGraphicsPopContext()
            
            CGContextSaveGState(ctx)
            
            // Quartz2d uses a different co-ordinate system, where the origin is in the lower left corner
            CGContextTranslateCTM(ctx, 0, rect.height);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            
            CGContextClipToMask(ctx, rect, drawMask)
            
            let gradientColors = [gradient1Color.CGColor, gradient2Color.CGColor, gradient3Color.CGColor, gradient4Color.CGColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations:[CGFloat] = [0.0, 0.25, 0.5, 0.75, 1.0]
            let gradient = CGGradientCreateWithColors(colorSpace, gradientColors, colorLocations)
            
            CGContextSetAlpha(ctx, 0.7)
            CGContextDrawLinearGradient(ctx, gradient, CGPoint.zero, CGPoint(x: 0, y: rect.height), CGGradientDrawingOptions.DrawsBeforeStartLocation)
            
            CGContextRestoreGState(ctx)
            
            drawText(ctx!, dateStringArray: sortedDateStringArray, rect: rect, barWidth: barWidth, graphRect: graphRect)
        }
    }
    
    func drawBackgroundBars(ctx: CGContext, graphRect: CGRect, index: Int, barWidth: CGFloat) {
        let y1 = graphRect.minY
        let x1 = graphRect.minX + CGFloat(index + 1) * gapWidth + CGFloat(index) * barWidth
        
        fillColor.setFill()
        
        CGContextAddRect(ctx, CGRectMake(x1, y1, barWidth, graphRect.height - lineWidth))
        CGContextFillPath(ctx)
    }
    
    func addRectsForDailyData(ctx: CGContext, graphRect: CGRect, dateString : String, index: Int, barWidth: CGFloat) {
        let x1 = graphRect.minX + CGFloat(index + 1) * gapWidth + CGFloat(index) * barWidth
        
        let unit = graphRect.height / CGFloat(wholeDaySeconds)
        
        for napTime in self.napDates[dateString]! {
            let startTime = napTime.startTime
            let endTime = napTime.endTime
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startOfDay = dateFormatter.dateFromString(dateString)
            
            var startTimeTimeInterval : NSTimeInterval = startTime!.timeIntervalSinceDate(startOfDay!)
            if startTimeTimeInterval < 0 {
                startTimeTimeInterval = 0
            }
            
            var endTimeTimeInterval : NSTimeInterval = endTime!.timeIntervalSinceDate(startOfDay!)
            if endTimeTimeInterval > Double(wholeDaySeconds) {
                endTimeTimeInterval = Double(wholeDaySeconds)
            }
            
            let height = unit * CGFloat(endTimeTimeInterval - startTimeTimeInterval)
            let y0 = graphRect.maxY - lineWidth - CGFloat(startTimeTimeInterval) * unit - height
            
            CGContextAddRect(ctx, CGRectMake(x1, y0, barWidth, height))
        }
    }
    
    func drawText(ctx: CGContext, dateStringArray: [String], rect: CGRect, barWidth: CGFloat, graphRect: CGRect) {
        let unit = graphRect.height / 24.0
        
        CGContextTranslateCTM(ctx, 0.0, rect.height)
        CGContextScaleCTM(ctx, 1.0, -1.0)
        
        let aFont = UIFont(name: "Helvetica Light", size: 7)
        let attr:CFDictionaryRef = [NSFontAttributeName:aFont!, NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        for (index, dateString) in dateStringArray.enumerate() {
            let x1 = graphRect.minX + CGFloat(index + 1) * gapWidth + CGFloat(index) * barWidth
            
            let text = CFAttributedStringCreate(nil, dateString, attr)
            let line = CTLineCreateWithAttributedString(text)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
            CGContextSetLineWidth(ctx, 1.5)
            CGContextSetTextDrawingMode(ctx, CGTextDrawingMode.Fill)
        
            let xn = x1 + barWidth / 2 - bounds.width/2
            let yn = rect.maxY - graphRect.maxY - 8.0 - bounds.midY
            
            CGContextSetTextPosition(ctx, xn, yn)
            CTLineDraw(line, ctx)
        }
        
        for i in 0...24 {
            let text = CFAttributedStringCreate(nil, i.description, attr)
            let line = CTLineCreateWithAttributedString(text)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
            CGContextSetLineWidth(ctx, 1.5)
            CGContextSetTextDrawingMode(ctx, CGTextDrawingMode.Fill)
            
            let xn = graphRect.minX - 8.0 - bounds.width/2
            let yn = rect.maxY - graphRect.maxY + unit * CGFloat(i) - bounds.midY
            
            CGContextSetTextPosition(ctx, xn, yn)
            CTLineDraw(line, ctx)
        }
    }
    
}