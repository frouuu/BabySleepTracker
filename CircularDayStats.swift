//
//  CircularDayStats.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 23/11/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class CircularDayStats: UIView {
    
    private struct ConversionFunctions {
        static func DegreesToRadians (value:CGFloat) -> CGFloat {
            return value * CGFloat(M_PI) / 180.0
        }
        
        static func RadiansToDegrees (value:CGFloat) -> CGFloat {
            return value * 180.0 / CGFloat(M_PI)
        }
        
        static func Degree2radian(a:CGFloat)->CGFloat {
            let b = CGFloat(M_PI) * a/180
            return b
        }
    }
    
    private struct UtilityFunctions {
        static func Clamp<T: Comparable>(value: T, minMax: (T, T)) -> T {
            let (min, max) = minMax
            if value < min {
                return min
            } else if value > max {
                return max
            } else {
                return value
            }
        }
        
        static func Mod(value: Double, range: Double, minMax: (Double, Double)) -> Double {
            let (min, max) = minMax
            assert(abs(range) <= abs(max - min), "range should be <= than the interval")
            if value >= min && value <= max {
                return value
            } else if value < min {
                return Mod(value + range, range: range, minMax: minMax)
            } else {
                return Mod(value - range, range: range, minMax: minMax)
            }
        }
    }
    
    private var progressLayer: CircularDayStatsViewLayer! {
        get {
            return layer as! CircularDayStatsViewLayer
        }
    }
    
    private var radius: CGFloat! {
        didSet {
            progressLayer.radius = radius
        }
    }
    
    public var statsData: [Double]? {
        didSet {
            progressLayer.statsData = statsData
            progressLayer.setNeedsDisplay()
        }
    }
    
    public var currentTimeAngle: Double! = 0 {
        didSet {
            progressLayer.currentTimeAngle = currentTimeAngle
        }
    }
    
    @IBInspectable public var glowAmount: CGFloat = 1.0 {//Between 0 and 1
        didSet {
            progressLayer.glowAmount = UtilityFunctions.Clamp(glowAmount, minMax: (0, 1))
        }
    }
    
    @IBInspectable public var progressThickness: CGFloat = 0.4 {//Between 0 and 1
        didSet {
            progressThickness = UtilityFunctions.Clamp(progressThickness, minMax: (0, 1))
            progressLayer.progressThickness = progressThickness/2
        }
    }
    
    @IBInspectable public var trackThickness: CGFloat = 0.5 {//Between 0 and 1
        didSet {
            trackThickness = UtilityFunctions.Clamp(trackThickness, minMax: (0, 1))
            progressLayer.trackThickness = trackThickness/2
        }
    }
    
    @IBInspectable public var trackColor: UIColor = UIColor.blackColor() {
        didSet {
            progressLayer.trackColor = trackColor
            progressLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var progressInsideFillColor: UIColor? = nil {
        didSet {
            if let color = progressInsideFillColor {
                progressLayer.progressInsideFillColor = color
            } else {
                progressLayer.progressInsideFillColor = UIColor.clearColor()
            }
        }
    }
    
    @IBInspectable public var progressColor: UIColor {
        get {
            return progressLayer.color
        }
        
        set(newValue) {
            setColor(newValue)
        }
    }
    
    private var animationCompletionBlock: ((Bool) -> Void)?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        userInteractionEnabled = false
        setInitialValues()
        refreshValues()
    }
    
    convenience public init(frame:CGRect, color: UIColor) {
        self.init(frame: frame)
        
        setColor(color)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        translatesAutoresizingMaskIntoConstraints = false
        userInteractionEnabled = false
        setInitialValues()
        refreshValues()
    }
    
    override public class func layerClass() -> AnyClass {
        return CircularDayStatsViewLayer.self
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        radius = (frame.size.width/2.0) * 0.8
    }
    
    private func setInitialValues() {
        radius = (frame.size.width/2.0) * 0.8 //We always apply a 20% padding, stopping glows from being clipped
        backgroundColor = .clearColor()
        setColor(UIColor.whiteColor())
    }
    
    private func refreshValues() {
        progressLayer.glowAmount = UtilityFunctions.Clamp(glowAmount, minMax: (0, 1))
        progressLayer.progressThickness = progressThickness/2
        progressLayer.trackColor = trackColor
        progressLayer.trackThickness = trackThickness/2
    }
    
    public func setColor(newColor: UIColor) {
        progressLayer.color = newColor
        progressLayer.setNeedsDisplay()
    }
    
    public override func didMoveToWindow() {
        if let window = window {
            progressLayer.contentsScale = window.screen.scale
        }
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {       
    }
    
    public override func prepareForInterfaceBuilder() {
        setInitialValues()
        refreshValues()
        progressLayer.setNeedsDisplay()
    }
    
    private class CircularDayStatsViewLayer: CALayer {
        var radius: CGFloat!
        var statsData : [Double]?
        var currentTimeAngle : Double!
        var glowAmount: CGFloat!
        var progressThickness: CGFloat!
        var trackThickness: CGFloat!
        var trackColor: UIColor!
        var progressInsideFillColor: UIColor = UIColor.clearColor()
        var color: UIColor!
        
        
        private struct GlowConstants {
            private static let sizeToGlowRatio: CGFloat = 0.00015
            static func glowAmountForAngle(angle: Int, glowAmount: CGFloat, size: CGFloat) -> CGFloat {
                    return 360 * size * sizeToGlowRatio * glowAmount
            }
        }
        
        override init(layer: AnyObject) {
            super.init(layer: layer)
            
            let progressLayer = layer as! CircularDayStatsViewLayer
            
            radius            = progressLayer.radius
            glowAmount        = progressLayer.glowAmount
            progressThickness = progressLayer.progressThickness
            trackThickness    = progressLayer.trackThickness
            trackColor        = progressLayer.trackColor
            color             = progressLayer.color
            statsData         = progressLayer.statsData
            currentTimeAngle  = progressLayer.currentTimeAngle
        }
        
        override init() {
            super.init()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func drawInContext(ctx: CGContext) {
            UIGraphicsPushContext(ctx)
            
            let rect = bounds
            let size = rect.size
            
            let trackLineWidth: CGFloat = radius * trackThickness
            let progressLineWidth       = radius * progressThickness
            let arcRadius               = max(radius - trackLineWidth/2, radius - progressLineWidth/2)
            
            let x0 = CGFloat(size.width/2.0)
            let y0 = CGFloat(size.height/2.0)
            
            CGContextAddArc(ctx, CGFloat(size.width/2.0), CGFloat(size.height/2.0), arcRadius, CGFloat(-M_PI_2), CGFloat(currentTimeAngle - M_PI_2), 0)
            
            trackColor.set()
            CGContextSetStrokeColorWithColor(ctx, trackColor.CGColor)
            CGContextSetFillColorWithColor(ctx, progressInsideFillColor.CGColor)
            CGContextSetLineWidth(ctx, trackLineWidth)
            CGContextSetLineCap(ctx, CGLineCap.Butt)
            CGContextDrawPath(ctx, .FillStroke)
            
            CGContextAddArc(ctx, CGFloat(size.width/2.0), CGFloat(size.height/2.0), arcRadius, CGFloat(currentTimeAngle - M_PI_2), CGFloat(3 * M_PI / 2), 0)
            CGContextSetAlpha(ctx, 0.2)
            CGContextDrawPath(ctx, .FillStroke)
            
            CGContextSetAlpha(ctx, 0.2)
            
            for i in 1...24 {
                // save the original position and origin
                CGContextSaveGState(ctx)
                // make translation
                CGContextTranslateCTM(ctx, x0, y0)
                // make rotation
                CGContextRotateCTM(ctx, ConversionFunctions.Degree2radian(CGFloat(i)*15))
                if i % 6 == 0 {
                    drawSecondMarker(ctx, x:radius-5, y:0, radius:radius)
                }
                else {
                    drawSecondMarker(ctx, x:radius-2, y:0, radius:radius)
                }
                // restore state before next translation
                CGContextRestoreGState(ctx)
            }
            
            CGContextSetAlpha(ctx, 1.0)
            
            if statsData != nil {
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                let imageCtx = UIGraphicsGetCurrentContext()
            
                for var index = 0; index < statsData!.count; index+=2 {
                    let startAngle : Double = statsData![index]
                    let angle : Double      = statsData![index+1]
                
                    let fromAngle = CGFloat(UtilityFunctions.Mod(-startAngle + M_PI_2,
                        range: (2 * M_PI),
                        minMax: (0, (2 * M_PI))))
                    let toAngle = CGFloat(UtilityFunctions.Mod(-startAngle - angle + M_PI_2,
                        range: (2 * M_PI),
                        minMax: (0, (2 * M_PI))))
                
                    let x1 = CGFloat(sin(startAngle)) * arcRadius + x0;
                    let y1 = CGFloat(cos(startAngle)) * arcRadius + y0;
                
                    CGContextMoveToPoint(imageCtx, x1, y1)
                    CGContextAddArc(imageCtx, x0, y0, arcRadius, fromAngle, toAngle, 1)
                }
            
                let glowValue = GlowConstants.glowAmountForAngle(90, glowAmount: glowAmount, size: size.width)
                if glowValue > 0 {
                    CGContextSetShadowWithColor(imageCtx, CGSizeZero, glowValue, UIColor.blackColor().CGColor)
                }
                
                CGContextSetLineCap(imageCtx, CGLineCap.Butt)
                CGContextSetLineWidth(imageCtx, progressLineWidth)
                CGContextDrawPath(imageCtx, .Stroke)
            
                let drawMask: CGImageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext())!
                
                UIGraphicsEndImageContext()
            
                CGContextSaveGState(ctx)
                CGContextClipToMask(ctx, bounds, drawMask)
            
                CGContextSetFillColorWithColor(ctx, color.CGColor)
                CGContextFillRect(ctx, bounds)
            
                CGContextRestoreGState(ctx)
            }
            
            drawText(rect, ctx: ctx, x: x0, y: y0, radius: radius+60, sides: 24, color: UIColor.whiteColor())
            
            UIGraphicsPopContext()
        }
        
        func drawSecondMarker(ctx:CGContextRef, x:CGFloat, y:CGFloat, radius:CGFloat) {
            // generate a path
            let path = CGPathCreateMutable()
            // move to starting point on edge of circle
            CGPathMoveToPoint(path, nil, radius, 0)
            // draw line of required length
            CGPathAddLineToPoint(path, nil, x, y)
            // close subpath
            CGPathCloseSubpath(path)
            // add the path to the context
            CGContextAddPath(ctx, path)
            // set the line width
            CGContextSetLineWidth(ctx, 1.5)
            // set the line color
            CGContextSetStrokeColorWithColor(ctx,color.CGColor)
            // draw the line
            CGContextStrokePath(ctx)
        }
        
        func circleCircumferencePoints(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,adjustment:CGFloat=0)->[CGPoint] {
            let angle = ConversionFunctions.Degree2radian(360/CGFloat(sides))
            let cx = x // x origin
            let cy = y // y origin
            let r  = radius // radius of circle
            var i = sides
            var points = [CGPoint]()
            while points.count <= sides {
                let xpo = cx - r * cos(angle * CGFloat(i)+ConversionFunctions.Degree2radian(adjustment))
                let ypo = cy - r * sin(angle * CGFloat(i)+ConversionFunctions.Degree2radian(adjustment))
                points.append(CGPoint(x: xpo, y: ypo))
                i--;
            }
            return points
        }
        
        func drawText(rect:CGRect, ctx:CGContextRef, x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, color:UIColor) {
            
            // Flip text co-ordinate space, see: http://blog.spacemanlabs.com/2011/08/quick-tip-drawing-core-text-right-side-up/
            CGContextTranslateCTM(ctx, 0.0, CGRectGetHeight(rect))
            CGContextScaleCTM(ctx, 1.0, -1.0)
            // dictates on how inset the ring of numbers will be
            let inset:CGFloat = radius/3.5
            // An adjustment of 270 degrees to position numbers correctly
            let points = circleCircumferencePoints(sides,x:x,y:y,radius:radius-inset,adjustment:270)
            var index = 0
            
            for p in points {
                if index > 0 {
                    // Font name must be written exactly the same as the system stores it (some names are hyphenated, some aren't) and must exist on the user's device. Otherwise there will be a crash. (In real use checks and fallbacks would be created.) For a list of iOS 7 fonts see here: http://support.apple.com/en-us/ht5878
                    let aFont = UIFont(name: "Helvetica Light", size: 10)
                    // create a dictionary of attributes to be applied to the string
                    let attr:CFDictionaryRef = [NSFontAttributeName:aFont!,NSForegroundColorAttributeName:UIColor.whiteColor()]
                    // create the attributed string
                    let text = CFAttributedStringCreate(nil, index.description, attr)
                    // create the line of text
                    let line = CTLineCreateWithAttributedString(text)
                    // retrieve the bounds of the text
                    let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
                    // set the line width to stroke the text with
                    CGContextSetLineWidth(ctx, 1.5)
                    // set the drawing mode to stroke
                    CGContextSetTextDrawingMode(ctx, CGTextDrawingMode.Fill)
                    // Set text position and draw the line into the graphics context, text length and height is adjusted for
                    let xn = p.x - bounds.width/2
                    let yn = p.y - bounds.midY
                    CGContextSetTextPosition(ctx, xn, yn)
                    // the line of text is drawn - see https://developer.apple.com/library/ios/DOCUMENTATION/StringsTextFonts/Conceptual/CoreText_Programming/LayoutOperations/LayoutOperations.html
                    // draw the line of text
                    CTLineDraw(line, ctx)
                }
                index++
            }
            
        }
        
    }
    
}
