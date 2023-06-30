//
//  CustomViewObjectsHelper.swift
//  RouteDraw
//
//  Created by Gaganjot Singh on 22/10/17.
//  Copyright © 2023 Gaganjot Singh. All rights reserved.
//

import UIKit

class CustomViewObjectsHelper: NSObject {
    static var activityView: UIActivityIndicatorView?
    
    /// Show alert on View
    ///
    /// - Parameters:
    ///   - title: title of the alert
    ///   - controller: the main controller on which alert to be shown
    ///   - message: message of alert
    ///   - affirmButton: text of afirm button
    ///   - isCancelRequired: is cancel button required?
    ///   - dismissAction: completion called on dismiss
    class func showAlertWithTitle(title: String, message: String, affirmButton: String?, isCancelRequired: Bool, dismissAction:(() -> Void)?) {
        
        let validationLinkAlert = UIAlertController(title:title, message:message, preferredStyle: .alert)
        let affirmAction = UIAlertAction(title: affirmButton, style: .default) { (_) -> Void in
            if dismissAction != nil {
                dismissAction!()
            }
        }
        if isCancelRequired == true {
            let dismissAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            validationLinkAlert.addAction(dismissAction)
        }
        
        validationLinkAlert.addAction(affirmAction)
        
        if let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window {
            window.rootViewController?.present(validationLinkAlert, animated: true, completion: nil)
        }
    }
    
    /// Show activity indicator in View
    ///
    /// - Parameter view: view on which activity indicator to be shown
    class func showActivityView(OnView view: UIView) {
        
        // Reset previous activity view
        activityView?.superview?.isUserInteractionEnabled = true
        
        activityView?.removeFromSuperview()
        
        //Create Activity Indicator
        
        activityView = UIActivityIndicatorView(style: .medium)
        
        activityView?.color = UIColor.black
        // Position Activity Indicator in the center of the main view
        activityView?.center = view.center
        
        activityView?.backgroundColor = UIColor.clear
        // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
        activityView?.hidesWhenStopped = false
        
        // Start Activity Indicator
        activityView?.startAnimating()
        
        // Call stopAnimating() when need to stop activity indicator
        //myActivityIndicator.stopAnimating()
        
        view.addSubview(activityView!)
        
        view.isUserInteractionEnabled = false
    }
    
    /// Hide activity indicator on View
    ///
    /// - Parameter view: View on which activity indicator to be hidden
    class func hideActivityView(onView view: UIView) {
        
        // Call stopAnimating() when need to stop activity indicator
        //myActivityIndicator.stopAnimating()
        activityView?.stopAnimating()
        activityView?.removeFromSuperview()
        activityView = nil
        view.isUserInteractionEnabled = true
        
    }
}
