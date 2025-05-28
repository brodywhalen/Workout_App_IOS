//  AddWorkoutTemplate.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/22/25.

import SwiftUI
import SwiftData


class ExerciseTemplateData: Identifiable, Equatable, ObservableObject {
    
    let id: UUID
    @Published var exercise: Exercise?
    @Published var sets: Int?
    @Published var reps: Int?
    @Published var listOrder: Int
    
    static func == (lhs: ExerciseTemplateData, rhs: ExerciseTemplateData) -> Bool {
        lhs.id == rhs.id
    }
    
    init(listOrder: Int) {
        self.listOrder = listOrder
        self.id = UUID()
        self.exercise = nil
        self.sets = nil
        self.reps = nil
    }
    
}

struct NewWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @Query var exercises: [Exercise]
    @Environment(\.modelContext) private var context
    
    @State private var workoutName = ""
    @State private var workoutDescriptor = ""
    @State private var exerciseTemplates: [ExerciseTemplateData] = [ExerciseTemplateData(listOrder: 0)]
    //    @State private var focusedFieldID: String? = nil
    //    @State private var draggedIndex: Int?
    
    //    func hideKeyboard() {
    //        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: <#T##Any?#>, from: <#T##Any?#>, for: <#T##UIEvent?#>)
    //    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List{
                    ForEach(exerciseTemplates){ exercise in
                        ExerciseView(exercise: exercise, exerciseSelection: exercises)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.2))
                                    .padding(.horizontal, 4)
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.vertical, 8)
                            
                    }
                    .onMove { IndexSet, destination in
                        exerciseTemplates.move(fromOffsets: IndexSet, toOffset: destination)
                        var counter = 0
                        for exerciseTemplate in exerciseTemplates {
                            exerciseTemplate.listOrder = counter
                            counter += 1
                            print("\(String(describing: exerciseTemplate.exercise)), listOrder = \(exerciseTemplate.listOrder)")
                        }
                    }
                }
                .listStyle(.plain)
                Button("Add Exercise") {
                    exerciseTemplates.append(ExerciseTemplateData(listOrder: exerciseTemplates.count))
                }
            }
            .navigationTitle("New Workout Template")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveWorkout() {
        // Implement your saving logic here
    }
}

struct ExerciseView: View {
    
    @ObservedObject var exercise: ExerciseTemplateData
    var exerciseSelection: [Exercise]
    
    var body: some View {
        VStack {
            Picker("Exercise: ", selection: $exercise.exercise) {
                ForEach(exerciseSelection, id:\.self){ selection in
                    Text(selection.name).tag(Optional(selection))
                    
                }
            }.pickerStyle(.navigationLink)
            HStack {
                Text("Sets: ")
                Spacer()
                NumericTextField(value: $exercise.sets, fieldtext: "# of Sets")
            }
            HStack {
                Text("Reps: ")
                Spacer()
                NumericTextField(value: $exercise.reps, fieldtext: "# of Repss")
            }
            
            
        }
        
    }
}


struct NumericTextField: View {
    @Binding var value: Int?
    var fieldtext: String
    
    var body:some View {
        TextField("\(fieldtext)", text: Binding(get: {
            value.map(String.init) ?? ""
        }, set: {
            if let intVal = Int($0) {
                value = intVal
            } else {
                value = nil
            }
        }))
        .keyboardType(.numberPad)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
}
