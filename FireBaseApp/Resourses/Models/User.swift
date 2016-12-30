//
//  User.swift
//  FireBaseApp
//
//  Created by Nikola Andriiev on 23.12.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation
import FirebaseAuth

class User: CustomDebugStringConvertible {
    let uid: String
    let email: String
    var name: String? = nil
    var photoURL: URL? = nil
    
    init(userData: FIRUser) {
        self.uid = userData.uid
        self.email = userData.email ?? ""
        self.name = userData.displayName
        self.photoURL = userData.photoURL
    }
    
    public var debugDescription: String {
        return String("uid: \(self.uid), email: \(self.uid), name: \(self.name), photoURL: \(self.photoURL?.absoluteString)")
    }
}
