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
            scheduleAutosave()
            if emojiArt.background != oldValue.background {
                updateBackgroundImage()
            }
        }
    }
    @Published var backgroundImage: UIImage?
    @Published var isLoadingBackgroundImage = false
    
    private var autosaveTimer: Timer?
    var emojis: [Emoji] { emojiArt.emojis }
    var background: Background { emojiArt.background }
    
    
    // MARK: - Methods
    init() {
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArt(url: url) {
            self.emojiArt = autosavedEmojiArt
            updateBackgroundImage()
        } else {
            emojiArt = EmojiArt()
            //        emojiArt.addEmoji("😀", at: (x: -200, y: -100), withSize: 80)
            //        emojiArt.addEmoji("😉", at: (x: 50, y: 100), withSize: 40)
        }
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
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data = try emojiArt.json()
            print("\(thisFunction), JSON = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisFunction) error: \(error)")
        }
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func scheduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.autosaveDelay, repeats: false, block: { _ in
            self.autosave()
        })
    }
    
    
    // MARK: - Intents
    func setBackground(_ background: Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), withSize size: Int) {
        emojiArt.addEmoji(emoji, at: location, withSize: size)
    }
    
    func deleteEmoji(_ emoji: Emoji) {
        emojiArt.deleteEmoji(emoji)
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
    
    // MARK: - Constants
    private struct Autosave {
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let autosaveDelay = 5.0
    }
}
