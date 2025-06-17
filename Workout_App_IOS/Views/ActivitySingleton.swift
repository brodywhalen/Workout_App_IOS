//
//  ActivityTest.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 6/14/25.
//

import ActivityKit
import SwiftUI

struct ActivityTest: View {
    
    @State private var activity: Activity<TimerAttributes>? = nil
    
    
    var body: some View {
        VStack {
            Button("Start") {
                startActivity()
            }
        }
    }
    func startActivity() {
        let attributes = TimerAttributes(timerName: "testTimer")
        let state = TimerAttributes.TimerStatus(startTime: Date())

        Task {
            do {
                let newActivity = try Activity<TimerAttributes>.request(
                    attributes: attributes,
                    content: .init(state: state, staleDate: nil),
                    pushType: nil
                )
                activity = newActivity
                print("✅ Started Live Activity: \(newActivity.id)")
            } catch {
                print("❌ Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
    }
}

