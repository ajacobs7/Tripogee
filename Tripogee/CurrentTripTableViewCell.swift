//
//  CurrentTripTableViewCell.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/26/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit

class CurrentTripTableViewCell: UITableViewCell {

    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    var currentTrip: Trip? {
        didSet {
            tripName.text = currentTrip!.name
            if let image = UIImage(data: currentTrip!.image as! Data) {
                tripImage.image = image
            }
            setDateLabels()
        }
    }
    
    private func setDateLabels(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        if currentTrip!.start != nil && currentTrip!.end != nil{
            datesLabel.text = formatter.string(from: currentTrip!.start as! Date) + " - " + formatter.string(from: currentTrip!.end as! Date)
            
            let calendar = Calendar.current
            let duration = calendar.dateComponents([.day], from: currentTrip!.start as! Date, to: currentTrip!.end as! Date).day!
            let daysTil = calendar.dateComponents([.day], from: Date(), to: currentTrip!.start as! Date)
            
            let todayDay = calendar.dateComponents([.day], from: Date()).day
            let startDay = calendar.dateComponents([.day], from: currentTrip!.start as! Date).day
            
            timerLabel.text = "\(duration) days long, "
            if daysTil.day! < 0 {
                timerLabel.text = timerLabel.text! + "started \(abs(daysTil.day!)) days ago"
            } else if daysTil.day! == 0 && todayDay == startDay {
                timerLabel.text = timerLabel.text! + "starts today"
            } else {
                timerLabel.text = timerLabel.text! + "starts in \(daysTil.day! + 1) days"
            }
        }
    }

}
