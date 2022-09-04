//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Andres Vazquez on 2022-03-19.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State var selectedEmojis = Set<EmojiArt.Emoji>()
    let defaultEmojiFontSize = 40.0
    
    @State private var inactiveZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    private var activeZoomScale: CGFloat {
        inactiveZoomScale * gestureZoomScale
    }
    
    @State private var inactivePanOffset = CGSize.zero
    @GestureState private var gesturePanOffset = CGSize.zero
    private var activePanOffset: CGSize {
        (inactivePanOffset + gesturePanOffset) * activeZoomScale
    }
    
    @GestureState private var gestureEmojiMovement = CGSize.zero
    
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser(emojiFontSize: defaultEmojiFontSize)
        }
    }
    
    // MARK: - Subviews
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .position(convertFromEmojiCoordinates((x: 0, y: 0), in: geometry))
                        .scaleEffect(activeZoomScale)
                )
                .gesture(doubleTapToZoom(in: geometry.size).exclusively(before: deselectAllEmojisGesture()))
                
                if document.isLoadingBackgroundImage {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        ZStack(alignment: .topTrailing) {
                            Text(emoji.text)
                                .font(.system(size: fontSize(for: emoji)))
                                .scaleEffect(activeZoomScale)
                                .border(selectedEmojis.contains(emoji) ? .blue : .clear, width: Constants.borderWidth)
                                .onTapGesture(perform: { toggleEmojiSelection(emoji) })
                            
                            if selectedEmojis.contains(emoji) {
                                Button(action: {
                                    document.deleteEmoji(emoji)
                                }, label: {
                                    Image(systemName: "x.circle.fill")
                                        .foregroundStyle(.white, .red)
                                        .font(Font.system(size: Constants.deleteButton.fontSize))
                                })
                                .offset(x: Constants.deleteButton.offset.x, y: Constants.deleteButton.offset.y)
                            }
                        }
                        .position(position(for: emoji, in: geometry))
//                        .gesture(moveEmojisGesture())
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                dropIntoDocument(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    
    // MARK: - Drag and Drop
    private func dropIntoDocument(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        // An URL was dropped
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        
        // An image was dropped
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(imageData))
                }
            }
        }
        
        // An emoji was dropped
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                guard let emoji = string.first, emoji.isEmoji else { return }
                
                let emojiLocation = convertToEmojiCoordinates(location, in: geometry)
                document.addEmoji(String(emoji), at: emojiLocation, withSize: Int(defaultEmojiFontSize / activeZoomScale))
            }
        }
        
        return found
    }
    
    
    // MARK: - Positioning / Sizing Emoji
    private func position(for emoji: EmojiArt.Emoji, in geometry: GeometryProxy) -> CGPoint {
        var emojiLocation = emoji.location
        
        if selectedEmojis.contains(emoji) {
            emojiLocation = (
                x: emoji.location.x + Int(gestureEmojiMovement.width),
                y: emoji.location.y + Int(gestureEmojiMovement.height)
            )
        }
        
        return convertFromEmojiCoordinates(emojiLocation, in: geometry)
    }
    
    private func fontSize(for emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let emojiLocation = CGPoint(
            x: (location.x - center.x - activePanOffset.width) / activeZoomScale,
            y: (location.y - center.y - activePanOffset.height) / activeZoomScale
        )
        
        return (x: Int(emojiLocation.x), y: Int(emojiLocation.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        
        return CGPoint(
            x: center.x + CGFloat(location.x) * activeZoomScale + activePanOffset.width,
            y: center.y + CGFloat(location.y) * activeZoomScale + activePanOffset.height
        )
    }
    
    
    // MARK: - Zooming
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { endGestureScale in
                if selectedEmojis.isEmpty {
                    inactiveZoomScale *= endGestureScale
                } else {
                    for emoji in selectedEmojis {
                        document.scaleEmoji(emoji, by: endGestureScale)
                    }
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        guard let image = image,
              image.size.width > 0, image.size.height > 0,
              size.width > 0, size.height > 0
        else { return }
        
        let hZoom = size.width / image.size.width
        let vZoom = size.height / image.size.height
        inactiveZoomScale = min(hZoom, vZoom)
        
        // reset panOffset
        inactivePanOffset = .zero
    }
    
    
    // MARK: - Panning / Drag Gesture
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / activeZoomScale
            }
            .onEnded { finalDragGestureValue in
                inactivePanOffset = inactivePanOffset + (finalDragGestureValue.translation / activeZoomScale)
            }
    }
    
    private func moveEmojisGesture() -> some Gesture {
        DragGesture()
            .updating($gestureEmojiMovement) { latestDragGestureValue, gestureEmojiMovement, _ in
                gestureEmojiMovement = latestDragGestureValue.translation
            }
            .onEnded { finalDragGestureValue in
                for emoji in selectedEmojis {
                    document.moveEmoji(emoji, by: finalDragGestureValue.translation)
                }
            }
    }
    
    
    // MARK: - Emoji Selection
    private func toggleEmojiSelection(_ emoji: EmojiArt.Emoji) {
        if selectedEmojis.contains(emoji) {
            selectedEmojis.remove(emoji)
        } else {
            selectedEmojis.insert(emoji)
        }
    }
    
    private func deselectAllEmojis() {
        selectedEmojis = []
    }
    
    private func deselectAllEmojisGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                deselectAllEmojis()
            }
    }
    
    
    // MARK: - Constants
    private struct Constants {
        static let borderWidth = 2.0
        static let deleteButton = (
            fontSize: 24.0,
            offset: (x: 13.0, y: -13.0)
        )
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
