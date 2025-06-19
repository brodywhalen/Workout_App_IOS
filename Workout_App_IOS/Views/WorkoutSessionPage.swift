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
    func deleteExercise(_ exercise: ExerciseSession) {
        modelContext.delete(exercise)
    }
    
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
        }
        .padding(.horizontal)
        .frame(maxWidth:.infinity)

    }
    
    
    

}

struct ExerciseDetailView: View {
    @Bindable var exercise: ExerciseSession
    @State private var showDeleteAlert = false
    
    //    @State private var Reps: Int
    
    var body: some View {
        Grid (horizontalSpacing: 24) {
            Divider()
            GridRow {
                Group {
                    // header row of exercise table
                    Text("Set").bold()
                    Text("Weight (lbs)").bold()
                    Text("Reps").bold()
                    Text(Image(systemName: "checkmark.diamond")).bold()
                }
            }
            Divider().gridCellUnsizedAxes(.horizontal)
            ForEach(Array(exercise.sets.enumerated()), id: \.1.id) { index, set in
                SetDetailView(set: set, index: index)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            ZStack {
                Divider()
                // TODO: Make it so the model deletes these rows! Also add cascade rule to delete to the model!!
                HStack(spacing: 24) {
                    Button(action: {
                        withAnimation {
                            if !exercise.sets.isEmpty {
                                exercise.sets.append(ExerciseSet(reps: 0, weight: 0, exercise: exercise.sets[0].exercise))
                            }
                        }
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                    }
                    Button(action: {
                        withAnimation {
                            if (exercise.sets.count > 1) {
                                exercise.sets.removeLast()
                            } else {
                                showDeleteAlert = true
                            }
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                    }
                    .alert("Deleting last Exercise will delete the entire set", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive){
                            exercise.
                        }
                    }


                }
                .padding(4)
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
        .gridColumnAlignment(.center)
    }
}
struct SetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var set: ExerciseSet
    @State var Weight: String
    @State var Reps: String
    
    private var index: Int
    
    init(set: ExerciseSet, index: Int) {
        self.set = set
        self.Weight = String(set.weight )
        self.index = index + 1
        self.Reps = String(set.reps )
    }
    
    var body: some View {
        GridRow {
            Text("\(index)")
            TextField("Enter Weight", text: $Weight).onChange(of: Weight) { _, newValue in
                    set.weight = (Double(newValue ) ?? 0)
                }
            .textFieldStyle(.roundedBorder)
            TextField("Enter Reps", text: $Reps).onChange(of: Reps) { _, newValue in
                set.reps = (Int(newValue ) ?? 0)
            }
            .textFieldStyle(.roundedBorder)
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
