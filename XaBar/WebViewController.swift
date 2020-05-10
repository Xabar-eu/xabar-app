//
//  WebViewController.swift
//  MessengerMenubar2.0
//
//  Created by   on 16/12/2018.
//  Copyright © 2018 Jan Kožnárek. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: WKWebView {
    
    let delegate = NSApplication.shared.delegate as! AppDelegate
    
    var actualMode: BrowserModes = .normal
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.1 Mobile/15E148 Safari/604.1"

        
        // Drawing code here.
    }
    
    override func keyUp(with event: NSEvent) {
        
        let code = event.keyCode
        
        if code == 53 {
            
            delegate.closePopover()
            
        }
        
    }
    
    
    func setMode(_ mode: BrowserModes) {
        
        let rules = """
            [
                {
                    "trigger": {
                        "url-filter": ".*mark_seen.*"
                    },
                    "action": {
                        "type": "block"
                    }
                },
                {
                    "trigger": {
                        "url-filter": ".*typ.*"
                    },
                    "action": {
                        "type": "block"
                    }
                },
                {
                    "trigger": {
                        "url-filter": ".*change.*"
                    },
                    "action": {
                        "type": "block"
                    }
                }
                
            ]
            """
        
        if mode == .incognito {
        
            WKContentRuleListStore.default()
                .compileContentRuleList(forIdentifier: "ContentBlockingRules",
                                        encodedContentRuleList: rules)
                { (contentRuleList, error) in
                    guard let contentRuleList = contentRuleList,
                        error == nil else {
                            return
                    }
                    
                    self.actualMode = .incognito
                    
                    self.configuration.userContentController.add(contentRuleList)
            }
        
        } else {
            
            self.actualMode = .normal
            self.configuration.userContentController.removeAllContentRuleLists()
            
        }
        
        self.reload()
    }
    
    enum BrowserModes {
        case normal
        case incognito
    }
    
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        
         for menuItem in menu.items {
            print(menuItem.identifier)
         }
     }

    @objc func menuClick(sender: AnyObject) {
         if let menuItem = sender as? NSMenuItem {
             Swift.print("Menu \(menuItem.title) clicked")
         }
     }
    
}
