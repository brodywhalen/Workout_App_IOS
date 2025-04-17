//
//  TabbedItems.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/16/25.
//

import Foundation
import SwiftUICore
import SwiftUI

//import Foundation

enum TabbedItems: Int, CaseIterable {
    case home = 0
    case favorite
    case chat
    case profile
    
    var title: String {
        switch self {
        case.home:
            return "Home"
        case.favorite:
            return "Favorite"
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
        case.favorite:
            return "star.fill"
        case.chat:
            return "message.fill"
        case.profile:
            return "person.crop.circle.fill"
        }
    }
}

struct MainTabbedView: View {
    @State var selectedTab = 0
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            
            TabView(selection: $selectedTab) {
                Text("test 3")
                    .tag(0)
                
                Text("test")
                    .tag(1)
                
                Text("test 2")
                    .tag(2)
                
                Text("test 2")
                    .tag(3)
                
            }
        }
            
        
            ZStack {
    //            Spacer()
                HStack{
                    ForEach((TabbedItems.allCases), id: \.self) { item in
                        Button{
                            selectedTab = item.rawValue
                        } label: {
                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                        }
                        
                    }
                }.padding(6)
            }
            .frame(height: 70)
            .background(.purple.opacity(0.2))
            .cornerRadius(35)
            .padding(.horizontal, 12)
        
    }
}

extension MainTabbedView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: imageName)
                .foregroundColor(isActive ? .black : .gray)
                .frame(width: 20, height: 20)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .black : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? .infinity : 60, height : 60)
        .background(isActive ? .purple.opacity(0.4) : .clear)
        .cornerRadius(30)
    }
}

#Preview {
    MainTabbedView()
}
