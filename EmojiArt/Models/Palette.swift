//
//  Palette.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-08-25.
//

import Foundation

struct Palette: Identifiable, Codable {
    let id: Int
    var name: String
    var emojis: String
}
