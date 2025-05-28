//
//  SwiftData.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//

import Foundation
import SwiftData

// defines schema of what is going to be stored localy.

@Model
class WorkoutTemplate: Identifiable {
    var id: String
    var name:String
    var descriptor: String
    var blocks: [WorkoutBlock]
    
    init(name: String, duration: Int, descriptor: String, blocks: [WorkoutBlock]  ) {
        self.id = UUID().uuidString
        self.name = name
        self.descriptor = descriptor
        self.blocks = blocks
    }
    
    
}
@Model
class ExerciseTemplate: Identifiable {
    var id: String
    var exercise: Exercise
    var defaultSets: Int
    var defaultReps: Int
    
    init(defaultSets: Int, defaultReps: Int, excercise: Exercise) {
        self.id = UUID().uuidString
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.exercise = excercise
    }
}

@Model
class WorkoutBlock: Identifiable {
    var id: String
    var workoutTemplate: WorkoutTemplate?

    // This enum differentiates the type of block
    var type: WorkoutBlockType

    // Properties for each type, optional because only one will be used
    var exercise: ExerciseTemplate?
    var exercises: [ExerciseTemplate]?
    
    enum WorkoutBlockType: Codable {
        case single
        case superset
    }

    init(workoutTemplate: WorkoutTemplate?, type: WorkoutBlockType, exercise: ExerciseTemplate? = nil, exercises: [ExerciseTemplate]? = nil) {
        self.id = UUID().uuidString
        self.workoutTemplate = workoutTemplate
        self.type = type
        self.exercise = exercise
        self.exercises = exercises
    }
}

@Model
class Exercise: Identifiable {
    var id: String
    var name: String
    var descriptor: String
    // muscles targeted
    
    init(name: String, descriptor: String) {
        self.id = UUID().uuidString
        self.name = name
        self.descriptor = descriptor
    }
}






//
