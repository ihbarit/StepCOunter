//
//  HealthManager.swift
//  fitnessApp
//
//  Created by MCNMACBOOK01 on 26/09/23.
//

import Foundation
import HealthKit

extension Date{
    static var startOfDay : Date{
        Calendar.current.startOfDay(for: Date())
    }
    static var oneMonthAgo : Date{
        let oneMonth =  Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return Calendar.current.startOfDay(for: oneMonth)
    }
}

class HealthManager : ObservableObject{
    let healthStore = HKHealthStore()
    @Published var activities : [String : ActivityModel] = [:]
    @Published var oneMonthChartData : [DailyStep] = [DailyStep]()
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let healthTypes : Set = [steps, calories]
        
        Task{
            do{
                try await healthStore.requestAuthorization(toShare:[] ,read: healthTypes)
                fetchTodaysSteps()
                fetchTodaysCalories()
                fetchPasthMonthStepData()
            }catch{
                print("Error finding health data")
            }
        }
        
    }
    func fetchTodaysSteps(){
        let step = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: step, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity() , error == nil else{
                print("Error fetching todays steps")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            let activity = ActivityModel(id: 0, title: "Today's steps", subtitle: "Goal 10,000 steps", image: "figure.walk", amount: stepCount)
            DispatchQueue.main.async{
                self.activities["TodaysSteps"] = activity
            }
            print(stepCount)
        }
        healthStore.execute(query)
        
    }
    
    func fetchTodaysCalories(){
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity() , error == nil else{
                print("Error fetching calories")
                return
            }
            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let activity = ActivityModel(id: 1, title: "Today's calories", subtitle: "Goal 900 kcal", image: "flame", amount: caloriesBurned)
            DispatchQueue.main.async{
                self.activities["TodaysCalories"] = activity
            }
            
        }
        healthStore.execute(query)
    }
    
    func fetchDailySteps(startDate : Date, completion : @escaping([DailyStep]) -> Void){
        let steps = HKQuantityType(.stepCount)
        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: steps, quantitySamplePredicate: nil, anchorDate: startDate, intervalComponents: interval)
        query.initialResultsHandler = { query, result, error in
            guard let result = result else{
                completion([])
                return
            }
            var dailySteps = [DailyStep]()
            result.enumerateStatistics(from: startDate, to: Date()) { statistics, stop in
                dailySteps.append(DailyStep(date: statistics.startDate, stepCount: statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0.0))
            }
            completion(dailySteps)
        }
        healthStore.execute(query)
    }
    
     func startObservingSteps() {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { (query, completionHandler, error) in
            if let error = error {
                // Handle error
                print("Observer query error: \(error.localizedDescription)")
                return
            }
            
            // Handle the step count update
            self.fetchTodaysSteps()
            
            // Call the completion handler
            completionHandler()
        }
        
        healthStore.execute(observerQuery)
    }
    
}
extension HealthManager{
    func fetchPasthMonthStepData(){
        fetchDailySteps(startDate: .oneMonthAgo) { dailySteps in
            DispatchQueue.main.async{
                self.oneMonthChartData = dailySteps
            }
        }
    }
}
