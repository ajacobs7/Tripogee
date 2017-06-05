//
//  TripTableViewController.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/26/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData
import EventKit

//http://manenko.com/2014/12/16/how-to-create-an-input-form-using-uitableview.html
class TripSettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var currentTrip: Trip?
    
    
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var name: UITextField! { didSet { name.delegate = self } }
    @IBOutlet weak var startDate: UITextField! { didSet { startDate.delegate = self } } //prevent keyboard
    @IBOutlet weak var endDate: UITextField! { didSet { endDate.delegate = self } }
    @IBOutlet weak var budget: UITextField! { didSet { budget.delegate = self } }
    @IBOutlet weak var calendar: UISwitch!
   
    private let formatter = DateFormatter()
    private let store = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "MM/dd/yyyy"
        
        //Load trip
        if let context = container?.viewContext, let title = self.navigationItem.title {
            currentTrip = try? Trip.findOrCreateTrip(matching: title, in: context)
            try? context.save()
        }
        if navigationItem.title != "Trip Information" {
            loadPreviousTrip()
        }
        
        //Set up custom keyboards
        setUpDateKeyboard(for: startDate)
        setUpDateKeyboard(for: endDate)
        addDoneToKeyboard(for: budget)
    }
    
    private func loadPreviousTrip() {
        let trip = currentTrip!
        name.text = trip.name
        if let start = trip.start as? Date {
            startDate.text = formatter.string(from: start)
        }
        if let end = trip.end as? Date {
            endDate.text = formatter.string(from: end)
        }
        if let budg = currentTrip?.budget {
            budget.text = String(budg)
        }
        if let data = trip.image as? Data, let image = UIImage(data: data) {
            tripImage.image = image
        }
        calendar.isOn = trip.calendarOn
    }
    
    private func addDoneToKeyboard(for textField: UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(
            keyboardDone))
        toolbar.items = [done]
        textField.inputAccessoryView = toolbar
    }
    
    private func setUpDateKeyboard(for textField: UITextField){
        let picker = UIDatePicker()
        picker.sizeToFit()
        picker.datePickerMode = UIDatePickerMode.date
        picker.date = ((textField == startDate) ? currentTrip?.start : currentTrip?.end) as? Date ?? Date()
        textField.inputView = picker;
        addDoneToKeyboard(for: textField)
    }
    

    // Text field Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == startDate {
            let picker = textField.inputView as! UIDatePicker
            startDate.text = formatter.string(from: picker.date)
        } else if textField == endDate {
            let picker = textField.inputView as! UIDatePicker
            endDate.text =  formatter.string(from: picker.date)
        }
        if calendar.isOn {
            makeEvent(updating: true)
        }
    }
    
    func keyboardDone(){
        budget.resignFirstResponder()
        startDate.resignFirstResponder()
        endDate.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Calendar
    
    @IBAction func updateCalendar(_ sender: UISwitch) {
        if sender.isOn {
            if EKEventStore.authorizationStatus(for: EKEntityType.event) == .authorized {
                makeEvent(updating: false)
            } else {
                store.requestAccess(to: .event, completion: { (granted, error) in
                    if granted {
                        self.makeEvent(updating: false)
                    }
                })
            }
        } else {
            deleteEvent()
        }
    }
    
    private func deleteEvent(){
        do {
            if let id = currentTrip?.calendarEventID, let event = store.event(withIdentifier: id) {
                try store.remove(event, span: .thisEvent)
                let alert = UIAlertController(title: "Success", message: "Trip deleted from calendar.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                errorDeletingEvent()
            }
        } catch {
            errorDeletingEvent()
        }
    }
    
    private func errorDeletingEvent() {
        let alert = UIAlertController(title: "Error", message: "Could not delete trip from calendar.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    //http://stackoverflow.com/questions/38091802/add-event-to-calendar-in-ios8-with-swift
    private func makeEvent(updating: Bool) {
        if let startDate = formatter.date(from: startDate.text!), let endDate = formatter.date(from: endDate.text!) {
            var event = EKEvent(eventStore : store)
            if updating {
                if let id = currentTrip?.calendarEventID {
                    event = store.event(withIdentifier: id)!
                }
            }
            if let name = name.text {
                event.title = name
            }
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = store.defaultCalendarForNewEvents
            saveEvent(event, updating: updating)
        } else {
            calendar.isOn = false
            let alert = UIAlertController(title: "Dates", message: "Please enter dates in order to add the trip to the calender.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

    }
    
    private func saveEvent(_ event: EKEvent, updating: Bool){
        do {
            if !updating {
                try store.save(event, span: .thisEvent)
            }
            if let context = container?.viewContext, !updating {
                currentTrip?.calendarEventID = event.eventIdentifier
                try? context.save()
            }
            
            //Success
            let message = (updating) ? "Trip was updated in your calendar" : "Trip was added to your calendar"
            let alert = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        } catch {
            //Error
            let alert = UIAlertController(title: "Error", message: "There was an error saving the trip to your calendar. Try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    // Image Picking
    
    //https://www.youtube.com/watch?v=1kCKlv1npw0
    @IBAction func pickImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func takeImageWithCamera(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera", message:
                "Device must have a camera.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            tripImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }

    
    // Table view asthetics
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.bounds.width/2
        }
        return UITableViewAutomaticDimension
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        tableView.reloadData()
    }
    
    //Saving trip
    
    override func viewWillDisappear(_ animated: Bool) {
        //Only save if not creating trip for first time
        if navigationItem.title != "Trip Information" {
            saveTrip()
        }
    }
    
    private func saveTrip() {
        if let context = container?.viewContext {
            currentTrip?.name = name.text
            currentTrip?.start = formatter.date(from: startDate.text!) as NSDate?
            currentTrip?.end = formatter.date(from: endDate.text!) as NSDate?
            if currentTrip?.end == nil {
                currentTrip?.upcoming = true
            } else {
                currentTrip?.upcoming = (currentTrip?.end as! Date) > Date()
            }
            if let budg = budget.text, let value = Double(budg) {
                currentTrip?.budget = value //make sure keyboard is only numbers...
            }
            currentTrip?.calendarOn = calendar.isOn
            if let image = tripImage.image {
                currentTrip?.image = UIImagePNGRepresentation(image) as NSData?
            }
            
            try? context.save()
        }
    }
    
    //Navigation
    
    //Do not segue if name, start date, or end date is not provided
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var title = ""
        var message = ""
        if name.text == "" {
            title = "No Trip Name"
            message = "Please choose a name for your trip before proceeding."
        } else if startDate.text == "" || endDate.text == "" {
            title = "No Trip Dates"
            message = "Please provided dates for your trip before proceeding."
        } else if self.navigationItem.rightBarButtonItem != nil { //Trip being created for first time
            if let context = container?.viewContext, try! Trip.tripExists(with: name.text!, in: context) {
                title = "Trip Already Exists"
                message = "Please choose a different name for your trip before proceeding."
            }
        }
        if title != "" {
            let alert = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func back(sender: UIBarButtonItem) {
        _ = self.navigationController?.popToRootViewController(animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveTrip() //save if segue always
        if let destination = segue.destination as? TripMenuViewController {
            destination.navigationItem.title = name.text
            destination.currentTrip = currentTrip
        }
        
    }
 

}
