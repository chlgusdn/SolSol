import UIKit

private final class ImageBundleToken {}
private let designSystemImageBundle = Bundle(for: ImageBundleToken.self)

public extension UIImage {
    static var icArrowRight: UIImage {
        UIImage(named: "ic_arrow_right", in: designSystemImageBundle, compatibleWith: nil) ?? UIImage()
    }

    static var icDollarSign: UIImage {
        UIImage(named: "ic_dollar_sign", in: designSystemImageBundle, compatibleWith: nil) ?? UIImage()
    }

    static var icTrendingUp: UIImage {
        UIImage(named: "ic_trending_up", in: designSystemImageBundle, compatibleWith: nil) ?? UIImage()
    }
}
