//
//  Tag.swift
//  swift-sd-tagger
//
//  Created by Vaida on 2026-05-19.
//

import Foundation
import TabularData


extension Tagger {
    
    public struct Tag {
        
        /// Identifier, not used.
        public let tag_id: Int
        
        public let name: String
        
        public let category: Category
        
        /// `count` column in source tag csv.
        public let count: Int
        
        
        static func load(from file: URL) throws -> [Tag] {
            let dataFrame = try DataFrame(contentsOfCSVFile: file)
            return dataFrame.rows.map { row in
                Tag(
                    tag_id: row["tag_id", Int.self]!,
                    name: row["name", String.self]!,
                    category: Category(rawValue: row["category", Int.self]!)!,
                    count: row["count", Int.self]!
                )
            }
        }
        
        
        public enum Category: Int, CaseIterable, Hashable, Sendable, Codable, CustomStringConvertible {
            case general = 0
            case character = 4
            case rating = 9
            
            public var description: String {
                switch self {
                case .general: "general"
                case .character: "character"
                case .rating: "rating"
                }
            }
        }
        
    }
    
}
