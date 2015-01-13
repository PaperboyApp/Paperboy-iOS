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
    var headlines = ["ISIS “Cyber Caliphate” Hacks U.S. Military Command Accounts", "80% Of All Online Adults Now Own A Smartphone, Less Than 10% Use Wearables"]
    var publisher = "Techcrunch"
    var url = "http://techcrunch.com/"
        
    @IBOutlet weak var subscriptionTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return subscriptions.count
        } else {
            return headlines.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell", forIndexPath: indexPath) as SubscriptionsTableViewCell
            
            cell.publisherNameLabel.text = subscriptions[indexPath.row]
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("LatestCell", forIndexPath: indexPath) as LatestTableViewCell
            
            cell.publisherNameLabel.text = publisher
            cell.headlineLabel.text = headlines[indexPath.row]
            cell.url = url
            return cell
            
        default:
            NSLog("Segmented control index out of bounds")
            return UITableViewCell()
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        subscriptionTableView.setEditing(editing, animated: animated)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            subscriptions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if segmentedControl.selectedSegmentIndex == 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as LatestTableViewCell
            
            if let url = cell.url? {
                UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            }
        }
    }
    
    @IBAction func switchHomeTables(sender: UISegmentedControl) {
        subscriptionTableView.reloadData()
    }

    
}