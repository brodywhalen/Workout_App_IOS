//
//  WorkoutSession.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/28/25.
//
import SwiftUI

struct WorkoutSessionPage: View {
    
    //    @Binding TemplateforSession: WorkoutTemplate
    
    
    var body: some View {
        VStack {
            HStack {
                VStack (alignment: .leading){
                    
                    Text("Workout Name")
                        .font(.title)
                    Text("May 28th, 2028")
                    Text("Hello World")
                    
//                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            .background(Color.blue)
            
            Grid {
                Divider()
                GridRow {
                    Group {
                        Text("Set")
                        Text("Weight (lbs)")
                        Text("Reps")
                        Text(Image(systemName: "checkmark.diamond"))
                    }.font(.headline)
                }
                Divider()
            
            }
            .background(Color.red)
            .padding()
//            .background(Color.red)
            Spacer()
        }
        

        
    }
}


#Preview {
    WorkoutSessionPage()
}
