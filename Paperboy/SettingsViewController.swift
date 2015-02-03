//
//  SettingsViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 2/3/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func termsOfUse() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://getpaperboy.com/terms.html")!)
    }

    @IBAction func privacyPolicy() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://getpaperboy.com/privacy.html")!)
    }
    
    @IBAction func contactUs() {
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto:hello@getpaperboy.com?Subject=Hi%20Paperboy!")!)
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
