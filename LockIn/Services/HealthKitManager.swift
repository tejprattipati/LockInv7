import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    @Published var isAuthorized = false
    @Published var todaySteps: Int = 0
    @Published var latestWeight: Double? = nil

    private let readTypes: Set<HKObjectType> = {
        var t = Set<HKObjectType>()
        if let w = HKObjectType.quantityType(forIdentifier: .bodyMass) { t.insert(w) }
        if let s = HKObjectType.quantityType(forIdentifier: .stepCount) { t.insert(s) }
        if let wk = HKObjectType.workoutType() { t.insert(wk) }
        return t
    }()

    private init() {
        isAuthorized = UserDefaults.standard.bool(forKey: "hk.authorized")
    }

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            UserDefaults.standard.set(true, forKey: "hk.authorized")
            await fetchTodayData()
        } catch {
            isAuthorized = false
        }
    }

    func fetchTodayData() async {
        await fetchLatestWeight()
        await fetchTodaySteps()
    }

    private func fetchLatestWeight() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            store.execute(HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { [weak self] _, samples, _ in
                Task { @MainActor in
                    self?.latestWeight = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: .pound())
                    cont.resume()
                }
            })
        }
    }

    private func fetchTodaySteps() async {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        let pred = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            store.execute(HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { [weak self] _, stats, _ in
                Task { @MainActor in
                    self?.todaySteps = Int(stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    cont.resume()
                }
            })
        }
    }
}
