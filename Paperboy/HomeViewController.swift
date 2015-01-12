//
//  HomeViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/12/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var subscriptions = ["Techcrunch", "Mashable", "CNN"]
        
    override func viewDidLoad() {
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as SubscriptionsTableViewCell
        
        cell.publisherNameLabel.text = subscriptions[indexPath.row]
        
        return cell
    }
    
    // TODO
    
    //    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    //        // Return false if you do not want the specified item to be editable.
    //        return true
    //    }
    //
    //    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    //        if editingStyle == .Delete {
    //            objects.removeObjectAtIndex(indexPath.row)
    //            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    //        } else if editingStyle == .Insert {
    //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    //        }
    //    }
}