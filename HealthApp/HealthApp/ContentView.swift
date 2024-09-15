//
//  ContentView.swift
//  HealthApp
//
//  Created by Javier Heisecke on 2024-09-15.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var healthKit: HealthKitManager

    var body: some View {
        VStack {
            Text("Steps today:")
            Text("\(healthKit.totalSteps)")
            Divider()
            HStack {
                TextField("Enter new steps for today", text: $healthKit.newStepsText)
                    .keyboardType(.numberPad)
                Button {
                    healthKit.saveStepCount()
                } label: {
                    Text("Send")
                        .tint(.blue)
                }
            }

        }
        .padding()
        .task {
            await healthKit.onAppear()
        }
    }
}

#Preview {
    ContentView(healthKit: HealthKitManager())
}
