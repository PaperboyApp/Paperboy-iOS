//
//  Subscription.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/14/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import Foundation

class Subscription {
    class func subscribe(#publisher: PFUser) {
        let currentUser = PFUser.currentUser()
        let currentInstallation = PFInstallation.currentInstallation()
        let relationSubscription = currentUser.relationForKey("subscription")
        
        // Subscribe user
        relationSubscription.addObject(publisher)
        currentUser.saveEventually()
        
        // Add to channel
        currentInstallation.addUniqueObject(publisher.username, forKey: "channels")
        currentInstallation.saveEventually()
    }
    
    class func unsubscribe(#publisher: PFUser) {
        let currentUser = PFUser.currentUser()
        let relationSubscription = currentUser.relationForKey("subscription")
        let currentInstallation = PFInstallation.currentInstallation()
        
        // Unsubscribe user
        relationSubscription.removeObject(publisher)
        currentUser.saveEventually()
        
        // Remove from channel
        currentInstallation.removeObject(publisher.username, forKey: "channels")
        currentInstallation.saveEventually()
    }
    
    class func subscribe(#publishers: [PFUser]) {
        let currentUser = PFUser.currentUser()
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
    
    class func unsubscribe(#publishers: [PFUser]) {
        let currentUser = PFUser.currentUser()
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
}