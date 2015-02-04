//
//  DiscoverTableViewController.swift
//  Paperboy
//
//  Created by Mario Encina on 1/13/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class DiscoverTableViewController: UITableViewController {
    var status: [Bool] = []
    var changes: [Bool] = []

    override func viewWillDisappear(animated: Bool) {
        // Get list of publishers to un/subscribe
        var publishersToSubscribe: [PFUser] = []
        var publishersToUnsubscribe: [PFUser] = []
        for (index, change) in enumerate(changes) {
            if change {
                let publisher = Manager.publishers[index]
                if status[index] {
                    publishersToUnsubscribe.append(publisher)
                } else {
                    publishersToSubscribe.append(publisher)
                }
            }
        }
        if publishersToSubscribe.count > 0 || publishersToUnsubscribe.count > 0 {
            Manager.subscribe(publishers: publishersToSubscribe)
            Manager.unsubscribe(publishers: publishersToUnsubscribe)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tracker = GAI.sharedInstance().defaultTracker as GAITracker? {
            tracker.set(kGAIScreenName, value:"Discover View")
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
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
        // Get user subscriptions
        let subscriptionsString = Manager.subscriptions.map({ (subscription: PFUser) -> String in
            return subscription.username
        })
        
        for publisher in Manager.publishers {
            let isSubscribedToPublisher = contains(subscriptionsString, publisher.username)
            status.append(isSubscribedToPublisher)
        }
        
        changes = [Bool](count: Manager.publishers.count, repeatedValue: false)
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Manager.publishers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscoverCell", forIndexPath: indexPath) as DiscoverTableViewCell
        let publisher = Manager.publishers[indexPath.row]
        if let publisherIcon = publisher["icon"] as? PFFile {
            publisherIcon.getDataInBackgroundWithBlock { (data: NSData!, error: NSError!) -> Void in
                cell.publisherIcon.image = UIImage(data: data)
            }
        }
        // Populate cells
        
        cell.publisherName.text = publisher.username
        if status.count > 0 && status[indexPath.row] {
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
    }
}
