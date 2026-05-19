//
//  Output.swift
//  swift-sd-tagger
//
//  Created by Vaida on 2026-05-19.
//

extension Tagger {
    
    public struct Output: Sequence {
        
        let probabilities: [Float]
        let tags: [Tag]
        
        public func makeIterator() -> Iterator {
            Iterator(probabilities: probabilities, tags: tags)
        }
        
        /// - Returns: Tags are reserved sorted by probability.
        public func collected(thresholds: [Tag.Category : Float]) -> [Tag.Category : [Element]] {
            var results: [Tag.Category : [Element]] = [:]
            results.reserveCapacity(Tag.Category.allCases.count)
            
            var i = 0
            while i < Tagger.tagsCount {
                let tag = self.tags[i]
                let probability = self.probabilities[i]
                let category = tag.category
                
                let threshold = thresholds[category] ?? 0.0
                if probability >= threshold {
                    results[category, default: []].append(Element(tag: tag, probability: probability))
                }
                
                i &+= 1
            }
            
            // sort results
            for key in results.keys {
                results[key]?.sort(by: { $0.probability > $1.probability })
            }
            
            return results
        }
        
        
        public struct Element: CustomStringConvertible {
            
            public let tag: Tag
            public let probability: Float
            @inlinable
            public var name: String { self.tag.name }
            @inlinable
            public var category: Tag.Category { self.tag.category }
            
            public var description: String {
                "\(self.tag.name): \(self.probability.formatted(.number.precision(.fractionLength(2))))"
            }
            
            
            internal init(tag: Tagger.Tag, probability: Float) {
                self.tag = tag
                self.probability = probability
            }
            
            public init(id: Int, name: String, category: Tag.Category, count: Int, probability: Float) {
                self.init(tag: Tag(tag_id: id, name: name, category: category, count: count), probability: probability)
            }
            
#if DEBUG
            public static var preview: Element {
                Element(tag: Tag(tag_id: 001, name: "general", category: .general, count: 1000), probability: 0.75)
            }
#endif
        }
        
        public struct Iterator: IteratorProtocol {
            private var index: Int
            private let probabilities: [Float]
            private let tags: [Tag]
            
            fileprivate init(probabilities: [Float], tags: [Tag]) {
                self.index = 0
                self.probabilities = probabilities
                self.tags = tags
            }
            
            public mutating func next() -> Element? {
                guard index < probabilities.count else { return nil }
                let probability = probabilities[index]
                let tag = tags[index]
                index += 1
                
                return Element(tag: tag, probability: probability)
            }
        }
        
    }
    
}
