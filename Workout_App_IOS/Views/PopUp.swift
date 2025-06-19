// Custom popup modal


import SwiftUI
import SwiftData

struct WorkoutPopUp: View {
    
    
    @EnvironmentObject var bannerManager: BannerManager
    @Environment(\.modelContext) private var context
    // place holder data
    let template: WorkoutTemplate
    
    //THIS CREATES THE WORKOUT SESSION. I WANT IT TO CALL WHEN THE START IS PRESSED
    func createWorkoutSession(template: WorkoutTemplate) -> ActiveWorkoutSession {
        //delete existing ActiveWorkoutSessions
        let descriptor = FetchDescriptor<ActiveWorkoutSession>()
        if let existingSessions = try? context.fetch(descriptor) {
            for session in existingSessions {
                context.delete(session)
            }
        }
        // This gets the an Array of Exercise Templates
        let myExercisesTemplates = template.blocks.flatMap(\.allExercises)
        // now I need to convert these templates into an Array of Exercise Sessions
        let exerciseSessions = myExercisesTemplates.map { template in
            
            // Create Sets with reps
            let sets = (0..<template.defaultSets).map { _ in
                ExerciseSet(reps: template.defaultReps, weight: 0, exercise: template.exercise)
            }
            
            return ExerciseSession(sets: sets)
        }
        
        let mySession = ActiveWorkoutSession(title: template.name, timestart: Date(), exercises: exerciseSessions)
        context.insert(mySession)
        do {
            try context.save()
            print("Successfully saved ActiveWorkoutSession: \(String(describing: mySession.title))")
        } catch {
            print("Error saving ActiveWorkoutSession: \(error)")
            // Handle the error appropriately, e.g., show an alert
        }
        return mySession
        
        
    }
    //    let name: String = t
    //    let exercises: Int
    @State private var offset: CGFloat = 1000
    //    @State private var isShowingSheet = false
    @Binding var isActive: Bool
    @Binding var workoutIsActive:Bool
    @Binding var isInSheetMode:Bool
    let action: () -> ()
    
    var body: some View {
        VStack {
            Text(template.name)
            ForEach(template.blocks.flatMap(\.allExercises)){ exercise in
                HStack {
                    Text(" - \(exercise.exercise.name): \(exercise.defaultSets)x\(exercise.defaultReps)")
                        .font(.body)
                    Spacer()
                }
                
            }
            .padding()
            Button {
                Task {
                    do {
                        let newSession = createWorkoutSession(template: template)
                        
                        // Await the save operation
                        try context.save()
                        print("Successfully saved ActiveWorkoutSession: \(String(describing: newSession.title))")
                        
                        // NOW that the save is confirmed, do the rest
                        bannerManager.startWorkout(session: newSession)
                        isInSheetMode = true
                        close()
                        action() // Call your action if it needs to happen after save and UI updates
                        
                    } catch {
                        print("Error during workout session creation or save: \(error)")
                        // Potentially show an alert to the user
                    }
                }
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.blue)
                    Text("Start Session")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                }
                .padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        print("working?")
                        close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .tint(.black)
                }
                
                Spacer()
            }.padding()
            
        }
        .shadow(radius: 20)
        .padding(30)
        .offset(x: 0, y: offset)
        .onAppear {
            withAnimation(.spring()) {
                offset = 0
            }
        }
        
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 1000
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isActive = false
        }
        
    }
    
}


#Preview {
    //    WorkoutPopUp(name: "Squat", duration: 5, isActive: .constant(true)) {
    //        print("button clicked")
    //    }
}
