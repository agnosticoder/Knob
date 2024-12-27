//
//  KnobWithVibration.swift
//  Knob
//
//  Created by Satinder Singh on 26/12/24.
//

import SwiftUI

//Todo: Try creating gap in the steps of knob and vibrate on those steps
struct KnobWithVibration: View {
    @State private var angle: Angle = .zero
    @State private var startAngle: Angle = .zero
    @State private var previousAngle: Angle = .zero
    @State private var gestureValue: DragGesture.Value?
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @Binding var knobWidth: Double
    @Binding var step: Double
    
    var center: Double {
        knobWidth/2
    }
    
    var normalizedAngle: Double {
        angle.degrees.truncatingRemainder(dividingBy: 360)
    }
    
    var snapPoints: [Double] {
        Array(stride(from: 0.0, to: 360.0, by: step))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("\(Int(normalizedAngle))")
                .font(.custom("Doto", size: 60))
                .fontWeight(.heavy)
                .padding(.vertical, 50)
            
            Spacer()
            
            ZStack {
                // Background markers
                ForEach(0..<snapPoints.count, id: \.self) { snapPoint in
                    Rectangle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 1.5, height: 12)
                        .offset(y: -(knobWidth/2 + 15))
                        .rotationEffect(.degrees(Double(snapPoint) * step))
                }
                
                // Rotating knob
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#000000"), Color(hex: "#212121")]),
                                center: .center,
                                startRadius: knobWidth/2 - 10,
                                endRadius: knobWidth/2
                            )
                        )
                        .frame(width: (knobWidth + 10))
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#212121"), Color(hex: "#111111")]),
                                center: .center,
                                startRadius: 0,
                                endRadius: knobWidth/2
                            )
                        )
                        .frame(width: knobWidth)
                        .shadow(radius: 50)
                        .overlay(
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 4, height: 20)
                                .cornerRadius(8)
                                .offset(y: -(knobWidth/2 - 20))
                                .rotationEffect(angle)
                        )
                        .gesture(DragGesture()
                            .onChanged { value in
                                gestureValue = value
                                rotateKnob(value: value)
                            }
                            .onEnded { _ in
                                previousAngle = angle
                                startAngle = .zero
                            }
                        )
                }
            }
            
            Spacer()
        }
        .onChange(of: angle, triggerHapticFeedback)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex:"#252525"))
        .preferredColorScheme(.dark)
    }
    
    // Handle the rotation of the knob
    private func rotateKnob(value: DragGesture.Value) {
        let center = CGPoint(x: center, y: center) // Center of the knob
        let touchPoint = CGPoint(x: value.location.x, y: value.location.y)
        let deltaX = touchPoint.x - center.x
        let deltaY = touchPoint.y - center.y
        let degrees = Angle(radians: atan2(deltaY, deltaX))
        if startAngle == .zero { startAngle = degrees }
        
        let arcAngle = (degrees - startAngle).degrees
        let normalizedArcAngle = arcAngle < 0 ? arcAngle + 360 : arcAngle.truncatingRemainder(dividingBy: 360)
        let snapAngle = snapToNearestMarker(normalizedArcAngle)
        
        angle = previousAngle + Angle(degrees: snapAngle)
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.6)
    }
    
    private func snapToNearestMarker(_ value: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: step)
        if remainder < step {
            return value - remainder
        } else if remainder > step - step {
            return value + (step - remainder)
        }
        return value
    }
    
}

#Preview {
    KnobWithVibration(knobWidth: .constant(320), step: .constant(10))
}
