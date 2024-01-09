//
//  AsimConfigurator.swift
//
//
//  Created by Nenad Biocanin on 8.1.24..
//

import Foundation

public final class AsimConfigurator {
    public static let shared = AsimConfigurator()
    public var cacheType: CacheType = .onDevice
    public var invalidationPeriod = InvalidationPeriod.never
    
    private init() {}
}
