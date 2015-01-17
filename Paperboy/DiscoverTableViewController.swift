//
//  DiscoverTableViewController.swift
//  Paperboy
//
//  Created by Mario Encina on 1/13/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class DiscoverTableViewController: UITableViewController {
    
    var publisherList: [PFUser] = []
    var status: [Bool] = []
    var changes: [Bool] = []

    @IBAction func closeDiscover(sender: AnyObject) {
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        for (index, change) in enumerate(changes) {
            if change {
                let publisher = publisherList[index]
                if status[index] {
                    Subscription.unsubscribe(publisher)
                } else {
                    Subscription.subscribe(publisher)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        // Get Publishers
        var query = PFRole.query()
        query.whereKey("name", equalTo: "Publisher")
        let role = query.getFirstObject() as PFRole
        query = role.users.query()
        
        publisherList = query.findObjects() as [PFUser]
        
        // Get user subscriptions
        let currentUser = PFUser.currentUser()
        query = currentUser.relationForKey("subscription").query()
        let subscriptions = query.findObjects() as [PFUser]
        let subscriptionsString = subscriptions.map({ (subscription: PFUser) -> String in
            return subscription.username
        })
        
        for publisher in publisherList {
            let isSubscribedToPublisher = contains(subscriptionsString, publisher.username)
            status.append(isSubscribedToPublisher)
        }
        
        changes = [Bool](count: publisherList.count, repeatedValue: false)
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return publisherList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscoverCell", forIndexPath: indexPath) as DiscoverTableViewCell
        let publisher = publisherList[indexPath.row]
        let publisherIcon = publisher["icon"] as PFFile
        // Populate cells
        
        cell.publisherName.text = publisher.username
        cell.publisherIcon.image = UIImage(data: publisherIcon.getData() as NSData)
        if status[indexPath.row] {
            cell.accessoryType = .Checkmark
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get selected cell
        let cell = tableView.cellForRowAtIndexPath(indexPath) as DiscoverTableViewCell
        
        // Check if it is an active subscription
        let active = cell.accessoryType == .Checkmark
        
        // Subscribe/Unsubcribe & toggle accessory
        changes[indexPath.row] = !changes[indexPath.row]
        if active {
            // Unsubscribe
            cell.accessoryType = .None
        } else {
            // Subscribe
            cell.accessoryType = .Checkmark
        }
        
        // TODO: Parse
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
