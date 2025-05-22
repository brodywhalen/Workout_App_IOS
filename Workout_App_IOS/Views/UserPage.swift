//
//  UserPage.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//

import SwiftUI



struct UserPage: View {
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Profile Info
                    HStack(alignment: .center, spacing: 16) {
                        Image("profile_placeholder") // Replace with AsyncImage if needed
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("strongdavid")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("56")
                                        .fontWeight(.bold)
                                    Text("Workout")
                                        .font(.caption)
                                }.frame(alignment: .leading)
                                VStack(alignment: .leading) {
                                    Text("72")
                                        .fontWeight(.bold)
                                    Text("Followers")
                                        .font(.caption)
                                }
                                VStack(alignment: .leading) {
                                    Text("55")
                                        .fontWeight(.bold)
                                    Text("Following")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    // Bio and Follow Button
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📍San Francisco 💪Trying to gain muscle!")
                            .font(.subheadline)
                        Button(action: {}) {
                            Text("Follow")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                }
                .padding()
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Handle edit profile action
                    }) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                            .accessibilityLabel("Edit Profile")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Open settings
                    }) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

#Preview {
    
    UserPage()
}


