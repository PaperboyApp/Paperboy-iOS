//
//  HomeViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/12/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var url = NSURL(string: "")
    var subscriptionsOn = true
    var currentUser = PFUser()
    
    @IBOutlet weak var subscriptionTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = PFUser.currentUser()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushNotificationReceived:", name: "pushNotification", object: nil)
        Manager.syncSubscriptionsWithInstallation()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Do first load
        Manager.load()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Manager.load()
    }
    
    func pushNotificationReceived(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let newsURL = userInfo["u"] as? String {
                url = NSURL(string: newsURL)
                segmentedControl.selectedSegmentIndex = 1
                subscriptionsOn = false
                performSegueWithIdentifier("openWebView", sender: self)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if subscriptionsOn {
            return Manager.subscriptions.count
        } else {
            return Manager.headlines.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if subscriptionsOn {
            // For subscriptions table
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell", forIndexPath: indexPath) as SubscriptionsTableViewCell
            let subscription = Manager.subscriptions[indexPath.row]
            let publisherIcon = subscription["icon"] as PFFile
            
            cell.publisherNameLabel.text = subscription.username
            cell.subscriptionStatus.on = true
            cell.subscriptionStatus.addTarget(self, action: "subscriptionChanged:", forControlEvents: UIControlEvents.ValueChanged)
            cell.subscriptionStatus.tag = indexPath.row
            cell.publisherIcon.image = UIImage(data: publisherIcon.getData())
            
            return cell
            
        } else {
            // For latest headlines table
            
            let cell = tableView.dequeueReusableCellWithIdentifier("LatestCell", forIndexPath: indexPath) as LatestTableViewCell
            let headline = Manager.headlines[indexPath.row] as PFObject
            let publisherName = headline["publisher"] as? String
            
            cell.publisherNameLabel.text = publisherName
            cell.headlineLabel.text = headline["headlineText"] as? String
            cell.url = NSURL(string: headline["url"] as String)
            cell.publisherIcon.image = Manager.headlinesIcons[indexPath.row]
            
            return cell
            
        }
    }
    
    func subscriptionChanged(sender: UISwitch) {
        // Change subscription
        if sender.on {
            Manager.subscribe(publisher: Manager.subscriptions[sender.tag])
        } else {
            Manager.unsubscribe(publisher: Manager.subscriptions[sender.tag])
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        subscriptionTableView.setEditing(editing, animated: animated)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return subscriptionsOn
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if subscriptionsOn {
                Manager.unsubscribe(publisher: Manager.subscriptions[indexPath.row])
                Manager.subscriptions.removeAtIndex(indexPath.row)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !subscriptionsOn {
            return 119
        } else {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !subscriptionsOn {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as LatestTableViewCell
            url = cell.url
            self.performSegueWithIdentifier("openWebView", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.editing = false
        if segue.identifier == "openWebView" && !subscriptionsOn {
            let nav = segue.destinationViewController as UINavigationController
            let webViewController = nav.topViewController as WebViewController
            webViewController.requestURL = url
        }
    }
    
    @IBAction func switchHomeTables(sender: UISegmentedControl) {
        subscriptionsOn = !subscriptionsOn
        
        if subscriptionsOn {
            navigationItem.leftBarButtonItem = editButtonItem()
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        editing = false
        subscriptionTableView.reloadData()
    }
    
    @IBAction func contactUs(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto:alvaro@getpaperboy.com?subject=Hi%20Paperboy!")!)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}