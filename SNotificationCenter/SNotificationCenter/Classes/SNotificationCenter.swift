//
//  SNotificationCenter.swift
//  Pods-SNotificationCenter_Example
//
//  Created by steve on 11/04/2018.
//

import Foundation

struct SObserver {
    weak var target: NSObject?
    var sel: Selector?
    var object: NSObject?
}

struct SNotification {
    var observers: Array<SObserver>!
    
    init(_ observers: Array<SObserver>) {
        self.observers = observers
    }
}

public class SNotificationCenter: NSObject {
    
    public static let `default`: SNotificationCenter = SNotificationCenter()
    
    var keymap: Dictionary<String, SNotification> = [:]
    
    
    public func addObserver(observer: NSObject, selector: Selector, name: String, object: NSObject) {
        var note: SNotification = (keymap.isEmpty ? SNotification(Array<SObserver>()) : keymap[name])!
        var sobserver: SObserver = SObserver()
        sobserver.target = observer
        sobserver.sel = selector
        sobserver.object = object
        note.observers.append(sobserver)
        keymap[name] = note
    }
    
    public func post(name: String, object: NSObject){
        let note: SNotification = (keymap.isEmpty ? SNotification(Array<SObserver>()) : keymap[name])!
        note.observers.forEach {
            $0.target!.perform($0.sel)
        }
    }
    
}
