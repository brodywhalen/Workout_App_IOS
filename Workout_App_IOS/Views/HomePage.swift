//
//  HomePage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 4/22/25.
//
import SwiftUI

struct HomePage: View {
    
    @State private var lastOffset: CGFloat = 0
    @State private var hideHeader: Bool = false
    @State private var pinned: Bool = true
    let headerHeight: CGFloat = 110
    
    
//    @ViewBuilder
    var body: some View {
//        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        ForEach(0..<50) { item in
                                Text("item \(item)")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                        Spacer()
                    }.edgesIgnoringSafeArea(.bottom)

                }.background(Color.blue)
                    .frame(maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.bottom)
//                Text("Please God Work")
//                    .background(Color.red)
                }
//                    ScrollView {
//                        VStack(spacing: 20) {
////                            Spacer()
////                                .frame(height: headerHeight - 40)
////                            GeometryReader { geo in
////                                Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
////                            }
////                            .frame(height: 0)
//                            
//                            ForEach(0..<50) { item in
//                                Text("item \(item)")
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .background(Color.white)
//                                    .cornerRadius(10)
//                                    .shadow(radius: 2)
//                            }
//                        }
//                    }
//                    .frame(maxHeight: .infinity, alignment: .top)
//                    .ignoresSafeArea(.container, edges: .bottom)
//                    .background(Color(.systemGroupedBackground))
//                    .onPreferenceChange(ScrollOffsetKey.self) { value in
////                            print("Scroll Offset: \(value)")
//                            let offsetChange = value - lastOffset
//                            
//                            if value > 5 {
//                                pinned = true
//                            } else {
//                                pinned = false
//                            }
//                        
//                            if offsetChange < -5 {
//                                withAnimation{
//                                    hideHeader = true
//                                }
//                            } else if offsetChange > 5 {
//                                withAnimation {
//                                    hideHeader = false
//                                }
//                            }
//                            lastOffset = value
//                        }
//                
//                    Header(headerHeight: headerHeight)
//                        .frame(height: headerHeight)
//                        .offset(y: hideHeader && !pinned ? -headerHeight : 0)
//                        .opacity(hideHeader ? 0 : 1)
//                        .animation(.easeInOut(duration: 0.25), value: hideHeader)
//                }
//        .navigationBarHidden(true)
//        .edgesIgnoringSafeArea(.bottom)
//            .background(Color(.systemGroupedBackground))
//            .edgesIgnoringSafeArea(.bottom)
    }

//            .edgesIgnoringSafeArea(.top)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
//    struct ScrollOffsetKey: PreferenceKey {
//        static var defaultValue: CGFloat = 0
//        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat){
//            value = nextValue()
//        }
//    }


//struct Header: View {
//    let headerHeight:CGFloat
//    
//    var body: some View {
//        VStack {
//            Spacer() // Pushes content to the bottom
//            Text("Twittr")
//                .font(.largeTitle)
//                .bold()
//                .frame(maxWidth: .infinity)
//                .padding(.bottom, 12)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: headerHeight) // Match your header height
//        .background(Color.blue)
//        .foregroundColor(.white)
//        .zIndex(1)
//        .overlay(
//            Rectangle()
//                .frame(height: 1)
//                .foregroundColor(.black),
//            alignment: .bottom
//        )
//    }
//   
//}
