//
//  UserPage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - ChartInteractionManager (UPDATED)
/// Manages the selected date and the array of sessions for that date.
class ChartInteractionManager: ObservableObject {
    @Published var selectedDate: Date? = nil
    @Published var selectedSessions: [WorkoutSession] = []
    
    func select(date: Date, sessions: [WorkoutSession]) {
        self.selectedDate = date
        self.selectedSessions = sessions
    }
    
    func clearSelection() {
        self.selectedDate = nil
        self.selectedSessions = []
    }
}

// MARK: - UserPage
struct UserPage: View {
    @StateObject private var interactionManager = ChartInteractionManager()
    @State private var showingBadgeSettings: Bool = false
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // LAYER 1: Main Content
            mainContentView
                .environmentObject(interactionManager)

            // LAYER 2: Modal Overlay (appears when sessions are selected for a date)
            if !interactionManager.selectedSessions.isEmpty, let date = interactionManager.selectedDate {
                modalWorkoutDetailView(for: interactionManager.selectedSessions, on: date)
            }
        }
    }
    
    private var mainContentView: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    GeometryReader { proxy in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                    }.frame(height: 0)

                    profileHeader
                    
                    GraphScrollView()
                        .frame(height: 300)
                        .background(Color.white)
                    
                    Spacer()
                }
                .background(Color.white)
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { self.scrollOffset = $0 }
            }
            .coordinateSpace(name: "scroll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(scrollOffset < -120 ? "Ralph Dibny" : "").font(.headline).fontWeight(.bold)
                        .opacity(scrollOffset < -120 ? 1 : 0).animation(.easeIn(duration: 0.2), value: scrollOffset < -120)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingBadgeSettings = true }) {
                        Image(systemName: "gearshape.fill").font(.title2).foregroundColor(.primary).padding(8)
                            .background(Color(.systemGray5).opacity(0.5)).clipShape(Circle())
                    }
                    .sheet(isPresented: $showingBadgeSettings) { Text("Badge Selection Settings").font(.title).padding() }
                }
            }
            .background(Color(.systemGray5).edgesIgnoringSafeArea(.top))
        }
    }

    @ViewBuilder
    private func modalWorkoutDetailView(for sessions: [WorkoutSession], on date: Date) -> some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    interactionManager.clearSelection()
                }
            }
            .transition(.opacity)

        WorkoutSessionDetailView(sessions: sessions, date: date)
//            .frame(maxHeight: 500)  Constrain the modal height
            .padding(25)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.25), radius: 30, y: 10)
            .padding(30)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .opacity.animation(.easeIn(duration: 0.15)))
            )
            .onTapGesture {}
    }
    
    private var profileHeader: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Image("ralph_dibny").resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100).clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 3)).shadow(radius: 8)
                HStack(spacing: 8) {
                    Text("Ralph Dibny").font(.title).fontWeight(.bold)
                    Text("Ego Lifter 🏋️‍♂️").font(.callout).fontWeight(.semibold)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(Color.orange.opacity(0.8)).shadow(radius: 1))
                        .foregroundColor(.white)
                }
            }.padding(.top, 20)
            HStack(spacing: 25) {
                BadgeImageView(imageName: "figure.strengthtraining.traditional", color: .red, size: 50)
                BadgeImageView(imageName: "figure.run", color: .cyan, size: 50)
                BadgeImageView(imageName: "dumbbell.fill", color: .purple, size: 50)
            }
            HStack(spacing: 30) {
                VStack { Text("172").font(.title2).fontWeight(.bold); Text("Followers").font(.subheadline).foregroundColor(.secondary) }
                VStack { Text("7842").font(.title2).fontWeight(.bold); Text("Following").font(.subheadline).foregroundColor(.secondary) }
                VStack { Text("10").font(.title2).fontWeight(.bold); Text("Badges").font(.subheadline).foregroundColor(.secondary) }
            }.padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray6)]), startPoint: .top, endPoint: .bottom))
        .overlay(Divider().padding(.horizontal, 0), alignment: .bottom)
    }
}


// MARK: - GraphScrollView

// MARK: - WorkoutSessionDetailView (UPDATED)
/// This view now displays a list of workouts for a given day.
// In UserPage.swift

// MARK: - WorkoutSessionDetailView (UPDATED)
/// This view now displays a list of workouts for a given day.
struct WorkoutSessionDetailView: View {
    let sessions: [WorkoutSession]
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workouts on \(date.formatted(date: .abbreviated, time: .omitted))")
                .font(.title2.bold())
                .padding(.bottom, 5)

            // A scrollable list in case of many workouts
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(sessions) { session in
                        // A new sub-view to display each individual session
                        SingleSessionCardView(session: session)
                        if session.id != sessions.last?.id {
                            Divider()
                        }
                    }
                }
//                .fixedSize(horizontal: false, vertical: true)

                // FIX: This modifier tells the content to take its ideal height,
                // which makes the parent ScrollView shrink-to-fit.
                
            }
//            .frame(maxHeight: .infinity)  Ensures the ScrollView itself can grow.
        }
        .frame(height: 400)
        .fixedSize(horizontal: false, vertical: true)
    }
}


// MARK: - SingleSessionCardView (NEW)
/// A new helper view to display the details of one workout session.
struct SingleSessionCardView: View {
    let session: WorkoutSession
    
    private var uniqueExercises: [String] { Array(Set(session.exercises.flatMap { $0.sets }.map { $0.exercise.name })).sorted() }
    private var startTime: String { session.timestart.formatted(date: .omitted, time: .shortened) }
    private var duration: String {
        guard let timeend = session.timeend else { return "In Progress" }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated; formatter.allowedUnits = [.hour, .minute]; formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeend.timeIntervalSince(session.timestart)) ?? "N/A"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Session at \(startTime)").font(.headline)
                    Label(duration, systemImage: "hourglass").font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if !uniqueExercises.isEmpty {
                    Text("Exercises:").font(.caption.bold()).foregroundColor(.secondary)
                    ForEach(uniqueExercises.prefix(4), id: \.self) { name in
                        Label(name, systemImage: "figure.strengthtraining.traditional").font(.callout)
                    }
                    if uniqueExercises.count > 4 {
                        Text("...and \(uniqueExercises.count - 4) more.").font(.caption).foregroundColor(.secondary).padding(.leading, 24)
                    }
                } else {
                    Text("No exercises recorded for this session.").font(.caption).foregroundColor(.secondary)
                }
            }
        }
    }
}


// MARK: - Helper Views and Keys
struct BadgeImageView: View {
    let imageName: String; let color: Color; var size: CGFloat = 60
    var body: some View {
        Image(systemName: imageName).resizable().aspectRatio(contentMode: .fit).frame(width: size, height: size)
            .foregroundColor(.white).background(color.gradient).clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 3).shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2))
            .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 3)
    }
}




// MARK: - Preview
struct UserPage_Previews: PreviewProvider {
    static var previews: some View {
        UserPage()
            .modelContainer(for: [WorkoutSession.self, Exercise.self, ExerciseSession.self, ExerciseSet.self], inMemory: true)
    }
}

