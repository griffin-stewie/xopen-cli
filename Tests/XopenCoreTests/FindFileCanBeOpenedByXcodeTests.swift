import Path
import Bucker
import XCTest

import class Foundation.Bundle

@testable import XopenCore

final class FindFileCanBeOpenedByXcodeTests: XCTestCase {
    func testFindPackageSwiftAtRoot() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── .xcode-version
        ├── Package.swift
        ├── app/
        └── scripts/
        """

        try Path.mktemp(treeString: tree) { root in
            try root.find().execute { path in
                if path.basename() == ".xcode-version" {
                    let version = "13.0.0"
                    try version.write(to: path)
                }
                return .continue
            }

            print(root.url.path)
            print("")

            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"Package.swift"))
        }
    }

    func testFindPackageSwiftInNestedDirectory() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── App/
        │   ├── .xcode-version
        │   └── Package.swift
        ├── Build/
        └── Scripts/
        """

        try Path.mktemp(treeString: tree) { root in
            try root.find().execute { path in
                if path.basename() == ".xcode-version" {
                    let version = "13.0.0"
                    try version.write(to: path)
                }
                return .continue
            }

            print(root.url.path)
            print("")

            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"App"/"Package.swift"))
        }
    }

    func testFindXcrowkspace() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── .gitignore
        ├── .xcode-version
        ├── GolfScoreCounter/
        │   ├── .DS_Store
        │   ├── App/
        │   │   ├── .DS_Store
        │   │   └── GolfScoreCounter/
        │   │       ├── .DS_Store
        │   │       └── GolfScoreCounter.xcodeproj/
        │   │           ├── project.pbxproj
        │   │           ├── xcshareddata/
        │   │           │   └── xcschemes/
        │   │           │       ├── GolfScoreCounter.xcscheme
        │   │           │       ├── GolfScoreCounterWatch Watch App.xcscheme
        │   │           │       ├── GolfScoreCounterWidgetsExtension.xcscheme
        │   │           │       └── WatchWidgetExtension.xcscheme
        │   │           └── xcuserdata/
        │   │               └── stewie.xcuserdatad/
        │   │                   └── xcschemes/
        │   │                       └── xcschememanagement.plist
        │   └── Package/
        │       ├── .DS_Store
        │       ├── .build/
        │       │   └── .DS_Store
        │       ├── .gitignore
        │       ├── .swiftpm/
        │       │   └── .DS_Store
        │       ├── Package.swift
        │       ├── Sources/
        │       │   ├── .DS_Store
        │       │   └── AppFeature/
        │       │       ├── .DS_Store
        │       │       └── AppLogger.swift
        │       └── Tests/
        │           └── .DS_Store
        ├── GolfScoreCounter.xcworkspace/
        │   ├── contents.xcworkspacedata
        │   ├── xcshareddata/
        │   │   ├── IDEWorkspaceChecks.plist
        │   │   └── swiftpm/
        │   │       └── configuration/
        │   └── xcuserdata/
        │       └── stewie.xcuserdatad/
        │           ├── UserInterfaceState.xcuserstate
        │           └── xcdebugger/
        │               └── Breakpoints_v2.xcbkptlist
        └── README.md
        """

        try Path.mktemp(treeString: tree) { root in
            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"GolfScoreCounter.xcworkspace"))
        }
    }

    func testFindXcrowkspaceAtSameLevel() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── .gitignore
        ├── .xcode-version
        ├── GolfScoreCounter.xcodeproj/
        ├── GolfScoreCounter.xcworkspace/
        │   ├── contents.xcworkspacedata
        │   ├── xcshareddata/
        │   │   ├── IDEWorkspaceChecks.plist
        │   │   └── swiftpm/
        │   │       └── configuration/
        │   └── xcuserdata/
        │       └── stewie.xcuserdatad/
        │           ├── UserInterfaceState.xcuserstate
        │           └── xcdebugger/
        │               └── Breakpoints_v2.xcbkptlist
        └── README.md
        """

        try Path.mktemp(treeString: tree) { root in
            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"GolfScoreCounter.xcworkspace"))
        }
    }

    func testFindXcrowkspaceAtSameLevel2() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── .gitignore
        ├── KitchenSink/
        │   ├── AppDelegate.swift
        │   ├── Assets.xcassets/
        │   │   ├── AppIcon.appiconset/
        │   │   │   ├── Contents.json*
        │   │   │   ├── Icon-App-20x20@1x.png
        │   │   │   ├── Icon-App-20x20@2x.png
        │   │   │   ├── Icon-App-20x20@3x.png
        │   │   │   ├── Icon-App-29x29@1x.png
        │   │   │   ├── Icon-App-29x29@2x.png
        │   │   │   ├── Icon-App-29x29@3x.png
        │   │   │   ├── Icon-App-40x40@1x.png
        │   │   │   ├── Icon-App-40x40@2x.png
        │   │   │   ├── Icon-App-40x40@3x.png
        │   │   │   ├── Icon-App-60x60@2x.png
        │   │   │   ├── Icon-App-60x60@3x.png
        │   │   │   ├── Icon-App-76x76@1x.png
        │   │   │   ├── Icon-App-76x76@2x.png
        │   │   │   ├── Icon-App-83.5x83.5@2x.png
        │   │   │   └── ItunesArtwork@2x.png
        │   │   ├── Contents.json
        │   │   ├── adjust-audio.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── adjust-audio_28.png
        │   │   │   ├── adjust-audio_28@2x.png
        │   │   │   └── adjust-audio_28@3x.png
        │   │   ├── attachment.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── attachment_20.png
        │   │   │   ├── attachment_20@2x.png
        │   │   │   └── attachment_20@3x.png
        │   │   ├── audio-call.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── audio-call_16_w.png
        │   │   │   ├── audio-call_16_w@2x.png
        │   │   │   └── audio-call_16_w@3x.png
        │   │   ├── audio-route.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── speaker-bluetooth_16_w.png
        │   │   │   ├── speaker-bluetooth_16_w@2x.png
        │   │   │   └── speaker-bluetooth_16_w@3x.png
        │   │   ├── audio-video.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── audio-video_28.png
        │   │   │   ├── audio-video_28@2x.png
        │   │   │   └── audio-video_28@3x.png
        │   │   ├── background-test.imageset/
        │   │   │   ├── Contents.json
        │   │   │   └── background-test.jpeg
        │   │   ├── blur.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── blur_24.png
        │   │   │   ├── blur_24@2x.png
        │   │   │   └── blur_24@3x.png
        │   │   ├── bubble-left.symbolset/
        │   │   │   ├── Contents.json
        │   │   │   └── bubble.left.svg
        │   │   ├── call-add.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── add_24_w.png
        │   │   │   ├── add_24_w@2x.png
        │   │   │   └── add_24_w@3x.png
        │   │   ├── call-hold.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── call-hold_24_w.png
        │   │   │   ├── call-hold_24_w@2x.png
        │   │   │   └── call-hold_24_w@3x.png
        │   │   ├── call-merge.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── call-merge_24_w.png
        │   │   │   ├── call-merge_24_w@2x.png
        │   │   │   └── call-merge_24_w@3x.png
        │   │   ├── call-swap.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── call-swap_28_w.png
        │   │   │   ├── call-swap_28_w@2x.png
        │   │   │   └── call-swap_28_w@3x.png
        │   │   ├── cisco-logo.imageset/
        │   │   │   ├── Contents.json
        │   │   │   └── logo@2x.png
        │   │   ├── delete.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── delete_24.png
        │   │   │   ├── delete_24@2x.png
        │   │   │   └── delete_24@3x.png
        │   │   ├── dialpad-white.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── dialpad_28_w.png
        │   │   │   ├── dialpad_28_w@2x.png
        │   │   │   └── dialpad_28_w@3x.png
        │   │   ├── dialpad.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── dialpad_28.png
        │   │   │   ├── dialpad_28@2x.png
        │   │   │   └── dialpad_28@3x.png
        │   │   ├── end-call.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── cancel_36_w.png
        │   │   │   ├── cancel_36_w@2x.png
        │   │   │   └── cancel_36_w@3x.png
        │   │   ├── feedback.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── feedback_72.png
        │   │   │   ├── feedback_72@2x.png
        │   │   │   └── feedback_72@3x.png
        │   │   ├── incoming-call.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── incoming-call-legacy_36.png
        │   │   │   ├── incoming-call-legacy_36@2x.png
        │   │   │   └── incoming-call-legacy_36@3x.png
        │   │   ├── keyboard-white.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── keyboard_28_w.png
        │   │   │   ├── keyboard_28_w@2x.png
        │   │   │   └── keyboard_28_w@3x.png
        │   │   ├── keyboard.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── keyboard_28.png
        │   │   │   ├── keyboard_28@2x.png
        │   │   │   └── keyboard_28@3x.png
        │   │   ├── logo.imageset/
        │   │   │   ├── Contents.json
        │   │   │   └── ItunesArtwork@2x.png
        │   │   ├── markdown.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── markdown_20_b3.png
        │   │   │   ├── markdown_20_b3@2x.png
        │   │   │   └── markdown_20_b3@3x.png
        │   │   ├── microphone-muted.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── microphone-muted_36_r1.png
        │   │   │   ├── microphone-muted_36_r1@2x.png
        │   │   │   └── microphone-muted_36_r1@3x.png
        │   │   ├── microphone-unmuted.imageset/
        │   │   │   ├── Contents.json
        │   │   │   └── microphone_on_bold_dark_level00_dark.pdf
        │   │   ├── microphone.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── microphone_36_w.png
        │   │   │   ├── microphone_36_w@2x.png
        │   │   │   └── microphone_36_w@3x.png
        │   │   ├── more.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── more_28.png
        │   │   │   ├── more_28@2x.png
        │   │   │   └── more_28@3x.png
        │   │   ├── none.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── cancel_36.png
        │   │   │   ├── cancel_36@2x.png
        │   │   │   └── cancel_36@3x.png
        │   │   ├── outgoing-call.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── outgoing-call-legacy_36.png
        │   │   │   ├── outgoing-call-legacy_36@2x.png
        │   │   │   └── outgoing-call-legacy_36@3x.png
        │   │   ├── participants.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── participant-list_32_w.png
        │   │   │   ├── participant-list_32_w@2x.png
        │   │   │   └── participant-list_32_w@3x.png
        │   │   ├── people.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── people_36_w.png
        │   │   │   ├── people_36_w@2x.png
        │   │   │   └── people_36_w@3x.png
        │   │   ├── pin.symbolset/
        │   │   │   ├── Contents.json
        │   │   │   └── pin.list.svg
        │   │   ├── quality-Indicator.symbolset/
        │   │   │   ├── Contents.json
        │   │   │   └── indicator.media.quality.good.filled.svg
        │   │   ├── reply.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── arrow-right_32_b1.png
        │   │   │   ├── arrow-right_32_b1@2x.png
        │   │   │   └── arrow-right_32_b1@3x.png
        │   │   ├── screen-share.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── share-screen-presence_28.png
        │   │   │   ├── share-screen-presence_28@2x.png
        │   │   │   └── share-screen-presence_28@3x.png
        │   │   ├── sign-in.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── sign-in_24_w.png
        │   │   │   ├── sign-in_24_w@2x.png
        │   │   │   └── sign-in_24_w@3x.png
        │   │   ├── sign-out.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── sign-out_24.png
        │   │   │   ├── sign-out_24@2x.png
        │   │   │   └── sign-out_24@3x.png
        │   │   ├── slider-horizontal-3.symbolset/
        │   │   │   ├── Contents.json
        │   │   │   └── slider-horizontal-3.svg
        │   │   ├── swap-camera.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── camera-swap_24.png
        │   │   │   ├── camera-swap_24@2x.png
        │   │   │   └── camera-swap_24@3x.png
        │   │   ├── text.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── text-format_24.png
        │   │   │   ├── text-format_24@2x.png
        │   │   │   └── text-format_24@3x.png
        │   │   ├── virtual-bg.imageset/
        │   │   │   ├── Contents.json
        │   │   │   ├── appearance_20.png
        │   │   │   ├── appearance_20@2x.png
        │   │   │   └── appearance_20@3x.png
        │   │   └── webhook.imageset/
        │   │       ├── Contents.json
        │   │       ├── condition_16.png
        │   │       ├── condition_16@2x.png
        │   │       └── condition_16@3x.png
        │   ├── Base.lproj/
        │   │   ├── LaunchScreen.storyboard
        │   │   └── Main.storyboard
        │   ├── CMakeLists.txt
        │   ├── Controllers/
        │   │   ├── CallViewController.swift
        │   │   ├── ExtrasViewController.swift
        │   │   ├── GetMeViewController.swift
        │   │   ├── HomeViewController.swift
        │   │   ├── InitiateCall/
        │   │   │   ├── InitiateCallViewController.swift
        │   │   │   ├── ParticipantListViewController.swift
        │   │   │   └── SubTabs/
        │   │   │       ├── CalendarMeetings/
        │   │   │       │   ├── CalendarAtendeesTableViewController.swift
        │   │   │       │   ├── CalendarMeetingDetailViewController.swift
        │   │   │       │   ├── CalendarMeetingsViewController.swift
        │   │   │       │   └── FilterCalendarMeetingsViewController.swift
        │   │   │       ├── CallingSpacesListViewController.swift
        │   │   │       ├── DialCallViewController.swift
        │   │   │       ├── HistoryCallViewController.swift
        │   │   │       └── SearchContactViewController.swift
        │   │   ├── LoginViewController.swift
        │   │   ├── Messaging/
        │   │   │   ├── MessagingViewController.swift
        │   │   │   ├── NavigationItemSetupProtocol.swift
        │   │   │   └── SubTabs/
        │   │   │       ├── New Group/
        │   │   │       │   └── MessagingSpacesViewController.swift
        │   │   │       ├── PeopleViewController.swift
        │   │   │       ├── PersonFormViewController.swift
        │   │   │       ├── Spaces/
        │   │   │       │   ├── AttachmentPreviewViewController.swift
        │   │   │       │   ├── ContactSearchViewController.swift
        │   │   │       │   ├── FilterSpacesViewController.swift
        │   │   │       │   ├── MessageComposerViewController.swift
        │   │   │       │   ├── SpaceMembershipReadStatusViewController.swift
        │   │   │       │   ├── SpaceMembershipViewController.swift
        │   │   │       │   └── SpaceMessagesTableViewController.swift
        │   │   │       └── Teams/
        │   │   │           ├── TeamMembershipViewController.swift
        │   │   │           └── TeamsViewController.swift
        │   │   ├── PushNotificationHandler.swift
        │   │   ├── SetupViewController.swift
        │   │   ├── Shared/
        │   │   │   └── BasicTableViewController.swift
        │   │   ├── WaitingCall/
        │   │   │   ├── IncomingCallViewCell.swift
        │   │   │   ├── IncomingCallViewController.swift
        │   │   │   ├── ScheduledCallViewController.swift
        │   │   │   └── ScheduledMeetingTableViewCell.swift
        │   │   └── Webhook/
        │   │       ├── NewWebhookFormViewController.swift
        │   │       └── WebhooksViewController.swift
        │   ├── Extensions/
        │   │   ├── UIAlertController+Extension.swift
        │   │   └── UIView+Extenstion.swift
        │   ├── Info.plist
        │   ├── KitchenSink-Bridging-Header.h
        │   ├── KitchenSink.entitlements
        │   ├── LICENSE
        │   ├── Models/
        │   │   └── Feature.swift
        │   ├── README.md
        │   ├── Sound/
        │   │   ├── call_1_1_ringback.wav
        │   │   └── call_1_1_ringtone.wav
        │   ├── ThirdPary/
        │   │   └── SwCrypt.swift
        │   ├── Utils/
        │   │   ├── CallObjectStorage.swift
        │   │   ├── ColorUtils.swift
        │   │   ├── ConstraintsExtension.swift
        │   │   ├── DateUtils.swift
        │   │   ├── EncryptionUtils.swift
        │   │   ├── FileUtils.swift
        │   │   ├── ImageExtension.swift
        │   │   ├── ReusableCell.swift
        │   │   ├── String+Extension.swift
        │   │   ├── UIAlertAction+Extensions.swift
        │   │   ├── UIAlertController+Extensions.swift
        │   │   ├── UILabel+Extensions.swift
        │   │   └── ViewUtils.swift
        │   ├── Views/
        │   │   ├── AuxCollectionViewCell.swift
        │   │   ├── CalendarMeetingTableViewCell.swift
        │   │   ├── CallButton.swift
        │   │   ├── ContactTableViewCell.swift
        │   │   ├── DialButton.swift
        │   │   ├── DialPadView.swift
        │   │   ├── Dropdown.swift
        │   │   ├── FeatureCollectionViewCell.swift
        │   │   ├── MediaStreamView.swift
        │   │   ├── MessageTableViewCell.swift
        │   │   ├── MultiStreamSettingsView.swift
        │   │   ├── ParticipantTableViewCell.swift
        │   │   ├── PasswordCaptchaView.swift
        │   │   ├── SpaceTableViewCell.swift
        │   │   ├── VirtualBackgroundViewCell.swift
        │   │   └── WebhookTableViewCell.swift
        │   └── images/
        │       ├── Picture1.png
        │       ├── Picture2.png
        │       ├── Picture3.png
        │       ├── Picture4.png
        │       ├── Picture5.png
        │       ├── Picture6.png
        │       ├── Picture7.png
        │       ├── Picture8.png
        │       ├── secrets.png
        │       └── signing_and_capabilities.png
        ├── KitchenSink.xcodeproj/
        │   ├── project.pbxproj
        │   ├── xcshareddata/
        │   │   └── xcschemes/
        │   │       ├── KitchenSink.xcscheme
        │   │       └── KitchenSinkUITests.xcscheme
        │   └── xcuserdata/
        │       └── stewie.xcuserdatad/
        │           └── xcschemes/
        │               └── xcschememanagement.plist
        ├── KitchenSink.xcworkspace/
        │   ├── contents.xcworkspacedata
        │   ├── xcshareddata/
        │   │   ├── IDEWorkspaceChecks.plist
        │   │   └── swiftpm/
        │   │       └── configuration/
        │   └── xcuserdata/
        │       └── stewie.xcuserdatad/
        │           └── UserInterfaceState.xcuserstate
        ├── KitchenSinkBroadcastExtension/
        │   ├── Info.plist
        │   ├── KitchenSinkBroadcastExtension.entitlements
        │   ├── KitchenSinkBroadcastExtension.h
        │   └── SampleHandler.swift
        ├── KitchenSinkUITests/
        │   ├── Info.plist
        │   ├── KitchenSinkUITests.swift
        │   ├── Messaging/
        │   │   ├── MessagingPeopleTests.swift
        │   │   ├── MessagingReadStatusUITests.swift
        │   │   ├── MessagingSpacesTests.swift
        │   │   ├── MessagingTeamsTests.swift
        │   │   ├── MessagingTestCase.swift
        │   │   └── MessagingTests.swift
        │   └── util/
        │       ├── Array+Extensions.swift
        │       ├── Character+Extensions.swift
        │       ├── KitchenSinkFeature.swift
        │       ├── MessagingTab.swift
        │       ├── NSPredicate+Extensions.swift
        │       ├── String+Extensions.swift
        │       └── XCTestCase+Extensions.swift
        ├── LICENSE
        ├── Podfile
        ├── Podfile.lock
        ├── Pods/
        │   ├── Headers/
        │   ├── Local Podspecs/
        │   ├── Manifest.lock
        │   ├── Pods.xcodeproj/
        │   │   ├── project.pbxproj
        │   │   └── xcuserdata/
        │   │       └── stewie.xcuserdatad/
        │   │           └── xcschemes/
        │   │               ├── Pods-KitchenSink-KitchenSinkUITests.xcscheme
        │   │               ├── Pods-KitchenSink.xcscheme
        │   │               ├── Pods-KitchenSinkBroadcastExtension.xcscheme
        │   │               ├── WebexBroadcastExtensionKit.xcscheme
        │   │               ├── WebexSDK.xcscheme
        │   │               └── xcschememanagement.plist
        │   ├── Target Support Files/
        │   │   ├── Pods-KitchenSink/
        │   │   │   ├── Pods-KitchenSink-Info.plist
        │   │   │   ├── Pods-KitchenSink-acknowledgements.markdown
        │   │   │   ├── Pods-KitchenSink-acknowledgements.plist
        │   │   │   ├── Pods-KitchenSink-dummy.m
        │   │   │   ├── Pods-KitchenSink-frameworks-Debug-input-files.xcfilelist
        │   │   │   ├── Pods-KitchenSink-frameworks-Debug-output-files.xcfilelist
        │   │   │   ├── Pods-KitchenSink-frameworks-Release-input-files.xcfilelist
        │   │   │   ├── Pods-KitchenSink-frameworks-Release-output-files.xcfilelist
        │   │   │   ├── Pods-KitchenSink-frameworks.sh*
        │   │   │   ├── Pods-KitchenSink-umbrella.h
        │   │   │   ├── Pods-KitchenSink.debug.xcconfig
        │   │   │   ├── Pods-KitchenSink.modulemap
        │   │   │   └── Pods-KitchenSink.release.xcconfig
        │   │   ├── Pods-KitchenSink-KitchenSinkUITests/
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-Info.plist
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-acknowledgements.markdown
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-acknowledgements.plist
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-dummy.m
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-frameworks-Debug-input-files.xcfilelist
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-frameworks-Debug-output-files.xcfilelist
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-frameworks-Release-input-files.xcfilelist
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-frameworks-Release-output-files.xcfilelist
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-frameworks.sh*
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests-umbrella.h
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests.debug.xcconfig
        │   │   │   ├── Pods-KitchenSink-KitchenSinkUITests.modulemap
        │   │   │   └── Pods-KitchenSink-KitchenSinkUITests.release.xcconfig
        │   │   ├── Pods-KitchenSinkBroadcastExtension/
        │   │   │   ├── Pods-KitchenSinkBroadcastExtension-Info.plist
        │   │   │   ├── Pods-KitchenSinkBroadcastExtension-acknowledgements.markdown
        │   │   │   ├── Pods-KitchenSinkBroadcastExtension-acknowledgements.plist
        │   │   │   ├── Pods-KitchenSinkBroadcastExtension-dummy.m
        │   │   │   ├── Pods-KitchenSinkBroadcastExtension-umbrella.h
        │   │   │   ├── Pods-KitchenSinkBroadcastExtension.debug.xcconfig
        │   │   │   ├── Pods-KitchenSinkBroadcastExtension.modulemap
        │   │   │   └── Pods-KitchenSinkBroadcastExtension.release.xcconfig
        │   │   ├── WebexBroadcastExtensionKit/
        │   │   │   ├── WebexBroadcastExtensionKit.debug.xcconfig
        │   │   │   └── WebexBroadcastExtensionKit.release.xcconfig
        │   │   └── WebexSDK/
        │   │       ├── WebexSDK.debug.xcconfig
        │   │       └── WebexSDK.release.xcconfig
        │   ├── WebexBroadcastExtensionKit/
        │   │   ├── Frameworks/
        │   │   │   └── WebexBroadcastExtensionKit.framework/
        │   │   │       ├── .DS_Store
        │   │   │       ├── Headers/
        │   │   │       │   ├── LLBSDConnection.h*
        │   │   │       │   ├── SampleHelper.h
        │   │   │       │   ├── ScreenShare.h
        │   │   │       │   ├── WebexBroadcastExtensionKit-Swift.h
        │   │   │       │   └── WebexBroadcastExtensionKit.h
        │   │   │       ├── Info.plist
        │   │   │       ├── Modules/
        │   │   │       │   ├── .DS_Store
        │   │   │       │   ├── WebexBroadcastExtensionKit.swiftmodule/
        │   │   │       │   │   ├── Project/
        │   │   │       │   │   │   ├── arm64-apple-ios.swiftsourceinfo
        │   │   │       │   │   │   ├── arm64.swiftsourceinfo
        │   │   │       │   │   │   ├── x86_64-apple-ios-simulator.swiftsourceinfo
        │   │   │       │   │   │   └── x86_64.swiftsourceinfo
        │   │   │       │   │   ├── arm64-apple-ios.swiftdoc
        │   │   │       │   │   ├── arm64-apple-ios.swiftinterface
        │   │   │       │   │   ├── arm64-apple-ios.swiftmodule
        │   │   │       │   │   ├── arm64.swiftdoc
        │   │   │       │   │   ├── arm64.swiftinterface
        │   │   │       │   │   ├── arm64.swiftmodule
        │   │   │       │   │   ├── x86_64-apple-ios-simulator.swiftdoc
        │   │   │       │   │   ├── x86_64-apple-ios-simulator.swiftinterface
        │   │   │       │   │   ├── x86_64-apple-ios-simulator.swiftmodule
        │   │   │       │   │   ├── x86_64.swiftdoc
        │   │   │       │   │   ├── x86_64.swiftinterface
        │   │   │       │   │   └── x86_64.swiftmodule
        │   │   │       │   └── module.modulemap
        │   │   │       └── WebexBroadcastExtensionKit*
        │   │   ├── LICENSE
        │   │   └── README.md
        │   └── WebexSDK/
        │       ├── Frameworks/
        │       │   ├── UCFBridge.framework/
        │       │   │   ├── .DS_Store
        │       │   │   ├── Headers/
        │       │   │   │   ├── AppleConversionFunctions.h
        │       │   │   │   ├── AppleSparkClientProvider.h
        │       │   │   │   ├── CHAccessTokenLoginResult.h
        │       │   │   │   ├── CHApplyVirtualBackgroundResult.h
        │       │   │   │   ├── CHBase64EncodeResult.h
        │       │   │   │   ├── CHBreakoutSessionError.h
        │       │   │   │   ├── CHCalendarMeetingEvent.h
        │       │   │   │   ├── CHCallAssociationType.h
        │       │   │   │   ├── CHCallDirection.h
        │       │   │   │   ├── CHCallMembershipState.h
        │       │   │   │   ├── CHCaptchaRefreshResult.h
        │       │   │   │   ├── CHCompositedVideoLayout.h
        │       │   │   │   ├── CHConversationSortType.h
        │       │   │   │   ├── CHConversationType.h
        │       │   │   │   ├── CHCreateSpaceMembershipResult.h
        │       │   │   │   ├── CHCreateTeamMembershipResult.h
        │       │   │   │   ├── CHCreateWebhookResult.h
        │       │   │   │   ├── CHDeleteMessageResult.h
        │       │   │   │   ├── CHDeleteSpaceResult.h
        │       │   │   │   ├── CHDeleteTeamMembershipResult.h
        │       │   │   │   ├── CHDeleteVirtualBackgroundResult.h
        │       │   │   │   ├── CHDeleteWebhookByIdResult.h
        │       │   │   │   ├── CHDownloadFileResult.h
        │       │   │   │   ├── CHDownloadThumbnailResult.h
        │       │   │   │   ├── CHFetchVirtualBackgroundResult.h
        │       │   │   │   ├── CHGetCalendarMeetingByIdResult.h
        │       │   │   │   ├── CHGetMembershipByIdResult.h
        │       │   │   │   ├── CHGetMessageResult.h
        │       │   │   │   ├── CHGetTeamMembershipResult.h
        │       │   │   │   ├── CHGetWebhookByIdResult.h
        │       │   │   │   ├── CHInviteeResponse.h
        │       │   │   │   ├── CHJWTTokenResult.h
        │       │   │   │   ├── CHJoinBreakoutResult.h
        │       │   │   │   ├── CHLetInResult.h
        │       │   │   │   ├── CHListCalendarMeetingsResult.h
        │       │   │   │   ├── CHListMembershipResult.h
        │       │   │   │   ├── CHListMembershipsReadStatusResult.h
        │       │   │   │   ├── CHListMessagesResult.h
        │       │   │   │   ├── CHListPersonsResult.h
        │       │   │   │   ├── CHListTeamMembershipResult.h
        │       │   │   │   ├── CHListWebhooksResult.h
        │       │   │   │   ├── CHMakeCallResult.h
        │       │   │   │   ├── CHMarkMessageReadResult.h
        │       │   │   │   ├── CHMediaQualityInfo.h
        │       │   │   │   ├── CHMediaStreamChangeEventType.h
        │       │   │   │   ├── CHMediaStreamQuality.h
        │       │   │   │   ├── CHMediaStreamType.h
        │       │   │   │   ├── CHMeetingLinkType.h
        │       │   │   │   ├── CHMeetingLockedErrorCodes.h
        │       │   │   │   ├── CHMeetingServiceType.h
        │       │   │   │   ├── CHMembershipDeleteResult.h
        │       │   │   │   ├── CHMembershipEvent.h
        │       │   │   │   ├── CHMembershipUpdateResult.h
        │       │   │   │   ├── CHMentionType.h
        │       │   │   │   ├── CHMessageEvent.h
        │       │   │   │   ├── CHMessageResult.h
        │       │   │   │   ├── CHNotificationCallType.h
        │       │   │   │   ├── CHOAuthResult.h
        │       │   │   │   ├── CHPersonCreateResult.h
        │       │   │   │   ├── CHPersonDeleteResult.h
        │       │   │   │   ├── CHPersonGetResult.h
        │       │   │   │   ├── CHPersonUpdateResult.h
        │       │   │   │   ├── CHPhoneServiceRegistrationFailureReason.h
        │       │   │   │   ├── CHPreviewVirtualBackgroundResult.h
        │       │   │   │   ├── CHResourceType.h
        │       │   │   │   ├── CHReturnToMainSessionResult.h
        │       │   │   │   ├── CHRole.h
        │       │   │   │   ├── CHServiceUrlType.h
        │       │   │   │   ├── CHSessionType.h
        │       │   │   │   ├── CHSetCompositedLayoutResult.h
        │       │   │   │   ├── CHSetRemoteVideoRenderModeResult.h
        │       │   │   │   ├── CHShareSourceType.h
        │       │   │   │   ├── CHSpaceEvent.h
        │       │   │   │   ├── CHTeamArchiveResult.h
        │       │   │   │   ├── CHTeamCreateResult.h
        │       │   │   │   ├── CHTeamGetResult.h
        │       │   │   │   ├── CHTeamListResult.h
        │       │   │   │   ├── CHTeamUpdateResult.h
        │       │   │   │   ├── CHTelemetry.h
        │       │   │   │   ├── CHUCBrowserLoginSSONavResult.h
        │       │   │   │   ├── CHUCLoginServerConnectionStatus.h
        │       │   │   │   ├── CHUCSSOFailureReason.h
        │       │   │   │   ├── CHUpdateSpaceTitleResult.h
        │       │   │   │   ├── CHUpdateTeamMembershipResult.h
        │       │   │   │   ├── CHUpdateWebhookByIdResult.h
        │       │   │   │   ├── CHUploadVirtualBackgroundResult.h
        │       │   │   │   ├── CHVideoFlashMode.h
        │       │   │   │   ├── CHVideoRenderMode.h
        │       │   │   │   ├── CHVideoStreamMode.h
        │       │   │   │   ├── CHVideoTorchMode.h
        │       │   │   │   ├── CHVirtualBackgroundType.h
        │       │   │   │   ├── CHWebexMeetingEntryPoint.h
        │       │   │   │   ├── CocoaFrameworks.h
        │       │   │   │   ├── Frameworks.h
        │       │   │   │   ├── OmniusServiceBridge.h
        │       │   │   │   ├── OmniusServiceBridgeProtocol.h
        │       │   │   │   ├── RootLoggerImpl.h
        │       │   │   │   ├── UCFBridge-Swift.h
        │       │   │   │   └── UCFBridge.h
        │       │   │   ├── Info.plist
        │       │   │   ├── Modules/
        │       │   │   │   ├── UCFBridge.swiftmodule/
        │       │   │   │   │   ├── Project/
        │       │   │   │   │   │   ├── arm64-apple-ios.swiftsourceinfo
        │       │   │   │   │   │   ├── arm64.swiftsourceinfo
        │       │   │   │   │   │   ├── x86_64-apple-ios-simulator.swiftsourceinfo
        │       │   │   │   │   │   └── x86_64.swiftsourceinfo
        │       │   │   │   │   ├── arm64-apple-ios.swiftdoc
        │       │   │   │   │   ├── arm64-apple-ios.swiftinterface
        │       │   │   │   │   ├── arm64-apple-ios.swiftmodule
        │       │   │   │   │   ├── arm64.swiftdoc
        │       │   │   │   │   ├── arm64.swiftinterface
        │       │   │   │   │   ├── arm64.swiftmodule
        │       │   │   │   │   ├── x86_64-apple-ios-simulator.swiftdoc
        │       │   │   │   │   ├── x86_64-apple-ios-simulator.swiftinterface
        │       │   │   │   │   ├── x86_64-apple-ios-simulator.swiftmodule
        │       │   │   │   │   ├── x86_64.swiftdoc
        │       │   │   │   │   ├── x86_64.swiftinterface
        │       │   │   │   │   └── x86_64.swiftmodule
        │       │   │   │   └── module.modulemap
        │       │   │   └── UCFBridge*
        │       │   ├── WebexSDK.framework/
        │       │   │   ├── .DS_Store
        │       │   │   ├── Headers/
        │       │   │   │   ├── BroadcastUtil.h
        │       │   │   │   ├── SparkVideoLayer.h
        │       │   │   │   ├── WebexBroadcastCallServerProtocol.h
        │       │   │   │   ├── WebexSDK-Swift.h
        │       │   │   │   └── WebexSDK.h
        │       │   │   ├── Info.plist
        │       │   │   ├── Modules/
        │       │   │   │   ├── .DS_Store
        │       │   │   │   ├── WebexSDK.swiftmodule/
        │       │   │   │   │   ├── Project/
        │       │   │   │   │   │   ├── arm64-apple-ios.swiftsourceinfo
        │       │   │   │   │   │   ├── arm64.swiftsourceinfo
        │       │   │   │   │   │   ├── x86_64-apple-ios-simulator.swiftsourceinfo
        │       │   │   │   │   │   └── x86_64.swiftsourceinfo
        │       │   │   │   │   ├── arm64-apple-ios.swiftdoc
        │       │   │   │   │   ├── arm64-apple-ios.swiftinterface
        │       │   │   │   │   ├── arm64-apple-ios.swiftmodule
        │       │   │   │   │   ├── arm64.swiftdoc
        │       │   │   │   │   ├── arm64.swiftinterface
        │       │   │   │   │   ├── arm64.swiftmodule
        │       │   │   │   │   ├── x86_64-apple-ios-simulator.swiftdoc
        │       │   │   │   │   ├── x86_64-apple-ios-simulator.swiftinterface
        │       │   │   │   │   ├── x86_64-apple-ios-simulator.swiftmodule
        │       │   │   │   │   ├── x86_64.swiftdoc
        │       │   │   │   │   ├── x86_64.swiftinterface
        │       │   │   │   │   └── x86_64.swiftmodule
        │       │   │   │   └── module.modulemap
        │       │   │   ├── PortraitSeg.mlmodelc/
        │       │   │   │   ├── analytics/
        │       │   │   │   │   └── coremldata.bin
        │       │   │   │   ├── coremldata.bin
        │       │   │   │   ├── metadata.json
        │       │   │   │   ├── model/
        │       │   │   │   │   └── coremldata.bin
        │       │   │   │   ├── model.espresso.net
        │       │   │   │   ├── model.espresso.shape
        │       │   │   │   ├── model.espresso.weights
        │       │   │   │   └── neural_network_optionals/
        │       │   │   │       └── coremldata.bin
        │       │   │   ├── PortraitSegNew.mlmodelc/
        │       │   │   │   ├── analytics/
        │       │   │   │   │   └── coremldata.bin
        │       │   │   │   ├── coremldata.bin
        │       │   │   │   ├── metadata.json
        │       │   │   │   ├── model/
        │       │   │   │   │   └── coremldata.bin
        │       │   │   │   ├── model.espresso.net
        │       │   │   │   ├── model.espresso.shape
        │       │   │   │   ├── model.espresso.weights
        │       │   │   │   └── neural_network_optionals/
        │       │   │   │       └── coremldata.bin
        │       │   │   ├── WebexSDK*
        │       │   │   └── wseFilter.metallib
        │       │   ├── mediastores_ios.framework/
        │       │   │   ├── Info.plist
        │       │   │   ├── _CodeSignature/
        │       │   │   │   └── CodeResources
        │       │   │   └── mediastores_ios
        │       │   ├── util_ios.framework/
        │       │   │   ├── Info.plist
        │       │   │   ├── _CodeSignature/
        │       │   │   │   └── CodeResources
        │       │   │   └── util_ios*
        │       │   ├── wbxaecodec.framework/
        │       │   │   ├── Info.plist
        │       │   │   └── wbxaecodec*
        │       │   └── wbxaudioengine.framework/
        │       │       ├── Info.plist
        │       │       └── wbxaudioengine*
        │       ├── LICENSE
        │       └── README.md
        ├── README.md
        └── images/
            ├── BlurVB.png
            ├── CUCM-flow-iOS-SDK.png
            ├── CustomVB.png
            ├── DurationISO.gif
            ├── Flash.gif
            ├── FocusPoint.gif
            ├── NoneVB.png
            ├── Picture1.png
            ├── Picture2.png
            ├── Picture3.png
            ├── Picture4.png
            ├── Picture5.png
            ├── Picture6.png
            ├── Picture7.png
            ├── Picture8.png
            ├── TakePhoto.gif
            ├── TargetBias.gif
            ├── Torch.gif
            ├── Zoom.gif
            ├── add_integration_button.png
            ├── apns.png
            ├── apns1.png
            ├── apns2.png
            ├── apns3.png
            ├── apns4.png
            ├── apns5.png
            ├── app_description.png
            ├── choose_icon.png
            ├── developer_email.png
            ├── fcm.png
            ├── fcm_generate_private_key_button.png
            ├── fcm_project_settings_button.png
            ├── integration_name.png
            ├── mqi1.gif
            ├── mqi2.gif
            ├── multistream.jpeg
            ├── multistreamNew.png
            ├── multistream_pinstream.png
            ├── redirect_uri.png
            ├── secrets.png
            ├── select_yes_for_sdk.png
            ├── signing_and_capabilities.png
            ├── wxa-can-control.gif
            ├── wxa-enable.gif
            └── wxa-rtt-reception.gif

        """

        try Path.mktemp(treeString: tree) { root in
            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"KitchenSink.xcworkspace"))
        }
    }

    func testFindXcrowkspaceAtSameLevel3() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── .gitignore
        ├── .ruby-version
        ├── .xcode-version
        ├── Gemfile
        ├── Gemfile.lock
        ├── Podfile
        ├── Podfile.lock
        ├── _myproj.xcworkspace/
        └── 1myproj.xcodeproj/

        """

        try Path.mktemp(treeString: tree) { root in
            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"_myproj.xcworkspace"))
        }
    }

}

/*

 try Path.mktemp { tmpdir in
     try tmpdir.a.touch()
     try tmpdir.b.touch()
     try tmpdir.c.mkdir().join("e").touch()

     do {
         let finder = tmpdir.find().depth(max: 1)
         XCTAssertEqual(finder.depth, 1...1)
       #if !os(Linux) || swift(>=5)
         XCTAssertEqual(Set(finder), Set([tmpdir.a, tmpdir.b, tmpdir.c].map(Path.init)))
       #endif
     }
     do {
         let finder = tmpdir.find().depth(max: 0)
         XCTAssertEqual(finder.depth, 0...0)
       #if !os(Linux) || swift(>=5)
         XCTAssertEqual(Set(finder), Set())
       #endif
     }
 }
 */
