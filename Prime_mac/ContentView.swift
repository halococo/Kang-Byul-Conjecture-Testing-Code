//
//  ContentView.swift
//  Prime_mac
//
//  Created by Kang Byul on 2025/07/06.
//

import SwiftUI

struct ContentView: View {
    @State private var message = "Calculating..."

    var body: some View {
        Text(message)
            .padding()
            .onAppear {
                DispatchQueue.global().async {
                    let calc = CalculCalculation()
                    calc.start()
                }
            }
    }
}

#Preview {
    ContentView()
}
