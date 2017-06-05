//
//  DestinationSearchTableViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/1/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import MapKit

protocol HandleDestinationSelection {
    func addDestination(city: String)
}

class DestinationSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var localSearchResponse:MKLocalSearchResponse!
    var searchMatches: [String] = []
    var handleDestinationSelectionDelegate: HandleDestinationSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let request = GooglePlacesRequest()
        request.getCities(for: searchController.searchBar.text!, with: { (matches) in
            self.searchMatches = matches
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMatches.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult", for: indexPath)
        cell.textLabel?.text = searchMatches[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = searchMatches[indexPath.row]
        handleDestinationSelectionDelegate?.addDestination(city: selectedCity)
        dismiss(animated: true, completion: nil)
    }

}
