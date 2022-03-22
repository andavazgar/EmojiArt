//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-03-20.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    typealias Background = EmojiArt.Background
    typealias Emoji = EmojiArt.Emoji
    
    @Published private(set) var emojiArt: EmojiArt
    var emojis: [Emoji] { emojiArt.emojis }
    var background: Background { emojiArt.background }
    
    
    // MARK: - Methods
    init() {
        emojiArt = EmojiArt()
        emojiArt.addEmoji("😀", at: (x: -200, y: -100), withSize: 80)
        emojiArt.addEmoji("😉", at: (x: 50, y: 100), withSize: 40)
    }
    
    
    // MARK: - Intents
    func setBackground(_ background: Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), withSize size: Int) {
        emojiArt.addEmoji(emoji, at: location, withSize: size)
    }
    
    func moveEmoji(_ emoji: Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].location.x += Int(offset.width)
            emojiArt.emojis[index].location.y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            let newSize = (CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero)
            emojiArt.emojis[index].size = Int(newSize)
        }
    }
}
