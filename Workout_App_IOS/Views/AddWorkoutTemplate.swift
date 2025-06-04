//  AddWorkoutTemplate.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/22/25.

import SwiftUI
import SwiftData
import UIKit

public func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
class ExerciseTemplateData: Identifiable, Equatable, ObservableObject {
    
    let id: UUID
    @Published var exercise: Exercise?
    @Published var sets: Int?
    @Published var reps: Int?
    @Published var listOrder: Int
    
    static func == (lhs: ExerciseTemplateData, rhs: ExerciseTemplateData) -> Bool {
        lhs.id == rhs.id
    }
    
    init(listOrder: Int, placeholder: Exercise) {
        self.listOrder = listOrder
        self.id = UUID()
        self.exercise = placeholder
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
    @State private var exerciseTemplates: [ExerciseTemplateData] = []

    
    var body: some View {
        NavigationStack {
            
            VStack {
                List{
                    Section {
                        HStack {
                            Spacer()
                            CustomTextField(text: $workoutName, placeholder: "Enter Template Title"){
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        HStack {
                            //                            Spacer()
                            TextField("Enter Description", text: $workoutDescriptor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .multilineTextAlignment(.center)
                            //                            Spacer()
                        }
                    } header: {
                        HStack {
                            Spacer()
                            Text("Template Data")
                            Spacer()
                        }
                        
                    }
                    .listRowSeparator(.hidden)
                    
                    
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
                    HStack {
                        Spacer()
                        Button("Add Exercise") {
                            exerciseTemplates.append(ExerciseTemplateData(listOrder: exerciseTemplates.count, placeholder: exercises[0]))
                        }
                        Spacer()
                    }.listRowSeparator(.hidden)
                        .padding()
                }
                .listStyle(.plain)
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
        .onAppear {
            if exerciseTemplates.isEmpty, let firstExercise = exercises.first {
                exerciseTemplates = [ExerciseTemplateData(listOrder: 0, placeholder: firstExercise)]
            }
        }


    }
    private func saveWorkout() {
        guard !workoutName.isEmpty else {
            print("Template name is required!")
            return
        }
        var workoutBlocks: [WorkoutBlock] = []
        
        // check that all fields are entered
        for template in exerciseTemplates {
            guard let selectedExercise = template.exercise,
                  let sets = template.sets,
                  let reps = template.reps else {
                print("Skipping incomplete template")
                continue
            }
            //Create exerciseTemplates
            let newExerciseTemplate = ExerciseTemplate(defaultSets: sets, defaultReps: reps, excercise: selectedExercise)
            //Create WorkoutBlock of type .single for now
            let block = WorkoutBlock(
                workoutTemplate: nil, // Will set later if needed
                type: .single,
                exercise: newExerciseTemplate
            )
            workoutBlocks.append(block)
        }
        
        //create the workout Template
        
        let newWorkoutTemplate = WorkoutTemplate(
            name: workoutName,
            descriptor: workoutDescriptor,
            blocks: workoutBlocks
        )
        // now we link the blocks to the workout
        for block in workoutBlocks {
            block.workoutTemplate = newWorkoutTemplate
        }
        // save to the model
        context.insert(newWorkoutTemplate)
        
        do {
            try context.save()
            print("Workout Template Saved")
        } catch {
            print("Failed to save workout: \(error)")
        }
    }
}

struct ExerciseView: View {
    
    @ObservedObject var exercise: ExerciseTemplateData
    var exerciseSelection: [Exercise]
    
    var body: some View {
        VStack {
            Picker("Exercise: ", selection: $exercise.exercise) {
                Text("None").tag(Exercise?.none)
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
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        VStack {
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
}


// custom keyboard



class KeyboardAccessoryView: UIView {

    var doneButtonAction: (() -> Void)?

    private let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Done", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .systemGray6
        addSubview(doneButton)

        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }

    @objc private func doneTapped() {
        doneButtonAction?()
    }
}


struct KeyboardAccessory: UIViewRepresentable {
    var doneAction: () -> Void
    
    func makeUIView(context: Context) -> KeyboardAccessoryView {
        let accessoryView = KeyboardAccessoryView()
        accessoryView.doneButtonAction = doneAction
        return accessoryView
    }
    
    func updateUIView(_ uiView: KeyboardAccessoryView, context: Context) {
        // No update needed for now
    }
}

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onDone: () -> Void
    
    func makeUIView(context: Context) -> UITextField {
        
        let textField = UITextField()
        textField.textAlignment = .center
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        
        // Style for rounded rectangle outline
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.clipsToBounds = true
        
        // Fix size so we can center it in SwiftUI later
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: 300),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Custom keyboard toolbar
        let accessory = KeyboardAccessory(doneAction: {
            onDone()
        })
        textField.inputAccessoryView = UIHostingController(rootView: accessory).view
        textField.inputAccessoryView?.frame.size.height = 44
        
        return textField
    }

    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}
