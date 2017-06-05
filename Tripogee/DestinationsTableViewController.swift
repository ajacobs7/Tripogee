//
//  DestinationsTableViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/28/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class DestinationsTableViewController: DestinationSearchableViewController, UITableViewDataSource, UITableViewDelegate {

    private var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sizeToFit()
        self.view = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = searchController?.searchBar
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    @IBAction func viewOptions(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Options", message:
            "", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "View Map", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            self.performSegue(withIdentifier: "viewMap", sender: alert)
        }))
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.destructive ,handler: { (_) in
            self.navigationItem.rightBarButtonItem = self.editButtonItem
            self.tableView.setEditing(true, animated: false)
            self.isEditing = true
            self.navigationItem.rightBarButtonItem?.action = #selector(self.endEdit(_:))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func endEdit(_ sender: UIBarButtonItem){
        tableView.setEditing(false, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: UIBarButtonItemStyle.plain, target: self, action: #selector(viewOptions(_:)))
    }
    
    override func addDestination(city: String) {
        super.addDestination(city: city)
        tableView.reloadData()
    }

    // Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "destination", for: indexPath)
        cell.textLabel?.text = destinations[indexPath.row].name
        return cell
    }
    
    // Table view editing
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            removeDestination(dest: destinations[indexPath.row])
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let curDest = destinations[fromIndexPath.row]
        if let context = container?.viewContext {
            //Shift following destiations up one in the order
            for index in 0...destinations.count {
                if index < fromIndexPath.row && index >= to.row {
                    let dest = destinations[index]
                    dest.order_position += 1
                }
            }
            curDest.order_position = Int32(to.row)
            try? context.save()
        }
        destinations.remove(at: fromIndexPath.row)
        destinations.insert(curDest, at: to.row)
        tableView.reloadData()
    }
    
    private func rearrangeOrder(){

    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AttractionsTableViewController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                destination.currentDest = destinations[indexPath.row]
            }
        }
        if let destination = segue.destination as? DestinationMapViewController {
            destination.currentTrip = currentTrip
        }
    }
    

}
