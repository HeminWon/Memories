//
//  AppDelegate.swift
//  Memories
//
//  Created by Hemin Won on 2019/5/3.
//  Copyright © 2019 Hemin Won. All rights reserved.
//

import Cocoa
import ScreenSaver

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var windowController: MEMWindowController = {
        let windowController = MEMWindowController()
        return windowController
    }()

    var view: ScreenSaverView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.windowController.showWindow(self)
        self.windowController.memWindow?.delegate = self
        
        setupAndStartAnimation()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func setupAndStartAnimation() {
        let saverName = UserDefaults.standard.string(forKey: "saver") ?? "WebHunt"
        
        guard let saverBundle = loadSaverBundle(saverName) else {
            print("Can't find or load bundle for saver named \(saverName).")
            return
        }
        
        let saverClass = saverBundle.principalClass! as! ScreenSaverView.Type

        let window = self.windowController.memWindow!
        
        view = saverClass.init(frame: window.contentView!.frame, isPreview: false)
        view.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]

        window.title = view.className
        window.contentView!.autoresizesSubviews = true
        window.contentView!.addSubview(view)
        
        view.startAnimation()
        
        window.beginSheet(view.configureSheet ?? window, completionHandler: nil)
    }
    
    private func loadSaverBundle(_ name: String) -> Bundle? {
        let myBundle = Bundle(for: AppDelegate.self)
        let saverBundleURL = myBundle.bundleURL.deletingLastPathComponent().appendingPathComponent("\(name).saver", isDirectory: true)
        let saverBundle = Bundle(url: saverBundleURL)
        saverBundle?.load()
        return saverBundle
    }
    
    func restartAnimation() {
        stopAnimation()
        view.startAnimation()
    }
    
    func stopAnimation() {
        if view.isAnimating {
            view.stopAnimation()
        }
    }
}

extension AppDelegate: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(windowController)
    }
    
    func windowDidResize(_ notification: Notification) {
        //
    }
    
    func windowWillBeginSheet(_ notification: Notification) {
        stopAnimation()
    }
    
    func windowDidEndSheet(_ notification: Notification) {
        restartAnimation()
    }
    
    
}
