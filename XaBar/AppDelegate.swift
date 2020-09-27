import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    typealias SM = SettingsManager
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    var popover: NSPopover!
    var mainMenu = NSMenu()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        firstLaunch()
        
        preparePopover()
        
        setupStatusItem()
        
    }
    
    
    //click on the menubar icon
    @objc func clickHandler(sender: NSStatusItem) {
        
        let event = NSApp.currentEvent!
        
        switch event.type {
        case .rightMouseUp:
            //right click
            
            statusItem.menu = mainMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
            
            break
        case .leftMouseUp:
            //left click
            togglePopover()
            break
        default:
            ()
        }
        
        
    }
    
    
    private func firstLaunch() {
        
        let KEY = "isFirstStart"
        let isFirstStart: Bool = UserDefaults.standard.bool(forKey: KEY)
        
        if isFirstStart == false {
            SettingsManager.setDefaults()
            UserDefaults.standard.set(true, forKey: KEY)
        }
        
    }
    
    
    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    
    func showPopover() {
        if let button = statusItem.button {
            NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    
    @objc func closePopover() {
        popover.performClose(Any?.self)
    }
    
}


//MARK: SETUP METHODS
extension AppDelegate {
    
    public func preparePopover() {
        
        if popover != nil {
            closePopover()
            popover = nil
        }
        
        let size = NSSize(width: SM.get(.width), height: SM.get(.height))
        
        popover = NSPopover()
        popover.contentViewController = PopoverVC.getPopoverVC()
    
        popover.contentViewController?.loadView()
        
        popover.animates = SM.get(.enableAnimations)
        popover.contentSize = size
        popover.behavior = (SM.get(.enableAutoClose) == false ? .applicationDefined : .transient)
        
    }
    
    
    private func setupStatusItem() {
        
        statusItem.button!.image?.isTemplate = true
        statusItem.button!.image = #imageLiteral(resourceName: "normal-icon")
        statusItem.button!.imageScaling = .scaleProportionallyUpOrDown
        statusItem.button!.action = #selector(self.clickHandler(sender:))
        statusItem.button!.sendAction(on: [.leftMouseUp, .rightMouseUp, .mouseEntered, .leftMouseDragged, .mouseMoved, .otherMouseDragged])
        statusItem.button!.menu = mainMenu
        
        statusItem.button?.window!.registerForDraggedTypes([.fileURL])
        statusItem.button?.window?.delegate = self
        
    }
    
}
