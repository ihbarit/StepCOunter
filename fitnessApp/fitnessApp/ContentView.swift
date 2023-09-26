//
//  ContentView.swift
//  fitnessApp
//
//  Created by MCNMACBOOK01 on 26/09/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var healthManager = HealthManager()
    
    var body: some View {
        NavigationView(content: {
            ScrollView{
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2), content: {
                       
                        ForEach(healthManager.activities.sorted(by: {$0.value.id < $1.value.id}) , id: \.key) { item in
                            ActivityCardView(activity: item.value)
                        }
                    })
                }
                .padding(.top)
            }
            .padding(.horizontal)
            .navigationTitle("All Health Data")
        })
        .onAppear{
            healthManager.startObservingSteps()
        }
    }
}

#Preview {
    ContentView()
}
