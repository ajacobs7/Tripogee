//
//  AttractionsTableViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/27/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class AttractionsTableViewController: FetchedResultsTableViewController {
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<Attraction>?
    
    var currentDest: Destination?
    
    private var selectedAttractions: [Attraction] = []
    @IBOutlet weak var attractionType: UISegmentedControl!
    @IBOutlet weak var planButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planButton.isEnabled = false
        
        let request = GooglePlacesRequest()
        request.getPOI(for: (currentDest?.name)!, with: { (matches) in
            if let context = self.container?.viewContext {
                for elem in matches {
                    _ = try? Attraction.findOrCreateAttraction(matching: elem, for: self.currentDest!, in: context)
                }
            }
        })
        updateUI()
    }
    
    //Reload when switching between planned and browse
    @IBAction func attractionTypeChanged(_ sender: UISegmentedControl) {
        updateUI()
        planButton.isEnabled = sender.selectedSegmentIndex == 1
    }
    
    //Save attraction as planned
    @IBAction func planAttractions(_ sender: UIBarButtonItem) {
        if let context = container?.viewContext {
            for attr in selectedAttractions {
                attr.planned = true
            }
            try? context.save()
        }
        updateUI()
    }
    
    //Load attractions for destination in order of rating
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Attraction> = Attraction.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "rating",
                ascending: false
                )]
            let pred = "destination == %@ AND planned == "
            if attractionType.selectedSegmentIndex == 0 {
                request.predicate = NSPredicate(format: pred + "YES", currentDest!)
            } else {
                request.predicate = NSPredicate(format: pred + "NO", currentDest!)
            }
            fetchedResultsController = NSFetchedResultsController<Attraction>(
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

    
    // Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attraction", for: indexPath) as! AttractionTableViewCell
        cell.isUserInteractionEnabled = planButton.isEnabled
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if let attr = fetchedResultsController?.object(at: indexPath) {
            cell.curAttraction = attr
            cell.planned.isHidden = !(attractionType.selectedSegmentIndex == 1 && selectedAttractions.contains(attr))
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if attractionType.selectedSegmentIndex == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! AttractionTableViewCell
            if selectedAttractions.contains(cell.curAttraction!) {
                cell.planned.isHidden = true
                cell.shakeRating()
                let index = selectedAttractions.index(of: cell.curAttraction!)
                selectedAttractions.remove(at: index!)
            } else {
                cell.planned.isHidden = false
                cell.growRating()
                selectedAttractions.append(cell.curAttraction!)
            }
            cell.setNeedsDisplay()
        }
    }
    

}
