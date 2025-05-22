//
//  LoggerPage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//

import SwiftUI
import SwiftData

struct Logger: View {
    
    @Environment(\.modelContext) private var context
    @Query var templates: [WorkoutTemplate]
    @State private var showingNewWorkoutTemplate = false
    @State private var showingModal = false
    @State private var selectedTemplate: WorkoutTemplate? = nil
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        context.delete(template)
    }
    func updateTemplate(_ template: WorkoutTemplate) {
        template.descriptor = "updated"
        try? context.save()
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        WorkoutTemplateSection(
                            templates: templates,
                            selectedTemplate: $selectedTemplate,
                            showingModal: $showingModal,
                            showingNewWorkoutTemplate: $showingNewWorkoutTemplate
                        )
                        HStack {
                            Text("My Challenges")
                                .font(.title2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                if showingModal, let session = selectedTemplate {
                    
                    WorkoutPopUp(name: session.name, duration: 6,  isActive: $showingModal) {
                        print("pass to VM")
                        
                    }
                }
            }
            
        }
        .navigationTitle("Logger").font(.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            //TBD
        }
        .fullScreenCover(isPresented: $showingNewWorkoutTemplate)  {
            NewWorkoutView()
                .interactiveDismissDisabled(true)
        }
    }
        
}
struct NewWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var workoutName = ""
    @State private var durationText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Info")) {
                    TextField("Workout Name", text: $workoutName)
                    TextField("Duration (minutes)", text: $durationText)
    
                }
            }
            .navigationTitle("New Workout")
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
        
//        let newSession = WorkoutTemplate(name: self.workoutName, duration: Int(self.durationText) ?? 0)
//        context.insert(newSession)
    }
}
struct AddNewTemplateSquare: View {
    
    
    @Binding var isShowing: Bool
    
    var body: some View {
        Button(action: {
            isShowing = true
        }) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
                .frame(width: 150, height: 150)
                .overlay(Text("Tap to add new session")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                )
        }.padding()
    }
}
struct AddNewTemplateButton: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        Button(action: {
            isShowing = true
        }) {
            Image(systemName: "plus.app")
                .imageScale(.medium)
                .accessibilityLabel("Add Workout")
        }
    }
}

struct WorkoutTemplateSection: View {
    let templates: [WorkoutTemplate]
    @Binding var selectedTemplate: WorkoutTemplate?
    @Binding var showingModal: Bool
    @Binding var showingNewWorkoutTemplate: Bool
    
    var body: some View {
        HStack {
            Text("My Workouts")
                .font(.title2)
            AddNewTemplateButton(isShowing: $showingNewWorkoutTemplate)
        }
        ScrollView(.horizontal){
            HStack {
                ForEach(templates){ template in
                    Button(action: {
                        selectedTemplate = template
                        print("clicked")
                        if showingModal {
                            // Reset first to ensure it's removed
                            showingModal = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                showingModal = true
                            }
                        } else {
                            showingModal = true
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 150, height: 150)
                            .overlay(
                                Text(template.name)
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                            )
                    }.padding()
                }
                AddNewTemplateSquare(isShowing: $showingNewWorkoutTemplate)
            }
            
        }
    }
}



