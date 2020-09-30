import AppKit
import WebKit
import EasyPeasy
import HotKey

class PopoverVC: CoreVC, NSUserNotificationCenterDelegate {
    
    typealias SM = SettingsManager
    
    @IBOutlet var mainMenu: NSMenu!
    @IBOutlet var webView: WebViewController!
    
    var actualTitle: String = ""
    let notification = NSUserNotification()
    let notificationCenter = NSUserNotificationCenter.default
    var titleMessage: String = ""
    var message: String = ""
    var contactPhotoUrl: String = ""
    var contactUrl: String = ""
    
    @IBOutlet var modeSwitch: NSMenuItem!
    @IBOutlet var incognitoIndicator: NSTextField!
    
    let togglePopoverHotKey = HotKey(key: .x, modifiers: [.command, .option])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        togglePopoverHotKey.keyDownHandler = {
            self.delegate.togglePopover()
        }
        
        delegate.mainMenu = mainMenu
        notificationCenter.delegate = self
        
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.checkTitle), userInfo: nil, repeats: true)
        
        setupWebView()
        prepareView()
        
    }
    
    
    private func prepareView() {
        
        let incognitoState = SM.get(.isIncognitoEnable)
        modeSwitch.state = (incognitoState == false ? .off : .on)
        webView.setMode(incognitoState == false ? .normal : .incognito)
        incognitoIndicator.isHidden = !incognitoState
        
    }
    
    override func viewDidAppear() {
        
        self.view.window?.isOpaque = false
        self.view.window?.makeKeyAndOrderFront(nil)
        
        self.webView.window?.makeKey()
        setCursor()
        
    }
    
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        //This function will run after you click on notification
        delegate.showPopover()
        notificationCenter.removeDeliveredNotification(notification)
    }
    
    
    @IBAction func reload(_ sender: NSButton) {
        performSelector(onMainThread: #selector(reloadOutside), with: self, waitUntilDone: true)
    }
    
    
    @IBAction func menuReload(_ sender: NSMenuItem) {
        performSelector(onMainThread: #selector(reloadOutside), with: self, waitUntilDone: true)
    }
    
    
    @IBAction func closeButton(_ sender: NSButton) {
        delegate.closePopover()
    }
    
    
    override func keyDown(with event: NSEvent) {
        
        let key = event.keyCode
        
        if (key == 53) {
            delegate.closePopover()
        }
        
    }
    
    
    @IBAction func quitButton(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        handleOverlay()
        
    }
    
}


//MARK: HELPER METHODS
extension PopoverVC {
    
    @objc func reloadOutside() {
        self.webView.load(URLRequest(url: URL(string: "https://messenger.com")!))
    }
    
    
    @IBAction func incognitoModeToggle(_ sender: NSMenuItem) {
        
        sender.state = (sender.state == .off ? .on : .off)
        
        SM.set(.isIncognitoEnable, value: (sender.state == .off ? false : true))
        
        if sender.state == .on {
            webView.setMode(.incognito)
            incognitoIndicator.isHidden = false
        } else if sender.state == .off {
            webView.setMode(.normal)
            incognitoIndicator.isHidden = true
        }
        
        print("Current mode: \(webView.actualMode)")
        
    }
    
    
    private func setCursor() {
        
        self.webView.evaluateJavaScript("setTimeout(function() { document.querySelector('._5rpu').focus() }, 0);") { (string, error) in }
        
    }
    
    
    private func handleOverlay() {
        
        if webView.isLoading == true {
            overlay.startLoading()
        } else {
            overlay.stopLoading()
        }
        
    }
    
}


//MARK: SETUP METHODS
extension PopoverVC {
    
    private func setupWebView() {
        
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: "https://messenger.com")!))
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options:.new, context: nil)
        
    }
    
}


//MARK: WKWebView METHODS
extension PopoverVC: WKNavigationDelegate {
    
    static func getPopoverVC() -> PopoverVC {
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        guard let vc = storyboard.instantiateController(withIdentifier: "PopoverVC") as? PopoverVC else {
            fatalError("Why i cant find MainViewController? - Check Main.storyboard")
        }
        
        return vc
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        //        if url?.pathExtension
        
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url {
                //Redirected to browser. No need to open it locally
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                
                // uprava pro dvou faktor
                if url.absoluteString.contains("facebook.com") {
                    decisionHandler(.allow)
                }
                
            } else {
                //Open it locally
                decisionHandler(.allow)
            }
        } else {
            //not a user click
            decisionHandler(.allow)
        }
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let css = "body{filter:invert(100%) hue-rotate(180deg)!important}[style^=background-image],img{filter:brightness(75%) invert(100%) hue-rotate(180deg)!important}[style^=background-image] *,img *{filter:none!important}"
        
        
        let css2 = "body{color:#cecece}a{color:#0084ff}h1,h2,h3,h4,h5,h6{color:#cecece}._4sp8{background-color:#1e1e1e}._36ic,._5742{background-color:#1e1e1e;border-bottom-color:#3e3e3e}._17w2{color:#cecece}._2v6o{color:#9e9e9e}._6ynl{box-shadow:0 1px 2px 0 rgba(0,0,0,.3)}._6-xo{color:#cecece}._6-xp,._6ymu{background-color:rgba(255,255,255,.04)}._6-xp path,._6ymu path{fill:#cecece}._6zkf{color:#cecece}._1ht3 ._1ht7._6zkh{color:#999}._8102 g,._8102._4-0i{fill:rgba(255,255,255,.34)}._53ik ._558b+._53io,._53il ._558b+._53io{-webkit-filter:brightness(.12);filter:brightness(.12)}._1ht6{color:#cecece}._1ht7{color:#9e9e9e}._1ht3 ._1htf{color:#cecece}._5iwm._6-_b ._58al{background-color:#2e2e2e;background-color:rgba(255,255,255,.04)}::placeholder{color:#7e7e7e!important;opacity:1!important}._225b._6ybl{color:rgba(255,255,255,.34)}._364g{color:#cecece}._225b{color:#9e9e9e}._4g0h{color:#cecece}._225b{background-color:#2e2e2e}._1ht1._1ht2 ._6zkc{background-color:#2e2e2e;background-color:rgba(255,255,255,.05)}._1u5d{background-color:#1e1e1e}._57pl{border-right-color:#1e1e1e}._57pm{border-bottom-color:#1e1e1e}._7q1j div[style=\"border: 2px solid white; height: 33px; width: 33px;\"]{border-color:transparent!important}._3eur._6ybk,._3eur._6ybk a{color:#cecece}._1lj0._6ybm{color:rgba(255,255,255,.34)}#bell path,#caution-triangle path,#magnifying-glass path,#message-cross path,#minus-circle path,#pencil-underline path{fill:#cecece}._7ht_{color:rgba(255,255,255,.4)}._3eus{color:#9e9e9e}._4_j5{border-left-color:#3e3e3e}._1li-{border-color:#3e3e3e}._4_j5{background-color:#1e1e1e}._1lj0{color:#aeaeae}._3szq{color:#cecece}._3x6v{color:#9e9e9e}._3m31:nth-of-type(3n+1){border-right-color:#1e1e1e}._3m31:nth-of-type(3n+2){border-left-color:#1e1e1e;border-right-color:#1e1e1e}._3m31:nth-of-type(3n+3){border-left-color:#1e1e1e}._2jnv{color:#cecece}._4rph ._4rpj{color:#cecece}._1t2u{border-color:#4e4e4e}._497p{color:#9e9e9e}._5irm._7mkm{background-color:#1e1e1e;background-color:#1e1e1e;border-top-color:#3e3e3e}._7kpk{background-color:rgba(255,255,255,.05)}._kmc._7kpg ._1p1t{color:rgba(206,206,206,.5);-webkit-text-fill-color:rgba(206,206,206,.5)}._hh7{background-color:#363636;color:#cecece}._hh7 a{color:#cecece}._2y8z{color:#9e9e9e}._14-7 ._58ah ._58al{color:#cecece}._2y8_{background-color:#1e1e1e}._ih3{color:#aeaeae}._7mki{-webkit-filter:invert(1);background:0 0}._2wy4{color:#9e9e9e}._2-x5{background-color:#1e1e1e}._2zl5{border-color:#3e3e3e}._1hbw ._5pd7{background-color:#cecece}.clearfix{background-color:#1e1e1e}._13iv ._1k1p:hover div{background-color:#2e2e2e!important}._hh7._6ybn._2f5r{background-color:transparent!important}._2poz._ui9._576q svg>rect[fill=white]{fill:#1e1e1e}._67tu{border-color:#3e3e3e}._2rvp._7i2l g,._3-wv._7i2n path,._5zvq._7i2o path{fill:rgba(255,255,255,.34)}._18p0,._5i_d{border-color:#3e3e3e}._5i_d .__6k{color:#cecece}._5i_d .__6l{color:#cecece}._5i_d .__6m{color:#aeaeae}._hh7>span>a:hover{background-color:transparent}._2f5n{background-color:#1e1e1e;border-color:#3e3e3e}.__6k,.__6l{color:#cecece}._33p7{background-color:rgba(30,30,30,.95);border-bottom-color:#3e3e3e}._llq{color:#cecece}._1n-e{color:#9e9e9e}._4kf5,._aou{background-color:#1e1e1e;box-shadow:0 2px 4px rgba(0,0,0,.7)}._koh{border-color:#3e3e3e}._3s-4{background:#1e1e1e}._2c9i ._19jt{color:#cecece}._3q34{color:#cecece}._3q35{color:#9e9e9e}._30e7 ._5j5f{border-color:#2e2e2e}._4eby{background-color:#1e1e1e}._51l0 .uiInputLabel .__rm+.uiInputLabelLabel{color:#cecece}._2c9g ._4ebz{color:#cecece}._4jgp ._4jgu{background-color:#1e1e1e}._2c9i ._4ebz,._4jgt{border-bottom-color:#3e3e3e}._5qsj,._5rh4{color:#aeaeae}._5l38{border-top-color:#2e2e2e}._1py_._1rb6{background:#1e1e1e!important}._3lxv{background:#1e1e1e!important;border-bottom-color:#3e3e3e!important}._3lxw{color:#cecece}._4iyh._2pia._2pi4,._59ry{border-color:#3e3e3e!important}._6s-6{background-color:#262626;border-color:#3e3e3e}._6s-6 span{color:#fff!important}._6s-6:not(._7nq7){outline-color:transparent}._558b ._54ng{background-color:#1e1e1e;border-color:#464646}._2i-c ._54nf ._54nh{color:#cecece}._2i-c ._54ne,._2i-c ._54ne ._54nc,._2i-c ._54ne ._54nh{color:#fff}._374c{color:#9e9e9e}._374b{border-bottom-color:#3e3e3e}._59s7{background:0 0}._4ng2{color:#cecece}._6cs7{color:rgba(206,206,206,.6)}._2poo{background-position:0 -120px}._2pop{background-position:0 -103px}._9jo li.navSubmenu a{color:#cecece}._558b ._54nc{border-color:transparent}._558b ._54ak{border-color:#2e2e2e}._3nta{background-color:#1e1e1e}._3nta:hover{background-color:#2f2f2f}._2n3u,._38wl,._4dx4,._4dx5,._4x79,._4x7b,._4x7m,._58al{color:#cecece}._4sp8{background-color:#1e1e1e}"
        
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css2)'; document.head.appendChild(style);"
        
        webView.evaluateJavaScript(js) { (response, error) in
            
        }
        
    }
    
    
    @objc func checkTitle(){
        
        //TODO: Please rename "string" vars to something that describes content of these variables
        
        if webView.title!.contains("Messenger") && webView.title!.contains("(") && webView.title!.contains(")") {
            if webView.title?.lowercased() != actualTitle.lowercased() {
                self.webView.evaluateJavaScript("document.querySelector('div[role=\"navigation\"] li._1ht1._1ht3 div[role=\"gridcell\"] div._1qt5 span._1ht6').innerText") { (string, error) in
                    self.titleMessage = String(describing: string ?? "null")
                    self.webView.evaluateJavaScript("document.querySelector('div[role=\"navigation\"] li._1ht1._1ht3 div[role=\"gridcell\"] .img').src") { (string, error) in
                        self.contactPhotoUrl = String(describing: string ?? "")
                    }
                    self.webView.evaluateJavaScript("document.querySelector('div[role=\"navigation\"] li._1ht1._1ht3 div[role=\"gridcell\"] a').href") { (string, error) in
                        self.contactUrl = String(describing: string ?? "")
                    }
                    self.webView.evaluateJavaScript("document.querySelector('div[role=\"navigation\"] li._1ht1._1ht3 div[role=\"gridcell\"] div._1qt5 span._1htf span').innerText") { (string, error) in
                        self.message = String(describing: string ?? "New message")
                        if self.delegate.popover.isShown == false && self.message != "null" {
                            self.notification.title = self.titleMessage
                            self.notification.subtitle = self.message
                            self.notification.informativeText = self.contactUrl
                            self.notification.soundName = NSUserNotificationDefaultSoundName
                            self.notification.contentImage = nil
                            self.notification.hasActionButton = true
                            self.notification.actionButtonTitle = "Open"
                            
                            
                            if self.contactPhotoUrl != "" {
                                self.notification.contentImage = NSImage(contentsOf: URL(string: self.contactPhotoUrl)!)!
                            }
                            self.delegate.statusItem.button?.image = #imageLiteral(resourceName: "notification-icon")
                            self.notificationCenter.deliver(self.notification)
                        }
                        
                    }
                }
            }
        }
        
        if webView.title == "Messenger" {
            self.delegate.statusItem.button?.image = #imageLiteral(resourceName: "normal-icon")
        }
        
        if (webView.title?.contains("Messenger"))! {
            actualTitle = webView.title!
        }
    }
    
}


