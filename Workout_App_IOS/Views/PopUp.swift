// Custom popup modal


import SwiftUI

struct WorkoutPopUp: View {
    
    
// place holder data
    
    let name: String
    let duration: Int
    @State private var offset: CGFloat = 1000
    @Binding var isActive: Bool
    let action: () -> ()
    
    var body: some View {
        VStack {
            Text(name)
            Button {
                action()
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
    WorkoutPopUp(name: "Squat", duration: 5, isActive: .constant(true)) {
        print("button clicked")
    }
}
