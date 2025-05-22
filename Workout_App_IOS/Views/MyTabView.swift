//
//  TabbedItems.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/16/25.
//

import Foundation
import SwiftUICore
import SwiftUI
import SwiftData

//import Foundation
struct MainTabbedView: View {
    @State var selectedTab = 0
    @Namespace var tabAnimation
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            
            TabView(selection: $selectedTab) {
                HomePage()
                    .tag(0)
                
                Logger()
                    .tag(1)
                
                CameraPage()
                    .tag(2)
                
                UserPage()
                    .tag(3)
                
            }
            ZStack {
                
                
                GeometryReader { geo in
                    let tabCount = TabbedItems.allCases.count
                    let tabWidth = geo.size.width / CGFloat(tabCount)
                    
                    // Background that slides
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.blue)
                        .frame(width: tabWidth, height: 90)
                        .offset(x: CGFloat(selectedTab) * tabWidth)
                        .matchedGeometryEffect(id: "tabBackground", in: tabAnimation)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        .background(.ultraThinMaterial)
                }
                
                HStack{
                    ForEach((TabbedItems.allCases), id: \.self) { item in
                        Button{
                            selectedTab = item.rawValue

                        } label: {

                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                        }
                    }
                }
            }
            .frame(height: 90)
            .background(.white.opacity(1))
            .padding(.horizontal, 0)
            .opacity(1)
        }.ignoresSafeArea(.all, edges: .all)
    }
}
extension MainTabbedView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        
        HStack(spacing: 0) {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(isActive ? .black : .gray)
                .frame(width: 25, height: 25)
            Spacer()
        }
        .frame(maxWidth: .infinity).frame(height: 90)
    }
    
}

enum TabbedItems: Int, CaseIterable {
    case home = 0
    case logger
    case chat
    case profile
    
    var title: String {
        switch self {
        case.home:
            return "Home"
        case.logger:
            return "Logger"
        case.chat:
            return "Chat"
        case.profile:
            return "Profile"
            
        }
        
    }
    var iconName: String {
        switch self {
        case.home:
            return "house.fill"
        case.logger:
            return "square.and.pencil"
        case.chat:
            return "camera.fill"
        case.profile:
            return "person.crop.circle.fill"
        }
    }
}



//#Preview {
//    
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: WorkoutSession.self, configurations: config)
//   
//    let context = container.mainContext
//    context.insert(WorkoutSession(name: "legs", duration: 10))
//    
//    
//   return MainTabbedView()
//        .modelContainer(container)
//}
