//
//  DestinationSearchableViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/10/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

//Superclass which implements searching of cities
class DestinationSearchableViewController: UIViewController, HandleDestinationSelection {

    private var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var currentTrip: Trip? {
        didSet {
            updateDestinations()
        }
    }
    var destinations: [Destination] = []
    
    var searchController: UISearchController? = nil

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDestinations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "DestinationSearchTable") as! DestinationSearchTableViewController
        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.handleDestinationSelectionDelegate = self
        
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "City"        
        searchController?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    

    func addDestination(city: String) {
        if let context = container?.viewContext {
            let newDest = Destination.createDestination(matching: city, in: context)
            newDest.trip = currentTrip!
            newDest.order_position = Int32(destinations.count)
            try? context.save()
            updateDestinations()
        }
    }
    
    func removeDestination(dest: Destination) {
        if let context = container?.viewContext {
            context.delete(dest)
            try? context.save()
        }
        updateDestinations()
    }
        
    func updateDestinations() {
        if let dests = currentTrip?.destinations?.allObjects as? [Destination] {
            destinations = dests.sorted(by: { (dest1, dest2) -> Bool in
                return dest1.order_position < dest2.order_position
            })
        }
    }

}
