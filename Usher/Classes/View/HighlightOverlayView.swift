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

    var autoDismissOnHighlightedTap = true
    var highlightTapped = false
    
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
    
    func highlight(views: [UIView]) {
        
        UIApplication.sharedApplication().keyWindow!.addSubview(self)
        var transformedViews: [HighlightView] = []
        for view in views {
            var highlight = HighlightView(frame: convertRect(view.frame, fromView: view.superview))
            highlight.associatedView = view
            transformedViews.append(highlight)
        }
        self.views = transformedViews
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
}

class HighlightView: UIView {
    var associatedView: UIView!
}
