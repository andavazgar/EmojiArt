//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-03-19.
//

import Foundation

struct EmojiArt {
    var background = Background.blank
    var emojis = [Emoji]()
    private var uniqueEmojiId = 0
    
    init() { }
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), withSize size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, location: location, size: size))
    }
    
    
    // MARK: - Emoji
    struct Emoji: Identifiable, Hashable {
        let id: Int
        let text: String
        var location: (x: Int, y: Int)  // Offset from the center
        var size: Int
        
        fileprivate init(id: Int, text: String, location: (x: Int, y: Int), size: Int) {
            self.id = id
            self.text = text
            self.location = location
            self.size = size
        }
        
        // MARK: Conformance to protocols
        // Conformance to Equatable
        static func == (lhs: EmojiArt.Emoji, rhs: EmojiArt.Emoji) -> Bool {
            lhs.id == rhs.id &&
            lhs.text == rhs.text &&
            lhs.location == rhs.location &&
            lhs.size == rhs.size
        }
        
        // Conformance to Hashable
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
