//
//  LocationService.swift
//  Qibla Finder
//
//  Created by sardar saqib on 04/03/2025.
//

import Foundation
import CoreLocation
import Combine
import OSLog

@available(iOS 15, watchOS 9, macOS 14, *)
public final class LocationService: NSObject {
    @Published public var locationAuthorizationStatus: CLAuthorizationStatus?
    @Published public var currentLocation: CLLocation?

    @Published public var headingDegrees: Double = .zero
    @Published public var qiblaAngle: CLLocationDegrees = .zero
    @Published public var cityName: String = ""

    private var locationManager: CLLocationManager
    private var lastLocation: CLLocation?
    // we can set any targeted coordinate in this case i'm setting Mecca's coordinates
    private let meccaCoordinate = CLLocationCoordinate2D(latitude: 21.422504, longitude: 39.826195)
    var isHeadingToTarget: Bool {
        
        let errorMargin: CLLocationDegrees = 5.0
       
        let lowerBound = qiblaAngle - errorMargin
        let upperBound = qiblaAngle + errorMargin
        
        return headingDegrees >= lowerBound && headingDegrees <= upperBound
    }

    // MARK: -
    public override init() {
        locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
        locationManager.distanceFilter = 500
      
    }

    // MARK: -
    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        
        guard CLLocationManager.headingAvailable() else { return }
        locationManager.startUpdatingHeading()
    }

    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: -

    private func calculateQiblaDirection(from location: CLLocation?) {
       
        guard let currentLocation = locationManager.location else { return }
        
        let lat1 = degreesToRadians(currentLocation.coordinate.latitude)
        let lon1 = degreesToRadians(currentLocation.coordinate.longitude)
        let lat2 = degreesToRadians(meccaCoordinate.latitude)
        let lon2 = degreesToRadians(meccaCoordinate.longitude)

        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
       
        var radiansBearing = atan2(y, x)
        radiansBearing += radiansBearing < 0.0 ? 2 * .pi : 0

        qiblaAngle = round(radiansBearing * 180 / .pi)
    }
}

@available(iOS 15, watchOS 9, macOS 14, *)
extension LocationService: CLLocationManagerDelegate, ObservableObject {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationAuthorizationStatus = status
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        default:
            print("Location auth Status: \(status)")
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        currentLocation = newLocation
        calculateQiblaDirection(from: newLocation)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       print("FAILURE :", "\(error)")
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingDegrees = newHeading.trueHeading
    }
    private func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    private func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
}

public extension CLLocationDegrees {
    var radian: Double { self * .pi / 180 }
}
