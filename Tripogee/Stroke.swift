//
//  Stroke.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/16/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class Stroke: NSManagedObject {
    
    class func getAll(for brainstorm: Brainstorm) -> [Stroke] {
        return (brainstorm.strokes)!.allObjects as! [Stroke]
    }

}
