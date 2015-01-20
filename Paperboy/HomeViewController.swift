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
    
    var subscriptions: [PFUser] = []
    var headlines: [PFObject] = []
    var url = NSURL(string: "")
    var subscriptionsOn = true
    
    @IBOutlet weak var subscriptionTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sync subscriptions to channel
        var currentInstalation: PFInstallation = PFInstallation.currentInstallation()
        let currentUser = PFUser.currentUser()
        var query = currentUser.relationForKey("subscription").query()
        let subscriptions = query.findObjects()
        for subscription in subscriptions {
            currentInstalation.addUniqueObject(subscription.username, forKey: "channels")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushNotificationReceived:", name: "pushNotification", object: nil)
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Request user subscriptions
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        let currentUser = PFUser.currentUser()
        
        // Request user subscriptions
        var query = currentUser.relationForKey("subscription").query()
        subscriptions = query.findObjects() as [PFUser]
        
        // Request latest feed
        if subscriptions.count != 0 {
            var headlinesQuery: [PFQuery] = []
            for subscription in subscriptions {
                let headlinesQueryForSubscription = subscription.relationForKey("headlines").query()
                headlinesQuery.append(headlinesQueryForSubscription)
            }
            query = PFQuery.orQueryWithSubqueries(headlinesQuery)
            query.orderByDescending("createdAt")
            query.limit = 10
            headlines = query.findObjects() as [PFObject]
        } else {
            headlines = []
        }
        
        // Reload table
        subscriptionTableView.reloadData()
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
            return subscriptions.count
        } else {
            return headlines.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if subscriptionsOn {
            let cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell", forIndexPath: indexPath) as SubscriptionsTableViewCell
            let subscription = subscriptions[indexPath.row]
            let publisherIcon = subscription["icon"] as PFFile
            
            
            cell.publisherNameLabel.text = subscription.username
            cell.subscriptionStatus.on = true
            cell.subscriptionStatus.addTarget(self, action: "subscriptionChanged:", forControlEvents: UIControlEvents.ValueChanged)
            cell.subscriptionStatus.tag = indexPath.row
            cell.publisherIcon.image = UIImage(data: publisherIcon.getData())
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LatestCell", forIndexPath: indexPath) as LatestTableViewCell
            let headline = headlines[indexPath.row] as PFObject
            let publisherName = headline["publisher"] as? String
            let publisherInSubscriptions = subscriptions.filter({ (subscription: PFUser) -> Bool in
                return subscription.username == publisherName
            }) // TOFIX
            var publisherIcon: PFFile?
            if publisherInSubscriptions.count != 0 {
                publisherIcon = publisherInSubscriptions[0]["icon"] as? PFFile
            }
            
            cell.publisherNameLabel.text = publisherName
            cell.headlineLabel.text = headline["headlineText"] as? String
            cell.url = NSURL(string: headline["url"] as String)
            if let pIcon = publisherIcon {
                cell.publisherIcon.image = UIImage(data: pIcon.getData())
            }
            return cell
        }
    }
    
    func subscriptionChanged(sender: UISwitch) {
        // Change subscription
        if sender.on {
//            let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
//            let cell = subscriptionTableView.cellForRowAtIndexPath(indexPath) as SubscriptionsTableViewCell
            Subscription.subscribe(publisher: subscriptions[sender.tag])
        } else {
            Subscription.unsubscribe(publisher: subscriptions[sender.tag])
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
                Subscription.unsubscribe(publisher: subscriptions[indexPath.row])
                subscriptions.removeAtIndex(indexPath.row)
            } else {
                headlines.removeAtIndex(indexPath.row)
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