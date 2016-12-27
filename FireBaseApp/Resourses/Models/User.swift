//
//  User.swift
//  FireBaseApp
//
//  Created by Nikola Andriiev on 23.12.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation
import FirebaseAuth

class User {
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
    
}
