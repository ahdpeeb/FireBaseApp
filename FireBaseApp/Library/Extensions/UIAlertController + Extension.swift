//
//  UIAlertController + Extension.swift
//  FireBaseApp
//
//  Created by Nikola Andriiev on 26.12.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
   public typealias ErrorAction = (UIAlertAction) -> Void
   public static func errorController(massage: String, alletAction action: ErrorAction?) -> UIAlertController {
        let controller = UIAlertController(title: "ERROR",
                                           message: massage,
                                           preferredStyle: .alert)
        //check if ErrorAction triggers
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: action)
        controller.addAction(okAction)
        
        return controller
    }
}
