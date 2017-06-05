//
//  StarsView.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/18/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit

//@IBDesignable
class StarsView: UIView {

    //@IBInspectable
    var rating: Double? {
        didSet {
            setRating()
        }
    }
    
    private var ratingBar = UIView()

    override func layoutSubviews() {
        
        //Add rating bar
        ratingBar.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        addSubview(ratingBar)
        
        //Add stars
        for i in 0...4 {
            let star_img = UIImage(named: "star.png")
            let img_view = UIImageView(image: star_img)
            img_view.frame = CGRect(x: (frame.size.width/5.0) * CGFloat(i), y: 0, width: frame.size.width/5.0, height: frame.size.height)
            addSubview(img_view)
        }
        
        //Set up rating
        setRating()
    }
    
    private func setRating(){
        if let fill = rating {
            ratingBar.backgroundColor = UIColor.yellow
            let numFull = floor(fill)
            let width = CGFloat(numFull+0.1)*(frame.size.width/5.0) //Add 0.1 to account for star spacing
            ratingBar.frame.size.width = width + (0.8 * CGFloat(fill - numFull))
        } else {
            ratingBar.backgroundColor = UIColor.lightGray
            ratingBar.frame.size.width = frame.size.width
        }
        
    }


}
