//
//  AttractionTableViewCell.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/2/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit

class AttractionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageOfAttraction: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var planned: UILabel!
    @IBOutlet weak var ratingView: StarsView!
    
    
    var cellImage: UIImage? {
        didSet {
            imageOfAttraction.contentMode = .scaleAspectFill
            imageOfAttraction.image = cellImage
            spinner.stopAnimating()
        }
    }
    
    var curAttraction: Attraction? {
        didSet {
            spinner.startAnimating()
            name.text = curAttraction!.name
            if let rating = curAttraction?.rating, rating > 0 {
                ratingView.rating = rating
            }
            setAttractionImage()
        }
    }
    
    private func setAttractionImage(){
        let width = imageOfAttraction.bounds.width
        let request = GooglePlacesRequest()
        if let ref = curAttraction!.imageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                
                request.getImage(for: ref, with: Int(width), using: { (data) in
                    DispatchQueue.main.async {
                        if let image_data = data, let image = UIImage(data: image_data) {
                            self?.cellImage = image
                        } else {
                            self?.setNoImage()
                        }
                    }
                })
            }
        } else {
            setNoImage()
        }
    }

    private func setNoImage() {
        cellImage = UIImage(named: "no-image-icon.jpg")
    }
    
    func growRating(){
        UIView.animate(withDuration: 0.3, animations: { (_) in
            self.ratingView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { (finished) in
            UIView.animate(withDuration: 0.3, animations: {
                self.ratingView.transform = CGAffineTransform.identity
            })
        })

    }
    
    func shakeRating() {
        UIView.animate(withDuration: 0.1, animations: { (_) in
            self.ratingView.transform = CGAffineTransform(translationX: 5, y: 0)
        }, completion: { (finished) in
            UIView.animate(withDuration: 0.1, animations: {
                self.ratingView.transform = CGAffineTransform(translationX: -10, y: 0)
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.1, animations: { 
                    self.ratingView.transform = CGAffineTransform.identity
                })
            })
        })
    }

}
