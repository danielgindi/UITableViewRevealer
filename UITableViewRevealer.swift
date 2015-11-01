//
//  UITableViewRevealer.swift
//  UITableViewRevealer
//
//  Created by Daniel Cohen Gindi on 11/1/15.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/UITableViewRevealer
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE. 
//  

import UIKit

@objc
public enum UITableViewRevealerPosition: Int
{
    /// :param: Reveals views on the right
    case Right
    
    /// :param: Reveals views on the left
    case Left
}

private class UITableViewRevealer: NSObject, UIGestureRecognizerDelegate
{
    private var _panGestureRecognizer: UIPanGestureRecognizer!
    
    /// The cuurent offset of the pan gesture
    private var _panOffset: CGFloat = 0
    
    /// The tableView the this revealer is attached to.
    /// It is a `weak` reference so that the tableView can be deallocated first, and then its revealer will be deallocated automatically
    private weak var _tableView: UITableView?
    
    /// The position where to reveal the views (on the right or on the left)
    private var position: UITableViewRevealerPosition = .Right
    
    /// :param: tableView The table view to attached to
    /// :position: position The position where to reveal the views (on the right or on the left)
    private init(tableView: UITableView, position: UITableViewRevealerPosition)
    {
        super.init()
        
        _tableView = tableView
        self.position = position
        
        _panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panGestureRecognized:"))
        _panGestureRecognizer.delegate = self
        _tableView?.addGestureRecognizer(_panGestureRecognizer)
    }
    
    /// :param: tableView The table view to attached to
    /// :position: position The position where to reveal the views (on the right or on the left)
    private static func revealer(tableView tableView: UITableView, position: UITableViewRevealerPosition) -> UITableViewRevealer
    {
        return UITableViewRevealer(tableView: tableView, position: position)
    }
    
    deinit
    {
        _tableView?.removeGestureRecognizer(_panGestureRecognizer)
        _tableView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    private override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if keyPath == "contentOffset"
        {
            layoutViews()
            return
        }
        
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
    
    private func layoutViews()
    {
        guard let visibleCells = _tableView?.visibleCells else { return }

        for cell in visibleCells
        {
            let isAttached: Bool = cell.revealerViewAttached
            let view = cell.revealerView
            
            if view !== nil
            {
                // Sanity check. If the user has done something to the view...
                if view!.superview !== cell
                {
                    print("UITableViewRevealer warning: The view \(view) is not a subview of the \(cell)");
                }
                
                // Make sure that the revealer view sticks to the correct side of the cell
                if position == .Right
                {
                    view!.autoresizingMask = [.FlexibleHeight, .FlexibleLeftMargin]
                }
                else
                {
                    view!.autoresizingMask = [.FlexibleHeight, .FlexibleRightMargin]
                }
                
                // Now prepare the new rect for the view
                var rect = view!.frame
                rect.origin.y = 0.0
                rect.size.height = cell.bounds.height
                
                if position == .Right
                {
                    rect.origin.x = cell.bounds.maxX + max(_panOffset, -rect.size.width)
                }
                else
                {
                    rect.origin.x = -rect.size.width + min(_panOffset, rect.size.width)
                }
                
                view!.frame = rect
                
                // If "attached" mode is on, then we need to reduce the contentView's size.
                // For example: In iMessage app, the right-aligned bubbles go left, and the left ones stay in place. So it's the width that is reduced.
                // But there's a problem: The cell's layoutSubviews is not animatable. So we move the whole cell to achieve a similar effect.
                if isAttached
                {
                    // This is how much we need to reduce the contentView by
                    let howMuch = position == .Right ?
                        min(max(0, -_panOffset), view!.bounds.width) :
                        max(min(0, -_panOffset), -view!.bounds.width)

                    // Let the cell lay out its contentView
                    cell.layoutSubviews()
                    
                    // Update the frame
                    var rect = cell.contentView.frame
                    rect.origin.x -= howMuch
                    //rect.size.width -= howMuch
                    cell.contentView.frame = rect
                }
            }
        }
    }
    
    /// MARK: - Gesture Handlers
    
    @objc
    private func panGestureRecognized(recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .Began:
            
            _tableView?.addObserver(self, forKeyPath: "contentOffset", options: [.Initial, .New], context: nil)
            
        case .Changed:
            
            let translationX = recognizer.translationInView(recognizer.view!).x
            _panOffset += translationX
            
            recognizer.setTranslation(CGPointZero, inView: recognizer.view)
            layoutViews()
            
        case .Ended: fallthrough
        case .Cancelled: fallthrough
        case .Failed:
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self._panOffset = 0.0
                self.layoutViews()
                
            })
            
            _tableView?.removeObserver(self, forKeyPath: "contentOffset")
            
        case .Possible:
            break
            
        }
    }
    
    /// MARK: - UIGestureRecognizerDelegate
    
    @objc
    private func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    @objc
    private func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (_panGestureRecognizer === gestureRecognizer)
        {
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translationInView(gestureRecognizer.view!)
            return fabs(translation.x) > fabs(translation.y)
        }
        
        return true
    }
}


var s_AssociatedKey_UITableViewRevealer: UInt8 = 0
var s_AssociatedKey_IsAttached: UInt8 = 0
var s_AssociatedKey_RevealerView: UInt8 = 0

extension UITableView
{
    /// Sets up a revealer for this table
    /// :param: position The gesture direction
    public func setupRevealerAtPosition(position: UITableViewRevealerPosition)
    {
        teardownRevealer()
        
        let revealer = UITableViewRevealer.revealer(tableView: self, position: position)
        
        objc_setAssociatedObject(self, &s_AssociatedKey_UITableViewRevealer, revealer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Removes the revealer for this table. You only need to call this if wanting to disable the revealer while keeping the tableview, as the revealer will be automatically deallocated with the tableview.
    public func teardownRevealer()
    {
        let revealer = objc_getAssociatedObject(self, &s_AssociatedKey_UITableViewRevealer) as? UITableViewRevealer
        
        if revealer != nil
        {
            objc_setAssociatedObject(self, &s_AssociatedKey_UITableViewRevealer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UITableViewCell
{
    /// Is the revealed view attached to this cell while sliding?
    public var revealerViewAttached: Bool
    {
        get
        {
            let val = objc_getAssociatedObject(self, &s_AssociatedKey_IsAttached) as! Bool?
            if val != nil
            {
                return val!.boolValue
            }
            return true
        }
        set
        {
            objc_setAssociatedObject(self, &s_AssociatedKey_IsAttached, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The view to be revealed
    public var revealerView: UIView?
    {
        get
        {
            return objc_getAssociatedObject(self, &s_AssociatedKey_RevealerView) as! UIView?
        }
        set
        {
            if self.revealerView?.superview == self
            {
                self.revealerView?.removeFromSuperview()
            }
            
            if newValue != nil
            {
                let didDisableAnimations = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                
                self.addSubview(newValue!)
                
                var rect = newValue!.frame
                rect.origin.y = 0.0
                rect.size.height = self.bounds.height
                rect.origin.x = self.bounds.maxX
                newValue!.frame = rect
                
                if didDisableAnimations
                {
                    UIView.setAnimationsEnabled(didDisableAnimations)
                }
            }
            
            objc_setAssociatedObject(self, &s_AssociatedKey_RevealerView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
