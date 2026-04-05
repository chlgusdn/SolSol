import Foundation

private final class DesignSystemBundleToken {}

public enum DesignSystemBundle {
    public static let bundle: Bundle = Bundle(for: DesignSystemBundleToken.self)
}
