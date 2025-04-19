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
                Text("test 3")/*.frame(maxWidth: .infinity, maxHeight: .infinity).background(.green).ignoresSafeArea()*/
                    .tag(0)
                
                Text("test")
                    .tag(1)
                
                Text("test 2")
                    .tag(2)
                
                Text("test 2")
                    .tag(3)
                
            }
//            Divider()
            ZStack {
    //
//                Divider()
                HStack{
//                    Divider()
                    ForEach((TabbedItems.allCases), id: \.self) { item in
                        Button{
                            selectedTab = item.rawValue

                        } label: {
                            
//                            Text("Test")
                            
                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                        }
                    }
//                    Divider()
                }
                
            }
            .frame(height: 90)
            .background(.purple.opacity(0.2))
//            .cornerRadius(12)
            .padding(.horizontal, 0)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.black),
                alignment: .top
            )
            

        

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
//            Text(title)
//                .font(.system(size: 14))
//                .foregroundColor(isActive ? .black : .gray)

//            if isActive {
//                Text(title)
//                    .font(.system(size: 14))
//                    .foregroundColor(isActive ? .black : .gray)
//            }
            Spacer()
        }
        /*.frame(width: isActive ? .infinity : 60, height : 60)*/
        .frame(width: isActive ? .infinity : .infinity, height : 90 )
        .background(isActive ? .purple.opacity(0.4) : .clear)
        .cornerRadius(0)
    }
}

#Preview {
    MainTabbedView()
}
