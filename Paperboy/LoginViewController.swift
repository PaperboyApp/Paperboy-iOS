//
//  LoginViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/19/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginUser(sender: UIButton) {
        PFUser.logInWithUsernameInBackground(usernameField.text, password: passwordField.text, block: { (user: PFUser!, error: NSError!) -> Void in
            if error == nil {
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                switch error.code {
                case kPFErrorConnectionFailed:
                    self.errorLabel.text = "Connection Failed."
                case kPFErrorObjectNotFound:
                    self.errorLabel.text = "Incorrect username or password"
                default:
                    self.errorLabel.text = "Error in login."
                }
            }
        })
    }

    @IBAction func contactUs(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto:alvaro@getpaperboy.com?subject=Hi%20Paperboy!")!)
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
