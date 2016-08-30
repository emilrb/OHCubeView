//
//  OHCubeView.swift
//  CubeController
//
//  Created by Øyvind Hauge on 11/08/16.
//  Copyright © 2016 Oyvind Hauge. All rights reserved.
//

import UIKit

@objc protocol OHCubeViewDelegate: class {
    
    optional func cubeViewDidScroll(cubeView: OHCubeView)
}

public class OHCubeView: UIScrollView, UIScrollViewDelegate {
    
    weak var cubeDelegate: OHCubeViewDelegate?
    
    private let maxAngle: CGFloat = 60.0
    
    private var childViews = [UIView]()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        configureScrollView()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func addChildViews(views: [UIView]) {
        
        let w = bounds.size.width
        let h = bounds.size.height
        
        for index in 0 ..< views.count {
            
            let view = views[index]
            
            view.frame = CGRectMake(CGFloat(index) * w, 0, w, h)
            view.layer.masksToBounds = true
            addSubview(view)
            
            childViews.append(view)
        }
        contentSize = CGSizeMake(CGFloat(childViews.count) * w, h)
    }
    
    public func addChildView(view: UIView) {
        addChildViews([view])
    }
    
    public func scrollToViewAtIndex(index: Int, animated: Bool) {
        if index > -1 && index < childViews.count {
            
            let width = self.frame.size.width
            let height = self.frame.size.height
            
            let frame = CGRectMake(CGFloat(index)*width, 0, width, height)
            scrollRectToVisible(frame, animated: animated)
        }
    }
    
    // MARK: Scroll view delegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        transformViewsInScrollView(scrollView)
        cubeDelegate?.cubeViewDidScroll?(self)
    }
    
    // MARK: Private methods
    
    private func configureScrollView() {
        
        //backgroundColor = UIColor(red:0.05, green:0.10, blue:0.14, alpha:1.0)
        backgroundColor = UIColor.whiteColor()
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        pagingEnabled = true
        bounces = true
        
        delegate = self
    }
    
    private func transformViewsInScrollView(scrollView: UIScrollView) {
        
        let xOffset = scrollView.contentOffset.x
        let svWidth = scrollView.frame.width
        var deg = maxAngle / bounds.size.width * xOffset
        
        for index in 0 ..< childViews.count {
            
            let view = childViews[index]
            
            deg = index == 0 ? deg : deg - maxAngle
            let rad = deg * CGFloat(M_PI) / 180
            
            var transform = CATransform3DIdentity
            transform.m34 = 1 / 500
            transform = CATransform3DRotate(transform, rad, 0, 1, 0)
            
            view.layer.transform = transform
            
            let x = xOffset / svWidth > CGFloat(index) ? 1.0 : 0.0
            setAnchorPoint(CGPoint(x: x, y: 0.5), forView: view)
            
            applyShadowForView(view, index: index)
        }
    }
    
    private func applyShadowForView(view: UIView, index: Int) {
        
        let w = self.frame.size.width
        let h = self.frame.size.height
        
        let r1 = frameFor(origin: contentOffset, size: self.frame.size)
        let r2 = frameFor(origin: CGPoint(x: CGFloat(index)*w, y: 0),
                          size: CGSize(width: w, height: h))
        
        // Only show shadow on right-hand side
        if r1.origin.x <= r2.origin.x {
            
            let intersection = CGRectIntersection(r1, r2)
            let intArea = intersection.size.width*intersection.size.height
            let union = CGRectUnion(r1, r2)
            let unionArea = union.size.width*union.size.height
            
            view.layer.opacity = Float(intArea / unionArea)
        }
    }
    
    private func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    private func frameFor(origin origin: CGPoint, size: CGSize) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }
}