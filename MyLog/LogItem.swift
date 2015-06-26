//
//  LogItem.swift
//  
//
//  Created by Roberto Robles on 6/25/15.
//
//

import Foundation
import CoreData

class LogItem: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var itemText: String
    @NSManaged var fullTitle: String
    @NSManaged var timeSeries: [Float]
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, text: String, fullTitle: String, timeSeries: [Float]) -> LogItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("LogItem", inManagedObjectContext: moc) as! LogItem
        newItem.title = title
        newItem.itemText = text
        newItem.fullTitle = fullTitle
        // newItem.timeSeries = timeSeries
        
        return newItem
    }
}
