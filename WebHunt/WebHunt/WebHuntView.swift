//
//  WebHuntView.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/2.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import ScreenSaver
import WebKit

class WebHuntView: ScreenSaverView, WKNavigationDelegate {

    var wkWebView: WKWebView?
    
    var preferencesWindowController: PreferencesWindowController?
    
    static var webs: [HunterWeb] = [HunterWeb]()
    
    static var previewView: WebHuntView?
    
    static var sharingWebs: Bool {
        let preferences = Preferences.sharedInstance
        return (preferences.multiMonitorMode == Preferences.MultiMonitorMode.mirrored.rawValue)
    }
    
    class var sharedWeb: HunterWeb {
        struct Static {
            static let instance: HunterWeb = HunterWeb(url: "", description: "", type: "")
            static var _web: HunterWeb?
            static var web: HunterWeb {
                if let activeWeb = _web {
                    return activeWeb
                }

                _web = ManifestLoader.instance.randomWeb(excluding: WebHuntView.webs)
                return _web!
            }
        }
        return Static.web
    }
    
    // MARK: init
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(frame) \(isPreview)")
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(decoder)")
        setup()
    }
    
    deinit {
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
    }
    
    // MARK: Lifecycle stuff
    override func startAnimation() {
        super.startAnimation()
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
    }
    
    // MARK: Private
    func setup(){

        setupWebView()
        
        ManifestLoader.instance.addCallback { _ in
            debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
            self.updateURL()
        }
    }
    
    func createWebView() -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration.init()
        let webView = WKWebView(frame:CGRect.zero, configuration: webViewConfiguration)
        return webView
    }
    
    func setupWebView() {
        if let webView = self.wkWebView {
            debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(webView)")
            return;
        }
        let webViewConfiguration = WKWebViewConfiguration.init()
        let wkWebView = WKWebView.init(frame: self.bounds, configuration: webViewConfiguration)
        wkWebView.isHidden = true
        wkWebView.navigationDelegate = self
        self.wkWebView = wkWebView
        self.addSubview(wkWebView)
    }
    
    func updateURL() {
        guard let wkWebView = self.wkWebView else {
            return;
        }
        wkWebView.stopLoading()
        
        var currentWeb: HunterWeb?
        if WebHuntView.sharingWebs {
            currentWeb = WebHuntView.sharedWeb
        } else {
            currentWeb = ManifestLoader.instance.randomWeb(excluding: WebHuntView.webs)
        }

        guard let web = currentWeb else {
            return
        }
        WebHuntView.webs.append(web)
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(web.url)")
        let url = URL(string: web.url)!
        
        let requ = URLRequest.init(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        if (url.scheme == "http" || url.scheme == "https") {
            wkWebView.load(requ)
        }
    }
    
    // MARK: delegate WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(webView) \(webView.frame) \(webView.isHidden)")
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }
    
    override var configureSheet: NSWindow? {
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
        if let controller = preferencesWindowController {
            return controller.window
        }
        
        let storyboard = NSStoryboard(name: "Preferences", bundle: Bundle.init(for: WebHuntView.self))
        let controller = storyboard.instantiateInitialController() as! NSWindowController
        preferencesWindowController = controller as? PreferencesWindowController
        return controller.window
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
    }
    
    // MARK:
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
