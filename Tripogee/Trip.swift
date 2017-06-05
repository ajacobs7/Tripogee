//
//  Trip.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/26/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class Trip: NSManagedObject {
    
    class func tripExists(with name: String, in context: NSManagedObjectContext) throws -> Bool {
        let request: NSFetchRequest<Trip> = Trip.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let matches = try context.fetch(request)
            return matches.count > 0
        } catch {
            throw error
        }
    }
    
    class func findOrCreateTrip(matching name: String, in context: NSManagedObjectContext) throws -> Trip {
        let request: NSFetchRequest<Trip> = Trip.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let trip = Trip(context: context)
        return trip
    }

}
