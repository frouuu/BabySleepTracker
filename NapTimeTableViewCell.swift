//
//  NapTimeTableViewCell.swift
//  BabySleepTracker
//
//  Created by Magdalena Łazarecka on 17/11/15.
//  Copyright © 2015 Magdalena Lazarecka. All rights reserved.
//

import UIKit

class NapTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    @IBInspectable var linesColor: UIColor = UIColor.whiteColor()
    @IBInspectable var bgColor1: UIColor = UIColor.whiteColor()
    @IBInspectable var bgColor2: UIColor = UIColor.whiteColor()
    
    let lineWidth : CGFloat = 1.5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        // lines
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextSetStrokeColorWithColor(ctx, linesColor.CGColor)
        
        let dashes: [CGFloat] = [0, lineWidth * 2]
        CGContextSetLineDash(ctx, 0, dashes, 2)
        CGContextSetLineCap(ctx, CGLineCap.Round)
        
        CGContextSetAlpha(ctx, 0.5)

        CGContextMoveToPoint(ctx, rect.minX, rect.maxY - lineWidth)
        CGContextAddLineToPoint(ctx, rect.maxX, rect.maxY - lineWidth)
        
        CGContextStrokePath(ctx)
    }

}
