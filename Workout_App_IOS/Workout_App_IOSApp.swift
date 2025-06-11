//
//  Workout_App_IOSApp.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/6/25.
//

import SwiftUI
import SwiftData


@main
struct Workout_App_IOSApp: App {

@StateObject var bannerManager = BannerManager() // intializes the banner at startup....maybe not the best idea if I was perfect
    

    var body: some Scene {
        WindowGroup {
            MainTabbedView()
                .environmentObject(bannerManager)
        }
        .modelContainer(appContainer)

    }
}

// banner provider
class BannerManager: ObservableObject {
    @Published var isActiveWorkout: Bool = false
    @Published var isInBannerMode: Bool = false
    @Published var isInSheetMode: Bool = false
    @Published var bannerData: ActiveWorkoutSession? = nil
    
    
    func startWorkout( session: ActiveWorkoutSession) {
        //--TODO: set title data differently
        bannerData = session
//        bannerData = BannerManagerData(title: title, session: session)
        isActiveWorkout = true
    }
   func saveWorkoutChanges(session: ActiveWorkoutSession) {
        // add logic that will update and call contex.save
    }
    
//    func goBannerMode() {
//        isActiveWorkout = true
//        //TODO: add way to pass current data to this banner. May have to have an active workout environment provider
//    }
    
    func restoreFullScreen(){
        print("restoring full screen")
        isInSheetMode = true
    }
}

//class BannerManagerData: ObservableObject {
//    @Published var title: String?
////    @Published var sessionDuration: TimeInterval
//    @Published var WorkoutSessionData: WorkoutSession
//    
//    init(title: String? = nil, session: WorkoutSession) {
//        self.title = title
//        self.WorkoutSessionData = session
//    }
//}
