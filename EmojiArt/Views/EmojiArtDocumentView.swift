//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-03-19.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    let defaultEmojiFontSize = 40.0
    let testEmojis = "😀😃😄😁😆🥹😅😂🤣🥲☺️😊😇🙂🙃😉😌"
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.yellow
                
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geometry))
                }
            }
            .onDrop(of: [.plainText], isTargeted: nil) { providers, location in
                dropEmojiIntoDocument(providers: providers, at: location, in: geometry)
            }
        }
    }
    
    private var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    private func fontSize(for emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates(emoji.location, in: geometry)
    }
    
    private func dropEmojiIntoDocument(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        providers.loadObjects(ofType: String.self) { string in
            guard let emoji = string.first, emoji.isEmoji else { return }
            
            let emojiLocation = convertToEmojiCoordinates(location, in: geometry)
            document.addEmoji(String(emoji), at: emojiLocation, withSize: Int(defaultEmojiFontSize))
        }
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        
        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
        )
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let emojiLocation = CGPoint(
            x: location.x - center.x,
            y: location.y - center.y
        )
        
        return (x: Int(emojiLocation.x), y: Int(emojiLocation.y))
    }
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
