import GoogleMaps

public class GoogleMapsMarker: GMSMarker, MapMarker {
    public var id: String = ""
    public var onTap: (MapMarker -> Bool)?
    public var onTooltipTap: (MapMarker -> Void)?
    public var tooltipView: UIView?
    public var appearAnimated: Bool {
        get { return self.appearAnimation == kGMSMarkerAnimationNone }
        set { self.appearAnimation = kGMSMarkerAnimationNone }
    }
    public var isTooltipVisible: Bool {
        return self.tooltipView != nil && self.map?.selectedMarker == self
    }
}
