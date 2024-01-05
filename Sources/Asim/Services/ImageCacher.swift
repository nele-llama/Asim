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
    private var cache = [String: UIImage]()
    private let concurrentQueue = DispatchQueue(label: "image cacher write queue", attributes: .concurrent)
    
    private init() {}
    
    func getCashedImage(for key: String) -> UIImage? {
        cache[key]
    }
    
    func cacheImage(with key: String, value: UIImage) {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            cache[key] = value
        }
    }
    
    public func invalidate() {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            cache.removeAll()
        }
    }
    
    public func invalidateCache(for key: String) {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            cache.removeValue(forKey: key)
        }
    }
}
