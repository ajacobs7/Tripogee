//
//  Destination.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/27/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class Destination: NSManagedObject {
    
    class func createDestination(matching name: String, in context: NSManagedObjectContext) -> Destination {
        let dest = Destination(context: context)
        dest.name = name
        return dest
    }
    
}
