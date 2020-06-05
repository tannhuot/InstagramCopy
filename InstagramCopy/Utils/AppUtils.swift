//
//  AppUtils.swift
//  InstagramCopy
//
//  Created by Huot on 11/27/19.
//

import Foundation
import UIKit

let PROGRESS_INDICATOR_VIEW_TAG:Int = 10
var activityIndicator :UIActivityIndicatorView?
/* Show Loading */
func showLoading(_ view: UIView){
    activityIndicator = UIActivityIndicatorView(style: .gray)
    view.addSubview(activityIndicator!)
    activityIndicator?.frame = view.bounds
    activityIndicator?.startAnimating()
    
}
/* Hide Loading */
func hideLoading(_ view: UIView){
    for v in view.subviews {
        if v is UIActivityIndicatorView {
            v.removeFromSuperview()
        }
    }
}

/* Show Progress Indicator */
func showProgressIndicator(view:UIView, title: String){
    view.isUserInteractionEnabled = false
    let progressIndicator = ProgressIndicator(text: title)
    progressIndicator.tag = PROGRESS_INDICATOR_VIEW_TAG
    progressIndicator.backgroundColor = UIColor.gray
    view.addSubview(progressIndicator)
}

/* Hide progress Indicator */
func hideProgressIndicator(view:UIView){
    view.isUserInteractionEnabled = true
    if let viewWithTag = view.viewWithTag(PROGRESS_INDICATOR_VIEW_TAG) {
        viewWithTag.removeFromSuperview()
    }
}

// use for present any VC on the top view
func parentAlertVC() -> UIViewController {
    let alertWindow = UIWindow(frame: UIScreen.main.bounds)
    alertWindow.rootViewController = UIViewController()
    alertWindow.windowLevel = UIWindow.Level.alert + 1
    alertWindow.makeKeyAndVisible()
    return alertWindow.rootViewController!
}

func dialogTwoButton(_ title: String = "",_ message: String, _ viewParent: UIViewController,okHandler: @escaping ((_: UIAlertAction) -> Void),cancelHandler: @escaping ((_: UIAlertAction) -> Void)){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: okHandler))
    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: cancelHandler))
    viewParent.present(alert, animated: true, completion: nil)
}
func dialogOneButton(_ title: String = "",_ message: String, _ viewParent: UIViewController,okHandler: @escaping ((_: UIAlertAction) -> Void)){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
    viewParent.present(alert, animated: true, completion: nil)
}
func fullScreen(viewController: UIViewController){
    if #available(iOS 13.0, *) {
        viewController.modalPresentationStyle = .fullScreen
    } else {
        // Fallback on earlier versions
    }
}
