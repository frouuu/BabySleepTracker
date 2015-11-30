//
//  BarChartView.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 28/11/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//
import UIKit

@IBDesignable class BarChartView: UIView {
    
    //1 - the properties for the gradient
    @IBInspectable var startColor: UIColor = UIColor.redColor()
    @IBInspectable var endColor: UIColor = UIColor.greenColor()
    @IBInspectable var fillColor: UIColor = UIColor.whiteColor()
    @IBInspectable var napColor: UIColor = UIColor.purpleColor()
    
    let margins : [CGFloat] = [20.0, 20.0, 30.0, 30.0]
    let lineWidth : CGFloat = 1.5
    let gapWidth : CGFloat = 10.0
    
    override func drawRect(rect: CGRect) {
        let graphRect = CGRectMake(rect.minX + margins[3], rect.minY + margins[0], rect.width - margins[3] - margins[1], rect.height - margins[0] - margins[2])
        
        let ctx = UIGraphicsGetCurrentContext()
        
        // background
        //let colors = [startColor.CGColor, endColor.CGColor]
        //let colorSpace = CGColorSpaceCreateDeviceRGB()
        //let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //let gradient = CGGradientCreateWithColors(colorSpace,
        //    colors,
        //    colorLocations)
        
        //let startPoint = CGPoint.zero
        //let endPoint   = CGPoint(x:0, y:self.bounds.height)
        
        //CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, .DrawsBeforeStartLocation)
        
        // lines
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
        
        CGContextAddLines(ctx, [CGPointMake(graphRect.minX, graphRect.minY), CGPointMake(graphRect.minX, graphRect.maxY), CGPointMake(graphRect.maxX, graphRect.maxY)], 3)
        
        CGContextSetLineCap(ctx, CGLineCap.Butt)
        
        let dashes: [CGFloat] = [0, lineWidth * 2]
        CGContextSetLineDash(ctx, 0, dashes, 2)
        CGContextSetLineCap(ctx, CGLineCap.Round)
        
        CGContextStrokePath(ctx)
        
        CGContextSetAlpha(ctx, 0.4)
        
        for i in 1...7 {
            drawDailyData(ctx!, graphRect: graphRect, index: i, countDays: 7/*, data: 0*/)
        }
        
    }
    
    func drawDailyData(ctx: CGContext, graphRect: CGRect, index: Int, countDays: Int/*, data: [NSDate]*/) {
        // data
        fillColor.setFill()
        
        let barWidth = graphRect.width / CGFloat(countDays) - gapWidth
        
        let y1 = graphRect.minY
        let x1 = graphRect.minX + CGFloat(index) * gapWidth + CGFloat(index - 1) * barWidth
        
        CGContextAddRect(ctx, CGRectMake(x1, y1, barWidth, graphRect.height - lineWidth))
        CGContextFillPath(ctx)
        
        napColor.setFill()
        
        let height = CGFloat(20)
        let y11 = graphRect.maxY - lineWidth - CGFloat(10) - height
        CGContextAddRect(ctx, CGRectMake(x1, y11, barWidth, height))
        
        let height2 = CGFloat(30)
        let y12 = graphRect.maxY - lineWidth - CGFloat(40) - height2
        CGContextAddRect(ctx, CGRectMake(x1, y12, barWidth, height2))
        
        CGContextFillPath(ctx)
    }
    
}