//
//  TravelersTableViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/11/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import CoreData


//https://www.shinobicontrols.com/blog/ios9-day-by-day-day7-contacts-framework
class TravelersTableViewController: UITableViewController, CNContactPickerDelegate {
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var curTrip: Trip?
    
    private let store = CNContactStore()
    private var contacts: [CNContact] = []
    private let picker = CNContactPickerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        //Get access to contacts
        store.requestAccess(for: .contacts) { (granted, error) in
            if granted && error == nil {
                self.addButton.isEnabled = true
                self.updateUI()
            }
        }
    }
    
    //Load travelers
    private func updateUI() {
        contacts = []
        let travelers = curTrip?.travelers?.allObjects as! [Traveler]
        for traveler in travelers {
            let predicate = CNContact.predicateForContacts(matchingName: traveler.name!)
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey]
            let newContacts = try? store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
            contacts += newContacts!
        }
        tableView.reloadData()
    }
    
    //Pick contact
    
    @IBAction func addContact(_ sender: UIBarButtonItem) {
        present(picker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let context = container?.viewContext {
            _ = try? Traveler.findOrCreateTraveler(matching: contactToName(contact), with: curTrip!, in: context)
            try? context.save()
        }
        picker.dismiss(animated: true, completion: nil)
        updateUI()
    }

    // Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact", for: indexPath)
        let contact = contacts[indexPath.row]
        cell.textLabel!.text = contactToName(contact)
        return cell
    }
    
    private func contactToName(_ contact: CNContact) -> String {
        return "\(contact.givenName) \(contact.familyName)"
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let context = container?.viewContext {
                let cell = tableView.cellForRow(at: indexPath)
                let traveler = try? Traveler.findOrCreateTraveler(matching: (cell?.textLabel?.text)!, with: curTrip!, in: context)
                if traveler != nil {
                    context.delete(traveler!)
                }
                try? context.save()
            }
            updateUI()
        }
    }

}
