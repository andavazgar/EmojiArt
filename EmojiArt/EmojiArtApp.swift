//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-03-19.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
