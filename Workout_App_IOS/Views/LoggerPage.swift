//
//  LoggerPage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//
// Issues to fix: Make a close keyboard button that works and does not require a re-render
// Feautures to add: Superset grouping


import SwiftUI
import SwiftData

struct Logger: View {
    @EnvironmentObject var bannerManager: BannerManager
    
    @Environment(\.modelContext) private var context
    @Query var templates: [WorkoutTemplate]
    @State private var showingNewWorkoutTemplate = false
    @State private var showingModal = false
//    @State private var showingWorkoutSession = false
    @State private var selectedTemplate: WorkoutTemplate? = nil
    // State for the sheet custom scrolldown
    @State private var selectedDetent: PresentationDetent = .medium
    
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
                    
                    WorkoutPopUp(template: session,  isActive: $showingModal, workoutIsActive: $bannerManager.isActiveWorkout, isInSheetMode: $bannerManager.isInSheetMode) {
                        print("pass to VM")
                        
                    }
                }
            }
            
        }
        .navigationTitle("Logger").font(.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingNewWorkoutTemplate)  {
            NavigationStack {
                NewWorkoutView()
                    .interactiveDismissDisabled(true)

            }
        }
        .sheet(isPresented: $bannerManager.isInSheetMode,
        onDismiss: {
            print("dismissed the sheet")
            withAnimation {
                bannerManager.isInBannerMode = true
            }
        }
        ) {
            if selectedTemplate != nil { // add if gate if this does not work
                WorkoutSessionPage(selectedDetent: $selectedDetent)
                    .presentationDetents([.fraction(0.2), .medium, .large], selection: $selectedDetent)
                    .interactiveDismissDisabled(selectedDetent != .fraction(0.2))
            }
            
        }
        
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



