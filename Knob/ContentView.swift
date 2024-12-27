//
//  ContentView.swift
//  Knob
//
//  Created by Satinder Singh on 22/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var step = 10.0
    @State private var knobWidth = 320.0

    var body: some View {
        HStack {
            Stepper("Step size \(step)", value: $step, in: 1...10)
            Spacer()
            TextField("Knob Width", value: $knobWidth, format: .number)
        }
        //        KnobView()
        //        OneFingerRotationView()
//                KnobTemplate(knobWidth: 300)
        KnobWithVibration(knobWidth: $knobWidth, step: $step)
//                Text("yo")
//        ExperimentView()
    }
}

#Preview {
    ContentView()
}
