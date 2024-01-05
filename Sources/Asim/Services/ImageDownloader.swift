//
//  ImageDownloader.swift
//
//
//  Created by Nenad Biocanin on 4.1.24..
//

import Foundation
import UIKit
import SwiftUI

struct ImageDownloader {
    static func download(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let urlResponse = response as? HTTPURLResponse,
              200...299 ~= urlResponse.statusCode,
              !data.isEmpty
        else { return nil }
        return await UIImage(data: data, scale: UIScreen.main.scale)
    }
}
