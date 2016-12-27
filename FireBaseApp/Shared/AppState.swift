//
//  AppState.swift
//  FireBaseApp
//
//  Created by Nikola Andriiev on 22.12.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation
import Firebase

class AppState: NSObject {
    // call thids method for singleton AppState instance
    static let instance = AppState()
    
    var isLoginned = false
    var user: User? = nil
}
