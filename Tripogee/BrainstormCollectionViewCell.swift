//
//  BrainstormCollectionViewCell.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/6/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class BrainstormCollectionViewCell: UICollectionViewCell, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var brainstormName: UILabel!
    
    @IBOutlet weak var brainstormImage: UIImageView!
    
    var brainstorm: Brainstorm? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI(){
        if let name = brainstorm?.name {
            brainstormName.text = name
        }
        if let image = getScreenshot(for: brainstorm!) {
            brainstormImage.image = image
        }

    }
    
    private func getScreenshot(for storm: Brainstorm) -> UIImage? {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let name = (storm.dateCreated?.description)! + ".summary.png"
        let filename = docDir.appendingPathComponent(name)
        return UIImage(contentsOfFile: filename.path)
    }
    
}
