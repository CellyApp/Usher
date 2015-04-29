//
//  HighlightOverlayView.swift
//  Usher
//
//  Created by Jeremy Lawrence on 4/28/15.
//  Copyright (c) 2015 Celly. All rights reserved.
//

import UIKit

class HighlightOverlayView: UIView {
    
    var views: [HighlightView]!
    var animationDuration: NSTimeInterval = 0.35

    // Tap interactions
    var autoDismissOnHighlightedTap = true
    var highlightTapped = false
    
    // Help text attributes
    var helpTextFont: UIFont = UIFont.systemFontOfSize(20)
    
    // MARK: - Initialization
    init() {
        super.init(frame: UIApplication.sharedApplication().keyWindow!.frame)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        alpha = 0
        userInteractionEnabled = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func drawRect(rect: CGRect) {
        UIColor.clearColor().setFill()
        for view in views {
            UIRectFill(CGRectIntersection(view.frame, rect))
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        for view in views {
            if CGRectContainsPoint(view.frame, point) {
                highlightTapped = true
                return view.associatedView
            }
        }
        return self
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if autoDismissOnHighlightedTap && highlightTapped {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismiss(nil)
            })
        }
    }
    
    // MARK: - Public
    
    func highlight(views: [UIView], withText highlightText: String = "") {
        
        UIApplication.sharedApplication().keyWindow!.addSubview(self)
        var transformedViews: [HighlightView] = []
        for view in views {
            var highlight = HighlightView(frame: convertRect(view.frame, fromView: view.superview))
            highlight.associatedView = view
            transformedViews.append(highlight)
            addSubview(highlight)
        }
        self.views = transformedViews
        
        if highlightText != "" {
            addText(highlightText)
        }
        
        setNeedsDisplay()
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.alpha = 1
            }) { (completed: Bool) -> Void in
                if completed {
                    self.userInteractionEnabled = true
                }
        }
    }
    
    func dismiss(completion: ((Void) -> Void)?) {
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.alpha = 0
            }) { (completed: Bool) -> Void in
                if completed {
                    self.userInteractionEnabled = false
                    self.removeFromSuperview()
                    completion?()
                }
        }
    }
    
    // MARK: - Internal
    
    func addText(text: String) {
        var textBounds = NSString(string: text).boundingRectWithSize(bounds.size, options: NSStringDrawingOptions.UsesFontLeading, attributes: [NSFontAttributeName : helpTextFont], context: nil)
        
        var textBuffer: CGFloat = 8
        var sideBuffer: CGFloat = 8
        var topBuffer: CGFloat = 28
        if let firstView = views.first {
            var originY = CGRectGetMinY(firstView.frame) - (textBuffer + textBounds.height)
            var originX = CGRectGetMinX(firstView.frame)
            
            if !(originY > topBuffer)  {
                originY = CGRectGetMaxY(firstView.frame) + textBuffer
            }
            if originX + CGRectGetWidth(textBounds) > CGRectGetWidth(bounds) {
                originX = CGRectGetWidth(bounds) - (sideBuffer + CGRectGetWidth(textBounds))
            }
            
            var label = UILabel()
            label.font = helpTextFont
            label.text = text
            label.textColor = .whiteColor()
            label.sizeToFit()
            var newFrame = label.frame
            newFrame.origin = CGPoint(x: originX, y: originY)
            label.frame = newFrame
            addSubview(label)
        }
    }
}

class HighlightView: UIView {
    var associatedView: UIView!
    
    var underlyingFrame: CGRect
    var buffer: CGFloat = 10
    
    override init(frame: CGRect) {
        underlyingFrame = frame
        var expandedFrame = CGRectInset(frame, -buffer, -buffer)
        super.init(frame: expandedFrame)
        backgroundColor = .clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        
        // Shared gradient parameters
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        var colors = [UIColor.clearColor().CGColor, superview!.backgroundColor!.CGColor]
        var radius: CGFloat = buffer * sqrt(2)
        var radialGradient = CGGradientCreateWithColors(colorSpace, colors, [0, buffer/radius])
        var linearGradient = CGGradientCreateWithColors(colorSpace, colors, [0, 1])
        
        // Corner positions
        var leftPosition = buffer
        var rightPosition = CGRectGetWidth(bounds) - buffer
        var topPosition = buffer
        var bottomPosition = CGRectGetHeight(bounds) - buffer
        // Corner position points
        var topLeftCenter = CGPoint(x: leftPosition, y: topPosition)
        var topRightCenter = CGPoint(x: rightPosition, y: topPosition)
        var bottomLeftCenter = CGPoint(x: leftPosition, y: bottomPosition)
        var bottomRightCenter = CGPoint(x: rightPosition, y: bottomPosition)
        
        
        // Corner gradients
        CGContextSaveGState(context)
        // Draw top left
        CGContextClipToRect(context, CGRect(x: 0, y: 0, width: buffer, height: buffer))
        CGContextDrawRadialGradient(context, radialGradient, topLeftCenter, 0, topLeftCenter, radius, 0)
        
        CGContextRestoreGState(context)
        CGContextSaveGState(context)
        
        // Top right
        CGContextClipToRect(context, CGRect(x: topRightCenter.x, y: 0, width: buffer, height: buffer))
        CGContextDrawRadialGradient(context, radialGradient, topRightCenter, 0, topRightCenter, radius, 0)
        
        CGContextRestoreGState(context)
        CGContextSaveGState(context)
        
        // Bottom left
        CGContextClipToRect(context, CGRect(x: 0, y: bottomLeftCenter.y, width: buffer, height: buffer))
        CGContextDrawRadialGradient(context, radialGradient, bottomLeftCenter, 0, bottomLeftCenter, radius, 0)
        
        CGContextRestoreGState(context)
        CGContextSaveGState(context)
        
        // Bottom right
        CGContextClipToRect(context, CGRect(x: bottomRightCenter.x, y: bottomRightCenter.y, width: buffer, height: buffer))
        CGContextDrawRadialGradient(context, radialGradient, bottomRightCenter, 0, bottomRightCenter, radius, 0)
        
        CGContextRestoreGState(context)
        CGContextSaveGState(context)
        
        
        // Edge gradients
        CGContextClipToRect(context, CGRect(x: 0, y: topLeftCenter.y, width: CGRectGetWidth(bounds), height: bottomLeftCenter.y - topLeftCenter.y))
        CGContextDrawLinearGradient(context, linearGradient, CGPoint(x: buffer, y: 0), CGPoint(x: 0, y: 0), 0)
        CGContextDrawLinearGradient(context, linearGradient, CGPoint(x: topRightCenter.x, y: 0), CGPoint(x: CGRectGetWidth(bounds), y: 0), 0)
        
        CGContextRestoreGState(context)
        CGContextSaveGState(context)
        
        CGContextClipToRect(context, CGRectMake(buffer, 0, topRightCenter.x - topLeftCenter.x, CGRectGetHeight(bounds)))
        CGContextDrawLinearGradient(context, linearGradient, CGPoint(x: 0, y: buffer), CGPoint(x: 0, y: 0), 0)
        CGContextDrawLinearGradient(context, linearGradient, CGPoint(x: 0, y: bottomLeftCenter.y), CGPoint(x: 0, y: CGRectGetHeight(bounds)), 0)
    }
}
