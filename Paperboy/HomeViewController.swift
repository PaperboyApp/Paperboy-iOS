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
    
    var headlineURL = NSURL(string: "")
    var headlinePublisher = ""
    var subscriptionsOn = true
    var currentUser = PFUser()
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var subscriptionTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        settingsButton.layer.cornerRadius = settingsButton.bounds.size.width / 2.0;
        
        var tracker:GAITracker = GAI.sharedInstance().defaultTracker as GAITracker
        tracker.set(kGAIScreenName, value:"Home View")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushNotificationReceived:", name: "pushNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadHeadlines", name: "updateHeadlines", object: nil)
        Manager.syncSubscriptionsWithInstallation()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        Manager.load { () -> () in
            self.subscriptionTableView.reloadData()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadHeadlines()
    }
    
    func pushNotificationReceived(notification: NSNotification) {
        if let alert = notification.userInfo?["aps"]?["alert"] as? String {
            if let newsURL = notification.userInfo?["u"] as? String {
                let splitHeadline = alert.componentsSeparatedByString(" - ")
                headlinePublisher = splitHeadline[0]
                let headline = splitHeadline[1]
                headlineURL = NSURL(string: newsURL)
                performSegueWithIdentifier("openWebView", sender: self)
                var tracker:GAITracker = GAI.sharedInstance().defaultTracker as GAITracker
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(headlinePublisher, action: headline as String, label: "Push", value: nil).build())
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
            if let publisherIcon = subscription["icon"] as? PFFile {
                publisherIcon.getDataInBackgroundWithBlock({ (data: NSData!, error: NSError!) -> Void in
                    cell.publisherIcon.image = UIImage(data: data)
                })
            }
            
            cell.publisherNameLabel.text = subscription.username
            
            return cell
            
        } else {
            // For latest headlines table
            let cell = tableView.dequeueReusableCellWithIdentifier("LatestCell", forIndexPath: indexPath) as LatestTableViewCell
            let headline = Manager.headlines[indexPath.row] as PFObject
            let publisherName = headline["publisher"] as? String

            let publisher = Manager.subscriptions.filter({ (publisher: PFUser) -> Bool in
                return publisher.username == publisherName
            })
            
            if publisher.count == 1 {
                if let publisherIcon = publisher[0]["icon"]? as? PFFile {
                    publisherIcon.getDataInBackgroundWithBlock({ (data: NSData!, error: NSError!) -> Void in
                        cell.publisherIcon.image = UIImage(data: data)
                    })
                }
            } // TODO: Fix this
            
            cell.publisherNameLabel.text = publisherName
            cell.headlineLabel.text = headline["headlineText"] as? String
            cell.url = NSURL(string: headline["url"] as String)
            
            return cell
            
        }
    }
    
    func loadHeadlines() {
        Manager.loadHeadlines { () -> () in
            self.subscriptionTableView.reloadData()
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
                Manager.unsubscribe(publishers: [Manager.subscriptions[indexPath.row]])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                loadHeadlines()
            }
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
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as LatestTableViewCell
            let headline = cell.headlineLabel.text
            headlineURL = cell.url
            headlinePublisher = cell.publisherNameLabel.text!
            self.performSegueWithIdentifier("openWebView", sender: self)
            var tracker:GAITracker = GAI.sharedInstance().defaultTracker as GAITracker
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(headlinePublisher, action: headline, label: "Latest", value: nil).build())
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        self.editing = false
        if segue.identifier == "openWebView" {
            navigationController?.popToRootViewControllerAnimated(true)
            
            let webViewController = segue.destinationViewController as WebViewController
            webViewController.requestURL = headlineURL
            webViewController.publisherName = headlinePublisher
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
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto:hello@getpaperboy.com?subject=Hi%20Paperboy!")!)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}