//
//  CurrentTripsTableViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/26/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class CurrentTripsTableViewController: FetchedResultsTableViewController {

    var fetchedResultsController: NSFetchedResultsController<Trip>?
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        { didSet { updateUI() } }
    
    @IBOutlet weak var tripType: UISegmentedControl!
    @IBAction func tripTypeChanged(_ sender: UISegmentedControl) {
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    //Populate cells with trips depending on state of segmented control
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Trip> = Trip.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "start",
                ascending: true,
                selector: #selector(NSDate.compare(_:)))
            ]
            if tripType.selectedSegmentIndex == 0 {
                request.predicate = NSPredicate(format: "upcoming == YES")
            } else {
                request.predicate = NSPredicate(format: "upcoming == NO")
            }
            fetchedResultsController = NSFetchedResultsController<Trip>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    

    // TableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trip", for: indexPath) as! CurrentTripTableViewCell
        if let trip = fetchedResultsController?.object(at: indexPath) {
            cell.currentTrip = trip
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let context = container?.viewContext {
                let trip = (tableView.cellForRow(at: indexPath) as! CurrentTripTableViewCell).currentTrip
                context.delete(trip!)
                try? context.save()
                updateUI()
            }
        }
    }

    
    // Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? CurrentTripTableViewCell {
            //Create new trip
            if let destination = segue.destination as? TripSettingsViewController {
                destination.navigationItem.title = cell.tripName.text
            }
            //Go to menu of old trip
            if let destination = segue.destination as? TripMenuViewController {
                destination.navigationItem.title = cell.tripName.text
                destination.currentTrip = cell.currentTrip
            }
        }
    }
    

}
