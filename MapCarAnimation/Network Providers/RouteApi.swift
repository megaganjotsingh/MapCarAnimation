//
//  RouteApi.swift
//  RouteDraw
//
//  Created by Gaganjot Singh on 21/06/23.
//  Copyright © 2023 Gaganjot Singh. All rights reserved.
//

import Foundation
import Moya

enum RouteData {
    case fetchRouteDataWithParams(params: [PlaceMark])
}

extension RouteData: TargetType {
    
    /// Provide headers if any
    public var headers: [String : String]? {
        return nil
    }
    
    /// Base url/host
    public var baseURL: URL { return URL(string: kGoogleHost)! }
    
    /// path to be appended to base url
    public var path: String {
        return "/maps/api/directions/json" //path for directions api using waypoints
    }
    
    /// type of request method get, post, put etc.
    public var method: Moya.Method {
        return .get
    }
    
    
    /// type of request
    public var task: Task {
        switch self {
        case .fetchRouteDataWithParams(var params):
            let originPlaceName = params[0].placeName
            let destinationPlaceName = params.last?.placeName
            guard params.count > 0 else {
                 return .requestParameters(parameters: ["origin": originPlaceName ?? "Noida","destination": destinationPlaceName ?? "Delhi","key": kGMapsAPIKey], encoding: URLEncoding.default)
            }
            let filteredarray = params.dropLast()
            let wayPointsArray = filteredarray.dropFirst()
            var waypoints = String()
            for item in wayPointsArray {
                waypoints.append(item.placeName!)
                waypoints.append("|")
            }
            return .requestParameters(parameters: ["origin": originPlaceName ?? "Noida","destination": destinationPlaceName ?? "Delhi","waypoints": waypoints,"key": kGMapsAPIKey], encoding: URLEncoding.default)
        }
    }
    
    // sample data received from api response
    public var sampleData: Data {
        // The response returns an html data
        return "".data(using: String.Encoding.utf8)!
    }
}

