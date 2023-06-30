//
//  RouteViewModel.swift
//  RouteDraw
//
//  Created by Gaganjot Singh on 21/06/23.
//  Copyright © 2023 Gaganjot Singh. All rights reserved.
//

import ObjectMapper
import GoogleMaps

class RouteViewModel: NSObject, Mappable {
    fileprivate var points: String?
    
    // MARK: JSON
    required init?(map: Map) { }
    
    /// Map the respnse data in objects
    ///
    /// - Parameter map: map which has the data
    func mapping(map: Map) {
        points <- map["routes.0.overview_polyline.points"]
    }
}

extension RouteViewModel {

    private func getGMSPathFromPoints() -> GMSPath? {
        guard points != nil, let path = GMSPath.init(fromEncodedPath: points!) else {
            print("Unable to create GMS path")
            return nil
        }
        return path
    }
    
    func getPolyLineForMap() -> GMSPolyline? {
        let polyline = GMSPolyline.init(path: getGMSPathFromPoints())
        return polyline
    }
    
}
