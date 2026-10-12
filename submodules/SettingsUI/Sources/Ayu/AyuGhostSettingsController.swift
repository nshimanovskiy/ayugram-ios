import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext

// The strings are not part of the Telegram localization platform, so the screen carries
// its own English and Russian copies.
private func ayuLocalized(_ strings: PresentationStrings, en: String, ru: String) -> String {
    return strings.baseLanguageCode == "ru" ? ru : en
}

public func ayuGhostModeTitle(strings: PresentationStrings) -> String {
    return ayuLocalized(strings, en: "Ghost Mode", ru: "Режим призрака")
}

private final class AyuGhostSettingsControllerArguments {
    let updateAll: (Bool) -> Void
    let updateDontReadMessages: (Bool) -> Void
    let updateDontReadStories: (Bool) -> Void
    let updateDontSendOnline: (Bool) -> Void
    let updateDontSendTyping: (Bool) -> Void

    init(
        updateAll: @escaping (Bool) -> Void,
        updateDontReadMessages: @escaping (Bool) -> Void,
        updateDontReadStories: @escaping (Bool) -> Void,
        updateDontSendOnline: @escaping (Bool) -> Void,
        updateDontSendTyping: @escaping (Bool) -> Void
    ) {
        self.updateAll = updateAll
        self.updateDontReadMessages = updateDontReadMessages
        self.updateDontReadStories = updateDontReadStories
        self.updateDontSendOnline = updateDontSendOnline
        self.updateDontSendTyping = updateDontSendTyping
    }
}

private struct AyuGhostSettingsState: Equatable {
    var dontReadMessages: Bool
    var dontReadStories: Bool
    var dontSendOnline: Bool
    var dontSendTyping: Bool

    static func current() -> AyuGhostSettingsState {
        return AyuGhostSettingsState(
            dontReadMessages: AyuGhostSettings.dontReadMessages,
            dontReadStories: AyuGhostSettings.dontReadStories,
            dontSendOnline: AyuGhostSettings.dontSendOnline,
            dontSendTyping: AyuGhostSettings.dontSendTyping
        )
    }

    var isFullyEnabled: Bool {
        return self.dontReadMessages && self.dontReadStories && self.dontSendOnline && self.dontSendTyping
    }
}

private enum AyuGhostSettingsSection: Int32 {
    case master
    case options
}

private enum AyuGhostSettingsControllerEntry: ItemListNodeEntry {
    case masterValue(String, Bool)
    case masterFooter(String)

    case optionsHeader(String)
    case dontReadMessages(String, Bool)
    case dontReadStories(String, Bool)
    case dontSendOnline(String, Bool)
    case dontSendTyping(String, Bool)
    case optionsFooter(String)

    var section: ItemListSectionId {
        switch self {
        case .masterValue, .masterFooter:
            return AyuGhostSettingsSection.master.rawValue
        case .optionsHeader, .dontReadMessages, .dontReadStories, .dontSendOnline, .dontSendTyping, .optionsFooter:
            return AyuGhostSettingsSection.options.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .masterValue:
            return 0
        case .masterFooter:
            return 1
        case .optionsHeader:
            return 2
        case .dontReadMessages:
            return 3
        case .dontReadStories:
            return 4
        case .dontSendOnline:
            return 5
        case .dontSendTyping:
            return 6
        case .optionsFooter:
            return 7
        }
    }

    static func <(lhs: AyuGhostSettingsControllerEntry, rhs: AyuGhostSettingsControllerEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! AyuGhostSettingsControllerArguments
        switch self {
        case let .masterValue(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAll(value)
            })
        case let .masterFooter(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .optionsHeader(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .dontReadMessages(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateDontReadMessages(value)
            })
        case let .dontReadStories(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateDontReadStories(value)
            })
        case let .dontSendOnline(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateDontSendOnline(value)
            })
        case let .dontSendTyping(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateDontSendTyping(value)
            })
        case let .optionsFooter(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private func ayuGhostSettingsControllerEntries(strings: PresentationStrings, state: AyuGhostSettingsState) -> [AyuGhostSettingsControllerEntry] {
    var entries: [AyuGhostSettingsControllerEntry] = []

    entries.append(.masterValue(ayuGhostModeTitle(strings: strings), state.isFullyEnabled))
    entries.append(.masterFooter(ayuLocalized(strings,
        en: "Turns every option below on or off at once.",
        ru: "Включает или выключает все параметры ниже сразу."
    )))

    entries.append(.optionsHeader(ayuLocalized(strings, en: "OPTIONS", ru: "ПАРАМЕТРЫ")))
    entries.append(.dontReadMessages(ayuLocalized(strings, en: "Don't Read Messages", ru: "Не читать сообщения"), state.dontReadMessages))
    entries.append(.dontReadStories(ayuLocalized(strings, en: "Don't Read Stories", ru: "Не читать истории"), state.dontReadStories))
    entries.append(.dontSendOnline(ayuLocalized(strings, en: "Don't Send Online", ru: "Не отправлять «в сети»"), state.dontSendOnline))
    entries.append(.dontSendTyping(ayuLocalized(strings, en: "Don't Send Typing", ru: "Не отправлять «печатает»"), state.dontSendTyping))
    entries.append(.optionsFooter(ayuLocalized(strings,
        en: "Chats and stories are still marked as read on this device, but other people are not told about it.",
        ru: "Чаты и истории отмечаются прочитанными только на этом устройстве, собеседники об этом не узнают."
    )))

    return entries
}

public func ayuGhostSettingsController(context: AccountContext) -> ViewController {
    let statePromise = ValuePromise(AyuGhostSettingsState.current(), ignoreRepeated: true)
    let refreshState: () -> Void = {
        statePromise.set(AyuGhostSettingsState.current())
    }

    let arguments = AyuGhostSettingsControllerArguments(
        updateAll: { value in
            AyuGhostSettings.setAll(value)
            refreshState()
        },
        updateDontReadMessages: { value in
            AyuGhostSettings.dontReadMessages = value
            refreshState()
        },
        updateDontReadStories: { value in
            AyuGhostSettings.dontReadStories = value
            refreshState()
        },
        updateDontSendOnline: { value in
            AyuGhostSettings.dontSendOnline = value
            refreshState()
        },
        updateDontSendTyping: { value in
            AyuGhostSettings.dontSendTyping = value
            refreshState()
        }
    )

    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        statePromise.get()
    )
    |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(ayuGhostModeTitle(strings: presentationData.strings)), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: ayuGhostSettingsControllerEntries(strings: presentationData.strings, state: state), style: .blocks, animateChanges: true)

        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    return controller
}
