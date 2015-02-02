//
//  NumberInputViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/14/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class NumberInputViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var phoneInput: UITextField!
    @IBOutlet weak var phonePrefix: UITextField!
    @IBOutlet weak var countryCodePlaceholderLabel: UILabel!
    
    var countryPrefix: String = "" {
        didSet {
            phonePrefix.text = "+" + countryPrefix
            countryCodePlaceholderLabel.hidden = true
        }
    }
    
    var country: String = "" {
        didSet {
            countryButton.setTitle(country, forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var tracker:GAITracker = GAI.sharedInstance().defaultTracker as GAITracker
        tracker.set(kGAIScreenName, value:"Number Input View")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add borders to form
        phoneInput.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
        phonePrefix.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
        countryButton.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
        phoneInput.layer.borderWidth = 1.0
        phonePrefix.layer.borderWidth = 1.0
        countryButton.layer.borderWidth = 1.0
        
        // Locale identification
        let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as String
        if let phonePrefix = Country().countryPhonePrefix[countryCode] {
            countryPrefix = phonePrefix
            if let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countryCode) {
                country = countryName
            }
        }
        
        phoneInput.becomeFirstResponder()
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "showAlerts:", userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlerts(timer: NSTimer) {
        let application = UIApplication.sharedApplication()
        if (application.respondsToSelector("isRegisteredForRemoteNotifications")) {
            if !application.isRegisteredForRemoteNotifications() {
                let alert = UIAlertController(title: "Allow the Paperboy to deliver on your phone", message: "So that he brings you the latest headlines.", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "GOT IT", style: .Default, handler: { (alertAction: UIAlertAction!) -> Void in
                    // Register for push notifications
                    let userNotificationTypes: UIUserNotificationType = (.Alert | .Badge | .Sound)
                    let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
                    application.registerUserNotificationSettings(settings)
                    application.registerForRemoteNotifications()
                })
                
                alert.addAction(alertAction)
                presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertView(title: "Allow the Paperboy to deliver on your phone", message: "So that he brings you the latest headlines.", delegate: nil, cancelButtonTitle: "GOT IT")
            alert.show()
            application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound )
        }
    }
    
    @IBAction func phoneEditChange(sender: UITextField) {
        doneButton.enabled = phoneInput.text.utf16Count > 0
    }
    
    @IBAction func phonePrefixEditChange(sender: UITextField) {
        countryCodePlaceholderLabel.hidden = phonePrefix.text.utf16Count != 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "codeInput" {
            let userPhoneNumber = phonePrefix.text + phoneInput.text
            
            // Send SMS to number
            PFCloud.callFunctionInBackground("getVerificationNumber", withParameters: ["phone": userPhoneNumber])
            
            // Do segue
            var destinationViewController = segue.destinationViewController as CodeInputViewController
            destinationViewController.phone = userPhoneNumber
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
