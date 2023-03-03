//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-08-30.
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStore
    @State private var chosenPaletteIndex = 0
    @State private var showPaletteEditor = false
    @State private var showPalettesManager = false
    var emojiFontSize = 40.0
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    var body: some View {
        HStack {
            paletteButton
            body(for: store.palette(at: chosenPaletteIndex))
        }
        .clipped()
    }
    
    // MARK: - Subviews
    
    var paletteButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu { contextMenu }
        .sheet(isPresented: $showPalettesManager) {
            PalettesManagerView()
        }
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
        .popover(isPresented: $showPaletteEditor) {
            PaletteEditor(palette: $store.palettes[chosenPaletteIndex])
        }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        // Edit Palette
        Button {
            withAnimation {
                showPaletteEditor = true
            }
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        
        // New Palette
        Button {
            withAnimation {
                store.insertPalette(named: "New", at: chosenPaletteIndex + 1)
                chosenPaletteIndex += 1
                showPaletteEditor = true
            }
        } label: {
            Label("New", systemImage: "plus")
        }
        
        // Delete Palette
        Button(role: .destructive) {
            withAnimation {
                chosenPaletteIndex = store.removePalette(at: chosenPaletteIndex)
            }
        } label: {
            Label("Delete", systemImage: "minus.circle")
        }
        
        // Manage Palettes
        Button {
            withAnimation {
                showPalettesManager = true
            }
        } label: {
            Label("Manage Palettes", systemImage: "slider.vertical.3")
        }
        
        // Go to Palette
        goToMenu
    }
    
    var goToMenu: some View {
        Menu {
            ForEach(store.palettes) { palette in
                Button(palette.name) {
                    withAnimation {
                        if let index = store.palettes.index(matching: palette) {
                            chosenPaletteIndex = index
                        }
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }

    }
    
    
    // MARK: - Other
    
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: emojiFontSize),
            removal: .offset(x: 0, y: -emojiFontSize)
        )
    }
}


struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.withNoRepeatedCharacters.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}


struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
            .environmentObject(PaletteStore(named: "Default"))
            .previewLayout(.sizeThatFits)
    }
}
