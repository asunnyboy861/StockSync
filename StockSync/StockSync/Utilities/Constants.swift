import Foundation

enum Constants {
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    static let supportURL = "https://asunnyboy861.github.io/StockSync/support.html"
    static let privacyURL = "https://asunnyboy861.github.io/StockSync/privacy.html"
    static let termsURL = "https://asunnyboy861.github.io/StockSync/terms.html"
    static let feedbackURL = "https://feedback-board.iocompile67692.workers.dev"
    static let contactEmail = "iocompile67692@gmail.com"

    enum Color {
        static let primaryHex = "#007AFF"
        static let secondaryHex = "#5856D6"
        static let successHex = "#34C759"
        static let warningHex = "#FF9500"
        static let dangerHex = "#FF3B30"
    }
}
