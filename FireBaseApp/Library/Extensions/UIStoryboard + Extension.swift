//
//  UIStoryboard + Extension.swift
//  VidMeTest
//
//  Created by Nikola Andriiev on 06.12.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    // this function works if user default storyboard name "Main"
    static func controllerWithIdentifier(_ identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}
