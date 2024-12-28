//
//  ContentView.swift
//  Knob
//
//  Created by Satinder Singh on 22/12/24.
//

import SwiftUI
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @State private var step = 3.0
    @State private var knobWidth = 320.0

    var body: some View {
         KnobWithVibration(knobWidth: $knobWidth, step: $step)
//        KnobTemplate(knobWidth: knobWidth)
            .enableInjection()
    }
}

#Preview {
    ContentView()
}
