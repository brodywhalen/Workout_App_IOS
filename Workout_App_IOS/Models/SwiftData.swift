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
    
    init(name: String, descriptor: String, blocks: [WorkoutBlock]  ) {
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
    
    var allExercises: [ExerciseTemplate] {
        switch type {
        case .single:
            return exercise.map { [$0] } ?? []
        case .superset:
            return exercises ?? []
        }
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
@Model
class WorkoutSession: Identifiable {
    var id: String
    var timestart: Date
    var timeend: Date?
    var exercises: [ExerciseSession]
    //var user -- implement once user admin is created
    
    
    init(timestart: Date, timeend: Date? = nil, exercises: [ExerciseSession]) {
        self.id = UUID().uuidString
        self.timestart = timestart
        self.timeend = timeend
        self.exercises = exercises
    }
    
}
// TODO: Add robust way to ensure that there is only one workout session in this model.
@Model
class ActiveWorkoutSession: Identifiable {
    var title: String?
    var timestart: Date
    var timeend: Date?
    var exercises: [ExerciseSession]
    //var user -- implement once user admin is created
    
    
    init(title: String? = nil, timestart: Date, timeend: Date? = nil, exercises: [ExerciseSession]) {
        self.title = title
        self.timestart = timestart
        self.timeend = timeend
        self.exercises = exercises
    }
    
}

@Model
class ExerciseSession: Identifiable {
//    var timestart: Date
//    var timeend: Date
    var sets: [ExerciseSet]
    
    init(/*timestart: Date,*/ /*timeend: Date*/ sets: [ExerciseSet]){
//        self.timestart = timestart
//        self.timeend = timeend
        self.sets = sets
    }
    
}
@Model
class ExerciseSet: Identifiable {
    var reps: Int
    var setType: SetType?
    var weight: Double
    var exercise: Exercise
    
    
    enum SetType: Codable {
        case warmUp
        case toFailure
        case dropSet
    }
    
    init(reps: Int, setType: SetType? = nil, weight: Double, exercise: Exercise) {
        self.reps = reps
        self.setType = setType
        self.weight = weight
        self.exercise = exercise
    }
    
}







//
