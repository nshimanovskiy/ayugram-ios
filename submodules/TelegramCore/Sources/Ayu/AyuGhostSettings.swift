import Foundation

/// Ghost mode switches, ported from AyuGram.
///
/// They are read on the network paths that report activity to other users, so they live in
/// UserDefaults rather than in Postbox: every check is synchronous and works on any queue.
public enum AyuGhostSettings {
    private enum Key: String {
        case dontReadMessages = "ayu.ghost.dontReadMessages"
        case dontReadStories = "ayu.ghost.dontReadStories"
        case dontSendOnline = "ayu.ghost.dontSendOnline"
        case dontSendTyping = "ayu.ghost.dontSendTyping"
    }

    private static var defaults: UserDefaults {
        return UserDefaults.standard
    }

    /// Don't send read receipts for messages, discussion threads and saved-message chats.
    public static var dontReadMessages: Bool {
        get { return self.defaults.bool(forKey: Key.dontReadMessages.rawValue) }
        set { self.defaults.set(newValue, forKey: Key.dontReadMessages.rawValue) }
    }

    /// Don't tell story authors that their stories were viewed.
    public static var dontReadStories: Bool {
        get { return self.defaults.bool(forKey: Key.dontReadStories.rawValue) }
        set { self.defaults.set(newValue, forKey: Key.dontReadStories.rawValue) }
    }

    /// Always report the account as offline.
    public static var dontSendOnline: Bool {
        get { return self.defaults.bool(forKey: Key.dontSendOnline.rawValue) }
        set { self.defaults.set(newValue, forKey: Key.dontSendOnline.rawValue) }
    }

    /// Don't send "typing…", "recording…" and other chat activity statuses.
    public static var dontSendTyping: Bool {
        get { return self.defaults.bool(forKey: Key.dontSendTyping.rawValue) }
        set { self.defaults.set(newValue, forKey: Key.dontSendTyping.rawValue) }
    }

    /// True when every ghost mode switch is on.
    public static var isFullyEnabled: Bool {
        return self.dontReadMessages && self.dontReadStories && self.dontSendOnline && self.dontSendTyping
    }

    /// Turns every ghost mode switch on or off at once.
    public static func setAll(_ value: Bool) {
        self.dontReadMessages = value
        self.dontReadStories = value
        self.dontSendOnline = value
        self.dontSendTyping = value
    }
}
