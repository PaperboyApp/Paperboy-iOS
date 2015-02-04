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
    var publisherName = ""
    let webNavBarView = NSBundle.mainBundle().loadNibNamed("WebNavigationBarView", owner: nil, options: nil)[0] as WebNavigationBarView

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tracker = GAI.sharedInstance().defaultTracker as GAITracker? {
            tracker.set(kGAIScreenName, value:"Web View")
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "close")
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationController?.navigationBar.addSubview(webNavBarView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
        if let url = requestURL {
            webView.loadRequest(NSURLRequest(URL: url))
            if let stringURL = url.absoluteString {
                PFAnalytics.trackEvent("urlOpen", dimensions:["publisher": publisherName, "url": stringURL])
            }
        }

    }
    
    func close() {
        webNavBarView.removeFromSuperview()
        self.navigationController?.popViewControllerAnimated(true)
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
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        webNavBarView.removeFromSuperview()
    }
}
