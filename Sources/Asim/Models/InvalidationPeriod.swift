//
//  InvalidationPeriod.swift
//
//
//  Created by Nenad Biocanin on 4.1.24..
//

import Foundation

public enum InvalidationPeriod: Equatable {
    case never
    case afterHours(Int)
    case afterMinutes(Int)
}
