//
//  TripMenuViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/1/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit

class TripMenuViewController: UIViewController {

    var currentTrip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let back = UIBarButtonItem(title: "Trips", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = back
    }
    
    // Navigation
    
    func back(sender: UIBarButtonItem) {
        //Always go back to trips menu
        _ = self.navigationController?.popToRootViewController(animated: false)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TripSettingsViewController {
            destination.navigationItem.rightBarButtonItem = nil //Don't need done button anymore
            destination.navigationItem.title = self.navigationItem.title
            destination.currentTrip = currentTrip
        }
        if let destination = segue.destination as? DestinationsTableViewController {
            destination.currentTrip = currentTrip
        }
        if let destination = segue.destination as? DestinationMapViewController {
            destination.currentTrip = currentTrip
            destination.navigationItem.title = self.navigationItem.title
        }
        if let Destination = segue.destination as? TravelersTableViewController {
            Destination.curTrip = currentTrip
        }
    }

}
