//
//  Converter.swift
//  VidMeTest
//
//  Created by Nikola Andriiev on 14.12.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import Foundation

class Converter {
    public class func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
    }
}
