//
//  Traveller.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/11/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class Traveler: NSManagedObject {

    class func findOrCreateTraveler(matching name: String, with trip: Trip, in context: NSManagedObjectContext) throws -> Traveler {
        let request: NSFetchRequest<Traveler> = Traveler.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                let match = matches[0]
                match.trips = match.trips?.adding(trip) as NSSet?
                return match
            }
        } catch {
            throw error
        }
        
        let traveler = Traveler(context: context)
        traveler.name = name
        traveler.trips = traveler.trips?.adding(trip) as NSSet?
        return traveler
    }
    
}
