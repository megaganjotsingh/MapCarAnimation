//
//  MapViewHelper.swift
//  Route Draw
//
//  Created by Gaganjot Singh on 20/06/23.
//  Copyright © 2023 Gaganjot Singh. All rights reserved.
//

import GoogleMaps

class CordinatesList: NSObject {
    var path: GMSPath?
    var target: UInt = 0
    
    func nextCordinate() -> CLLocationCoordinate2D? {
        target += 1
        if target == path?.count() {
            return nil
        }
        return path?.coordinate(at: target)
    }
}

class PlaceMark {
    var placeName: String?
    var placeLatitude: String?
    var placeLongitude: String?
    var placeAddress: String?
}

struct MapViewProperties {
    var polyLineWidth: CGFloat = 4
    var polyLineColor: UIColor = .blue
    var waypointMarker: UIImage? = UIImage(named: "glow-marker")
}

class MapViewHelper {
    
    static var properties = MapViewProperties()
    
    static var wayPointsMarkers = [GMSMarker]()

    /// Creates map view
    ///
    /// - Returns: MapView instance
    class func setMapView(_ mapView: GMSMapView, withCordicate cordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: cordinate.latitude, longitude: cordinate.longitude, zoom: 16.0)
        mapView.camera = camera
    }
    
    /// Create polyline on map
    ///
    /// - Parameters:
    ///   - polyline: polyline path
    ///   - mapView: map on which marker will be shown
    ///   - placeMarksArray: place marks
    class func createPolylineOnMap(mapView: GMSMapView, placeMarksArray: [PlaceMark], polyline: GMSPolyline) {
 
        // Creates a marker in the center of the map.
        guard let startPlaceMark = placeMarksArray.first, startPlaceMark.placeLatitude != nil, startPlaceMark.placeLongitude != nil else {
            print("startPlacemark lat or long is nil")
            return
        }
        guard let endPlaceMark = placeMarksArray.last, endPlaceMark.placeLatitude != nil,  endPlaceMark.placeLongitude != nil else {
            print("endPlacemark lat or long is nil")
            return
        }
        let filteredArray = placeMarksArray.dropLast()
        let wayPointsArray = filteredArray
            .dropFirst()
        // add waypoints on map
        MapViewHelper.addWayPointsMarkerOnMap(mapView: mapView, wayPointsArray: Array(wayPointsArray))
        
        // create custom markers
        if let startLat = startPlaceMark.placeLatitude?.inDouble , let startLong = startPlaceMark.placeLongitude?.inDouble {
            let position =
                CLLocationCoordinate2D(latitude: startLat, longitude: startLong)
            MapViewHelper.createCustomMarker(title: startPlaceMark.placeName!, mapView: mapView, position: position)
        }
        
        if let endLat = endPlaceMark.placeLatitude?.inDouble, let endLong = endPlaceMark.placeLongitude?.inDouble {
            let position = CLLocationCoordinate2D(latitude: endLat, longitude: endLong)
            MapViewHelper.createCustomMarker(title: endPlaceMark.placeName ?? "", mapView: mapView, position: position)
        }
        
        // create polyline
        MapViewHelper.customizePolyline(polyLine: polyline, mapView: mapView)
    }
    
    /// Method to move marker on the path provided on map
    ///
    /// - Parameters:
    ///   - path: path on whoch marker will move
    ///   - markerImage: marker image
    ///   - markerPosition: marker's position
    ///   - mapView: map on which marker will be shown
    class func moveMarkerOnPath(_ path: GMSPath?, markerPosition: CLLocationCoordinate2D, mapView: GMSMapView, markerImage: UIImage) {
        guard path != nil else {
            return
        }
        let marker = GMSMarker()
        marker.icon = markerImage
        marker.appearAnimation = .pop
        marker.position = markerPosition
        marker.map = mapView
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.isFlat = true
        let coordsList = CordinatesList()
        coordsList.path = path
        marker.userData = coordsList
        MapViewHelper.animateMarkerToNextCordinate(marker: marker, mapView: mapView)
    }
}

private extension MapViewHelper {
    class func movement(marker: GMSMarker, oldCoordinate: CLLocationCoordinate2D, newCoordinate: CLLocationCoordinate2D, mapView: GMSMapView, bearing: Float = 0) {
       // calculate the bearing value from old and new coordinates
       let calBearing = GMSGeometryHeading(oldCoordinate, newCoordinate)
       marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
       marker.rotation = CLLocationDegrees(calBearing) // found bearing value by calculation when marker add
       marker.position = oldCoordinate // this can be old position to make car movement to new position
       
       // marker movement animation
       CATransaction.begin()
       CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
       CATransaction.setCompletionBlock {
           marker.rotation = (Int(bearing) != 0) ? CLLocationDegrees(bearing) : CLLocationDegrees(calBearing)
       }
       
       mapView.animate(toLocation: newCoordinate)
       
       marker.position = newCoordinate // this can be new position after car moved from old position to new position with animation
       marker.map = mapView
       marker.rotation = CLLocationDegrees(calBearing)
       CATransaction.commit()
    }
    
    /// create custom markers
    ///
    /// - Parameters:
    ///   - title: title of marker
    ///   - position: position of marker
    ///   - mapView: map on which marker will be shown
    class func createCustomMarker(title: String, mapView: GMSMapView, position: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.title = title
        marker.position = position
        marker.map = mapView
    }
    
    /// Customize the polyline properties
    /// - Parameters:
    ///   - polyLine: polyLine instance
    ///   - mapView: map on which marker will be shown
    class func customizePolyline(polyLine: GMSPolyline, mapView: GMSMapView) {
        polyLine.strokeWidth = properties.polyLineWidth
        polyLine.strokeColor = properties.polyLineColor
        polyLine.map = mapView
    }
    
    /// Add waypoints on the polyline
    ///
    /// - Parameters:
    ///   - mapView: map on which polyline drawn
    ///   - wayPointsArray: array of waypoints
    class func addWayPointsMarkerOnMap(mapView: GMSMapView, wayPointsArray: [PlaceMark]) {
        for placemark in wayPointsArray {
            guard placemark.placeLatitude != nil, placemark.placeLongitude != nil else {
                print("placemark waypoint lat or long is nil")
                continue
            }
            let wayPointMarker = GMSMarker()
            
            guard let lat = placemark.placeLatitude?.inDouble, let long = placemark.placeLongitude?.inDouble else { continue }

            wayPointMarker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            wayPointMarker.title = placemark.placeName
            wayPointMarker.map = mapView
            // creating a marker view
            let markerView = UIImageView(image: properties.waypointMarker)
            wayPointMarker.iconView = markerView
            wayPointsMarkers.append(wayPointMarker)
        }
    }
    
    /// Animate marker to next cordinate
    ///
    /// - Parameter marker: marker to be moved
    /// - Parameter mapView: map on which marker will be shown
    class func animateMarkerToNextCordinate(marker: GMSMarker, mapView: GMSMapView) {
        if let cordinates = marker.userData as? CordinatesList {
            guard let nextCordinate = cordinates.nextCordinate() else {
                return
            }
            let previousCordinate = marker.position
            var timer = 2.0
            if MapViewHelper.isMarkerPostionEqualToWaypointPosition(marker: marker) {
                wayPointsMarkers.removeFirst() // remove the waypoint
                timer = 5.0 // delay of 5 sec
                print("WayPoint occured in path")
            }
            
            movement(marker: marker, oldCoordinate: previousCordinate, newCoordinate: nextCordinate, mapView: mapView)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timer , execute: {
                self.animateMarkerToNextCordinate(marker: marker, mapView: mapView)
            })
        }
    }
    
    /// Check if waypoint is encountered on map while marker moves
    ///
    /// - Parameter marker: marker moving
    /// - Returns: status true or false
    class func isMarkerPostionEqualToWaypointPosition(marker: GMSMarker) -> Bool{
        let markerLatitude = String(format: "%.1f", marker.position.latitude)
        let markerLongitude = String(format: "%.1f", marker.position.longitude)
        let filteredMarkerArray = wayPointsMarkers.filter { waypoint -> Bool in
            let wayPointLatitude =  String(format: "%.1f", waypoint.position.latitude)
            let wayPointLongitude =  String(format: "%.1f", waypoint.position.longitude)
            return wayPointLatitude == markerLatitude &&  wayPointLongitude == markerLongitude
        }
        return filteredMarkerArray.count > 0
    }
}

fileprivate extension String {
    var inDouble: Double {
        Double(self) ?? 0
    }
}
