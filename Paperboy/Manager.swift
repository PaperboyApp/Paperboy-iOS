//
//  Manager.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/14/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import Foundation

struct Manager {
    static var publishers: [PFUser] = []
    static var subscriptions: [PFUser] = []
    static var currentUser: PFUser = PFUser()
    static var headlines: [PFObject] = []
    static var headlinesIcons: [UIImage] = []
    
    // Load info functions
    
    static func load(block: ()->()) {
        loadSubscriptions(block)
        loadPublishers()
    }
    
    static func loadSubscriptions(block: ()->()) {
        currentUser = PFUser.currentUser()
        var query = currentUser.relationForKey("subscription").query()
        query.findObjectsInBackgroundWithBlock({ (subscriptions: [AnyObject]!, error: NSError!) -> Void in
            self.subscriptions = subscriptions as [PFUser]
            self.loadHeadlines(block)
        })
    }
    
    static func loadHeadlines(block: ()->()) {
        headlines = []
        if subscriptions.count != 0 {
            // Get headlines
            var headlinesQuery: [PFQuery] = []
            for subscription in subscriptions {
                let headlinesQueryForSubscription = subscription.relationForKey("headlines").query()
                headlinesQuery.append(headlinesQueryForSubscription)
            }
            var query = PFQuery.orQueryWithSubqueries(headlinesQuery)
            query.orderByDescending("createdAt")
            query.limit = 10
            
            query.findObjectsInBackgroundWithBlock({ (headlines: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    self.headlines = headlines as [PFObject]
                    block()
                } else {
                    // log errors
                }
            })
        }
    }

    static func loadPublishers() {
        // Get publisher role
        var query = PFRole.query()
        query.whereKey("name", equalTo: "Publisher")
        query.getFirstObjectInBackgroundWithBlock({ (role: PFObject!, error: NSError!) -> Void in
            query = (role as PFRole).users.query()
            query.findObjectsInBackgroundWithBlock({ (publishers: [AnyObject]!, error: NSError!) -> Void in
                self.publishers = publishers as [PFUser]
            })
        })
    }

    // Subscription functions

    static func subscribe(#publisher: PFUser) {
        let currentInstallation = PFInstallation.currentInstallation()
        let relationSubscription = currentUser.relationForKey("subscription")
        
        // Subscribe user
        relationSubscription.addObject(publisher)
        currentUser.saveEventually()
        
        // Add to channel
        currentInstallation.addUniqueObject(publisher.username, forKey: "channels")
        currentInstallation.saveEventually()
    }
    
    static func unsubscribe(#publisher: PFUser) {
        self.currentUser = PFUser.currentUser()
        let relationSubscription = currentUser.relationForKey("subscription")
        let currentInstallation = PFInstallation.currentInstallation()
        
        // Unsubscribe user
        relationSubscription.removeObject(publisher)
        currentUser.saveEventually()
        
        // Remove from channel
        currentInstallation.removeObject(publisher.username, forKey: "channels")
        currentInstallation.saveEventually()
    }
    
    static func subscribe(#publishers: [PFUser]) {
        let currentInstallation = PFInstallation.currentInstallation()
        let relationSubscription = currentUser.relationForKey("subscription")
        
        // Subscribe user & add channel
        for publisher in publishers {
            relationSubscription.addObject(publisher)
            currentInstallation.addUniqueObject(publisher.username, forKey: "channels")
        }
        
        // Save user and installation
        currentUser.saveEventually()
        currentInstallation.saveEventually()
    }
    
    static func unsubscribe(#publishers: [PFUser]) {
        let relationSubscription = currentUser.relationForKey("subscription")
        let currentInstallation = PFInstallation.currentInstallation()
        
        // Unsubscribe user & remove channel
        for publisher in publishers {
            relationSubscription.removeObject(publisher)
            currentInstallation.removeObject(publisher.username, forKey: "channels")
        }
        
        // Save user and installation
        currentUser.saveEventually()
        currentInstallation.saveEventually()
    }
    
    static func syncSubscriptionsWithInstallation() {
        self.currentUser = PFUser.currentUser()
        var currentInstalation: PFInstallation = PFInstallation.currentInstallation()
        var query = currentUser.relationForKey("subscription").query()
        query.findObjectsInBackgroundWithBlock({ (subscriptions: [AnyObject]!, error: NSError!) -> Void in
            for subscription in subscriptions {
                currentInstalation.addUniqueObject(subscription.username, forKey: "channels")
            }
            currentInstalation.saveEventually()
        })
    }
}