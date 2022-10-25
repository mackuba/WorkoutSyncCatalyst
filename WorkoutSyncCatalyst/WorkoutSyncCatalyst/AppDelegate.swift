//
//  AppDelegate.swift
//  WorkoutSyncCatalyst
//
//  Created by Kuba Suder on 25/10/2022.
//

import HealthKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        authorizeHealthKit()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Sorry, HealthKit is not available")
            return
        }

        let dataTypes: Set<HKObjectType> = [HKObjectType.workoutType()]
        let healthStore = HKHealthStore()

        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { success, error in
            if success {
                print("HealthKit authorized")

                let query = HKSampleQuery(
                    sampleType: .workoutType(),
                    predicate: nil,
                    limit: 0,
                    sortDescriptors: [NSSortDescriptor(
                        key: HKSampleSortIdentifierEndDate,
                        ascending: false
                    )]
                ) { query, samples, error in
                    if let samples = samples as? [HKWorkout] {
                        print("Got \(samples.count) workouts:")

                        for workout in samples.prefix(upTo: 25) {
                            let type: String
                            switch workout.workoutActivityType {
                            case .running:
                                type = "running 🏃🏻‍♂️"
                            case .walking:
                                type = "walking 🚶🏻‍♂️"
                            case .hiking:
                                type = "hiking 🏔"
                            case .cycling:
                                type = "cycling 🚴🏻‍♂️"
                            default:
                                type = "other (\(workout.workoutActivityType.rawValue))"
                            }

                            let formatter = DateComponentsFormatter()
                            formatter.allowedUnits = [.hour, .minute]
                            formatter.unitsStyle = .abbreviated

                            print("At \(workout.startDate): \(type), time = \(formatter.string(from: workout.duration)!), distance = \(workout.totalDistance!)")
                        }
                    } else {
                        print("Error loading workouts: \(error)")
                    }
                }

                healthStore.execute(query)
            } else {
                print("Error: \(error)")
            }
        }
    }
}

