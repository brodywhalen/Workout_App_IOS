//
//  UserPage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//

import SwiftUI
import SwiftData
import Charts

struct UserPage: View {
    @Environment(\.modelContext) private var modelContext
    @Query var workoutSessions: [WorkoutSession]
    
    var body: some View {
        VStack {
            ScrollView {
                Chart(workoutSessions) {
                    LineMark(x: .value("Date", $0.timestart),
                             y: .value("Exercises Completed", $0.exercises.count)
                    )
                    
                }
                
                
                ForEach(workoutSessions) { workoutSessions in
                    Text("\(workoutSessions.timestart)")
                }
            }
            
        }
    }
}



