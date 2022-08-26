//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-03-19.
//

import Foundation

struct EmojiArt: Codable {
    var background = Background.blank
    var emojis = [Emoji]()
    private var uniqueEmojiId = 0
    
    init() { }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArt.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArt(json: data)
    }
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), withSize size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, location: location, size: size))
    }
    
    mutating func deleteEmoji(_ emoji: Emoji) {
        emojis.remove(emoji)
    }
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    
    // MARK: - Emoji
    struct Emoji: Identifiable, Hashable, Codable {
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
        private enum CodingKeys: CodingKey {
            case id, text, locationX, locationY, size
        }
        
        // Conformance to Decodable
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.text = try container.decode(String.self, forKey: .text)
            self.size = try container.decode(Int.self, forKey: .size)
            
            let x = try container.decode(Int.self, forKey: .locationX)
            let y = try container.decode(Int.self, forKey: .locationY)
            self.location = (x, y)
        }
        
        // Conformance to Encodable
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(text, forKey: .text)
            try container.encode(location.x, forKey: .locationX)
            try container.encode(location.y, forKey: .locationY)
            try container.encode(size, forKey: .size)
        }
        
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
