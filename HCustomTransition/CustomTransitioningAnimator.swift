//
//  CustomTransitioningAnimator.swift
//  HCustomTransition
//
//  Created by wuqiuhao on 2016/6/30.
//  Copyright © 2016年 wuqiuhao. All rights reserved.
//

import UIKit

class CustomTransitioningAnimator: UIPercentDrivenInteractiveTransition {
    
    var isDismiss: Bool!
    weak var presentViewController: UIViewController!
    var transitionContext: UIViewControllerContextTransitioning!
    // 是否处于交互视图切换过程
    var interacting = false
    // 是否手势完成
    var shouleComplete = true
    
    init(presentViewController: UIViewController) {
        super.init()
        self.presentViewController = presentViewController
    }
}

// MARK: - 手势操作
extension CustomTransitioningAnimator {
    /**
     处理手势操作
     
     - parameter gestureRecognizer:
     */
    func handleGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translationInView(gestureRecognizer.view)
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.Began:
            interacting = true
            if presentViewController is GoodsDetailViewController {
                (presentViewController as! GoodsDetailViewController).delegate?.dismissPresentViewController()
            }
        case .Changed:
            var fraction = translation.y / 200.0
            fraction = fmin(fmax(fraction, 0.0), 1.0)
            shouleComplete = fraction > 0.5
            self.updateInteractiveTransition(fraction)
        case .Ended, .Cancelled:
            interacting = false
            if !shouleComplete || gestureRecognizer.state == .Cancelled || gestureRecognizer.velocityInView(gestureRecognizer.view).y < 0 {
                self.cancelInteractiveTransition()
            } else {
                self.finishInteractiveTransition()
            }
        default:
            break
        }
    }
    
    /**
     开始手势拖拽
     
     - parameter transitionContext:
     */
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        self.transitionContext = transitionContext
        UIView.animateWithDuration(transitionDuration(transitionContext)) {
            var transform = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, 0, 15, 0)
            transform.m24 = -1/5000
            transform = CATransform3DScale(transform, 0.85, 1 , 1)
            toViewController.view.layer.transform = transform
        }
    }
    
    /**
     手势拖动过程中不断更新
     
     - parameter percentComplete: 更新百分比0~1
     */
    override func updateInteractiveTransition(percentComplete: CGFloat) {
        guard let _ = transitionContext else {
            return
        }
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var transform = CATransform3DIdentity
        transform.m24 = -1/3500 + 1/3500 * percentComplete
        transform = CATransform3DScale(transform, 0.85 + 0.15 * percentComplete, 0.9 + 0.1 * percentComplete , 1)
        toViewController.view.layer.transform = transform
        toViewController.view.alpha = 0.5 + 0.5 * percentComplete
    }
    
    /**
     完成手势dismiss
     */
    override func finishInteractiveTransition() {
        let finalFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        UIView.animateWithDuration(2 * transitionDuration(transitionContext), animations: {
            fromViewController.view.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
            toViewController.view.layer.transform = CATransform3DIdentity
            toViewController.view.alpha = 1
            toViewController.view.frame = finalFrame
        }) { (finished) in
            if finished {
                self.transitionContext.completeTransition(true)
                self.transitionContext = nil
            }
        }
    }
    
    /**
     手势取消操作
     */
    override func cancelInteractiveTransition() {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            fromViewController.view.userInteractionEnabled = false
            fromViewController.view.frame = CGRect(x: 0, y: 0, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height)
        }) { (finished) -> Void in
            if finished {
                UIView.animateWithDuration(self.transitionDuration(self.transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    var transform = CATransform3DIdentity
                    transform = CATransform3DTranslate(transform, 0, -15, 0)
                    transform = CATransform3DScale(transform, 0.8,0.9, 1)
                    toViewController.view.layer.transform = transform
                    toViewController.view.alpha = 0.5
                }) { (finished) in
                    if finished {
                        fromViewController.view.userInteractionEnabled = true
                        self.transitionContext.completeTransition(false)
                    }
                }
            }
            
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
/**
 1. 这四个方法用于设定present或dismiss的动画的代理对象，设置成self则由本类的方法实现，设置成nil则不处理。
 2. 如果是手势驱动的情况下，需要代理对象实现UIViewControllerInteractiveTransitioning协议，幸运的是系统为我们提供了UIPercentDrivenInteractiveTransition类，此类本生就实现了UIViewControllerInteractiveTransitioning协议，支持百分比变换，并在此基础上扩展updateInteractiveTransition、finishInteractiveTransition、cancelInteractiveTransition等方法，大大简化了手势驱动。
 3. 如果是非手势驱动我们的类需要实现UIViewControllerAnimatedTransitioning协议
 */
extension CustomTransitioningAnimator: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isDismiss = false
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isDismiss = true
        return self
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        isDismiss = true
        return self.interacting ? self : nil
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        isDismiss = false
        return nil
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
// 非手势情况
extension CustomTransitioningAnimator: UIViewControllerAnimatedTransitioning {
    
    /**
     动画持续时间
     
     - parameter transitionContext:
     
     - returns:
     */
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    /**
     动画执行效果
     
     - parameter transitionContext:
     */
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        /**
         *  如果是手势驱动的直接返回
         */
        guard !interacting else {
            return
        }
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        /**
         *  判断是否是dismiss的动画还是present的动画
         */
        if isDismiss! {
            let finalFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                fromViewController.view.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
                var transform = CATransform3DIdentity
                transform.m24 = -1/5000
                transform = CATransform3DScale(transform, 0.95, 0.95, 1)
                toViewController.view.layer.transform = transform
                toViewController.view.alpha = 1
            }) { (finished) in
                if finished {
                    UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        toViewController.view.layer.transform = CATransform3DIdentity
                        toViewController.view.frame = finalFrame
                    }) { (finished) in
                       transitionContext.completeTransition(true)
                    }
                }
            }
        } else {
            transitionContext.containerView()?.addSubview(toViewController.view)
            let finalFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
            toViewController.view.frame = CGRectOffset(finalFrame, 0, UIScreen.mainScreen().bounds.height)
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                var transform = CATransform3DIdentity
                transform.m24 = -1/2000
                fromViewController.view.alpha = 0.5
                fromViewController.view.layer.transform = transform
                toViewController.view.frame = finalFrame
            }) { (finished) in
                if finished {
                    UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        var transform = CATransform3DIdentity
                        transform = CATransform3DTranslate(transform, 0, -15, 0)
                        transform = CATransform3DScale(transform, 0.8,0.9, 1)
                        fromViewController.view.layer.transform = transform
                    }) { (finished) in
                        if finished {
                            transitionContext.completeTransition(true)
                        }
                    }
                }
            }
        }
    }
}
