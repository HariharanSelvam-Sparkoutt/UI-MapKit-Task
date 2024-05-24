//
//  MapViewController.swift
//  UI-MapKit
//
//  Created by Sparkout on 24/05/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                mapView.delegate = self
                mapView.mapType = .standard
                mapView.isZoomEnabled = true
                mapView.isScrollEnabled = true
                
                // Show user's location on the map
                mapView.showsUserLocation = true
        
        if let userLocation = mapView.userLocation.location {
                    let initialRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    mapView.setRegion(initialRegion, animated: false)
                    updateCenterMarkerLabel()
                }
            }
            
            func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
                updateCenterMarkerLabel()
            }
            
            func updateCenterMarkerLabel() {
                let centerCoordinate = mapView.centerCoordinate
                latitudeLabel.text = "Center Latitude: \(centerCoordinate.latitude)"
                longitudeLabel.text = "Center Longitude: \(centerCoordinate.longitude)"
                
                if let existingAnnotation = mapView.annotations.first {
                            mapView.removeAnnotation(existingAnnotation)
                        }
                        
                        // Add new annotation at the center coordinate
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = centerCoordinate
                        mapView.addAnnotation(annotation)
                    }
            }
    
    

    


