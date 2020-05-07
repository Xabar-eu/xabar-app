import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    var mainMenu = NSMenu()
    var mainViewController: PopoverVC!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        
        mainViewController = PopoverVC()        
        statusItem.button!.image = #imageLiteral(resourceName: "normal-icon")
        statusItem.button!.imageScaling = .scaleProportionallyUpOrDown
        statusItem.button!.action = #selector(self.clickHandler(sender:))
        statusItem.button!.sendAction(on: [.leftMouseUp, .rightMouseUp, .mouseEntered, .leftMouseDragged, .mouseMoved, .any, .appKitDefined])
        statusItem.button!.menu = mainMenu
        
        popover.contentViewController = PopoverVC.getPopoverVC()
        popover.contentViewController?.loadView()
        
        //zavření po kliknutí jinam
        //popover.behavior = .transient
    }
    
    
    //click on the menubar icon
    @objc func clickHandler(sender: NSStatusItem) {
        
        let event = NSApp.currentEvent!
        
        print(event.type.rawValue)
        
        if event.type == NSEvent.EventType.rightMouseUp {
            //right click
            statusItem.button!.menu = mainMenu
            statusItem.popUpMenu(statusItem.button!.menu!)
            
        } else if event.type == .leftMouseUp {
            //left click
            
            togglePopover()
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
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    @objc func closePopover() {
        popover.performClose(Any?.self)
    }
    
}
