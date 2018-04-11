//
//  ViewController.swift
//  SNotificationCenter
//
//  Created by steve on 04/11/2018.
//  Copyright (c) 2018 steve. All rights reserved.
//

import UIKit
import SNotificationCenter

// simple imp for Swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SNotificationCenter.default.addObserver(observer: self, selector: #selector(test), name: "postNotify", object: NSObject())
        SNotificationCenter.default.addObserver(observer: self, selector: #selector(hello), name: "postNotify", object: NSObject())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SNotificationCenter.default.post(name: "postNotify", object: NSObject())
    }

    @objc func test() {
        print("test 🌹")
    }
    
    @objc func hello() {
        print("hello 🌹")
    }

}

