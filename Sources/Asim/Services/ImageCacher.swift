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
    @UserStorage("cache", defaultValue: [String: Any]()) private var cache
    private let concurrentQueue = DispatchQueue(label: "image cacher write queue", attributes: .concurrent)
    private lazy var cacheDirectoryUrl = URL.cachesDirectory.appending(path: "Images")
    var cacheType: CacheType = .inMemory {
        didSet {
            setupFileManager()
        }
    }
    
    private init() {}
    
    public func setCacheType(_ cacheType: CacheType) {
        self.cacheType = cacheType
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
    
    func invalidate() {
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
    
    func invalidateCache(for key: String) {
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

private extension ImageCacher {
    func setupFileManager() {
        switch cacheType {
        case .inMemory:
            try? FileManager.default.removeItem(at: cacheDirectoryUrl)
        case .onDevice:
            try? FileManager.default.createDirectory(
                at: cacheDirectoryUrl,
                withIntermediateDirectories: false
            )
        }
    }
}
