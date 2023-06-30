//
//  NetworkPluginHelper.swift
//  RouteDraw
//
//  Created by Gaganjot Singh on 22/10/17.
//  Copyright © 2023 Gaganjot Singh. All rights reserved.
//

import UIKit
//import Result
import Moya

protocol NetworkResponseDelegate: NSObjectProtocol {
    func networkResult(_ response: Result<Moya.Response, MoyaError>, target: TargetType)
    func networkRetryRequest(target: TargetType)
}

/// Notify a request's network activity changes (request begins or ends).
public final class NetworkPluginHelper: PluginType {
    
    weak var delegate: NetworkResponseDelegate?
    
    var showActivityIndicator = true
    
    private var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController!
    }
    // MARK: Plugin
    /// Called by the provider as soon as the request is about to start
    public func willSend(_ request: RequestType, target: TargetType) {
        guard showActivityIndicator == true else {
            return
        }
//        CustomViewObjectsHelper.showActivityView(OnView: (self.viewController?.view)!)
    }
    
    /// Called by the provider as soon as a response arrives, even if the request is canceled.
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if showActivityIndicator == true {
            CustomViewObjectsHelper.hideActivityView(onView: (self.viewController?.view)!)
        }
        var errorOccured = false
        var errorMessage = "Something went wrong"
        //only continue if result is a failure
        switch result {
        case .success(let response):
            if response.statusCode == SUCCESS_CODE {
                self.delegate?.networkResult(result, target: target)
            } else {
                errorOccured = true
            }
        case .failure:
            errorOccured = true
            switch result {
            case .success: break
            case let .failure(error):
                errorMessage = error.localizedDescription
            }
//            errorMessage = (result.error?.localizedDescription)!
            
        }
        guard errorOccured == true else { return }
        CustomViewObjectsHelper.showAlertWithTitle(title: "Error", message: errorMessage, affirmButton: "Retry", isCancelRequired: true) {
            self.delegate?.networkRetryRequest(target: target)
        }
    }
    
}

