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
    @State private var startTouchAngle: Angle = .zero
    @State private var previousAngle: Angle = .zero
    @State private var examine: Double = 0
    @State private var examine2: Double = 0
    
    @Binding var knobWidth: Double
    @Binding var step: Double

    private let generator = UIImpactFeedbackGenerator(style: .soft)
    
    var knobCenter: Double {
        knobWidth/2
    }

    var snapPoints: [Double] {
        Array(stride(from: 0.0, to: 360.0, by: step))
    }
    
    var body: some View {
        VStack {
//            Text("examine: \(Int(examine))")
//                .font(.custom("Doto", size: 30))
//                .fontWeight(.heavy)
//                .foregroundStyle(.black)
//
//            Text("examine2: \(Int(examine2))")
//                .font(.custom("Doto", size: 30))
//                .fontWeight(.heavy)
//                .foregroundStyle(.black)
//
//            Text("Previous: \(previousAngle.degrees)")
//                .font(.custom("Doto", size: 30))
//                .fontWeight(.heavy)
//                .foregroundStyle(.black)
//
//            Text("Angle: \(angle.degrees)")
//                .font(.custom("Doto", size: 30))
//                .fontWeight(.heavy)
//                .foregroundStyle(.black)
//
//            Spacer()
            
            Text("\(angle.degrees)")
                .font(.custom("Doto", size: 60))
                .fontWeight(.heavy)
                .foregroundStyle(.black)
                .padding(.vertical, 50)
            
            Spacer()
            
            ZStack {
                // Background markers
                ForEach(0..<snapPoints.count, id: \.self) { snapPoint in
                Rectangle()
                    .fill(angle.degrees >= Double(snapPoint) * step ? .yellow : Color.black.opacity(0.8))
                    .frame(width: 1.5, height: 10)
                    .offset(y: -(knobWidth/2 + 15))
                    .rotationEffect(.degrees(Double(snapPoint) * step))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: angle.degrees)
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
                        .frame(width: (knobWidth + 5))
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#404040"), Color(hex: "#232323")]),
                                center: .center,
                                startRadius: 0,
                                endRadius: knobWidth/2
                            )
                        )
                        .frame(width: knobWidth)
                        .shadow(color: .black, radius: 10, x: 3, y:3)
                        .overlay(
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 4, height: 20)
                                .cornerRadius(8)
                                .offset(y: -(knobWidth/2 - 20))
                                .rotationEffect(angle)
                                //Todo: Fix the animation when knob goes from 359 to 0
                                // .animation(.spring(response: 0.3, dampingFraction: 0.3), value: reactangleAnimation)
                        )
                        .gesture(DragGesture()
                            .onChanged { value in
                                rotateKnob(value: value, knobCenter: knobCenter)
                            }
                            .onEnded { _ in
                                previousAngle = Angle(degrees: normalizeAngle(angle.degrees))
                                startTouchAngle = .zero
                            }
                        )
                }
            }
            
            Spacer()
        }
        .onChange(of: angle, triggerHapticFeedback)
        // .onChange(of: angle) { oldValue, newValue in 
        //     print("Old Value: \(oldValue)")
        //     reactangleAnimation += 3
        // }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex:"#717171"))
        .preferredColorScheme(.dark)
    }
    
    // Handle the rotation of the knob
    private func rotateKnob(value: DragGesture.Value, knobCenter: Double) {
        let touchPoint = CGPoint(x: value.location.x, y: value.location.y)
        let deltaX = touchPoint.x - knobCenter
        let deltaY = touchPoint.y - knobCenter
        let currentTouchAngle = Angle(radians: atan2(deltaY, deltaX))

        // Reset start angle of arc when the knob is touched
        if startTouchAngle == .zero { startTouchAngle = currentTouchAngle }
        let arcAngle = (currentTouchAngle - startTouchAngle).degrees
        let normalizedArcAngle = normalizeAngle(arcAngle)

        let snapAngle = snapToNearestMarker(normalizedArcAngle)
        
        let newAngle = previousAngle + Angle(degrees: snapAngle)
        angle = Angle(degrees: normalizeAngle(newAngle.degrees))
    }
    
    private func snapToNearestMarker(_ value: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: step)
        return value - remainder
    }

    private func triggerHapticFeedback() {
        generator.prepare()
        generator.impactOccurred(intensity: 0.6)
    }

    private func normalizeAngle(_ angle: Double) -> Double {
        angle < 0 ? angle + 360 : angle.truncatingRemainder(dividingBy: 360)
    }
    
}

#Preview {
    KnobWithVibration(knobWidth: .constant(320), step: .constant(5))
}
