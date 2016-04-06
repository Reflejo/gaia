/**
 Represents a marker that can be highlighted and selected in the map (e.g. change the icon according to
 the marker state).
 */
public protocol MapHighlightableMarker: MapMarker {
    /// Whether the marker is currently higlighted (showing the highlighted state).
    var highlighted: Bool { get set }

    /**
     Select the marker. This will potentially change the visual representation and call `onSelected`.
     */
    func select()
}
