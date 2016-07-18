//
//  GoodsDetailViewController.swift
//  HCustomTransition
//
//  Created by wuqiuhao on 2016/7/4.
//  Copyright © 2016年 wuqiuhao. All rights reserved.
//

import UIKit

class GoodsDetailViewController: UIViewController {

    @IBOutlet var imgGoods: UIImageView!
    
    @IBOutlet var viewBack: UIView!
    
    @IBOutlet var contentView: UIView!
    
    var delegate: CustomTransitioningDelegate?
    
    var panGesture: UIPanGestureRecognizer!
    
    // 取消
    @IBAction func btnCancelClicked() {
        delegate?.dismissPresentViewController()
    }
    
    // 确定
    @IBAction func btnAccount(sender: UIBarButtonItem) {
        delegate?.dismissPresentViewController()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(btnCancelClicked))
        viewBack.userInteractionEnabled = true
        viewBack.addGestureRecognizer(gesture)
        imgGoods.layer.cornerRadius = 10
        imgGoods.layer.shadowOpacity = 1
        imgGoods.layer.shadowRadius = 10
        imgGoods.layer.shadowOffset = CGSize(width: 0, height: 0)
        imgGoods.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        imgGoods.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).CGColor
        contentView.layer.shadowColor = UIColor.blackColor().CGColor
        contentView.layer.shadowOpacity = 0.5
        contentView.addGestureRecognizer(panGesture)
        imgGoods.clipsToBounds = true
    }
}
