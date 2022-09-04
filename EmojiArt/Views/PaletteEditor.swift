//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-08-30.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    @State private var emojisToAdd = ""
    
    var body: some View {
        Form {
            nameSection
            addEmojiSection
            removeEmojiSection
        }
        .navigationTitle("Edit \(palette.name)")
        .frame(minWidth: 300, minHeight: 350)
    }
    
    var nameSection: some View {
        Section("Name") {
            TextField("Name", text: $palette.name)
        }
    }
    
    var addEmojiSection: some View {
        Section("Add emoji") {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emoji in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            emojisToAdd = ""
                            addEmoji(emoji)
                        }
                    }
                }
        }
    }
    
    var removeEmojiSection: some View {
        Section("Remove Emoji") {
            let emojis = palette.emojis.withNoRepeatedCharacters.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll { String($0) == emoji }
                            }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }
    
    // MARK: - Methods
    func addEmoji(_ emoji: String) {
        palette.emojis = (emoji + palette.emojis).filter{ $0.isEmoji }.withNoRepeatedCharacters
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: .constant(PaletteStore(named: "Default").palette(at: 0)))
            .previewLayout(.sizeThatFits)
    }
}
