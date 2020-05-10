import Cocoa
import AppKit
import PopoverResize

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    typealias SM = SettingsManager
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var popover: PopoverResize!
    var mainMenu = NSMenu()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        firstLaunch()
        
        let min = NSSize(width: CGFloat(860), height: CGFloat(525))
        let max = NSSize(width: CGFloat(1000), height: CGFloat(1000))
        popover = PopoverResize(min: min, max: max)
        popover.setContentViewController(PopoverVC.getPopoverVC(), initialSize: min)
        
        statusItem.button!.image?.isTemplate = true
        statusItem.button!.image = #imageLiteral(resourceName: "normal-icon")
        statusItem.button!.imageScaling = .scaleProportionallyUpOrDown
        statusItem.button!.action = #selector(self.clickHandler(sender:))
        statusItem.button!.sendAction(on: [.leftMouseUp, .rightMouseUp, .mouseEntered, .leftMouseDragged, .mouseMoved, .otherMouseDragged])
        statusItem.button!.menu = mainMenu
        
        statusItem.button?.window!.registerForDraggedTypes([.fileURL])
        statusItem.button?.window?.delegate = self
        
        popover.animates = true
        popover.resized {(size: NSSize) in
            print("Popover resized: \(size)")
        }
        
        popover.contentViewController?.loadView()
        
        popover.behavior = (SM.get(.enableAutoClose) == false ? .applicationDefined : .transient)
        
    }
    
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .link
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        showPopover()
        
        return true
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
        case .leftMouseDragged, .otherMouseDragged:
            print("Draged")
            showPopover()
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
            //popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    
    @objc func closePopover() {
        popover.performClose(Any?.self)
    }
    
}
