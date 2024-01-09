//
//  ImageCacher.swift
//
//
//  Created by Nenad Biocanin on 4.1.24..
//

import Foundation
import UIKit

public final class ImageCacher {
    public static let shared = ImageCacher()
    private var cacheType: CacheType
    private var cache = [String: Any]()
    private let concurrentQueue = DispatchQueue(label: "image cacher write queue", attributes: .concurrent)
    private lazy var cacheDirectoryUrl = URL.cachesDirectory.appending(path: "Images")
    
    private init() {
        cacheType = AsimConfigurator.shared.cacheType
        guard cacheType == .onDevice else { return }
        try? FileManager.default.createDirectory(
            at: cacheDirectoryUrl,
            withIntermediateDirectories: false
        )
    }
    
    func getCashedImage(for key: String) -> UIImage? {
        switch cacheType {
        case .inMemory:
            return cache[key] as? UIImage
        case .onDevice:
            guard let name = cache[key] as? String else { return nil }
            return try? UIImage(data: Data(contentsOf:  cacheDirectoryUrl.appending(path: name)))
        }
    }
    
    func cacheImage(with key: String, value: UIImage) {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            switch cacheType {
            case .inMemory:
                cache[key] = value
            case .onDevice:
                let name = UUID().uuidString
                cache[key] = name
                guard let data = value.jpegData(compressionQuality: 1.0) else { return }
                try? data.write(
                    to: cacheDirectoryUrl.appending(path: name),
                    options: [.atomic, .completeFileProtection]
                )
            }
        }
    }
    
    public func invalidate() {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            switch cacheType {
            case .inMemory:
                cache.removeAll()
            case .onDevice:
                cache.removeAll()
                try? FileManager.default.removeItem(at: cacheDirectoryUrl)
                try? FileManager.default.createDirectory(
                    at: cacheDirectoryUrl,
                    withIntermediateDirectories: false
                )
            }
            
        }
    }
    
    public func invalidateCache(for key: String) {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            switch cacheType {
            case .inMemory:
                cache.removeValue(forKey: key)
            case .onDevice:
                guard let name = cache[key] as? String else { return }
                cache.removeValue(forKey: key)
                try? FileManager.default.removeItem(at: cacheDirectoryUrl.appending(path: name))
            }
        }
    }
}
