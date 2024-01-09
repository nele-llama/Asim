

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
ImageCacher.shared.setCacheType(.onDevice)
```

- Set invalidation period
```swift
ImageInvalidator.shared.setInvalidationPeriod(.afterHours(4))
```

- Manual invalidation
```swift
ImageInvalidator.shared.invalidate()
```
