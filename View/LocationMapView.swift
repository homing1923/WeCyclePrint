//
//  LocationMapView.swift
//  WeCyclePrint
//
//  Created by Homing Lau on 2023-03-29.
//

import SwiftUI
import MapKit

struct LocationMapView: View {
    @EnvironmentObject var locationManager : LocationManager
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State var mapCenter : CLLocationCoordinate2D? = nil
    @State var locSelection : String = ""
    
    var body: some View {
        VStack{
            Picker("Locations",selection: $locSelection, content: {
                ForEach(self.locationManager.recyclePointStringList, id: \.self){str in
                    Text(str)
                }
            })
            Spacer()
            MyMap(l_location: mapCenter ?? locationManager.lastKnownLocation.coordinate,
                  l_selectedLocation: $selectedLocation,
                  l_region: $region)
            
            .onAppear{
                self.locationManager.initializePointList {
                    self.selectedLocation = self.locationManager.recyclePointCenter
                }
            }
            .frame(height: 500)
            Spacer()
            Button(action: {
                self.selectedLocation = self.locationManager.currentLocation?.coordinate
            }){
                Text("Use My Location")
            }
            Spacer()
            Button(action: {
                    let locDul = self.locationManager.choiceClosestLocation()
                    if let locStr = locDul.0{
//                        self.selectedLocation = locDul.0
                        self.locSelection = locDul.1!
                    }

            }){
                Text("Find the closest one")
            }
            Spacer()
//            Button(action: {
//                if let currentLoc = self.locationManager.currentLocation{
//                    if let dest = self.selectedLocation{
//                        self.locationManager.sl(startCoor: currentLoc.coordinate, destCoor: dest, completion: {line, err in
//                            if let line = line{
//                                self.locationManager.pLine = line
//                            }
//                        })
//                    }
//                }
//            }){
//                Text("Guide Me to it")
//            }
            
        }
        .onChange(of: self.locationManager.currentLocation, perform: {newLoc in
            self.selectedLocation = newLoc?.coordinate
            print(#function, "updating camera Center to \(self.selectedLocation)")
        })
        .onChange(of: locSelection, perform: {str in
            if(!self.locationManager.recyclePointCLLocationList.isEmpty){
                
                self.selectedLocation = self.locationManager.recyclePointCLLocationList[str]?.coordinate
                print(#function, "updating camera Center to \(self.selectedLocation)")
            }
        })
        .onAppear{
            self.locSelection = self.locationManager.recyclePointStringList[0]
        }
    }
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView()
    }
}

struct MyMap: UIViewRepresentable{
    typealias UIViewType = MKMapView
    
    
    var selectedLocation: CLLocationCoordinate2D?
    var region: MKCoordinateRegion
    
    private var location: CLLocation
    @EnvironmentObject var locationHelper : LocationManager
    
    
    
    init(l_location: CLLocationCoordinate2D,
         l_selectedLocation: Binding<CLLocationCoordinate2D?>,
         l_region: Binding<MKCoordinateRegion>) {
        
        let centerLoc = CLLocation(latitude: l_location.latitude, longitude: l_location.longitude)
        self.location = centerLoc
        self.selectedLocation = l_selectedLocation.wrappedValue
        self.region = l_region.wrappedValue
    }
    

//    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        mapView.delegate = self
//    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
    }
    
    func makeUIView(context: Context) -> MKMapView{
//        var sourceCordinates : CLLocationCoordinate2D
        let defaultSpanLatDelta : CLLocationDegrees = 0.003
        let defaultSpanLngDelta : CLLocationDegrees = 0.003
        var SpanLatDelta : CLLocationDegrees
        var SpanLngDelta : CLLocationDegrees
        
//        sourceCordinates = self.location.coordinate
        
        if let spanDelta : (CLLocationDegrees, CLLocationDegrees)? = self.locationHelper.getMaxLatAndLngDifference(locations: Array(self.locationHelper.recyclePointCLLocationList.values)) ?? nil{
            SpanLatDelta = spanDelta!.0
            SpanLngDelta = spanDelta!.1
            SpanLatDelta += self.roundToNearestPowerOf10(defaultSpanLatDelta)
            SpanLngDelta += self.roundToNearestPowerOf10(defaultSpanLngDelta)
        }
        
        let map = MKMapView()
        
        map.mapType = MKMapType.standard
        map.setRegion(self.region, animated: true)
        map.showsUserLocation = true
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsScale = true
        map.setCamera(MKMapCamera(lookingAtCenter: self.location.coordinate, fromEyeCoordinate: self.location.coordinate, eyeAltitude: self.location.altitude), animated: true)
        
        return map
        
    }
    
    func roundToNearestPowerOf10(_ value: Double) -> Double {
        let exponent = floor(log10(value))
        let factor = pow(10, exponent)
        let roundedValue = round(value / factor) * factor
        return roundedValue
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let selectedLocation = selectedLocation{
            let Nregion = MKCoordinateRegion(center: selectedLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            uiView.setRegion(Nregion, animated: true)
        }else{
            uiView.setRegion(region, animated: true)
            
        }
        
        uiView.removeOverlays(uiView.overlays)
                
                // Add polyline overlay
//        if let directions = self.$locationHelper.polyline, let route = directions.routes.first {
//                    let polyline = route.polyline
//                    uiView.addOverlay(polyline)
//                }
        
        self.locationHelper.addMuliplePinsToMap(mapView: uiView, coordinates: Array(self.locationHelper.recyclePointCLLocationList.values))
    }
}



