//
//  PersistentWorkoutActivityBundle.swift
//  PersistentWorkoutActivity
//
//  Created by Brody Whalen on 6/11/25.
//
import ActivityKit
import WidgetKit
import SwiftUI

@main
struct Persistent_Workout_Widget: Widget {
    let kind:String = "Persistent_Workout_Widget"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            TimerActivityView(context: context )
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded region
                DynamicIslandExpandedRegion(.center) {
                    EmptyView() // placeholder
                }
            } compactLeading: {
                EmptyView()
            } compactTrailing: {
                EmptyView()
            } minimal: {
                EmptyView()
            }
        }
    }
            
}

struct TimerActivityView: View {
    let context: ActivityViewContext<TimerAttributes>
    
    var body : some View {
        VStack {
            Text(context.attributes.timerName)
                .font(.headline)
            Text(context.state.startTime, style: .timer)
             
        }
    }
    
    
}
