//
//  MSUserLocationHelper.swift
//  RandomLunch
//
//  Created by Sebastien Villar on 01/07/15.
//  Copyright (c) 2015 -. All rights reserved.
//

import Foundation
import CoreLocation

class MSUserLocationHelper: NSObject, CLLocationManagerDelegate {
  static let sharedInstance = MSUserLocationHelper()
  
  lazy var locationManager: CLLocationManager = {
    var manager = CLLocationManager()
    manager.delegate = self
    return manager
  }()
  
  var authorizationCallback: ((success: Bool) -> Void)?
  var currentLocationCallback: ((location: CLLocation?, error: NSError?) -> Void)?
  
  /////////////////////////////////////////////
  // Public
  /////////////////////////////////////////////
  
  func askForAuthorization(#callback: ((success: Bool) -> Void)?) {
    var status = CLLocationManager.authorizationStatus()
    
    switch status {
    case .NotDetermined:
      self.authorizationCallback = callback
      self.locationManager.requestWhenInUseAuthorization()
      
    case .AuthorizedWhenInUse, .AuthorizedAlways:
      callback?(success: CLLocationManager.locationServicesEnabled())
    default:
      callback?(success: false)
    }
  }
  
  func currentLocation(#callback: (location: CLLocation?, error: NSError?) -> Void) {
    self.currentLocationCallback = callback
    self.locationManager.startUpdatingLocation()
  }
  
  /////////////////////////////////////////////
  // Private
  /////////////////////////////////////////////
  
  private override init() {
    super.init()
  }
  
  /////////////////////////////////////////////
  // CLLocationManagerDelegate
  /////////////////////////////////////////////
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    switch status {
    case .AuthorizedWhenInUse, .AuthorizedAlways:
      self.authorizationCallback?(success: CLLocationManager.locationServicesEnabled())
    default:
      self.authorizationCallback?(success: false)
    }
    
    self.authorizationCallback = nil
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    self.locationManager.stopUpdatingLocation()
    var location = locations.first as? CLLocation
    self.currentLocationCallback?(location: location, error: nil)
    self.currentLocationCallback = nil
  }
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    self.currentLocationCallback?(location: nil, error: error)
    self.currentLocationCallback = nil
  }
  
}