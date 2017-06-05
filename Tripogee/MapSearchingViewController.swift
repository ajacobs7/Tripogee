//
//  MapViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/1/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapSearchingViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    private var searchMatches: [MKMapItem] = []
    private var locationManager = CLLocationManager()
    private var searchBar: UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add search bar
        searchBar.frame.origin = CGPoint.zero
        view.addSubview(searchBar)
        
        map.delegate = self
        searchBar.delegate = self
        
        //Setup location tracking
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.showsUserLocation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.sizeToFit()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        updateSearchResults()
    }
    
    private func updateSearchResults() {
        //https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { response, _ in
            if response != nil {
                self.searchMatches = (response?.mapItems)!
                self.updateMap()
            }
        }
    }
    
    private func updateMap() {
        map.removeAnnotations(map.annotations)
        for match in searchMatches {
            let annotation = MKPointAnnotation()
            annotation.coordinate = match.placemark.coordinate
            annotation.title = match.name
            map.addAnnotation(annotation)
        }
        map.showAnnotations(map.annotations, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //keeps search pins in view if user moves
        map.showAnnotations(map.annotations, animated: true)
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        searchBar.sizeToFit()
        map.showAnnotations(map.annotations, animated: true)
    }


}
