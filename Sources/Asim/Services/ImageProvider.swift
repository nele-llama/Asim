//
//  ImageProvider.swift
//
//
//  Created by Nenad Biocanin on 4.1.24..
//

import Foundation
import UIKit

struct ImageProvider {
    static func getImage(for url: String) async throws -> UIImage? {
        if let cachedImage = await ImageCacher.shared.getCashedImage(for: url) {
            return cachedImage
        }
        let freshImage = try await ImageDownloader.download(from: url)
        Task {
            guard let freshImage else { return }
            await ImageCacher.shared.cacheImage(with: url, value: freshImage)
            ImageInvalidator.shared.addInvalidationRecord(for: url)
        }
        return freshImage
    }
}
