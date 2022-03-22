//
//  EmojiArt.Background.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-03-19.
//

import Foundation

extension EmojiArt {
    enum Background: Equatable {
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case.imageData(let imageData): return imageData
            default: return nil
            }
        }
    }
}
