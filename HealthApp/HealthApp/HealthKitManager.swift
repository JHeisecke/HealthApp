//
//  ContentViewModel.swift
//  HealthApp
//
//  Created by Javier Heisecke on 2024-09-15.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore: HKHealthStore?

    @Published var totalSteps: Double = 0.0
    @Published var newStepsText: String = ""

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        } else {
            self.healthStore = nil
        }
    }

    func onAppear() async {
        guard let healthStore else { return }
        do {
            try await healthStore.requestAuthorization(toShare: Constants.allTypes, read: Constants.allTypes)
        } catch {
            fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
        }
        getStepCount()
    }

    func getStepCount() {
        guard let healthStore else { return }
        let today = Date()
        let startDate = Calendar.current.startOfDay(for: today)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let query = HKSampleQuery(sampleType: HKObjectType.quantityType(forIdentifier: .stepCount)!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            for sample in samples {
                DispatchQueue.main.async { [weak self] in
                    self?.totalSteps += sample.quantity.doubleValue(for: HKUnit.count())
                }
            }
        }

        healthStore.execute(query)
    }

    func saveStepCount() {
        guard let healthStore, let newSteps = Double(newStepsText) else { return }
        let sample = HKQuantitySample(type: HKObjectType.quantityType(forIdentifier: .stepCount)!, quantity: HKQuantity(unit: HKUnit.count(), doubleValue: newSteps), start: Date(), end: Date())

        healthStore.save(sample) { [weak self] (success, error) in
            if success {
                DispatchQueue.main.async { [weak self] in
                    self?.totalSteps += newSteps
                }
            }
        }
    }

    // MARK: - Constants

    struct Constants {
        static let allTypes: Set = [
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate)
        ]
    }
}
