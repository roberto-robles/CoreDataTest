//
//  ViewController.swift
//  MyLog
//
//  Created by Roberto Robles on 6/25/15.
//  Copyright (c) 2015 Roberto Robles. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var logTableView = UITableView(frame: CGRectZero, style: .Plain)
    var logItems = [LogItem]()
    
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Retreive the managedObjectContext from AppDelegate
        
        if let moc = self.managedObjectContext {
            
            // Create some dummy data to work with
            var items = [
                ("Best Animal", "Dog"),
                ("Best Language","Swift"),
                ("Worst Animal","Cthulu"),
                ("Worst Language","LOLCODE")
            ]
            
            // Loop through, creating items
            for (itemTitle, itemText) in items {
                // Create an individual item
                LogItem.createInManagedObjectContext(moc,
                    title: itemTitle,
                    text: itemText,
                    fullTitle: "\(itemTitle) \(itemText)",
                    timeSeries: getRandomFloatArray() as! [Float])
            }
        }
        // Print it to the console
        // Now that the view loaded, we have a frame for the view, which will be (0,0,screen width, screen height)
        // This is a good size for the table view as well, so let's use that
        // The only adjust we'll make is to move it down by 20 pixels, and reduce the size by 20 pixels
        // in order to account for the status bar
        
        // Store the full frame in a temporary variable
        var viewFrame = self.view.frame
        
        // Adjust it down by 20 points
        viewFrame.origin.y += 20
        
        // Add in the "+" button at the bottom
        let addButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        addButton.setTitle("+", forState: .Normal)
        addButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        addButton.addTarget(self, action: "addNewItem", forControlEvents: .TouchUpInside)
        self.view.addSubview(addButton)
        
        // Reduce the total height by 20 points for the status bar, and 44 points for the bottom button
        viewFrame.size.height -= (20 + addButton.frame.size.height)
        
        // Set the logTableview's frame to equal our temporary variable with the full size of the view
        // adjusted to account for the status bar height
        logTableView.frame = viewFrame
        
        // Add the table view to this view controller's view
        self.view.addSubview(logTableView)
        
        // Here, we tell the table view that we intend to use a cell we're going to call "LogCell"
        // This will be associated with the standard UITableViewCell class for now
        logTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "LogCell")
        
        // This tells the table view that it should get it's data from this class, ViewController
        logTableView.dataSource = self
        logTableView.delegate = self
        
        fetchLog()
    }
    
    func getRandomFloatArray() -> NSArray {
        var myRandomArray = [Float](count: 20000, repeatedValue: Float(arc4random()) / Float(UINT32_MAX))
//        for i in 1...20000 {
//            myRandomArray[i] = Float(arc4random()) / Float(UINT32_MAX)
//        }
        println(myRandomArray)
        
        return myRandomArray
    }
    
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "LogItem")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let firstPredicate = NSPredicate(format: "title == %@", "Best Language")
        
        // Search for only items using the substring "Worst"
        let thPredicate = NSPredicate(format: "title contains %@", "Worst")
        // Combine the two predicates above in to one compound predicate
 
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate, thPredicate])
        
        
        // Set the predicate on the fetch request
        //fetchRequest.predicate = predicate
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LogItem] {
            logItems = fetchResults
        }
    }

    func addNewItem() {
        
        var titlePrompt = UIAlertController(title: "Enter Title",
            message: "Enter Text",
            preferredStyle: .Alert)
        
        var titleTextField: UITextField?
        titlePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Title"
        }
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                if let textField = titleTextField {
                    self.saveNewItem(textField.text)
                }
        }))
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
    }

    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    func saveNewItem(title : String) {
        // Create the new  log item
        var newLogItem = LogItem.createInManagedObjectContext(self.managedObjectContext!, title: title, text: "", fullTitle: "My Full Title", timeSeries: getRandomFloatArray() as! [Float])
        
        // Update the array containing the table view row data
        self.fetchLog()
        
        // Animate in the new row
        // Use Swift's find() function to figure out the index of the newLogItem
        // after it's been added and sorted in our logItems array
        if let newItemIndex = find(logItems, newLogItem) {
            // Create an NSIndexPath from the newItemIndex
            let newLogItemIndexPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            // Animate in the insertion of this row
            logTableView.insertRowsAtIndexPaths([ newLogItemIndexPath ], withRowAnimation: .Automatic)
            save()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("LogCell") as! UITableViewCell
        
        // Get the LogItem for this index
        let logItem = logItems[indexPath.row]
        
        // Set the title of the cell to be the title of the logItem
        cell.textLabel?.text = logItem.title
        return cell
    }
    
    // delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let logItem = logItems[indexPath.row]
        println(logItem.itemText)
        println(logItem.timeSeries)
    }
    
    // is_editable?
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // edit cell
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the LogItem object the user is trying to delete
            let logItemToDelete = logItems[indexPath.row]
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(logItemToDelete)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchLog()
            
            // Tell the table view to animate out that row
            logTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            save()
        }
    }
    
}

