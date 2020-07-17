//
//  WrappedWKWebView.swift
//
//  Created by Zhengqian Kuang on 2020-06-26.
//  Copyright © 2019 Zhengqian Kuang. All rights reserved.
//

import SwiftUI
import UIKit
import WebKit

// For your convenience to add this file to your Swift Package, all the types are declared "public" when necessary.

public enum WrappedWKWebViewEvent: String {
    case textClickHandler
}

public protocol WrappedWKWebViewEventDelegate {
    func didHappen(event: WrappedWKWebViewEvent, info: Any?)
}

public extension WrappedWKWebViewEventDelegate {
    func didHappen(event: WrappedWKWebViewEvent, info: Any?) {
        //
    }
}

// Ref.
//  https://medium.com/john-lewis-software-engineering/ios-wkwebview-communication-using-javascript-and-swift-ee077e0127eb
//  https://www.hackingwithswift.com/quick-start/swiftui/how-to-wrap-a-custom-uiview-for-swiftui
//  https://www.hackingwithswift.com/articles/112/the-ultimate-guide-to-wkwebview

public struct WrappedWKWebView: UIViewRepresentable {
    let postMessageHandlers: [WrappedWKWebViewEvent]?
    let wkWebViewWrapper = WKWebViewWrapper()
    let customDelegate: WrappedWKWebViewEventDelegate?
    
    public init(postMessageHandlers: [WrappedWKWebViewEvent]? = nil, customDelegate: WrappedWKWebViewEventDelegate? = nil) {
        self.postMessageHandlers = postMessageHandlers
        wkWebViewWrapper.createWKWebView(postMessagehandlers: postMessageHandlers, customDelegate: customDelegate)
        self.customDelegate = customDelegate
    }
    
    public func makeUIView(context: UIViewRepresentableContext<WrappedWKWebView>) -> WKWebView {
        return wkWebViewWrapper.wrappedValue(postMessageHandlers: postMessageHandlers, customDelegate: customDelegate)
    }
    
    public func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WrappedWKWebView>) {
        //
    }
    
    @discardableResult public func load(urlString: String) -> Self {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            wkWebViewWrapper.wrappedValue().load(request)
        }
        return self
    }
    
    /**
     * loadFile(resource: "index", ext: "html") - to load index.html
     */
    @discardableResult public func loadFile(resource: String? = nil, ext: String? = nil) -> Self {
        if let url = Bundle.main.url(forResource: resource, withExtension: ext) {
            // url.deletingLastPathComponent() part tells WebKit it can read from the directory that contains help.html – that’s a good place to put any assets such as images, JavaScript, or CSS.
            wkWebViewWrapper.wrappedValue().loadFileURL(url, allowingReadAccessTo: url.deletingPathExtension())
        }
        return self
    }
    
    @discardableResult public func loadHTMLString(htmlString: String, baseURLString: String? = nil) -> Self {
        var baseURL: URL? = nil
        if let baseURLString = baseURLString {
            guard let url = URL(string: baseURLString) else {
                return self
            }
            baseURL = url
        }
        wkWebViewWrapper.wrappedValue().loadHTMLString(htmlString, baseURL: baseURL)
        return self
    }
    
    @discardableResult public func evaluateJavaScript(javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)?) -> Self {
        wkWebViewWrapper.wrappedValue().evaluateJavaScript(javaScriptString) { (result, error) in
            if let completionHandler = completionHandler {
                completionHandler(result, error)
            }
        }
        return self
        
        // e.g.
        // if you had a page that contained <div id="username">@twostraws</div>,
        // you would use "document.getElementById('username').innerText" as javaScriptString
        // and the result would be "@twostraws"
    }
    
    public func backList() -> [WKBackForwardListItem] {
        return wkWebViewWrapper.wrappedValue().backForwardList.backList
    }
    
    public func forwardList() -> [WKBackForwardListItem] {
        return wkWebViewWrapper.wrappedValue().backForwardList.forwardList
    }
    
    @discardableResult public func handleCookiesExample() -> Self {
        // As an example, this code loops over all cookies, and when it finds one called “authentication” deletes it – all other cookies are just printed out
        wkWebViewWrapper.wrappedValue().configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.name == "authentication" {
                    self.wkWebViewWrapper.wrappedValue().configuration.websiteDataStore.httpCookieStore.delete(cookie)
                } else {
                    print("\(cookie.name) is set to \(cookie.value)")
                }
            }
        }
        return self
    }
    
    @discardableResult public func takeSnapshot(rect: CGRect, completionHandler: @escaping (UIImage?, Error?) -> Void) -> Self {
        let config = WKSnapshotConfiguration()
        config.rect = rect
        wkWebViewWrapper.wrappedValue().takeSnapshot(with: config) { (image, error) in
            completionHandler(image, error)
        }
        return self
    }

    class WKWebViewWrapper: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        private var wkWebView: WKWebView? = nil
        private var customDelegate: WrappedWKWebViewEventDelegate? = nil
        
        @discardableResult func createWKWebView(postMessagehandlers: [WrappedWKWebViewEvent]? = nil, customDelegate: WrappedWKWebViewEventDelegate? = nil) -> WKWebView {
            let config = WKWebViewConfiguration()
            // config.preferences.javaScriptEnabled = true
            // config.dataDetectorTypes = [.address, .calendarEvent, .flightNumber, .link, .lookupSuggestion, .phoneNumber, .trackingNumber]
            // wkWebView = WKWebView(frame: .zero, configuration: config)
            if let postMessagehandlers = postMessagehandlers {
                for postMessagehandler in postMessagehandlers {
                    config.userContentController.add(self, name: postMessagehandler.rawValue)
                }
            }
            
            wkWebView = WKWebView(frame: .zero, configuration: config)
            wkWebView?.navigationDelegate = self
            wkWebView?.uiDelegate = self
            
            wkWebView?.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            wkWebView?.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
            
            self.customDelegate = customDelegate
            
            return wkWebView!
        }
        
        func wrappedValue(postMessageHandlers: [WrappedWKWebViewEvent]? = nil, customDelegate: WrappedWKWebViewEventDelegate? = nil) -> WKWebView {
            if wkWebView == nil {
                createWKWebView(postMessagehandlers: postMessageHandlers, customDelegate: customDelegate)
            }
            return wkWebView!
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // if let url = navigationAction.request.url {
                // check url and
                //   decisionHandler(.cancel)
                // to cancel
            // }
            decisionHandler(.allow)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == WrappedWKWebViewEvent.textClickHandler.rawValue {
                guard
                    let body = message.body as? [String: Any],
                    let param1 = body["param1"] as? String
                else {
                    return
                }
                customDelegate?.didHappen(event: .textClickHandler, info: param1)
            }
        }
        
//        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//            // let ac = UIAlertController(title: "Hey, listen!", message: message, preferredStyle: .alert)
//            // ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            // present(ac, animated: true)
//            completionHandler()
//        }
//
//        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
//            // show confirm panel
//            completionHandler(true or false according to the confirm panel)
//        }
//
//        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
//            // show text input panel
//            completionHandler(text according to the input panel)
//        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "estimatedProgress" {
                // print(Float(wkWebView!.estimatedProgress))
            }
            else if keyPath == "title" {
                // if let title = wkWebView?.title {
                    //
                // }
            }
        }
    }
}
