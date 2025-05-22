//
//  Workout_App_IOSApp.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/6/25.
//

import SwiftUI
import SwiftData

@main
struct Workout_App_IOSApp: App {


    var body: some Scene {
        WindowGroup {
            MainTabbedView()
        }
        .modelContainer(for: [
            WorkoutTemplate.self,
            ExerciseTemplate.self,
            WorkoutBlock.self,
            
            
        
        
        ])

    }
}
