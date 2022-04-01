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
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.removeCache()
        
        let window = UIApplication.shared.keyWindow
        let topPadding = (window?.safeAreaInsets.top ?? 0) + 20
        
        let webview = WKWebView(frame: CGRect(x: 0, y: topPadding + 42, width: self.view.frame.width, height: self.view.frame.height - 40))
        let link = URL(string:"https://my.indihome.co.id/oauth-dev/test/sdk")!
        var request = URLRequest(url: link)
        request.httpMethod = "POST"
        let params = [
            "client_id": "oT8cUbus-Vxfv-yC3c-oBvbvAsA",
            "apps_name": "apps-indistorage-key",
            "redirect_uri": "https://page.cloudstorage.co.id/auth"
        ]
        let postString = self.getPostString(params: params)
        request.httpBody = postString.data(using: .utf8)
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
        self.view.backgroundColor = .white
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
        self.delegate?.urlStartLoad(url: urlNow)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let urlNow = webView.url?.absoluteString ?? ""
        self.delegate?.urlEndLoad(url: urlNow)
    }
}
