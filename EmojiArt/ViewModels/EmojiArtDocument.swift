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
    
    @Published private(set) var emojiArt: EmojiArt {
        didSet {
            if emojiArt.background != oldValue.background {
                updateBackgroundImage()
            }
        }
    }
    @Published var backgroundImage: UIImage?
    @Published var isLoadingBackgroundImage = false
    
    var emojis: [Emoji] { emojiArt.emojis }
    var background: Background { emojiArt.background }
    
    
    // MARK: - Methods
    init() {
        emojiArt = EmojiArt()
        emojiArt.addEmoji("😀", at: (x: -200, y: -100), withSize: 80)
        emojiArt.addEmoji("😉", at: (x: 50, y: 100), withSize: 40)
    }
    
    private func updateBackgroundImage() {
        switch emojiArt.background {
        case .url(let url):
            isLoadingBackgroundImage = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                
                DispatchQueue.main.async { [weak self] in
                    self?.isLoadingBackgroundImage = false
                    
                    if imageData != nil {
                        if self?.emojiArt.background == Background.url(url) {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let imageData):
            backgroundImage = UIImage(data: imageData)
        default:
            backgroundImage = nil
        }
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
