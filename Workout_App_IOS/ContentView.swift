//
//  ContentView.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        TabView{
            
                
                
                Group{
                    Text("Tab Vie")
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    Text("Tab View 2")
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    Text("Tab View 3")
                        .tabItem {
                            Label("Record", systemImage: "video.badge.plus")
                        }
                    Text("Tab View 4")
                        .tabItem {
                            Label("Schedule", systemImage: "calendar.badge.plus")
                        }
                    Text("Tab View 4")
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle.fill")
                        }.background(.yellow)
                    
                }
//                .toolbarBackground(.indigo, for: .tabBar)
//                .toolbarBackground(.visible, for: .tabBar)
//                .toolbarColorScheme(.dark, for: .tabBar)
                
            }
        

    }
}
    

#Preview {
    ContentView()
}
