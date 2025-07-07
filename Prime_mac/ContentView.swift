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
                    //verification of the conjecture in base 7
                    //let calc = CalculCalculation()
                    //calc.start()
                    
                    //verification in other bases
                    //let tester = GeneralConjectureTester()
                    //tester.start()
                    
                    // verification for a specific base
                    let tester = SpecialBaseTester()
                    tester.start()

                }
            }
    }
}

#Preview {
    ContentView()
}
