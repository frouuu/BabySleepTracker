//
//  NiceView.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 10/12/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import UIKit

class NiceView: UIView {
    
    @IBInspectable var linesColor: UIColor = UIColor.whiteColor()
    
    let lineWidth :CGFloat = 1.5

    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        // lines
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextSetStrokeColorWithColor(ctx, linesColor.CGColor)
        
        CGContextSetAlpha(ctx, 0.2)
        
        CGContextMoveToPoint(ctx, rect.minX, rect.maxY - lineWidth)
        CGContextAddLineToPoint(ctx, rect.maxX, rect.maxY - lineWidth)
        
        let dashes: [CGFloat] = [0, lineWidth * 2]
        CGContextSetLineDash(ctx, 0, dashes, 2)
        CGContextSetLineCap(ctx, CGLineCap.Round)
        
        CGContextStrokePath(ctx)
    }

}
