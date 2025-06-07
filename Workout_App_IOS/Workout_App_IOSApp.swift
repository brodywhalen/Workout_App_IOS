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
    
    
//    init() {
//        // Disable the scrollEdgeAppearance "feature"
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .white // or whatever your tab bar background color is
//
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
//    }
    
//    UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance.init(idiom: .unspecified)
//    
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
    @Published var title: String?
    
    func goBannerMode() {
        isActiveWorkout = true
        //TODO: add way to pass current data to this banner. May have to have an active workout environment provider
    }
    
    func restoreFullScreen(){
        print("restoring full screen")
        isInSheetMode = true
    }
}

