//
//  Subscription.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/14/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import Foundation

class Subscription {
    class func subscribe(publisher: PFUser) {
        let currentUser = PFUser.currentUser()
        let relationSubscription = currentUser.relationForKey("subscription")
        
        // Subscribe
        relationSubscription.addObject(publisher)
        currentUser.saveEventually()
    }
    
    class func unsubscribe(publisher: PFUser) {
        let currentUser = PFUser.currentUser()
        let relationSubscription = currentUser.relationForKey("subscription")
        
        // Unsubscribe
        relationSubscription.removeObject(publisher)
        currentUser.saveEventually()
    }
}