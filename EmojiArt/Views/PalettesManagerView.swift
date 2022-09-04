//
//  PalettesManagerView.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-08-31.
//

import SwiftUI

struct PalettesManagerView: View {
    @EnvironmentObject var store: PaletteStore
    @Environment(\.dismiss) var dismiss
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, offset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: offset)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct PalettesManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PalettesManagerView()
            .environmentObject(PaletteStore(named: "Default"))
            .previewDevice("iPhone 13 Pro")
    }
}
