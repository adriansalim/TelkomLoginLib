//
//  TelkomLoginController.swift
//  TelkomLogin
//
//  Created by adrian.salim on 29/03/22.
//

import UIKit
import WebKit

public protocol TelkomLoginDelegate {
    func urlStartLoad(url: String?)
    func urlEndLoad(url: String?)
}

public class TelkomLoginController: UIViewController {
    public var delegate: TelkomLoginDelegate?
    public var url: String = ""
    public var clientId: String = ""
    public var appsName: String = ""
    public var redirectUri: String = ""
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.removeCache()
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        
        let webview = WKWebView(frame: CGRect(x: 0, y: topPadding, width: self.view.frame.width, height: self.view.frame.height))
        let link = URL(string:self.url)!
        var request = URLRequest(url: link)
        request.httpMethod = "POST"
        let params = [
            "client_id": self.clientId,
            "apps_name": self.appsName,
            "redirect_uri": self.redirectUri
        ]
        let postString = self.getPostString(params: params)
        request.httpBody = postString.data(using: .utf8)
        webview.load(request)
        webview.navigationDelegate = self
        
        self.view.addSubview(webview)
        self.view.backgroundColor = .white
    }
    
    func removeCache() {
        // Cache
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records.filter { $0.displayName.contains("indi") },
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
                URLCache.shared.removeAllCachedResponses()
            }
        }
    }
    
    func getPostString(params: [String: String]) -> String {
        var data = [String]()
        for(key, value) in params {
            data.append(key + "=\(value)")
        }
        return data.map { String($0)}.joined(separator: "&")
    }
}

extension TelkomLoginController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let urlNow = webView.url?.absoluteString ?? ""
        if urlNow.contains(self.redirectUri) {
            self.delegate?.urlStartLoad(url: urlNow)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let urlNow = webView.url?.absoluteString ?? ""
        self.delegate?.urlEndLoad(url: urlNow)
    }
}
