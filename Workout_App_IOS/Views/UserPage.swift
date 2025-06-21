//
//  UserPage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//

import SwiftUI
import SwiftData


struct UserPage: View {
    @Environment(\.modelContext) private var modelContext
    @Query var workoutSessions: [WorkoutSession]
    
    var body: some View {
        VStack {
            ForEach(workoutSessions) { workoutSessions in
                Text("\(workoutSessions.timestart)")
            }
        }
    }
}



