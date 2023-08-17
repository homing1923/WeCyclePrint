//
//  locationManager.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-28.
//

import Foundation
import CoreLocation
import Contacts
import MapKit

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate{
    @Published var authorizationStatus : CLAuthorizationStatus = .notDetermined
    @Published var currentLocation : CLLocation? = nil
    @Published var lastKnownLocation : CLLocation = CLLocation(latitude: 35.702074, longitude: 139.7753144)
    
    @Published var longitude : Double = 0.0
    @Published var latitude : Double = 0.0
    @Published var ReversedLocation : String = ""
    
    
    var recyclePointStringList : [String] = ["12 st clair e, toronto, canada", "900 dufferin st., toronto, canada", "2861 Danforth ave, toronto, canada", "2525 st clair ave w, toronto, canada", "1019 sheppard ave e, toronto, canada"]
    @Published var recyclePointCLLocationList : [String:CLLocation] = [:]
    @Published var recyclePointCenter : CLLocationCoordinate2D? = nil
    @Published var cameraCenter : CLLocationCoordinate2D? = nil
    @Published var pLine : MKPolyline? = nil
    
    private let locationManager = CLLocationManager()
    
    private let geocoder = CLGeocoder()
    
//    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
    }
    
    func initializePointList(complete: @escaping ()-> Void) {
        if self.recyclePointCLLocationList.isEmpty {
            let dispatchGroup = DispatchGroup()
            print(#function, "address count: \(self.recyclePointStringList.count)")
            DispatchQueue.main.async {
                for address in self.recyclePointStringList {
                    dispatchGroup.enter()
                    print(#function, "converting address: \(address)")
                    self.doForwardGeocoding(address: address) { convertedLocation in
                        self.recyclePointCLLocationList[address] = convertedLocation
                        print(#function, "got \(convertedLocation) for \(address)")
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    // This closure will be called when all the asynchronous calls in the group have completed.
                    self.recyclePointCenter = self.calculateCenterPoint()
                    complete()
                }
            }
        } else {
            self.recyclePointCenter = self.calculateCenterPoint()
            complete()
        }
    }
//    func sl(startCoor: CLLocationCoordinate2D, destCoor: CLLocationCoordinate2D, completion: @escaping(MKPolyline?, Error?) -> Void) {
//        let req = MKDirections.Request()
//        req.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoor))
//        req.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoor))
//        let dicection = MKDirections(request: req)
//        dicection.calculate(completionHandler: {res, err in
//            if let err = err{
//                completion(nil, err)
//            }
//            if let res = res {
//                if(!res.routes.isEmpty){
//                    completion(res.routes.first!.polyline, nil)
//                }
//            }else{
//                completion(nil, nil)
//            }
//
//        })
//
//        }
    
    
    func calculateCenterPoint() -> CLLocationCoordinate2D? {
        guard !self.recyclePointCLLocationList.isEmpty else {
            return nil
        }
        
        var totalLat: CLLocationDegrees = 0
        var totalLng: CLLocationDegrees = 0
        
        for location in self.recyclePointCLLocationList.values {
            totalLat += location.coordinate.latitude
            totalLng += location.coordinate.longitude
        }
        
        let averageLat = totalLat / CLLocationDegrees(self.recyclePointCLLocationList.count)
        let averageLng = totalLng / CLLocationDegrees(self.recyclePointCLLocationList.count)
        
        return CLLocationCoordinate2D(latitude: averageLat, longitude: averageLng)
    }
    
    func choiceClosestLocation() -> (CLLocationCoordinate2D?, String?) {
        guard let currentLocation = self.currentLocation else {
            return (nil,nil)
        }
        guard !self.recyclePointCLLocationList.isEmpty else {
            return (nil,nil)
        }
        
        var closestLocation: CLLocation?
        var closestLocationString: String?
        var minDistance: CLLocationDistance = CLLocationDistanceMax
        
        for (x, location) in recyclePointCLLocationList.enumerated() {
            let distance = currentLocation.distance(from: location.value)
            if distance < minDistance {
                minDistance = distance
                closestLocation = location.value
                closestLocationString = self.recyclePointStringList[x]
            }
        }
        
        guard let closest = closestLocation else {
            return (nil,nil)
        }
        
        return (closest.coordinate, closestLocationString)
    }
    
    

    func getMaxLatAndLngDifference(locations: [CLLocation]?) -> (latDifference: CLLocationDegrees, lngDifference: CLLocationDegrees)? {
        guard let locations = locations else {
            return nil
        }
        if(locations.isEmpty){
            return nil
        }
        
        var minLat: CLLocationDegrees = locations[0].coordinate.latitude
        var maxLat: CLLocationDegrees = locations[0].coordinate.latitude
        var minLng: CLLocationDegrees = locations[0].coordinate.longitude
        var maxLng: CLLocationDegrees = locations[0].coordinate.longitude
        
        for location in locations {
            if location.coordinate.latitude < minLat {
                minLat = location.coordinate.latitude
            }
            if location.coordinate.latitude > maxLat {
                maxLat = location.coordinate.latitude
            }
            if location.coordinate.longitude < minLng {
                minLng = location.coordinate.longitude
            }
            if location.coordinate.longitude > maxLng {
                maxLng = location.coordinate.longitude
            }
        }
        
        let latDifference = maxLat - minLat
        let lngDifference = maxLng - minLng
        
        return (latDifference, lngDifference)
    }

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.locationManager.requestAlwaysAuthorization()
        case .denied:
            self.locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            self.locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        @unknown default:
            print(#function, "Unknown Error when getting location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locations.last != nil){
            self.currentLocation = locations.last
            self.lastKnownLocation = locations.last!
        }else{
            self.currentLocation = locations.first
            self.currentLocation = locations.first
        }
        self.longitude = self.currentLocation?.coordinate.longitude ?? 35.702074
        self.latitude = self.currentLocation?.coordinate.latitude ?? 139.7753144
        print(#function, "Last known location : \(lastKnownLocation)")
        print(#function, "Most recent location : \(currentLocation)")
    }
    
    func doReverseGeocoding(location : CLLocation, completionHandler: @escaping(String?, NSError?) -> Void){
        let loc_geocoder = CLGeocoder()
        loc_geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if (error != nil){
                print(#function, "Unable to perform reverse geocoding : \(error?.localizedDescription)")
                
                //completionHandler of doReverseGeocoding()
                completionHandler(nil, error as NSError?)
            }else{
                if let placemarkList = placemarks, let placemark = placemarkList.first {
                    
                    print(#function, "Locality : \(placemark.locality ?? "NA")")
                    print(#function, "country : \(placemark.country ?? "NA")")
                    print(#function, "country code : \(placemark.isoCountryCode ?? "NA")")
                    print(#function, "sub-Locality : \(placemark.subLocality ?? "NA")")
                    print(#function, "Street-level address : \(placemark.thoroughfare ?? "NA")")
                    print(#function, "province : \(placemark.administrativeArea ?? "NA")")
    
                    let postalAddress : String = CNPostalAddressFormatter.string(from: placemark.postalAddress!, style: .mailingAddress)
                    print(#function, "Postal Address : \(postalAddress)")
//                    self.ReversedLocation = postalAddress
                    completionHandler(postalAddress, nil)
                   
                }else{
                    print(#function, "Unable to obtain placemark for reverse geocoding")
                }
            }
        })
    }
    
    func doForwardGeocoding(address : String, completion :  @escaping (CLLocation) -> Void){
        let loc_geocoder = CLGeocoder()
        loc_geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
//            CLPlacemark
            
            if (error != nil){
                print(#function, "Unable to perform forward geocoding : \(error?.localizedDescription)")
            }else{
                
                if let placemark = placemarks?.first {
                    
                    let obtainedLocation = placemark.location!
                    print(#function, "Obtained location after forward geocoding : \(obtainedLocation)")
                    completion(obtainedLocation)
                    
                }else{
                    print(#function, "Unable to obtain placemark for forward geocoding")
                }
            }
            loc_geocoder.cancelGeocode()
        })
        
    }
    
    func addMuliplePinsToMap(mapView: MKMapView, coordinates : [CLLocation]){
        for each in coordinates{
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = each.coordinate
            mapAnnotation.title = "Recycle Point"
            mapView.addAnnotation(mapAnnotation)
        }
        
    }
    
    func addPinToMap(mapView: MKMapView, coordinates : CLLocationCoordinate2D){
        
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = coordinates
        mapAnnotation.title = "You Parked Here"
        mapView.addAnnotation(mapAnnotation)
    }
}
