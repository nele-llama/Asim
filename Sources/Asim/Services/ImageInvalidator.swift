//
//  ImageInvalidator.swift
//
//
//  Created by Nenad Biocanin on 4.1.24..
//

import Foundation

public final class ImageInvalidator {
    public static let shared = ImageInvalidator()
    @UserStorage("invalidationList", defaultValue: [String: Date]()) private var invalidationList
    private var timer: Timer?
    private let concurrentQueue = DispatchQueue(label: "invalidation list write queue", attributes: .concurrent)
    private var invalidationPeriod = InvalidationPeriod.never {
        didSet {
            startInvalidationMonitoring()
        }
    }
    
    private init() {}
    
    deinit {
        timer?.invalidate()
    }
    
    public func setInvalidationPeriod(_ period: InvalidationPeriod) {
        invalidationPeriod = period
    }
    
    public func invalidate() {
        ImageCacher.shared.invalidate()
    }
    
    func addInvalidationRecord(for key: String) {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            invalidationList[key] = Date()
        }
    }
    
    func invalidateRecord(id: String) {
        ImageCacher.shared.invalidateCache(for: id)
    }
}

private extension ImageInvalidator {
    func startInvalidationMonitoring() {
        var invalidationPeriodInMinutes = calculateInvalidationPeriodInMinutes()
        guard invalidationPeriodInMinutes > 0 else { return }
        startTimer(with: invalidationPeriodInMinutes)
    }
    
    func calculateInvalidationPeriodInMinutes() -> Double {
        switch invalidationPeriod {
        case .afterHours(let hours):
            return hours * 60
        case .afterMinutes(let minutes):
            return minutes
        default:
            return 0
        }
    }
    
    func startTimer(with invalidationPeriodInMinutes: Double) {
        timer = Timer(timeInterval: 30, repeats: true) { _ in
            Task.detached { [weak self] in
                self?.performInvalidation(with: invalidationPeriodInMinutes)
            }
        }
        guard let timer else { return }
        timer.tolerance = TimeInterval(5)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func performInvalidation(with invalidationPeriodInMinutes: Double) {
        invalidationList.forEach { key, value in
            if shouldInvalidate(candidate: value, invalidationPeriodInMinutes: invalidationPeriodInMinutes) {
                ImageCacher.shared.invalidateCache(for: key)
                concurrentQueue.async(flags: .barrier) { [unowned self] in
                    invalidationList.removeValue(forKey: key)
                }
            }
        }
    }
    
    func shouldInvalidate(candidate: Date, invalidationPeriodInMinutes: Double) -> Bool {
        abs(candidate.timeIntervalSinceNow) / 60 > invalidationPeriodInMinutes
    }
}


