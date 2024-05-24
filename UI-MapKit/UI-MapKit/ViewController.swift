//
//  ViewController.swift
//  UI-MapKit
//
//  Created by Sparkout on 22/05/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var searchBar: UITextField!
    
    
    let locationManager = CLLocationManager()
    var searchedLocationCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.locationManager.requestAlwaysAuthorization()

            // For use in foreground
            
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }

            mapView.delegate = self
            mapView.mapType = .standard
            mapView.isZoomEnabled = true
            mapView.isScrollEnabled = true
        
            mapView.showsUserLocation = true

            if let coor = mapView.userLocation.location?.coordinate{
                mapView.setCenter(coor, animated: true)
            }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                let locValue = location.coordinate
                mapView.setCenter(locValue, animated: true)
                locationManager.stopUpdatingLocation()
                
                latitudeLabel.text = "Latitude: \(location.coordinate.latitude)"
                longitudeLabel.text = "Longitude: \(location.coordinate.longitude)"
                
                mapView.mapType = MKMapType.standard

                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: locValue, span: span)
                mapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = locValue
                annotation.title = "Location"
                annotation.subtitle = "current location"
                mapView.addAnnotation(annotation)
            }
        }

        @IBAction func searchLocation(_ sender: UIButton) {
            guard let searchText = searchBar.text, !searchText.isEmpty else {
                return
            }
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchText) { (placemarks, error) in
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }

                guard let placemark = placemarks?.first, let location = placemark.location else {
                    print("Location not found")
                    return
                }

                self.searchedLocationCoordinate = location.coordinate
                self.drawRoute()
            }
        }

        func drawRoute() {
            guard let searchedLocationCoordinate = searchedLocationCoordinate else {
                return
            }
            
            mapView.removeOverlays(mapView.overlays)

            if let userLocation = locationManager.location {
                let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate)
                let destinationPlacemark = MKPlacemark(coordinate: searchedLocationCoordinate)

                let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

                let directionsRequest = MKDirections.Request()
                directionsRequest.source = sourceMapItem
                directionsRequest.destination = destinationMapItem
                directionsRequest.transportType = .automobile

                let directions = MKDirections(request: directionsRequest)
                directions.calculate { (response, error) in
                    guard let response = response else {
                        if let error = error {
                            print("Error calculating directions: \(error.localizedDescription)")
                        }
                        return
                    }

                    let route = response.routes[0]
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)

                    let rect = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                }
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        print(mode.rawValue)
        print(mapView.centerCoordinate)
    }
    @IBAction func liveMap(_ sender: UIButton) {
            performSegue(withIdentifier: "MapSegue", sender: self)
        }
    }

