//
//  Attraction.swift
//  Tripogee
//
//  Created by Austin Jacobs on 2/27/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class Attraction: NSManagedObject {

    class func findOrCreateAttraction(matching info: [String : Any], for destination: Destination, in context: NSManagedObjectContext) throws -> Attraction {
        let request: NSFetchRequest<Attraction> = Attraction.fetchRequest()
        request.predicate = NSPredicate(format: "destination == %@ && name == %@", destination , info["name"] as! String)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                return matches[0]
            }
        } catch {
            throw error
        }

        let attr = Attraction(context: context)
        attr.name = info["name"] as! String?
        attr.destination = destination
        attr.planned = false
        if let rating = info["rating"] as? Double {
            attr.rating = rating
        }
        if let photos = info["photos"] as? [[String: Any]] {
            let photo = photos[0]
            attr.imageURL = photo["photo_reference"] as? String
            attr.aspect_ratio = (photo["width"] as! Double)/(photo["height"] as! Double)
        }
        return attr
    }
    
}
