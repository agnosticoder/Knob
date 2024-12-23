import SwiftUI

struct OneFingerRotationView: View {
    @State private var angle: Angle = .zero
    @State private var previousAngle: Angle = .zero
    @State private var xAxis: Double = 0
    @State private var yAxis: Double = 0
    @State private var extraVariable: Double = 0
    @State private var startAngle: Angle = .zero

    var body: some View {
        VStack {
            Form {
                Text("\(angle.degrees)")
                Text("\(extraVariable)")
            }
            .frame(height: 200)
            
            Spacer()
            
            ZStack {
                Image(.house)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 350, height: 350)
                    .clipShape(.circle)
                    .rotationEffect(angle)
                    .background(.yellow)
                    .overlay {
                        Circle()
                            .fill(.red)
                            .frame(width:50)
                            .position(x: (xAxis), y: (yAxis))
                    }
                    .overlay {
                        Circle()
                            .fill(.black)
                            .frame(width:5)
                            .position(x: 175, y: 175)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                xAxis = value.location.x
                                yAxis = value.location.y
                                calculateAngle()
                            }
                            .onEnded { _ in
                                previousAngle = angle
                                startAngle = .zero
                            }
                    )
            }
            Spacer()
        }
        .preferredColorScheme(.dark)
    }
    
    func calculateAngle() {
        let center = CGPoint(x: 175, y: 175) // Circle's center
        let touchPoint = CGPoint(x: xAxis, y: yAxis)
        let deltaX = touchPoint.x - center.x
        let deltaY = touchPoint.y - center.y
        let degrees = Angle(radians: atan2(deltaY, deltaX))
        if startAngle == .zero {
            startAngle = degrees
        }
        let arcAngle = (degrees - startAngle).degrees
        let normalizedArcAngle = arcAngle < 0 ? arcAngle + 360 : arcAngle.truncatingRemainder(dividingBy: 360)
        
        angle = previousAngle + Angle(degrees: normalizedArcAngle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OneFingerRotationView()
    }
}
