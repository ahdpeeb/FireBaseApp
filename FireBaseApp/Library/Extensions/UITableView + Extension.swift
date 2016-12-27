//
//  File.swift
//  VidMeTest
//
//  Created by Nikola Andriiev on 23.11.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation
import UIKit

extension UITableView  {
    func update(_ block: () -> ()) {
        self.beginUpdates()
        block()
        self.endUpdates()
    }
    
    func registerCell(withClass cls: AnyClass?) {
        if let cls = cls {
            let name = String(describing: cls.self)
            let cell = UINib.init(nibName: name, bundle: nil)
            self.register(cell, forCellReuseIdentifier: name)
        }
    }
    
    func dequeueCell<T>(cls: T.Type, indexPath path: IndexPath) -> T {
        let clsString = String(describing: T.self)
        return self.dequeueReusableCell(withIdentifier: clsString, for: path) as! T
    }
}

