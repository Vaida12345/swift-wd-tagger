//
//  Tagger.swift
//  swift-sd-tagger
//
//  Created by Vaida on 2026-05-19.
//

import CoreML


public final class Tagger {
    
    private let model: TaggerModel
    
    private let tags: [Tag]
    
    static let tagsCount = 10861
    
    
    /// Loads the tagger into memory.
    ///
    /// - Tip: Loading a tagger is a time-consuming process, taking around 800 ms. Additionally, it requires a significant amount of memory while an instance exists, around 500 MB.
    public init(configuration: MLModelConfiguration = MLModelConfiguration()) async throws {
        self.model = try await TaggerModel.load(configuration: configuration)
        self.tags = try Tag.load(from: Bundle.module.url(forResource: "selected_tags", withExtension: "csv")!)
        precondition(self.tags.count == Tagger.tagsCount)
    }
    
    /// Predict tag for the given image.
    public func predict(_ image: CGImage) async throws -> Output {
        // transform image
        let context = CGContext(
            data: nil,
            width: 448,
            height: 448,
            bitsPerComponent: 8,
            bytesPerRow: 448 * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(alpha: .premultipliedFirst)
        )! // input requires kCVPixelFormatType_32ARGB
        
        context.setFillColor(.white)
        context.fill(CGRect(origin: .zero, size: CGSize(width: 448, height: 448)))
        
        context.draw(
            image,
            in: CGRect(
                center: CGPoint(x: 224, y: 224),
                size: CGSize(width: image.width, height: image.height).fitting(in: CGSize(width: 448, height: 448))
            )
        )
        
        let image = context.makeImage()!
        
        let input = try TaggerModelInput(inputWith: image)
        let probabilities = try await self.model.prediction(input: input).output
        
        precondition(self.tags.count == Tagger.tagsCount)
        precondition(probabilities.count == Tagger.tagsCount)
        
        return Output(
            probabilities: [Float](unsafeUninitializedCapacity: Tagger.tagsCount) { buffer, initializedCount in
                initializedCount = Tagger.tagsCount
                probabilities.withUnsafeBytes { bytes in
                    _ = memcpy(buffer.baseAddress, bytes.baseAddress, Tagger.tagsCount * MemoryLayout.stride(ofValue: Float.self))
                }
            },
            tags: self.tags
        )
    }
    
}


extension CGRect {
    
    /// Returns the length of the longer side
    @inlinable
    var longerSide: CGFloat {
        max(self.width, self.height)
    }
    
    /// A point that specifies the coordinates of the rectangle’s center.
    ///
    /// The `origin` is at its lower-left corner.
    @inlinable
    var center: CGPoint {
        get { CGPoint(x: self.origin.x + self.size.width / 2, y: self.origin.y + self.size.height / 2) }
        set { self = CGRect(center: newValue, size: self.size) }
    }
    
    /// Creates an instance with the center point and the size of `CGRect`.
    ///
    /// - Parameters:
    ///   - center: The center point.
    ///   - size: The size of the `CGRect`.
    @inlinable
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
    
}


extension CGSize {
    
    /// Returns the size which `self` fits in `target`.
    @inlinable
    func fitting(in target: CGSize) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        // if the `size` is wider than `pixel size`
        if target.width / target.height >= self.width / self.height {
            height = target.height
            width = self.width * target.height / self.height
        } else {
            width = target.width
            height = self.height * target.width / self.width
        }
        
        return CGSize(width: width, height: height)
    }
    
}
