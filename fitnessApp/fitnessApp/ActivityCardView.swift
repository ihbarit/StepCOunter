//
//  ActivityCardView.swift
//  fitnessApp
//
//  Created by MCNMACBOOK01 on 26/09/23.
//

import SwiftUI

struct ActivityCardView: View {
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter
      }
    var activity : ActivityModel
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            VStack(spacing: 10){
                HStack(alignment: .top){
                    VStack(alignment: .leading, spacing: 5){
                        Text(activity.title)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        Text(activity.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: activity.image)
                        .foregroundColor(.red)
                }
                
                AnimateNumberText(value: .constant(activity.amount) , textColor: .constant(.white), numberFormatter: numberFormatter)
                    .font(.system(size: 24))
                
            }
            .padding()
        }
    }
}

extension Double{
 func formattedNumberWithDecimal(_ number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
    }
}

#Preview {
    ActivityCardView(activity: ActivityModel(id: 0, title: "Daily steps", subtitle: "Goal : 10,000", image: "figure.walk", amount: 6234))
}
