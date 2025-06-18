//
//  WorkoutSession.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/28/25.
//
import SwiftUI
import SwiftData

struct WorkoutSessionPage: View {
    @Query var activeSession: [ActiveWorkoutSession]
    @Environment(\.modelContext) private var modelContext
//    @State private var sessionState: ActiveWorkoutSession?

    
    var body: some View {
        VStack {
            HStack {
                VStack (alignment: .leading){
                    
                    Text("\(activeSession.first?.title ?? "No title")")
                        .font(.title)
                    Text("\(activeSession.first?.timestart.formatted(date:.abbreviated, time: .shortened) ?? "Time not set")")
                    ForEach(activeSession) { session in
                        ForEach(session.exercises) { exercise in
                            ExerciseDetailView(exercise: exercise)
                        }
                    }
                }
            }
        }.onAppear(){

        }

    }
    
    
    

}

struct ExerciseDetailView: View {
    @Bindable var exercise: ExerciseSession
    
    //    @State private var Reps: Int
    
    var body: some View {
        Grid {
            Divider()
            GridRow {
                Group {
                    // header row of exercise table
                    Text("Set")
                    Text("Weight (lbs)")
                    Text("Reps")
                    Text(Image(systemName: "checkmark.diamond"))
                }
            }
            Divider()
            ForEach(exercise.sets) { set in
                SetDetailView(set: set)
            }
            Divider()
        }
    }
}
struct SetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var set: ExerciseSet
    @State var Weight: String
    
    init(set: ExerciseSet) {
        self.set = set
        self.Weight = String(set.reps.first?.weight ?? 200.00)
    }
    
    var body: some View {
        GridRow {
            Text("a")
            TextField("Enter Weight", text: $Weight).onChange(of: Weight) { _, newValue in
                for i in set.reps.indices {
                    set.reps[i].weight = Double(newValue) ?? 400.000
                }
                
            }
            Text("c")
            Text("d")
        }
    }
}


//#Preview {
//    let exercise1 = Exercise(name: "testsquat", descriptor: "just for funsies")
//    let exercise2 = Exercise(name: "testlift", descriptor: "tesylewis")
//    
//    let template1 = ExerciseTemplate(defaultSets: 4, defaultReps: 5, excercise: exercise1)
//    let template2 = ExerciseTemplate(defaultSets: 6, defaultReps: 7, excercise: exercise2)
//    
//    let block = WorkoutBlock(workoutTemplate: nil, type: .superset, exercise: nil, exercises: [template1, template2])
//    
//    let workoutTemplate = WorkoutTemplate(name: "Mock Template", descriptor: "Preview Description", blocks: [block])
//    
//    // back-fill the template reference to avoid circular logic errors in previews
//    block.workoutTemplate = workoutTemplate
//    
//    return WorkoutSessionPage(TemplateforSession: workoutTemplate)
//}
