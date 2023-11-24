//
//  UberMapViewRepresentable.swift
//  Uber
//
//  Created by Nilay on 12/11/23.
//

import SwiftUI
import MapKit

struct UberMapViewRepresentable: UIViewRepresentable {
    
    let mapView = MKMapView()
    let locationManager = LocationManager()
    @Binding var mapState: MapViewState
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        return mapView
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        switch mapState {
        case .noInput:
            context.coordinator.clearMapViewAndreCenterOnUserLocation()
            break
        case .locationSelected:
            if let coordinate = locationViewModel.selectedLocationCoordinate {
                //            print("Selected coordinate in mapview \(coordinate)")
                context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate)
                context.coordinator.configurePolyline(withDestinationCoordinate: coordinate)
            }
            break
        case .searchingForLocation:
            break
        }
        
        //        if mapState == .locationSelected {
        //            context.coordinator.clearMapViewAndreCenterOnUserLocation()
        //        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}


extension UberMapViewRepresentable {
    
    class MapCoordinator: NSObject, MKMapViewDelegate {
        
        // MARK: - Properties
        
        let parent: UberMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        
        // MARK: - LifeCycles
        
        init(parent: UberMapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        // MARK: - MKMapViewDelegte
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            self.userLocationCoordinate = userLocation.coordinate
            
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            
            self.currentRegion = region
            parent.mapView.setRegion(region, animated: true)
        }
        
        // MARK: - Helpers
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            let polyLine = MKPolylineRenderer(overlay: overlay)
            polyLine.strokeColor = .systemBlue
            polyLine.lineWidth = 6
            return polyLine
        }
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            
            let anno = MKPointAnnotation()
            anno.coordinate = coordinate
            parent.mapView.addAnnotation(anno)
            parent.mapView.selectAnnotation(anno, animated: true)
            
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            
            guard let userLocationCoordinate = self.userLocationCoordinate else { return }
            
            self.parent.mapView.removeOverlays(self.parent.mapView.overlays)
            
            getDestinationRoute(from: userLocationCoordinate, to: coordinate) { route in
                
                self.parent.mapView.addOverlay(route.polyline)
                let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect,
                                                               edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32)
                )
                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
            
        }
        
        func getDestinationRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> Void) {
            
            let userPlaceMark = MKPlacemark(coordinate: userLocation)
            let request = MKDirections.Request()
            let destinationPlacemark = MKPlacemark(coordinate: destination)
            request.source = MKMapItem(placemark: userPlaceMark)
            request.destination = MKMapItem(placemark: destinationPlacemark)
            
            let directions = MKDirections(request: request)
            
            directions.calculate { response, error in
                if let error = error {
                    print("Fail to get directions \(error.localizedDescription)")
                    return
                }
                
                guard let route = response?.routes.first else { return }
                
                completion(route)
            }
        }
        
        func clearMapViewAndreCenterOnUserLocation() {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
            
            if let currentRegion = currentRegion {
                parent.mapView.setRegion(currentRegion, animated: true)
            }
        }
    }
}
