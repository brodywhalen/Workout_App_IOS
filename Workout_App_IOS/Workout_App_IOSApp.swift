//
//  Workout_App_IOSApp.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/6/25.
//

import SwiftUI
import SwiftData
import Auth


@main
struct Workout_App_IOSApp: App {
    
    @StateObject var bannerManager = BannerManager()// intializes the banner at startup....maybe not the best idea if I was perfect
    @StateObject var userData = UserStateData()
    
    
    var body: some Scene {
        WindowGroup {
            if(userData.session != nil) {
                
                MainTabbedView()
                    .environmentObject(bannerManager)
                    .environmentObject(userData)
            }
            else {
                SignInPage()
                    .environmentObject(userData)
            }
        }
        .modelContainer(appContainer)
        
    }
}

// banner provider
class BannerManager: ObservableObject {
    @Published var isActiveWorkout: Bool = false
    @Published var isInBannerMode: Bool = false
    @Published var isInSheetMode: Bool = false
    @Published var bannerData: ActiveWorkoutSession? = nil //maybe switch this to usign query?? Anway on stop workout defintely just want to use query data
    //    @Environment(\.modelContext) private var modelContext
    //    @Query var activeSession: [ActiveWorkoutSession]
    
    
    func startWorkout( session: ActiveWorkoutSession) {
        //--TODO: set title data differently
        bannerData = session
        isActiveWorkout = true
    }
    func stopWorkout() {
        print("Stop Workout Function Called")
        //reset banner
        isActiveWorkout = false
        bannerData = nil
        isInSheetMode = false
        isInSheetMode = false
        // do actual operations on swiftdata store
        
        
    }
    func saveWorkoutChanges(session: ActiveWorkoutSession) {
    }
    
    func restoreFullScreen(){
        print("restoring full screen")
        isInSheetMode = true
    }
}
@MainActor
class UserStateData: ObservableObject {
    
    @Published var session: Session?
    
    init() {
        // 2. Set up a listener that fires whenever the auth state changes.
        // This is the key to making your UI react automatically to logins and logouts.
        Task {
            for await state in supabase.auth.authStateChanges {
                // The session is nil if the user is logged out.
                self.session = state.session
            }
        }
    }
}
