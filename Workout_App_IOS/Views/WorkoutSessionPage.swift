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
    @EnvironmentObject var bannerManager: BannerManager
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack (alignment: .leading, spacing: 0){
                headerView
//                    .padding()
                    .background(Color.blue.opacity(0.2))
                ScrollView {
                    
                    exerciseListView(proxy: proxy)
//                        .background(Color.clear)
                }
                .background(Color.white)
                .padding(.horizontal)
                .frame(maxWidth:.infinity, alignment: .leading)
            }
//            .background(Color.blue.opacity(0.2))
//            .padding(.horizontal)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("\(activeSession.first?.title ?? "No title")")
                    .font(.title)
                Text("\(activeSession.first?.timestart.formatted(date:.abbreviated, time: .shortened) ?? "Time not set")")
            }
            Spacer()
            Button(action: {
                // do something
                stopExercise()
            }) {
                Image(systemName: "stop.circle")
                    .font(.title)
            }
        }
        .padding()

    }
    private func stopExercise() -> Void {
        // 1) Copy and save data
        guard let savedSession = activeSession.first else { return print("exit here") }
        // retains and sets new connections for dependant
        // gets past active session check
       print("active session: \(savedSession)")
        let newItem = WorkoutSession(
            timestart: savedSession.timestart,
            timeend: Date(),
            exercises: savedSession.exercises)
        
        modelContext.insert(newItem)
        modelContext.delete(savedSession)
        do {
            try modelContext.save()
            bannerManager.stopWorkout()
            print("Save succeeded")
        } catch {
            print("Save failed with error: \(error)")
        }
    }
    
    private func exerciseListView(proxy: ScrollViewProxy) -> some View {
        Group {
            ForEach(activeSession) { session in
                ForEach(session.exercises) { exercise in
                    ExerciseDetailView(exercise: exercise, onDelete:{ deleteExercise(exercise)}, scrollProxy: proxy, scrollTargetId: exercise.id)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }

    }
    
    func deleteExercise(_ exerciseToDelete: ExerciseSession) -> Void {
        // clean the entire tree
        guard let session = activeSession.first else {
            print ("No Active Session Found")
            return
        }
        // Check if exerciseToDelete is in session.exercises
        if let index = session.exercises.firstIndex(where: { $0.id == exerciseToDelete.id }) {
            // Remove it from the session's array (mutates the model)
            let foundExercise = session.exercises[index]
            // suppress the warning that the result of withAnimation is unused
            _ = withAnimation {
                session.exercises.remove(at: index)
            }
            let setsToDelete = foundExercise.sets
            foundExercise.sets.removeAll()
            for set in setsToDelete{
                modelContext.delete(set)
            }
            try? modelContext.save()
            // Also delete the exercise entity from modelContext to persist deletion
            modelContext.delete(foundExercise)
            
            // Save changes to persist deletion
            do {
                try modelContext.save()
                print("Exercise deleted successfully")
            } catch {
                print("Failed to save context after deleting exercise: \(error)")
            }
        } else {
            print("Exercise not found in session")
        }
    }
}

struct ExerciseDetailView: View {
    @Bindable var exercise: ExerciseSession
    @State private var showDeleteAlert = false
    @Environment(\.modelContext) private var modelContext
    var onDelete: (() -> Void)?
    // scroll proxy
    var scrollProxy: ScrollViewProxy
    var scrollTargetId: AnyHashable
    
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(exercise.sets.first?.exercise.name ?? "No Exercise")")
                    .font(.headline)
                Spacer()
            }
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
    //            Divider().gridCellUnsizedAxes(.horizontal)
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
                            // scroll to when adding
                            
                                
                         
                            
                        }) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                        }
                        Button(action: {
                            withAnimation {
                                if (exercise.sets.count > 1) {
                                    let removed = exercise.sets.removeLast()
                                    //remove model
                                    modelContext.delete(removed)
                                } else {
                                    showDeleteAlert = true
                                }
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.title2)
                        }
                        .alert("Are you sure?", isPresented: $showDeleteAlert) {
                            Button("Delete", role: .destructive){
                                // remove the Exercise (not just the set)
                                onDelete?()
                            }
                            Button("Cancel", role : .cancel) {
                                
                            }} message: {
                                Text("Deleting the last set will remove the entire exercise from your workout log.")
                            }
                    }
                    .id(scrollTargetId)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .onChange(of: exercise.sets.count) { oldValue, newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                withAnimation {
                                    scrollProxy.scrollTo(scrollTargetId, anchor: .bottom)
                                }
                            }
                        }
                    
                }
    //            .padding(8)

                
            }
            .gridColumnAlignment(.center)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.gray, lineWidth: 2)
            )
        }

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

