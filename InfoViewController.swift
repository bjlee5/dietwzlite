//
//  InfoViewController.swift
//  Moblzip
//
//  Copyright (c) 2017 Moblzip LLC. All rights reserved.
//

import UIKit
import MBProgressHUD
import WebKit
class InfoViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var infoItem: InfoItem.Data?
    var recipe: Recipes?
    @IBOutlet weak var infoTxt: UITextView!
    //@IBOutlet weak var infoWeb: UIWebView!//Commented out UIWebView and also removed from Main.storyBoard
    var infoWeb: WKWebView!//Declare WKWebView from code as we can't declare it in Main.storyBoard
    
    
    // MARK: - View Cycle
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
        configWithInfo()
     
    
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Actions
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - UIWKViewDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let newURL = navigationAction.request.url,
                let host = newURL.host , !host.hasPrefix("https://www.dietwz.com") &&
                UIApplication.shared.canOpenURL(newURL) &&
                UIApplication.shared.openURL(newURL) {
                //print(newURL)
                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
            //print("not a user click")
            decisionHandler(.allow)
        }
    }
    func didFinishNavigation(webView: WKWebView) {
        let zoom = webView.bounds.size.width / webView.scrollView.contentSize.width
        webView.scrollView.setZoomScale(zoom, animated: true)
    }    
    // MARK: - UIWebViewDelegate
    //Replacing UIWebView with WKWebView, so commenting out this section of code.
    /*
     func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
//        NSLog("loading fail: (%@)", error)
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
*/
    
    
    // MARK: - Private
    
    fileprivate func configWithInfo() {
        
        if let recipe = recipe {
            navigationItem.title = "Recipe"
            
            let configuration = WKWebViewConfiguration()
            
            infoWeb = WKWebView(frame: self.view.frame, configuration: configuration)
            infoWeb.contentMode = UIViewContentMode.scaleAspectFit
            infoWeb.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            var infoHTML=recipe.recipeHTML
            //Adjust dynamic HTML
            infoHTML = infoHTML.replacingOccurrences(of: "<html>", with: "<html><head><meta name='viewport' content='initial-scale=1.0' /><style>.clear-area-spacing{margin-top:80px;margin-bottom:100px;}</style></head>")
            
            infoHTML=infoHTML.replacingOccurrences(of:"<div style = 'font-family: ArialMT'>",with:"<body><div style='font-family: ArialMT' class='clear-area-spacing'>")
            
            infoHTML=infoHTML.replacingOccurrences(of:"</div></html>",with:"</div></body></html>")
           
            //infoWeb.loadHTMLString(recipe.recipeHTML, baseURL: nil)//commented out old code
            infoWeb.loadHTMLString(infoHTML, baseURL: nil)
            
            infoWeb.navigationDelegate = self
            self.view.addSubview(infoWeb)
            
        } else if let dataItem = infoItem {
            navigationItem.title = dataItem.displayFormat
            configHTMLFromFile(dataItem.htmlFileNameFormat, type: "html")
        }
    }
        
    fileprivate func configHTMLFromFile(_ filename: String, type: String) {
        infoTxt.isHidden = true
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        /*infoWeb = WKWebView(frame: CGRect(x:15, y:70, width:self.view.bounds.width, height:self.view.bounds.height), configuration: configuration)*/
        
        
        infoWeb = WKWebView(frame: self.view.frame, configuration: configuration)
     
        infoWeb.contentMode = UIViewContentMode.scaleAspectFit
        infoWeb.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        
        infoWeb.isHidden = false
        
        let path = Bundle.main
        let baseURL = URL(fileURLWithPath: path.resourcePath!)
        
        if let filePath = path.path(forResource: filename, ofType: type), let htmlStr = try? String(contentsOf: URL(fileURLWithPath: filePath), encoding: String.Encoding.utf8) {
            
            
            infoWeb.loadHTMLString(htmlStr, baseURL: baseURL)
           
            infoWeb.navigationDelegate = self
            
         
            self.view.addSubview(infoWeb)
            
          
        }
    }
}
