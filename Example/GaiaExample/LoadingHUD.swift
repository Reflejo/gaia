import UIKit

final class LoadingHUD: UIView {

    @IBOutlet private var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.alpha = 0.0
        self.hidden = false
    }

    /**
     Shows the HUD animated showing the given message

     - parameter title: The message to show on the HUD.
     */
    func show(title: String) {
        self.messageLabel.text = title

        self.layer.setAffineTransform(CGAffineTransformMakeScale(0.5, 0.5))
        UIView.animateWithDuration(0.3) {
            self.alpha = 1.0
            self.layer.setAffineTransform(CGAffineTransformIdentity)
        }
    }

    /**
     Hides the HUD animated.
     */
    func hide() {
        UIView.animateWithDuration(0.2) {
            self.alpha = 0.0
            self.layer.setAffineTransform(CGAffineTransformMakeScale(0.5, 0.5))
        }
    }
}