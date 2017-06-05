//
//  TripInformationTableViewCell.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/28/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit

class TripInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var infoField: UITextView!
    
    func getInformation() -> String {
        return infoField.text
    }

}
