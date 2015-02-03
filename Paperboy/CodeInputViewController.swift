//
//  CodeInputViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/20/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class CodeInputViewController: UIViewController {
    
    @IBOutlet weak var codeInput: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    var secondsLeft = 120
    
    var phone: String? {
        didSet {
            navigationItem.title = phone
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var tracker:GAITracker = GAI.sharedInstance().defaultTracker as GAITracker
        tracker.set(kGAIScreenName, value:"Code Input View")
        tracker.send(GAIDictionaryBuilder.createScreenView().build())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        codeInput.becomeFirstResponder()
        startCountdown()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startCountdown() {
        resendButton.enabled = false
        secondsLeft = 120
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateCountdown:", userInfo: nil, repeats: true)
    }
    
    func updateCountdown(timer: NSTimer) {
        secondsLeft--
        let minutes = secondsLeft/60
        let seconds = secondsLeft - minutes * 60
        if secondsLeft > 0 {
            var message = "Resend SMS in \(minutes):\(seconds)"
            if secondsLeft < 10 {
                message = "Resend SMS in \(minutes):0\(seconds)"
            }
            UIView.setAnimationsEnabled(false)
            resendButton.setTitle(message, forState: .Normal)
            resendButton.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
        } else {
            resendButton.setTitle("Resend SMS", forState: .Normal)
            resendButton.enabled = true
            timer.invalidate()
        }
    }
    
    func showLoading() -> UIView {
        // Activity indicator view
        var loadingView = UIView(frame: UIScreen.mainScreen().bounds)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        var activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activityIndicatorView.center = loadingView.center
        activityIndicatorView.activityIndicatorViewStyle = .White
        activityIndicatorView.startAnimating()
        loadingView.addSubview(activityIndicatorView)
        
        var validatingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        validatingLabel.textAlignment = NSTextAlignment.Center
        validatingLabel.text = "Validating..."
        validatingLabel.textColor = UIColor.whiteColor()
        validatingLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 30)
        
        loadingView.addSubview(validatingLabel)
        
        navigationController?.view.addSubview(loadingView)
        
        return loadingView
    }
    
    func showAlert(title: String, message: String) -> Void {
        if (NSProcessInfo.instancesRespondToSelector("isOperatingSystemAtLeastVersion:")) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(alertAction)
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    @IBAction func codeInputChanged(sender: UITextField) {
        if codeInput.text.utf16Count == 6 {
            let loadingView = showLoading()
            codeInput.resignFirstResponder()
            PFUser.logInWithUsernameInBackground(phone, password: codeInput.text, block: { (user: PFUser!, error: NSError!) -> Void in
                if error == nil {
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = mainStoryboard.instantiateInitialViewController() as UIViewController
                    loadingView.removeFromSuperview()
                    UIApplication.sharedApplication().keyWindow?.rootViewController = initialViewController
                    let currentUser = PFUser.currentUser()
                    currentUser.setValue(true, forKey: "verified")
                    currentUser.saveEventually()
                } else {
                    loadingView.removeFromSuperview()
                    self.codeInput.becomeFirstResponder()
                    
                    if error.code == kPFErrorObjectNotFound {
                        self.showAlert("Incorrect Code", message: "Please verify your 6 digit code.")
                    } else if error.code == kPFErrorConnectionFailed {
                        self.showAlert("Connection failed", message: "Please check your connection and try again later.")
                    } else {
                        self.showAlert("Network Error", message: "Please try again later.")
                        if let errorString = error.userInfo?["error"] as? NSString {
                            NSLog(errorString)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func resendSMS() {
        if let userPhoneNumber = phone {
            PFCloud.callFunctionInBackground("getVerificationNumber", withParameters: ["phone": userPhoneNumber])
            startCountdown()
        }
    }

}
