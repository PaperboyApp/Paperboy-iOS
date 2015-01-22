//
//  WebViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/15/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var requestURL: NSURL? = NSURL(string: "")
    let webNavBarView = NSBundle.mainBundle().loadNibNamed("WebNavigationBarView", owner: nil, options: nil)[0] as WebNavigationBarView

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
        if requestURL != nil {
            webView.loadRequest(NSURLRequest(URL: requestURL!))
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "close")
        
        self.navigationController?.navigationBar.addSubview(webNavBarView)
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webNavBarView.titleLabel.text = webView.stringByEvaluatingJavaScriptFromString("document.title")
        webNavBarView.urlLabel.text = webView.stringByEvaluatingJavaScriptFromString("window.location.host")
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        webNavBarView.titleLabel.text = "Loading ..."
        webNavBarView.urlLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
