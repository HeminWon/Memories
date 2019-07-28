//
//  WebHuntView.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/2.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import ScreenSaver
import WebKit
import RxSwift

class WebHuntView: ScreenSaverView {
    
    var preferencesWindowController: PreferencesWindowController?
    var intervalTimer: Timer = Timer()
    
    static var webs: [HunterWeb] = [HunterWeb]()
    
    static var previewView: WebHuntView?
    
    let disposeBag = DisposeBag()
    
    static var sharingWebs: Bool {
        let preferences = Preferences.sharedInstance
        return (preferences.newViewingMode == Preferences.NewViewingMode.mirrored.rawValue) ||
            (preferences.newViewingMode == Preferences.NewViewingMode.spanned.rawValue)
    }
    
    struct Static {
        static let instance: HunterWeb = HunterWeb(url: "", remark: "", group: "")
        static var _web: HunterWeb?
        static var web: HunterWeb {
            if let activeWeb = _web {
                return activeWeb
            }
            _web = ManifestLoader.instance.randomWeb(excluding: WebHuntView.webs)
            return _web!
        }
    }
    
    class var sharedWeb: HunterWeb {
        get {
            return Static.web
        }
        set {
            Static._web = newValue
        }
    }
    
    lazy var webViewController: WHWebViewController = {
        let webViewController = WHWebViewController()
        return webViewController
    }()
    
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
    
    func setupWebView() {
        self.webViewController.webVIew.frame = self.bounds
        self.addSubview(self.webViewController.webVIew)
    }
    
    func updateURL() {
        let wkWebView = self.webViewController.webVIew
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

        let subject = PublishSubject<WebHuntView>()
        if WebHuntView.sharingWebs {
            WebHuntViewManager.manager.subjects.append(subject)
        }
        
        debugLog("timeExhibition: \(web.timeInterval) \(web.timeExhibition) \(web.url)")
        if web.timeExhibition > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(web.timeExhibition)) {
                debugLog("timeExhibition: >>> \(web.url)")
                
                if WebHuntView.sharingWebs {
                    if !WebHuntViewManager.manager.ziping {
                        WebHuntViewManager.manager.ziping = true
                        
                        Observable.zip(WebHuntViewManager.manager.subjects).subscribe { (event) in
                            WebHuntView.Static._web = nil
                            WebHuntViewManager.manager.subjects.removeAll()
                            //
                            if let webHuntViews:[WebHuntView] = event.element {
                                for webHuntView in webHuntViews {
                                    webHuntView.updateURL()
                                }
                            }
                            WebHuntViewManager.manager.ziping = false
                            }.disposed(by: self.disposeBag)
                    }
                    subject.onNext(self)
                } else {
                    self.updateURL()
                }
            }
        }
        
        WebHuntView.webs.append(web)
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(web.url)")
        let url = URL(string: web.url)!
        
        let requ = URLRequest.init(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        if (url.scheme == "http" || url.scheme == "https") {
            debugLog("timeInterval: \(web.timeInterval) \(web.timeExhibition) \(web.url)")
            intervalTimer.invalidate()
            if web.timeInterval > 0 {
                intervalTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(web.timeInterval), repeats: true) { (timer) in
                    debugLog("timeInterval: --- \(timer) \(web.url)")
                    wkWebView.load(requ)
                }
            } else {
                wkWebView.load(requ)
            }
        }
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

class WebHuntViewManager {
    static let manager:WebHuntViewManager = WebHuntViewManager()
    var ziping = false
    var subjects = [PublishSubject<WebHuntView>]()
}
