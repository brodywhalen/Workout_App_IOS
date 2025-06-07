// Custom popup modal


import SwiftUI

struct WorkoutPopUp: View {
    
    
// place holder data
    let template: WorkoutTemplate
    
//    let name: String = t
//    let exercises: Int
    @State private var offset: CGFloat = 1000
//    @State private var isShowingSheet = false
    @Binding var isActive: Bool
    @Binding var workoutIsActive:Bool
    @Binding var isInSheetMode:Bool
    let action: () -> ()
    
    var body: some View {
        VStack {
            Text(template.name)
            ForEach(template.blocks.flatMap(\.allExercises)){ exercise in
                HStack {
                    Text(" - \(exercise.exercise.name): \(exercise.defaultSets)x\(exercise.defaultReps)")
                        .font(.body)
                    Spacer()
                }
                
            }
            .padding()
            Button {
                action()
                workoutIsActive.toggle() // maybe have it so that workout is active is only started when play is pressed.
                isInSheetMode.toggle()
                close()
            } label: {
                ZStack{
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.blue)
                    Text("Start Session")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                    
                    
                }
                .padding()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        print("working?")
                        close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .tint(.black)
                }
                
                Spacer()
            }.padding()
            
        }
        .shadow(radius: 20)
        .padding(30)
        .offset(x: 0, y: offset)
        .onAppear {
            withAnimation(.spring()) {
                offset = 0
            }
        }

    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 1000
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isActive = false
        }
        
    }
    
}


#Preview {
//    WorkoutPopUp(name: "Squat", duration: 5, isActive: .constant(true)) {
//        print("button clicked")
//    }
}
