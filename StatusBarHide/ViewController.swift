//
//  ViewController.swift
//  StatusBarHide
//
//  Created by Zheng on 6/1/21.
//

import UIKit

class ViewController: UIViewController {

    var statusBarHidden: Bool = false /// no more computed property, otherwise reading safe area would be too late
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    @IBAction func showButtonPressed(_ sender: Any) {
        statusBarHidden.toggle()
        if statusBarHidden {
            sideMenuWillAppear()
        } else {
            sideMenuWillDisappear()
        }
    }
    
    lazy var overlayViewController: UIViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "OverlayViewController")
    }()
    
    var additionalHeight: CGFloat {
        if view.window?.safeAreaInsets.top ?? 0 > 20 { /// is iPhone X or other device with notch
            return 0 /// add 0 height
        } else {
            /// the height of the status bar
            return view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
        }
    }
}

extension ViewController {
    
    /// add placeholder height to substitute status bar
    func addAdditionalHeight(_ add: Bool) {
        if add {
            if let navigationController = self.navigationController {
                /// set insets of navigation controller if you're using navigation controller
                navigationController.additionalSafeAreaInsets.top = additionalHeight
            } else {
                /// set insets of self if not using navigation controller
                self.additionalSafeAreaInsets.top = additionalHeight
            }
        } else {
            if let navigationController = self.navigationController {
                /// set insets of navigation controller if you're using navigation controller
                navigationController.additionalSafeAreaInsets.top = 0
            } else {
                /// set insets of self if not using navigation controller
                self.additionalSafeAreaInsets.top = 0
            }
        }
    }
    
    func sideMenuWillAppear() {
        
        addChild(overlayViewController)
        view.addSubview(overlayViewController.view)
        overlayViewController.view.frame = view.bounds
        overlayViewController.view.frame.origin.x = -400
        overlayViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayViewController.didMove(toParent: self)
        
        addAdditionalHeight(true) /// add placeholder height
        
        UIView.animate(withDuration: 1) {
            self.overlayViewController.view.frame.origin.x = -100
            self.setNeedsStatusBarAppearanceUpdate() /// hide status bar
        }
    }

    func sideMenuDidAppear() {}

    func sideMenuWillDisappear() {
        
        addAdditionalHeight(false) /// remove placeholder height
        
        UIView.animate(withDuration: 1) {
            self.overlayViewController.view.frame.origin.x = -400
            self.setNeedsStatusBarAppearanceUpdate() /// show status bar
        } completion: { _ in
            self.overlayViewController.willMove(toParent: nil)
            self.overlayViewController.view.removeFromSuperview()
            self.overlayViewController.removeFromParent()
        }
    }

    func sideMenuDidDisappear() {}
}
