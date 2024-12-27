//
//  KnobTemplate.swift
//  Knob
//
//  Created by Satinder Singh on 26/12/24.
//

import SwiftUI

struct KnobTemplate: View {
    @State private var angle: Angle = .zero
    @State private var startAngle: Angle = .zero
    @State private var previousAngle: Angle = .zero
    @State private var gestureValue: DragGesture.Value?
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    let knobWidth: Double
    var center: Double {
        knobWidth/2
    }
    
    var normalizedAngle: Double {
        angle.degrees.truncatingRemainder(dividingBy: 360)
    }
    
    // Snap points for the knob (e.g., every 30 degrees)
    private let snapPoints = stride(from: 0.0, to: 360.0, by: 30.0).map { $0 }
    
    var body: some View {
        VStack {
            Text("\(normalizedAngle)")
                .padding(.vertical, 50)
            
            ZStack {
                // Background markers
                ForEach(0..<snapPoints.count, id: \.self) { snapPoint in
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 8, height: 8)
                        .offset(y: -(knobWidth/2 + 15))
                        .rotationEffect(.degrees(Double(snapPoint) * 30))
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
        }
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
        if startAngle == .zero {
            startAngle = degrees
        }
        let arcAngle = (degrees - startAngle).degrees
        let normalizedArcAngle = arcAngle < 0 ? arcAngle + 360 : arcAngle.truncatingRemainder(dividingBy: 360)
        
        angle = previousAngle + Angle(degrees: normalizedArcAngle)
    }
}

#Preview {
    KnobTemplate(knobWidth: 300)
}
