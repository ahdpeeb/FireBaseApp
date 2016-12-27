//
//  Locker.swift
//  VidMeTest
//
//  Created by Nikola Andriiev on 23.11.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation

class Locker {
     public class func synced(lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
   
    public class func syncedValue<T>(lock: Any, closure: () -> T) -> T {
        objc_sync_enter(lock)
        let result:T = closure()
        objc_sync_exit(lock)
        
        return result
    }
    
    //if closure throws Error use this method 
    public class func synchronized<T>(lock: Any, closure: () throws -> T) rethrows -> T {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        return try closure()
    }
}
