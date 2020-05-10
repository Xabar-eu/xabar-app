//
//  SettingsManager.swift
//  PWGen
//
//  Created by Jan Kožnárek on 28/03/2020.
//  Copyright © 2020 Adbros. All rights reserved.
//

import Foundation


class SettingsManager {
    
    private static var URL: String {
        get {
            return "settings"
        }
    }
    
    
    static func setDefaults() -> Void {
        set(.enableAnimations, value: true)
        set(.isIncognitoEnable, value: false)
        set(.height, value: 525)
        set(.width, value: 860)
        set(.enableAutoClose, value: false)
    }
    
    
    //MARK: GETTERs
    static func get(_ key: Bools) -> Bool {
        return UserDefaults.standard.bool(forKey: "\(SettingsManager.URL)/bools/\(key)")
    }
    
    
    static func get(_ key: Strings) -> String? {
        return UserDefaults.standard.string(forKey: "\(SettingsManager.URL)/strings/\(key)")
    }
    
    
    static func get(_ key: Integers) -> Int {
        return UserDefaults.standard.integer(forKey: "\(SettingsManager.URL)/integers/\(key)")
    }
    
    
    //MARK: SETTERs
    static func set(_ key: Bools, value: Bool) {
        UserDefaults.standard.set(value, forKey: "\(SettingsManager.URL)/bools/\(key)")
    }
    
    
    static func set(_ key: Strings, value: String) {
        UserDefaults.standard.set(value, forKey: "\(SettingsManager.URL)/strings/\(key)")
    }
    
    
    static func set(_ key: Integers, value: Int) {
        UserDefaults.standard.set(value, forKey: "\(SettingsManager.URL)/integers/\(key)")
    }

}


//MARK: ENUMs
extension SettingsManager {
    
    enum Bools {
        case isIncognitoEnable
        case enableAnimations
        case enableAutoClose
    }
    
    
    enum Strings {
        
    }
    
    
    enum Integers {
        case height
        case width
    }
    
}
