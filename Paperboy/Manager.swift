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
    
    static func load() {
        loadSubscriptions()
        loadPublishers()
        loadHeadlines()
    }
    
    static func loadSubscriptions() {
        currentUser = PFUser.currentUser()
        var query = currentUser.relationForKey("subscription").query()
        subscriptions = query.findObjects() as [PFUser]
    }
    
    static func loadHeadlines() {
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
            
            headlines = query.findObjects() as [PFObject]
            
            // get icons
            for headline in headlines {
                let publisher = subscriptions.filter({ (publisher: PFUser) -> Bool in
                    return publisher.username == headline["publisher"] as String
                })
                if publisher.count == 1 {
                    let publisherIcon = publisher[0]["icon"] as PFFile
                    if let img = UIImage(data: publisherIcon.getData()) {
                        headlinesIcons.append(img)
                    }
                }
            }
        }
    }

    static func loadPublishers() {
        // Get publisher role
        var query = PFRole.query()
        query.whereKey("name", equalTo: "Publisher")
        let role = query.getFirstObject() as PFRole

        // Get publishers in role publisher
        query = role.users.query()
        publishers = query.findObjects() as [PFUser]
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
        println(currentUser.isAuthenticated())
        let subscriptions = query.findObjects() as [PFUser]
        for subscription in subscriptions {
            currentInstalation.addUniqueObject(subscription.username, forKey: "channels")
        }
        currentInstalation.saveEventually()
    }
}