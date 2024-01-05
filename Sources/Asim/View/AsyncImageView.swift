//
//  AsyncImageView.swift
//
//
//  Created by Nenad Biocanin on 4.1.24..
//

import SwiftUI

public struct AsyncImageView<Placeholder: View>: View {
    private let urlString: String
    @ViewBuilder private let placeholder: () -> Placeholder
    @State private var image: UIImage?
    
    public init(urlString: String, placeholder: @escaping () -> Placeholder) {
        self.urlString = urlString
        self.placeholder = placeholder
    }
    
    public var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                placeholder()
            }
        }
        .task {
            loadImage()
        }
    }
}

private extension AsyncImageView {
    func loadImage() {
        Task.detached {
            guard let uiImage = try? await ImageProvider.getImage(for: urlString)
            else { return }
            DispatchQueue.main.async { image = uiImage }
        }
    }
}

#Preview {
    AsyncImageView(urlString: "https://zipoapps-storage-test.nyc3.digitaloceanspaces.com/17_4691_besplatnye_kartinki_volkswagen_golf_1920x1080.jpg") {
        Text("Downloading...")
    }
}
