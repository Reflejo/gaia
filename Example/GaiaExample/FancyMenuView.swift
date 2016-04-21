import UIKit

private let kInitialAngle = CGFloat(M_PI_4)
private let kMinimumAngle = 0.25
private let kOptionsRadius = 70.0

final class FancyMenuView: UIView {

    @IBOutlet private var options: [UIButton]!
    @IBOutlet private var mainButton: UIView!

    var isShown: Bool {
        return self.options.first?.alpha > CGFloat(FLT_EPSILON)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.closeMenu(animated: false)

        let selector = #selector(FancyMenuView.toggleMenu)
        self.options.forEach { $0.addTarget(self, action: selector, forControlEvents: .TouchUpInside) }
    }

    @IBAction func toggleMenu() {
        self.isShown ? self.closeMenu() : self.openMenu()
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let mainButtonHit = CGRectContainsPoint(self.mainButton.frame, point)
        if mainButtonHit || !self.isShown {
            return mainButtonHit ? self.mainButton : nil
        }

        let hitButtons = self.options.filter { CGRectContainsPoint($0.frame, point) }
        return hitButtons.first
    }

    // MARK: - Private methods

    private func closeMenu(animated animated: Bool = true) {
        UIView.animateWithDuration(animated ? 0.2 : 0.0) {
            for option in self.options {
                option.center = self.mainButton.center
                option.alpha = 0.0
                option.layer.setAffineTransform(CGAffineTransformMakeRotation(kInitialAngle))
            }

            self.mainButton.layer.setAffineTransform(CGAffineTransformIdentity)
        }
    }

    private func openMenu() {
        let deltaAngle = (M_PI - kMinimumAngle * 2) / Double(self.options.count - 1)

        self.closeMenu(animated: false)
        UIView.animateWithDuration(0.2) {
            for (i, option) in self.options.enumerate() {
                let angle = 2.0 * M_PI - Double(i) * deltaAngle - kMinimumAngle
                option.alpha = 1.0
                option.layer.setAffineTransform(CGAffineTransformIdentity)
                option.center.x = self.mainButton.center.x + CGFloat(kOptionsRadius * cos(angle))
                option.center.y = self.mainButton.center.y + CGFloat(kOptionsRadius * sin(angle))
            }

            self.mainButton.layer.setAffineTransform(CGAffineTransformMakeRotation(kInitialAngle))
        }
    }
}
