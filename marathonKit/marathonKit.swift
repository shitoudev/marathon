//
//  marathonKit.swift
//  marathon
//
//  Created by zhenwen on 9/9/15.
//  Copyright © 2015 zhenwen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

public let appNormalColor = UIColor(hex: "#ee6e4a") //UIColor(hex: "#435E9F") //UIColor(hex: "#CD3200")

/**
    计算两个经纬度之间的距离米
*/
public func distanceBetweenOrderBy(lat1: Double, lat2: Double, lng1: Double, lng2: Double) -> Double {
    let location1 = CLLocation(latitude: lat1, longitude: lng1)
    let location2 = CLLocation(latitude: lat2, longitude: lng2)
    let distance = location1.distanceFromLocation(location2)
    return distance
}

public func stringDistance(meters: Double) -> String {
    return String(format: "%.2f", arguments: [meters/1000])
}

public func stringSecondCount(seconds: Int) -> String {
    var remainingSeconds = seconds
    let hours = remainingSeconds / 3600
    remainingSeconds = remainingSeconds - hours * 3600;
    let minutes = remainingSeconds / 60
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if hours > 0 {
        return String(format: "%i:%02i:%02i", arguments: [hours, minutes, remainingSeconds])
    } else if minutes > 0 {
        return String(format: "%02i:%02i", arguments: [minutes, remainingSeconds])
    } else {
        return String(format: "00:%02i", arguments: [remainingSeconds])
    }
}

public func stringAvgPace(meters: Double, seconds: Int) -> String {
    if meters == 0 || seconds == 0 {
        return "0"
    }
    
    let avgPaceSecMeters = Double(seconds) / meters
    let paceMin = Int((avgPaceSecMeters * 1000) / 60)
    let paceSec = Int((avgPaceSecMeters * 1000) - Double(paceMin * 60))
    
//    return String(format: "%i:%02i %@", arguments: [paceMin, paceSec, "min/km"])
    return String(format: "%i'%02i''", arguments: [paceMin, paceSec])
}

public func isLocationOutOfChina(location: CLLocationCoordinate2D) -> Bool {
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271) {
        return true
    }
    return false
}

public func mapRegion(locations: [CLLocation]) -> MKCoordinateRegion {
    
    let firstLocation = locations.first!
    var minLat = firstLocation.coordinate.latitude
    var minLng = firstLocation.coordinate.longitude
    var maxLat = firstLocation.coordinate.latitude
    var maxLng = firstLocation.coordinate.longitude
    
    for location in locations {
        if (location.coordinate.latitude < minLat) {
            minLat = location.coordinate.latitude
        }
        if (location.coordinate.longitude < minLng) {
            minLng = location.coordinate.longitude
        }
        if (location.coordinate.latitude > maxLat) {
            maxLat = location.coordinate.latitude
        }
        if (location.coordinate.longitude > maxLng) {
            maxLng = location.coordinate.longitude
        }
    }
    
    let latitude = (minLat + maxLat) / 2.0
    let longitude = (minLng + maxLng) / 2.0
    let latitudeDelta = (maxLat - minLat) * 2.1 // 10% padding
    let longitudeDelta = (maxLng - minLng) * 2.1 // 10% padding
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
    
    return region
}

public func getCalByMeter(meter: Double) -> Double {
    // 70体重
    return (70 * meter / 1000 * 1.036)
}