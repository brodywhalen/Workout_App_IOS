//
//  WorkoutSession.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/28/25.
//
import SwiftUI

struct WorkoutSessionPage: View {
    
    let TemplateforSession: WorkoutTemplate
    
    // init copy
    // for now we will have changes to sets and reps update
    
    
    var body: some View {
        VStack {
            HStack {
                VStack (alignment: .leading){
                    
                    Text("Workout Name")
                        .font(.title)
                    Text("May 28th, 2028")
                    Text("Hello World")
                    
                    //                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            .background(Color.blue)
            ForEach(TemplateforSession.blocks){ block in
                ForEach(block.allExercises) { setgroup in
                    Text("Title: \(setgroup.exercise.name)")
                    Grid {
                        Divider()
                        GridRow {
                            Group {
                                Text("Set")
                                Text("Weight (lbs)")
                                Text("Reps")
                                Text(Image(systemName: "checkmark.diamond"))
                            }.font(.headline)
                        }
                        Divider()
                        // this is creating sets
                        ForEach(0..<setgroup.defaultSets, id: \.self) { index in
                            GridRow {
                                Group {
                                    Text("\(index)")
                                    Text("2 lb") // make field
                                    Text("\(setgroup.defaultReps)") // make field
                                    Text(Image(systemName: "checkmark.diamond")) // make field
                                    
                                }
                            }
                        }
                        
                        
                    }
                }
                
                
            }
            .background(Color.red)
            .padding()
            //            .background(Color.red)
            Spacer()
        }
        
        
        
    }
}


#Preview {
    let exercise1 = Exercise(name: "testsquat", descriptor: "just for funsies")
    let exercise2 = Exercise(name: "testlift", descriptor: "tesylewis")
    
    let template1 = ExerciseTemplate(defaultSets: 4, defaultReps: 5, excercise: exercise1)
    let template2 = ExerciseTemplate(defaultSets: 6, defaultReps: 7, excercise: exercise2)
    
    let block = WorkoutBlock(workoutTemplate: nil, type: .superset, exercise: nil, exercises: [template1, template2])
    
    let workoutTemplate = WorkoutTemplate(name: "Mock Template", descriptor: "Preview Description", blocks: [block])
    
    // back-fill the template reference to avoid circular logic errors in previews
    block.workoutTemplate = workoutTemplate
    
    return WorkoutSessionPage(TemplateforSession: workoutTemplate)
}
