import Testing
import WaifuDiffusionTagger
import Foundation
import CoreGraphics
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


@Test func example() async throws {
    let tagger = try await Tagger()
    
    let url = Bundle.module.url(forResource: "dog", withExtension: "png", subdirectory: "Resources")!
    let image: CGImage
#if os(macOS)
    image = NSImage(contentsOf: url)!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
#else
    image = UIImage(contentsOfFile: url.path)!.cgImage!
#endif
    let output = try await tagger.predict(image)
    let collected = output.collected(thresholds: [.character : 0.5, .general: 0.5, .rating : 0.5])
    
    print(collected)
    
    #expect(Array(output).count == 10861)
    #expect(collected[.general]!.contains(where: { $0.tag.name == "dog" }))
    #expect(collected[.general]!.contains(where: { $0.tag.name == "no humans" }))
    #expect(collected[.general]!.contains(where: { $0.tag.name == "shiba inu" }))
}
