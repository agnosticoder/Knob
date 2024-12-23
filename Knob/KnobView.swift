import SwiftUI
import CoreHaptics

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct KnobView: View {
    @State private var angle: Angle = .zero
    @State private var startAngle: Angle = .zero
    @State private var previousAngle: Angle = .zero
    @State private var gestureValue: DragGesture.Value?
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // Snap points for the knob (e.g., every 30 degrees)
    private let snapPoints = stride(from: 0.0, to: 360.0, by: 30.0).map { $0 }
    
    var body: some View {
        VStack {
            Button("Snap") {
                print(snapPoints)
            }
            Text("\(angle.degrees)")
            //            TextField("Angle", value: $angle, formatter: NumberFormatter())
            //                .background(.white)
            //                .foregroundStyle(.black)
            //
            //            Text("\(gestureValue?.location.x ?? 0)")
            //                .background(.white)
            //                .foregroundStyle(.black)
            //                .padding(.bottom, 50)
            //            Text("\(gestureValue?.location.y ?? 0)")
            //                .background(.white)
            //                .foregroundStyle(.black)
            //                .padding(.bottom, 50)
            
            ZStack {
                // Background markers
                ForEach(0..<snapPoints.count, id: \.self) { snapPoint in
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 8, height: 8)
                        .offset(y: -130)
                        .rotationEffect(.degrees(Double(snapPoint) * 30))
                }
                
                // Rotating knob
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#000000"), Color(hex: "#212121")]),
                                center: .center,
                                startRadius: 110,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#212121"), Color(hex: "#111111")]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 115
                            )
                        )
                        .frame(width: 230)
                    //                        .background(.red)
                        .shadow(radius: 10)
                        .overlay(
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 4, height: 20)
                                .cornerRadius(8)
                                .offset(y: -100)
                                .rotationEffect(withAnimation(.spring) { angle })
                        )
                        .gesture(DragGesture()
                            .onChanged { value in
                                gestureValue = value
                                rotateKnob(value: value)
                            }
                            .onEnded { _ in
                                snapToClosestPoint()
                                previousAngle = angle
                                startAngle = .zero
                            }
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex:"#252525"))
        .preferredColorScheme(.dark)
    }
    
    // Handle the rotation of the knob
    private func rotateKnob(value: DragGesture.Value) {
        let center = CGPoint(x: 115, y: 115) // Center of the knob
        let touchPoint = CGPoint(x: value.location.x, y: value.location.y)
        let deltaX = touchPoint.x - center.x
        let deltaY = touchPoint.y - center.y
        let degrees = Angle(radians: atan2(deltaY, deltaX))
        if startAngle == .zero {
            startAngle = degrees
        }
        let arcAngle = (degrees - startAngle).degrees
        let normalizedArcAngle = arcAngle < 0 ? arcAngle + 360 : arcAngle.truncatingRemainder(dividingBy: 360)
        
        angle = previousAngle + Angle(degrees: normalizedArcAngle)
        
//         Check if we are near a snap point and trigger haptic feedback
        if let closest = snapPoints.min(by: { abs($0 - angle.degrees) < abs($1 - angle.degrees) }),
           abs(angle.degrees - closest) < 5 { // Small threshold for snapping
                                hapticGenerator.impactOccurred()
        }
    }
    
    // Snap the knob to the nearest snap point
    // Fix it should snap to 0 when around 355
    private func snapToClosestPoint() {
        angle.degrees = angle.degrees.truncatingRemainder(dividingBy: 360)
        if let closest = snapPoints.min(by: { abs($0 - angle.degrees) < abs($1 - angle.degrees) }) {
            print(closest)
            angle = Angle(degrees: closest)
        }
    }
}

#Preview {
    KnobView()
}
