//
//  GoodsViewController.swift
//  HCustomTransition
//
//  Created by wuqiuhao on 2016/7/4.
//  Copyright © 2016年 wuqiuhao. All rights reserved.
//

import UIKit

class HNavigationController: UINavigationController {
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.topViewController
    }
}

class GoodsViewController: UIViewController {

    @IBOutlet var barAtBottom: UIToolbar!
    var animator: CustomTransitioningAnimator!
    
    @IBAction func addGoodsToShopCart(sender: UIBarButtonItem) {
        let shopCartVC = UIStoryboard(name: "Shop", bundle: nil).instantiateViewControllerWithIdentifier("GoodsDetailViewController") as! GoodsDetailViewController
        animator = CustomTransitioningAnimator(presentViewController: shopCartVC)
        shopCartVC.delegate = self
        shopCartVC.modalPresentationStyle = UIModalPresentationStyle.Custom
        shopCartVC.transitioningDelegate = animator
        shopCartVC.panGesture = UIPanGestureRecognizer(target: animator, action: #selector(animator.handleGesture(_:)))
        self.presentViewController(shopCartVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

extension GoodsViewController: CustomTransitioningDelegate {
    func dismissPresentViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
