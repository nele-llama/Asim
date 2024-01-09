//
//  ImageInvalidator.swift
//
//
//  Created by Nenad Biocanin on 4.1.24..
//

import Foundation

public final class ImageInvalidator {
    public static let shared = ImageInvalidator()
    private var invalidationList = [String: Date]()
    private var timer: Timer?
    private let concurrentQueue = DispatchQueue(label: "invalidation list write queue", attributes: .concurrent)

    private init() {
        guard AsimConfigurator.shared.invalidationPeriod != .never else { return }
        startInvalidationMonitoring()
    }
    
    deinit {
        timer?.invalidate()
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
    
    func calculateInvalidationPeriodInMinutes() -> Int {
        switch AsimConfigurator.shared.invalidationPeriod {
        case .afterHours(let hours):
            return hours * 60
        case .afterMinutes(let minutes):
            return minutes
        default:
            return 0
        }
    }
    
    func startTimer(with invalidationPeriodInMinutes: Int) {
        timer = Timer(timeInterval: 30, repeats: true) { _ in
            Task.detached { [weak self] in
                self?.performInvalidation(with: invalidationPeriodInMinutes)
            }
        }
        guard let timer else { return }
        timer.tolerance = TimeInterval(5)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func performInvalidation(with invalidationPeriodInMinutes: Int) {
        invalidationList.forEach { key, value in
            if shouldInvalidate(candidate: value, invalidationPeriodInMinutes: invalidationPeriodInMinutes) {
                ImageCacher.shared.invalidateCache(for: key)
                concurrentQueue.async(flags: .barrier) { [unowned self] in
                    invalidationList.removeValue(forKey: key)
                }
            }
        }
    }
    
    func shouldInvalidate(candidate: Date, invalidationPeriodInMinutes: Int) -> Bool {
        Calendar.current.dateComponents([.minute], from: candidate, to: Date()).minute ?? 0 > invalidationPeriodInMinutes
    }
}


