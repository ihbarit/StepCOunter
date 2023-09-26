//
//  ChartsView.swift
//  fitnessApp
//
//  Created by MCNMACBOOK01 on 26/09/23.
//

import SwiftUI
import Charts

struct DailyStep : Identifiable{
    var id = UUID().uuidString
    let date : Date
    let stepCount : Double
    
}

enum FilterSelection : String, CaseIterable {
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonth = "3M"
    case oneYear = "1Y"
}

struct ChartsView: View {
    @StateObject var healthManager = HealthManager()
    @State var segmentationSelection : FilterSelection = .oneWeek
    var body: some View {
        ScrollView{
            VStack(spacing: 12){
                HStack{
                    Text("Step Chart")
                        .font(.title)
                        .fontWeight(.bold)
                   Spacer()
                }
                .padding(.bottom)
                Chart{
                    ForEach(healthManager.oneMonthChartData){daily in
                        BarMark(x: .value(daily.date.formatted(), daily.date , unit: .day), y: .value("Steps", daily.stepCount))
                    }
                }
                .chartYAxis(content: {
                    AxisMarks(position: .leading)
                })
                .frame(alignment: .leading)
                .frame(height: 350)
                .foregroundColor(.red)
                
                Picker("", selection: $segmentationSelection) {
                    ForEach(FilterSelection.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                    
                }.pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal)
            .onChange(of: segmentationSelection) { newValue in
                //
            }
        }
    }
}

#Preview {
    ChartsView()
}
