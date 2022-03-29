//
//  TelkomLoginController.swift
//  TelkomLogin
//
//  Created by adrian.salim on 29/03/22.
//

import UIKit
import WebKit

public class TelkomLoginController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.removeCache()
        
        let window = UIApplication.shared.keyWindow
        let topPadding = (window?.safeAreaInsets.top ?? 0) + 20
        
        let webview = WKWebView(frame: CGRect(x: 0, y: topPadding + 42, width: self.view.frame.width, height: self.view.frame.height - 40))
        let link = URL(string:"https://my.indihome.co.id/oauth")!
        let request = URLRequest(url: link)
        webview.load(request)
        webview.navigationDelegate = self
        
        let viewTop = UIView(frame: CGRect(x: 0, y: topPadding , width: self.view.frame.width, height: 40))
        viewTop.backgroundColor = .white
        
        let viewLine = UIView(frame: CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1))
        viewLine.backgroundColor = .gray
        
        if #available(iOS 13.0, *) {
            let backButton = UIButton(frame: CGRect(x: 10, y: 5, width: 30, height: 30))
            backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
            backButton.tintColor = .black
            backButton.imageView?.contentMode = .scaleAspectFit
            backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            viewTop.addSubview(backButton)
        } else {
            let backButton = UIButton(frame: CGRect(x: 0, y: 5, width: 50, height: 30))
            backButton.setTitle("←", for: .normal)
            backButton.setTitleColor(.black, for: .normal)
            backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            viewTop.addSubview(backButton)
        }
        
        viewTop.addSubview(viewLine)
        self.view.addSubview(viewTop)
        self.view.addSubview(webview)
    }
    
    public func getToken() -> String {
        return UserDefaults.standard.string(forKey: "currentTelkomUrl") ?? ""
    }
    
    @objc func backAction(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func removeCache() {
        // Cache
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records.filter { $0.displayName.contains("facebook") },
                completionHandler: {}
            )
        }
        
        // Cookies
        if #available(iOS 9.0, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("error")
                URLCache.shared.removeAllCachedResponses()
            }
        }
              
    }
}

extension TelkomLoginController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let urlNow = webView.url?.absoluteString ?? ""
        UserDefaults.standard.set(urlNow, forKey: "currentTelkomUrl")
        print(UserDefaults.standard.string(forKey: "currentTelkomUrl") ?? "")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let urlNow = webView.url?.absoluteString ?? ""
        UserDefaults.standard.set(urlNow, forKey: "currentTelkomUrl")
        print(UserDefaults.standard.string(forKey: "currentTelkomUrl") ?? "")
    }
}
