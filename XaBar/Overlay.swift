//
//  Overlay.swift
//  XaBar
//
//  Created by Jan Kožnárek on 09/06/2019.
//  Copyright © 2019 Jan Kožnárek. All rights reserved.
//

import Cocoa
import EasyPeasy


class Overlay: NSView {
    
    private let size: CGRect!
    private let HEIGHT_OF_POPOVER_HEADER: CGFloat = 20
    let overlayIndicator = NSProgressIndicator()

    init(targetView: NSView) {
        self.size = CGRect(x: 0, y: -HEIGHT_OF_POPOVER_HEADER, width: targetView.bounds.width, height: targetView.bounds.height)
        super.init(frame: size)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(size)

        self.addSubview(overlayIndicator)
        
        overlayIndicator.style = .spinning
        overlayIndicator.controlSize = .regular
        overlayIndicator.isDisplayedWhenStopped = false
        overlayIndicator.appearance = NSAppearance(named: NSAppearance.Name.aqua)
        
        
        overlayIndicator.easy.layout(
            CenterX(),
            CenterY()
        )
        
        let layer = CALayer()
        layer.backgroundColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.7505226673)
        layer.frame = self.size
        
        self.layer = layer
    }
    
    public func startLoading() {
        self.isHidden = false
        overlayIndicator.startAnimation(Any?.self)
    }
    
    public func stopLoading() {
        self.isHidden = true
        overlayIndicator.stopAnimation(Any?.self)
    }
    

    
}
