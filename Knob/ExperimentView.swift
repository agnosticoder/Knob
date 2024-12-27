//
//  ExperimentView.swift
//  Knob
//
//  Created by Satinder Singh on 26/12/24.
//

import SwiftUI

struct ExperimentView: View {
    @State private var dragLocation: CGPoint = .zero
    @State private var isInsideSquare: Bool = false
    
    let squareSize: CGFloat = 350 // Size of the square
    
    var body: some View {
        ZStack {
            // The square that the user will interact with
            Rectangle()
                .frame(width: squareSize, height: squareSize)
                .foregroundColor(.blue)
                .position(x: 200, y: 300) // Position of the square on the screen
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragLocation = value.location
                            isInsideSquare = isPointInsideSquare(dragLocation)
                            if isInsideSquare {
                                triggerHapticFeedback()
                            }
                        }
                )
            
            // Optional: Show the current drag position
            Text("Drag Position: (\(Int(dragLocation.x)), \(Int(dragLocation.y)))")
                .position(x: 200, y: 500)
                .foregroundColor(.black)
        }
    }
    
    // Check if the point is inside the square
    private func isPointInsideSquare(_ point: CGPoint) -> Bool {
        let squareOrigin = CGPoint(x: 200 - squareSize / 2, y: 300 - squareSize / 2)
        return point.x >= squareOrigin.x &&
        point.x <= squareOrigin.x + squareSize &&
        point.y >= squareOrigin.y &&
        point.y <= squareOrigin.y + squareSize
    }
    
    // Trigger the haptic feedback when inside the square
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    ExperimentView()
}
