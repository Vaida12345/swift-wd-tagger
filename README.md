# WaifuDiffusion Tagger in Swift

This is a swift implementation of [wd-swinv2-tagger-v3](https://huggingface.co/SmilingWolf/wd-swinv2-tagger-v3/).

```swift
// import this package
import WaifuDiffusionTagger

// Load Tagger into memory.
let tagger = try await Tagger()

// Load input image
let image: CGImage = ...

// predict tags, returns tags and their corresponding probabilities.
let output = try await tagger.predict(image)

// use `collected` to filter and categorize results
let collected = output.collected(thresholds: [.character : 0.5, .general: 0.5, .rating : 0.5])

print(collected)
// [general: [no humans: 0.99, shiba inu: 0.99, ...], rating: [general: 0.99]]
````

## Credits
- [SmilingWolf/wd-swinv2-tagger-v3](https://huggingface.co/SmilingWolf/wd-swinv2-tagger-v3/)
- [Jannchie/wdtagger](https://github.com/Jannchie/wdtagger)
