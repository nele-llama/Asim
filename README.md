

# Asim

### SDK for downloading and caching images

## Instalation - SPM

`link here`

## Usage

- AsyncImageView
```swift
AsyncImageView(urlString: "https://some.url.to/image.jpg") {
    Text("Downloading...")
}
```

- Set invalidation period
```swift
ImageInvalidator.shared.setInvalidationPeriod(.afterHours(4))
```

- Manual invalidation
```swift
ImageInvalidator.shared.invalidate()
```
