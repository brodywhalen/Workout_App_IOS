//
//  SwiftDataAppContainer.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/22/25.
//

import SwiftData

@MainActor
let appContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for:
            WorkoutTemplate.self,
            ExerciseTemplate.self,
            WorkoutBlock.self,
            Exercise.self
        )
        
        //check to see if default data was already loaded
        var exerciseFetchDescriptor = FetchDescriptor<Exercise>()
        exerciseFetchDescriptor.fetchLimit = 1
        
        guard try container.mainContext.fetch(exerciseFetchDescriptor).count == 0 else {return container}
        
        //This code will only run if persistent store is empty
        let exercises = [
            Exercise(name: "Squat", descriptor: "Standard Squat variation"),
            Exercise(name: "Bench Press", descriptor: "Bench press with barbell"),
            Exercise(name: "Pull up", descriptor: "Pull up with hands at sholder length")
        ]
        
        for exercise in exercises {
            container.mainContext.insert(exercise)
        }
        return container
    } catch {
        fatalError("failed to create container")
    }
}()
