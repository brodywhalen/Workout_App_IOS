//
//  DemoTimer.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 6/11/25.
//

import ActivityKit
import SwiftUI

struct TimerAttributes: ActivityAttributes {
    public typealias TimerStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var startTime: Date
    }
    
    var timerName: String
}
