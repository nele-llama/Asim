

# Asim

### SDK for downloading and caching images

## Instalation - SPM

`https://github.com/nele-llama/Asim.git`

## Usage

- AsyncImageView
```swift
AsyncImageView(urlString: "https://some.url.to/image.jpg") {
    Text("Downloading...")
}
```

- Set cache type
```swift
AsimConfigurator.shared.cacheType = .onDevice
```

- Set invalidation period
```swift
AsimConfigurator.shared.invalidationPeriod = .afterMinutes(2)
```

- Manual invalidation
```swift
ImageInvalidator.shared.invalidate()
```
