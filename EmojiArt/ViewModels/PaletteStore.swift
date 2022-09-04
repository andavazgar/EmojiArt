//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-08-25.
//

import SwiftUI

class PaletteStore: ObservableObject {
    let name: String
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }
    private var userDefaultsKey: String {
        return "PaletteStore:" + name
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        
        if palettes.isEmpty {
            let defaultPalettes = [
                "Vehicles": "🚙🚗🚘🚕🚖🏎🚚🛻🚛🚐🚓🚔🚑🚒🚀✈️🛫🛬🛩🚁🛸🚲🏍🛶⛵️🚤🛥🛳⛴🚢🚂🚝🚅🚆🚊🚉🚇🛺🚜",
                "Sports": "🏈⚾️🏀⚽️🎾🏐🥏🏓⛳️🥅🥌🏂⛷🎳",
                "Music": "🎼🎤🎹🪘🥁🎺🪗🪕🎻",
                "Animals": "🐥🐣🐂🐄🐎🐖🐏🐑🦙🐐🐓🐁🐀🐒🦆🦅🦉🦇🐢🐍🦎🦖🦕🐅🐆🦓🦍🦧🦣🐘🦛🦏🐪🐫🦒🦘🦬🐃🦙🐐🦌🐕🐩🦮🐈🦤🦢🦩🕊🦝🦨🦡🦫🦦🦥🐿🦔",
                "Animal Faces": "🐵🙈🙊🙉🐶🐱🐭🐹🐰🦊🐻🐼🐻‍❄️🐨🐯🦁🐮🐷🐸🐲",
                "Flora": "🌲🌴🌿☘️🍀🍁🍄🌾💐🌷🌹🥀🌺🌸🌼🌻",
                "Weather": "☀️🌤⛅️🌥☁️🌦🌧⛈🌩🌨❄️💨☔️💧💦🌊☂️🌫🌪",
                "COVID": "💉🦠😷🤧🤒",
                "Faces": "😀😃😄😁😆😅😂🤣🥲☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🥸🤩🥳😏😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤯😳🥶😥😓🤗🤔🤭🤫🤥😬🙄😯😧🥱😴🤮😷🤧🤒🤠"
            ]
            
            for palette in defaultPalettes {
                insertPalette(named: palette.key, emojis: palette.value)
            }
        }
    }
    
    
    // MARK: - Methods
    private func storeInUserDefaults() {
        do {
            let json = try JSONEncoder().encode(palettes)
            UserDefaults.standard.set(json, forKey: userDefaultsKey)
        } catch {
            print("\(String(describing: self)).\(#function) failed: \(error)")
        }
    }
    
    private func restoreFromUserDefaults() {
        if let palettesData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                palettes = try JSONDecoder().decode([Palette].self, from: palettesData)
            } catch {
                print("\(String(describing: self)).\(#function) failed: \(error)")
            }
        }
    }
    
    // MARK: - Intents
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojis: String = "", at index: Int = 0) {
        let nextID = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(id: nextID, name: name, emojis: emojis)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}
