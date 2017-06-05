//
//  DestinationMapViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/10/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class DestinationMapViewController: DestinationSearchableViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!

    private var orderedAnnotations: [MKAnnotation?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self

        
        //Add search bar
        let height = searchController?.searchBar.frame.height
        searchController?.searchBar.frame = CGRect(x: 0, y:0, width:(self.navigationController?.view.bounds.size.width)!, height: height!)
        self.view.addSubview((searchController?.searchBar)!)
        
        searchController?.hidesNavigationBarDuringPresentation = true
        updateMap()
    }

    //Find destinations on map and annotate
    private func updateMap(){
        orderedAnnotations = [MKAnnotation?](repeating: nil, count: destinations.count)
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
        for (index, dest) in destinations.enumerated() {
            let geo = CLGeocoder()
            geo.geocodeAddressString(dest.name!, completionHandler: { (placemarks, error) in
                if error == nil && (placemarks?.count)! > 0 {
                    let place = placemarks?.first
                    let mark = MKPlacemark(placemark: place!)
                    
                    DispatchQueue.main.async {
                        self.map.addAnnotation(mark)
                        self.orderedAnnotations[index] = mark
                        
                        if self.map.annotations.count == self.destinations.count && self.destinations.count > 1 {
                            self.connectPoints()
                            self.map.showAnnotations(self.map.annotations, animated: true)
                        }
                    }
                }
            })
        }
    }
    
    override func addDestination(city: String) {
        super.addDestination(city: city)
        updateMap()
    }
    
    //Draw lines between annotations
    
    private func connectPoints(){
        var coordinates: [CLLocationCoordinate2D] = []
        for annot in orderedAnnotations {
            coordinates.append(annot!.coordinate)
        }
        coordinates.append((orderedAnnotations.first!?.coordinate)!) //round-trip
        
        let line = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        map.add(line)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineView = MKPolylineRenderer(overlay: overlay)
        lineView.strokeColor = UIColor.red
        return lineView
    }
    
    // Set up buttons for destinations
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //http://stackoverflow.com/questions/9822756/replace-icon-pin-by-text-label-in-annotation/9823109#9823109
        let number = orderedAnnotations.index{$0 === annotation}! + 1
        
        let annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotView.tag = number
        
        let destButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        destButton.addTarget(self, action: #selector(destinationSelected(_:)), for: UIControlEvents.touchUpInside)
        destButton.setTitle(String(number), for: UIControlState.normal)
        destButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        destButton.backgroundColor = UIColor.white
        destButton.layer.borderColor = UIColor.red.cgColor
        destButton.layer.borderWidth = 2
        destButton.layer.cornerRadius = 10
        annotView.addSubview(destButton)
        annotView.frame = destButton.frame
        
        return annotView
    }
    
    func destinationSelected(_ sender: UIButton) {
        performSegue(withIdentifier: "showDestination", sender: sender)
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        searchController?.searchBar.sizeToFit()
        map.showAnnotations(map.annotations, animated: true)
    }
    
    // Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AttractionsTableViewController, let button = sender as? UIButton {
            let index = Int((button.titleLabel?.text)!)! - 1
            destination.currentDest = destinations[index]
        }
    }



}
