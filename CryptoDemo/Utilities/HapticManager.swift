//
//  HapticManager.swift
//  CryptoDemo
//
//  Created by Philophobic on 13/11/24.
//

import Foundation
import SwiftUI

class HapticManager {
    
    static private let genrator = UINotificationFeedbackGenerator()
    
    static func notification(type:UINotificationFeedbackGenerator.FeedbackType) {
        genrator.notificationOccurred(type)
    }
}
