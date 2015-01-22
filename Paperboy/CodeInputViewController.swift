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
    
    @IBAction func codeInputChanged(sender: UITextField) {
        if codeInput.text.utf16Count == 6 {
            PFUser.logInWithUsernameInBackground(phone, password: codeInput.text, block: { (user: PFUser!, error: NSError!) -> Void in
                if error == nil {
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = mainStoryboard.instantiateInitialViewController() as UIViewController
                    self.navigationController?.setViewControllers([initialViewController], animated: true)
                }
            })
        }
    }
    
    @IBAction func resendSMS() {
        if let userPhoneNumber = phone {
            PFCloud.callFunction("getVerificationNumber", withParameters: ["phone": userPhoneNumber])
            startCountdown()
        }
    }

}
