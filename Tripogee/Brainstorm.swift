//
//  Brainstorm.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/6/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import UIKit
import CoreData

class Brainstorm: NSManagedObject {

    class func getAll(in context: NSManagedObjectContext) -> [Brainstorm]? {
        let request: NSFetchRequest<Brainstorm> = Brainstorm.fetchRequest()
        request.predicate = NSPredicate(format: "any")
        var matches = try? context.fetch(request)
        //sort by date created
        matches = matches?.sorted(by: { (storm1, storm2) -> Bool in
            let date1 = storm1.dateCreated as! Date
            let date2 = storm2.dateCreated as! Date
            return date1.compare(date2).rawValue > 0
        })
        return matches
    }
    
    class func delete(_ storm: Brainstorm, in context: NSManagedObjectContext) {
        //clean up screenshot
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = docDir.appendingPathComponent((storm.dateCreated?.description)! + ".png")
        try? FileManager.default.removeItem(atPath: filename.path)

        context.delete(storm)
        try? context.save()
    }
    
}
