import QtQuick
import QtQuick.Layouts
import Mahina

Window {
    width:   1000
    height:  680
    visible: true
    title:   "Mahina — Kitchen Sink"
    color:   Theme.background

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Key handling lives on the content root so it is an ancestor of every
        // focusable item: unhandled keys bubble up here, while a focused text
        // field still consumes "d" normally.
        focus: true
        Keys.onPressed: (e) => { if (e.text === "d") Theme.dark = !Theme.dark }

        // ── NavBar ────────────────────────────────────────────────────────────
        NavBar {
            title: "Mahina UI"
            Layout.fillWidth: true

            Button {
                text:    Theme.dark ? "Light" : "Dark"
                variant: Button.Variant.Ghost
                size:    Button.Size.Sm
                onClicked: Theme.dark = !Theme.dark
            }

            Button {
                text: "Sign in"
                size: Button.Size.Sm
            }
        }

        // ── Body: Sidebar + Content ───────────────────────────────────────────
        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing: 0

            // ── Sidebar ───────────────────────────────────────────────────────
            Sidebar {
                Layout.fillHeight: true
                title:        "Kitchen Sink"
                subtitle:     "Mahina UI v0.45.0"
                footerText:   "Press D for dark mode"
                currentIndex: _stack.currentIndex
                model: [
                    { icon: Icons.squaresFour, label: "Components"    },
                    { icon: Icons.bell,        label: "Notifications" },
                    { icon: Icons.textAa,      label: "Typography"    },
                    { icon: Icons.palette,     label: "Icons"         },
                    { icon: Icons.textT,       label: "Forms"         },
                    { icon: Icons.table,       label: "Data"          },
                    { icon: Icons.magicWand,   label: "Extended"      },
                    { icon: Icons.sparkle,     label: "More"          },
                    { icon: Icons.lightning,   label: "Advanced"      },
                    { icon: Icons.gear,        label: "Settings"      },
                    { icon: Icons.monitor,     label: "Display & Data"   },
                    { icon: Icons.chartBar,    label: "Charts & Layout"  },
                    { icon: Icons.chartLine,   label: "Charts & Nav"     },
                    { icon: Icons.sliders,     label: "Inputs & Charts"  },
                    { icon: Icons.chat,        label: "Social & Feedback"},
                    { icon: Icons.users,       label: "Social & Charts"  },
                    { icon: Icons.compass,     label: "Nav & Inputs"     },
                    { icon: Icons.code,        label: "Editors & Tools"  },
                    { icon: Icons.dotsThree,   label: "Odds & Ends"      },
                ]
                onItemClicked: (i) => _stack.currentIndex = i
            }

            // ── Page content ──────────────────────────────────────────────────
            StackLayout {
                id: _stack
                Layout.fillWidth:  true
                Layout.fillHeight: true
                currentIndex: 0

                // Page 0 — Components
                Flickable {
                    contentWidth:  width
                    contentHeight: _page0.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id: _page0
                        width: parent.width
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp8 }
                        spacing: Theme.sp8

                        Text {
                            text: "Buttons"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp3
                            Button { text: "Primary";  variant: Button.Variant.Filled   }
                            Button { text: "Outlined"; variant: Button.Variant.Outlined  }
                            Button { text: "Ghost";    variant: Button.Variant.Ghost     }
                            Button { text: "Danger";   variant: Button.Variant.Danger    }
                            Button { iconName: Icons.gear; iconOnly: true }
                        }

                        RowLayout { spacing: Theme.sp3
                            Button { text: "Download"; iconName: Icons.download;   size: Button.Size.Sm }
                            Button { text: "Settings"; iconName: Icons.gear;       size: Button.Size.Md }
                            Button { text: "Continue"; iconName: Icons.arrowRight; size: Button.Size.Lg }
                        }

                        Text {
                            text: "Badges"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp2
                            Badge { text: "Default" }
                            Badge { text: "Primary"; colorScheme: Badge.Color.Primary; pill: true }
                            Badge { text: "Success"; colorScheme: Badge.Color.Success; iconName: Icons.checkCircle }
                            Badge { text: "Warning"; colorScheme: Badge.Color.Warning }
                            Badge { text: "Error";   colorScheme: Badge.Color.Error   }
                            Badge { text: "Info";    colorScheme: Badge.Color.Info    }
                        }

                        Text {
                            text: "Inputs"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp4
                            Input {
                                label: "Email"; placeholderText: "name@example.com"
                                leadingIcon: Icons.envelope; Layout.fillWidth: true
                            }
                            Input {
                                label: "Password"; placeholderText: "••••••••"
                                leadingIcon: Icons.lockSimple; errorText: "Too short"
                                Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: "Card"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        Card {
                            title: "Notifications"; subtitle: "You have 3 unread messages"
                            hoverable: true; Layout.fillWidth: true

                            RowLayout { spacing: Theme.sp3
                                Icon { name: Icons.bell; size: 18; color: Theme.primary }
                                Text {
                                    text: "Enable desktop notifications"
                                    color: Theme.textPrimary; font.family: Theme.fontFamily
                                    font.pixelSize: Theme.textSm
                                }
                                Item { Layout.fillWidth: true }
                                Button { text: "Enable"; size: Button.Size.Sm }
                            }
                        }

                        Divider { label: "or continue with" }

                        Text {
                            text: "Avatars"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp4
                            // Sizes
                            Avatar { size: Avatar.Size.Xs; name: "João Ribeiro" }
                            Avatar { size: Avatar.Size.Sm; name: "Ana Silva" }
                            Avatar { size: Avatar.Size.Md; name: "Carlos Mendes" }
                            Avatar { size: Avatar.Size.Lg; name: "Diana Ferreira" }
                            Avatar { size: Avatar.Size.Xl; name: "Eduardo Costa" }

                            Item { width: Theme.sp4 }

                            // Status indicators
                            Avatar { name: "Online";  status: Avatar.Status.Online  }
                            Avatar { name: "Away";    status: Avatar.Status.Away    }
                            Avatar { name: "Busy";    status: Avatar.Status.Busy    }
                            Avatar { name: "Offline"; status: Avatar.Status.Offline }

                            Item { width: Theme.sp4 }

                            // Fallback & square
                            Avatar { size: Avatar.Size.Md }
                            Avatar { size: Avatar.Size.Md; name: "Square"; square: true }
                        }

                        Text {
                            text: "Chips"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        // Color variants
                        RowLayout { spacing: Theme.sp2
                            Chip { text: "Default" }
                            Chip { text: "Primary"; colorScheme: Chip.Color.Primary }
                            Chip { text: "Success"; colorScheme: Chip.Color.Success }
                            Chip { text: "Warning"; colorScheme: Chip.Color.Warning }
                            Chip { text: "Error";   colorScheme: Chip.Color.Error   }
                            Chip { text: "Info";    colorScheme: Chip.Color.Info    }
                        }

                        // Interactive + removable
                        RowLayout { spacing: Theme.sp2
                            Chip { text: "TypeScript";  iconName: Icons.code;   selected: true  }
                            Chip { text: "QML";         iconName: Icons.code;   selected: false }
                            Chip { text: "C++";         iconName: Icons.code                    }
                            Chip { text: "removable@example.com"; removable: true }
                            Chip { text: "tag"; removable: true; colorScheme: Chip.Color.Primary }
                        }

                        Text {
                            text: "Progress"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        ColumnLayout { spacing: Theme.sp4; Layout.fillWidth: true
                            ProgressBar { label: "Uploading file"; showValue: true; value: 0.67; Layout.fillWidth: true }
                            ProgressBar { label: "Processing";     indeterminate: true;          Layout.fillWidth: true }
                            ProgressBar { value: 1.0; colorScheme: ProgressBar.Color.Success; size: ProgressBar.Size.Sm; Layout.fillWidth: true }
                            ProgressBar { value: 0.4; colorScheme: ProgressBar.Color.Warning; size: ProgressBar.Size.Sm; Layout.fillWidth: true }
                            ProgressBar { value: 0.2; colorScheme: ProgressBar.Color.Error;   size: ProgressBar.Size.Sm; Layout.fillWidth: true }
                        }

                        Text {
                            text: "Spinners"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp6
                            Spinner { size: 16 }
                            Spinner { size: 20 }
                            Spinner { size: 24 }
                            Spinner { size: 32 }
                            Spinner { size: 40 }
                            Spinner { size: 24; color: Theme.success }
                            Spinner { size: 24; color: Theme.warning }
                            Spinner { size: 24; color: Theme.error   }
                        }

                        Text {
                            text: "Tooltips"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp3
                            Tooltip {
                                text: "Save the document (Ctrl+S)"
                                Button { text: "Save"; iconName: Icons.floppyDisk }
                            }
                            Tooltip {
                                text: "Open settings"
                                Button { iconName: Icons.gear; iconOnly: true; variant: Button.Variant.Ghost }
                            }
                            Tooltip {
                                text: "This action is permanent and cannot be undone."
                                Button { text: "Delete"; variant: Button.Variant.Danger }
                            }
                            Tooltip {
                                text: "Tooltip on a badge"
                                Badge { text: "Beta"; colorScheme: Badge.Color.Info }
                            }
                        }

                        Text {
                            text: "Checkboxes & Toggles"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp8
                            ColumnLayout { spacing: Theme.sp3
                                Checkbox { text: "Unchecked" }
                                Checkbox { text: "Checked"; checked: true }
                                Checkbox { text: "Indeterminate"; checkState: Qt.PartiallyChecked; tristate: true }
                                Checkbox { text: "Disabled"; enabled: false }
                                Checkbox { text: "Error state"; errorText: "This field is required" }
                            }
                            ColumnLayout { spacing: Theme.sp3
                                Toggle { text: "Off by default" }
                                Toggle { text: "On by default"; checked: true }
                                Toggle { text: "Disabled off"; enabled: false }
                                Toggle { text: "Disabled on"; checked: true; enabled: false }
                            }
                        }

                        Text {
                            text: "Dropdowns"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp4
                            Dropdown {
                                label: "Language"
                                model: ["English", "Portuguese", "Spanish", "French", "Japanese"]
                                currentIndex: 0
                                Layout.preferredWidth: 200
                            }
                            Dropdown {
                                label: "Role"
                                placeholder: "Choose a role…"
                                model: [
                                    { value: "admin",  label: "Administrator" },
                                    { value: "editor", label: "Editor"        },
                                    { value: "viewer", label: "Viewer"        },
                                ]
                                currentIndex: -1
                                Layout.preferredWidth: 200
                            }
                            Dropdown {
                                label: "Status"
                                model: ["Active", "Inactive"]
                                currentIndex: 0
                                disabled: true
                                Layout.preferredWidth: 160
                            }
                        }

                        Text {
                            text: "Dialog"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp3
                            Button {
                                text: "Open dialog"
                                iconName: Icons.arrowSquareOut
                                onClicked: _confirmDlg.open()
                            }
                            Button {
                                text: "Info dialog"
                                variant: Button.Variant.Outlined
                                onClicked: _infoDlg.open()
                            }
                        }

                        Item { height: Theme.sp8 }
                    }

                    // ── Confirm dialog ────────────────────────────────────────
                    Dialog {
                        id: _confirmDlg
                        title:    "Delete project"
                        subtitle: "This action cannot be undone."

                        Text {
                            text: "All files, members, and settings for this project will be permanently removed. Are you sure you want to continue?"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textSm
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        footer: Row {
                            spacing: Theme.sp2
                            Button { text: "Cancel"; variant: Button.Variant.Ghost;  onClicked: _confirmDlg.close() }
                            Button { text: "Delete"; variant: Button.Variant.Danger; onClicked: _confirmDlg.close() }
                        }
                    }

                    // ── Info dialog ───────────────────────────────────────────
                    Dialog {
                        id: _infoDlg
                        title: "Keyboard shortcuts"

                        Column {
                            width: parent.width
                            spacing: Theme.sp2

                            Repeater {
                                model: [
                                    { key: "D",          desc: "Toggle dark mode"  },
                                    { key: "Ctrl+S",     desc: "Save document"     },
                                    { key: "Ctrl+Z",     desc: "Undo"              },
                                    { key: "Ctrl+Shift+Z", desc: "Redo"            },
                                ]

                                RowLayout {
                                    width: parent.width
                                    spacing: Theme.sp3

                                    Rectangle {
                                        implicitWidth:  _keyLabel.implicitWidth + Theme.sp3 * 2
                                        implicitHeight: _keyLabel.implicitHeight + Theme.sp1 * 2
                                        color:  Theme.panel
                                        radius: Theme.radiusSm
                                        border.color: Theme.border

                                        Text {
                                            id: _keyLabel
                                            anchors.centerIn: parent
                                            text: modelData.key
                                            color: Theme.textPrimary
                                            font.family: Theme.fontFamilyMono
                                            font.pixelSize: Theme.textXs
                                            font.weight: Theme.weightSemibold
                                        }
                                    }

                                    Text {
                                        text: modelData.desc
                                        color: Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.textSm
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }

                        footer: Row {
                            Button { text: "Close"; variant: Button.Variant.Ghost; onClicked: _infoDlg.close() }
                        }
                    }
                }

                // Page 1 — Notifications
                Flickable {
                    contentWidth:  width
                    contentHeight: _page1.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id: _page1
                        width: parent.width
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp8 }
                        spacing: Theme.sp4

                        Text {
                            text: "Notifications"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        Notification {
                            type: Notification.Type.Info
                            title: "Update available"
                            message: "Version 2.1.0 is ready to install."
                            Layout.fillWidth: true
                        }
                        Notification {
                            type: Notification.Type.Success
                            title: "Changes saved"
                            message: "Your profile was updated successfully."
                            Layout.fillWidth: true
                        }
                        Notification {
                            type: Notification.Type.Warning
                            title: "Storage almost full"
                            message: "You are using 90% of your available space."
                            Layout.fillWidth: true
                        }
                        Notification {
                            type: Notification.Type.Error
                            title: "Connection failed"
                            message: "Could not reach the server. Check your network."
                            Layout.fillWidth: true
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 2 — Typography
                Flickable {
                    contentWidth:  width
                    contentHeight: _page2.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id: _page2
                        width: parent.width
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp8 }
                        spacing: Theme.sp3

                        Text { text: "Display";   font.pixelSize: Theme.text4xl; font.weight: Theme.weightBold;     color: Theme.textPrimary;   font.family: Theme.fontFamily }
                        Text { text: "Heading 1"; font.pixelSize: Theme.text3xl; font.weight: Theme.weightSemibold; color: Theme.textPrimary;   font.family: Theme.fontFamily }
                        Text { text: "Heading 2"; font.pixelSize: Theme.text2xl; font.weight: Theme.weightSemibold; color: Theme.textPrimary;   font.family: Theme.fontFamily }
                        Text { text: "Heading 3"; font.pixelSize: Theme.textXl;  font.weight: Theme.weightSemibold; color: Theme.textPrimary;   font.family: Theme.fontFamily }
                        Text { text: "Body large"; font.pixelSize: Theme.textLg; color: Theme.textPrimary;   font.family: Theme.fontFamily }
                        Text { text: "Body base";  font.pixelSize: Theme.textBase; color: Theme.textPrimary; font.family: Theme.fontFamily }
                        Text { text: "Body small"; font.pixelSize: Theme.textSm;  color: Theme.textSecondary; font.family: Theme.fontFamily }
                        Text { text: "Caption";    font.pixelSize: Theme.textXs;  color: Theme.textDisabled;  font.family: Theme.fontFamily }
                        Divider {}
                        Text { text: "Primary color";   font.pixelSize: Theme.textBase; color: Theme.primary;   font.family: Theme.fontFamily }
                        Text { text: "Success color";   font.pixelSize: Theme.textBase; color: Theme.success;   font.family: Theme.fontFamily }
                        Text { text: "Warning color";   font.pixelSize: Theme.textBase; color: Theme.warning;   font.family: Theme.fontFamily }
                        Text { text: "Error color";     font.pixelSize: Theme.textBase; color: Theme.error;     font.family: Theme.fontFamily }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 3 — Icons
                Flickable {
                    contentWidth:  width
                    contentHeight: _page3.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id: _page3
                        width: parent.width
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp8 }
                        spacing: Theme.sp8

                        Text {
                            text: "Icon Weights"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp6
                            Repeater {
                                model: [
                                    { label: "Thin",    w: Icon.Weight.Thin    },
                                    { label: "Light",   w: Icon.Weight.Light   },
                                    { label: "Regular", w: Icon.Weight.Regular },
                                    { label: "Bold",    w: Icon.Weight.Bold    },
                                    { label: "Fill",    w: Icon.Weight.Fill    },
                                    { label: "Duotone", w: Icon.Weight.Duotone },
                                ]
                                ColumnLayout {
                                    spacing: Theme.sp2
                                    Icon {
                                        name: Icons.heart; size: 32; weight: modelData.w
                                        color: Theme.error; Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        text: modelData.label; color: Theme.textSecondary
                                        font.family: Theme.fontFamily; font.pixelSize: Theme.textXs
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 4 — Forms
                Flickable {
                    contentWidth:  width
                    contentHeight: _page4.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id: _page4
                        width: parent.width
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp8 }
                        spacing: Theme.sp8

                        Text {
                            text: "Textarea"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        ColumnLayout { spacing: Theme.sp4; Layout.fillWidth: true
                            Textarea {
                                label:           "Description"
                                placeholderText: "Write a short description…"
                                rows:            4
                                Layout.fillWidth: true
                            }
                            Textarea {
                                label:     "Bio"
                                placeholderText: "Tell us about yourself…"
                                rows:      3
                                showCount: true
                                maxLength: 280
                                Layout.fillWidth: true
                            }
                            Textarea {
                                label:     "Notes (auto-grow)"
                                placeholderText: "Starts small, grows as you type…"
                                autoGrow:  true
                                Layout.fillWidth: true
                            }
                            Textarea {
                                label:     "Error state"
                                placeholderText: "Required field"
                                errorText: "This field cannot be empty"
                                rows:      2
                                Layout.fillWidth: true
                            }
                        }

                        // ── Sliders ───────────────────────────────────────────────────────────
                        Text {
                            text: "Sliders"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        ColumnLayout { spacing: Theme.sp4; Layout.fillWidth: true
                            Slider { label: "Volume"; from: 0; to: 100; value: 72; showValue: true; decimals: 0; Layout.fillWidth: true }
                            Slider { label: "Opacity"; from: 0.0; to: 1.0; value: 0.5; showValue: true; decimals: 2; Layout.fillWidth: true }
                            Slider { label: "Disabled"; value: 0.3; disabled: true; Layout.fillWidth: true }
                            Slider { label: "Error state"; value: 0.8; errorText: "Value exceeds limit"; Layout.fillWidth: true }
                        }

                        // ── Radio buttons ─────────────────────────────────────────────────────
                        Text {
                            text: "Radio"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp10; Layout.fillWidth: true
                            RadioGroup {
                                label: "Subscription plan"
                                model: ["Monthly — $9/mo", "Annual — $7/mo", "Lifetime — $149"]
                                currentIndex: 1
                            }
                            RadioGroup {
                                label: "Alignment"
                                model: ["Left", "Center", "Right"]
                                horizontal: true
                                currentIndex: 0
                            }
                        }

                        // ── Accordion ─────────────────────────────────────────────────────────
                        Text {
                            text: "Accordion"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight:   _accCol.implicitHeight
                            color:            Theme.surface
                            radius:           Theme.radiusLg
                            border.color:     Theme.border
                            border.width:     1
                            clip:             true

                            Column {
                                id:    _accCol
                                width: parent.width

                                Accordion {
                                    title: "What is Mahina?"
                                    width: parent.width
                                    Text {
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                        text: "Mahina is a QML component library that blends the flat-design aesthetic with a CryptoChroma-inspired color system."
                                        color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                    }
                                }

                                Rectangle { width: parent.width; height: 1; color: Theme.border }

                                Accordion {
                                    title: "Installation"
                                    expanded: true
                                    width: parent.width
                                    Text {
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                        text: "Add Mahina as a subdirectory in your CMake project, then link against the Mahina target and import the QML module."
                                        color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                    }
                                }

                                Rectangle { width: parent.width; height: 1; color: Theme.border }

                                Accordion {
                                    title: "Customisation"
                                    width: parent.width
                                    ColumnLayout {
                                        width: parent.width
                                        spacing: Theme.sp3
                                        Text {
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                            text: "Override Theme properties at startup to adjust the palette, spacing, and typography tokens globally."
                                            color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                        }
                                        Toggle { text: "Dark mode"; onCheckedChanged: Theme.dark = checked }
                                    }
                                }
                            }
                        }

                        // ── Popover ───────────────────────────────────────────────────────────
                        Text {
                            text: "Popover"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp3

                            Button {
                                id: _popBottomBtn
                                text: "Below ↓"
                                variant: Button.Variant.Outlined
                                onClicked: _popBottom.open()
                            }
                            Popover {
                                id: _popBottom
                                anchor: _popBottomBtn
                                title: "Quick actions"
                                preferredWidth: 220
                                ColumnLayout {
                                    width: parent.width
                                    spacing: Theme.sp1
                                    Button { text: "Rename";   variant: Button.Variant.Ghost; Layout.fillWidth: true }
                                    Button { text: "Duplicate";variant: Button.Variant.Ghost; Layout.fillWidth: true }
                                    Button { text: "Archive";  variant: Button.Variant.Ghost; Layout.fillWidth: true }
                                    Divider {}
                                    Button { text: "Delete"; variant: Button.Variant.Danger; Layout.fillWidth: true; onClicked: _popBottom.close() }
                                }
                            }

                            Button {
                                id: _popTopBtn
                                text: "Above ↑"
                                variant: Button.Variant.Outlined
                                onClicked: _popTop.open()
                            }
                            Popover {
                                id: _popTop
                                anchor: _popTopBtn
                                position: Popover.Position.Top
                                preferredWidth: 200
                                Text {
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                    text: "This popover opens above the trigger button."
                                    color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                }
                            }

                            Button {
                                id: _popNoTitleBtn
                                text: "No title"
                                variant: Button.Variant.Ghost
                                onClicked: _popNoTitle.open()
                            }
                            Popover {
                                id: _popNoTitle
                                anchor: _popNoTitleBtn
                                preferredWidth: 180
                                RowLayout {
                                    spacing: Theme.sp2
                                    Avatar { name: "João Ribeiro"; size: Avatar.Size.Sm }
                                    ColumnLayout {
                                        spacing: 2
                                        Text { text: "João Ribeiro"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Theme.weightSemibold }
                                        Text { text: "iamajr@pm.me"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                                    }
                                }
                            }
                        }

                        // ── Skeleton ──────────────────────────────────────────────────────────
                        Text {
                            text: "Skeleton"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true

                            // Card-like loading placeholder
                            ColumnLayout { spacing: Theme.sp3
                                Skeleton { shape: Skeleton.Shape.Rect; width: 240; height: 120 }
                                RowLayout { spacing: Theme.sp3
                                    Skeleton { shape: Skeleton.Shape.Circle; width: 36 }
                                    ColumnLayout { spacing: Theme.sp2
                                        Skeleton { shape: Skeleton.Shape.Text; lines: 1; width: 140 }
                                        Skeleton { shape: Skeleton.Shape.Text; lines: 1; width: 100 }
                                    }
                                }
                                Skeleton { shape: Skeleton.Shape.Text; lines: 3; width: 240 }
                            }

                            // Text block
                            ColumnLayout { spacing: Theme.sp3
                                Skeleton { shape: Skeleton.Shape.Text; lines: 1; width: 180; implicitHeight: 20 }
                                Skeleton { shape: Skeleton.Shape.Text; lines: 4; width: 260 }
                                RowLayout { spacing: Theme.sp2
                                    Skeleton { width: 80;  height: 32; implicitHeight: 32 }
                                    Skeleton { width: 80;  height: 32; implicitHeight: 32 }
                                }
                            }

                            // Circles
                            RowLayout { spacing: Theme.sp3
                                Skeleton { shape: Skeleton.Shape.Circle; width: 28 }
                                Skeleton { shape: Skeleton.Shape.Circle; width: 36 }
                                Skeleton { shape: Skeleton.Shape.Circle; width: 48 }
                                Skeleton { shape: Skeleton.Shape.Circle; width: 56 }
                            }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 5 — Data / Navigation components
                Flickable {
                    contentWidth:  width
                    contentHeight: _page5.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id:      _page5
                        x:       Theme.sp8
                        y:       Theme.sp8
                        width:   parent.width - Theme.sp8 * 2
                        spacing: Theme.sp6

                        // ── SearchInput & NumberInput ──────────────────────────────────────
                        Text {
                            text: "Search & Number Input"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            SearchInput { placeholder: "Search components…"; Layout.fillWidth: true }
                            NumberInput { label: "Quantity"; value: 3;   min: 0;   max: 99; Layout.fillWidth: true }
                            NumberInput { label: "Price";    value: 9.99; min: 0.0; max: 999.99; step: 0.01; decimals: 2; Layout.fillWidth: true }
                        }

                        // ── Kbd ───────────────────────────────────────────────────────────
                        Text {
                            text: "Keyboard shortcuts"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp4
                            Kbd { keys: ["⌘", "K"] }
                            Kbd { shortcut: "Ctrl+Shift+P" }
                            Kbd { keys: ["Esc"] }
                            Kbd { keys: ["⌘", "Z"] }
                            Kbd { keys: ["⌘", "Shift", "Z"] }
                            Kbd { keys: ["↑"] }
                            Kbd { keys: ["↓"] }
                            Kbd { keys: ["Enter"] }
                        }

                        // ── Breadcrumb ────────────────────────────────────────────────────
                        Text {
                            text: "Breadcrumb"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        ColumnLayout { spacing: Theme.sp3
                            Breadcrumb { model: ["Home", "Products", "Electronics", "Laptops"] }
                            Breadcrumb { model: ["Home", "Settings", "Account"]; separator: "›" }
                            Breadcrumb { model: ["Home"] }
                        }

                        // ── Pagination ────────────────────────────────────────────────────
                        Text {
                            text: "Pagination"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        ColumnLayout { spacing: Theme.sp4
                            Pagination {
                                id:           _pag1
                                currentPage:  1
                                totalPages:   5
                                onPageChanged: (p) => currentPage = p
                            }
                            Pagination {
                                id:           _pag2
                                currentPage:  7
                                totalPages:   20
                                onPageChanged: (p) => currentPage = p
                            }
                            Pagination {
                                id:           _pag3
                                currentPage:  1
                                totalPages:   1
                            }
                        }

                        // ── Stepper ───────────────────────────────────────────────────────
                        Text {
                            text: "Stepper"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        ColumnLayout { spacing: Theme.sp5; Layout.fillWidth: true
                            Stepper {
                                id:           _stepper
                                Layout.fillWidth: true
                                steps:       ["Account", "Plan", "Payment", "Review"]
                                currentStep: 2
                            }

                            Stepper {
                                Layout.fillWidth: true
                                steps: [
                                    { label: "Account",  description: "Create profile" },
                                    { label: "Plan",     description: "Choose plan"   },
                                    { label: "Payment",  description: "Enter card"    },
                                    { label: "Done",     description: "All set!"      },
                                ]
                                currentStep: 1
                            }

                            RowLayout { spacing: Theme.sp2
                                Button {
                                    text: "← Back"
                                    variant: Button.Variant.Ghost
                                    enabled: _stepper.currentStep > 0
                                    onClicked: _stepper.currentStep--
                                }
                                Button {
                                    text: "Next →"
                                    enabled: _stepper.currentStep < _stepper.steps.length - 1
                                    onClicked: _stepper.currentStep++
                                }
                            }
                        }

                        // ── Menu ──────────────────────────────────────────────────────────
                        Text {
                            text: "Menu"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp3
                            Button {
                                id:   _menuBtn
                                text: "Actions ▾"
                                onClicked: _ctxMenu.open()
                            }
                            Menu {
                                id:     _ctxMenu
                                anchor: _menuBtn
                                model: [
                                    { label: "Edit",      icon: Icons.pencil                  },
                                    { label: "Duplicate", icon: Icons.copy,   shortcut: "⌘D"  },
                                    { label: "Share",     icon: Icons.shareNetwork             },
                                    null,
                                    { label: "Delete",    icon: Icons.trash,  danger: true     },
                                ]
                                onTriggered: (i, item) => console.log("Menu:", item.label)
                            }

                            Button {
                                id:   _menuBtn2
                                text: "File"
                                variant: Button.Variant.Ghost
                                onClicked: _fileMenu.open()
                            }
                            Menu {
                                id:     _fileMenu
                                anchor: _menuBtn2
                                model: [
                                    { label: "New",    shortcut: "⌘N" },
                                    { label: "Open",   shortcut: "⌘O" },
                                    { label: "Save",   shortcut: "⌘S" },
                                    { label: "Save As…", shortcut: "⌘⇧S" },
                                    null,
                                    { label: "Close",  shortcut: "⌘W" },
                                ]
                                onTriggered: (i, item) => console.log("File:", item.label)
                            }
                        }

                        // ── EmptyState ────────────────────────────────────────────────────
                        Text {
                            text: "Empty state"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            Card {
                                Layout.fillWidth: true
                                EmptyState {
                                    icon:        Icons.ghost
                                    title:       "No results"
                                    description: "Try adjusting your search or clearing the filters."
                                    action:      "Clear filters"
                                }
                            }
                            Card {
                                Layout.fillWidth: true
                                EmptyState {
                                    icon:   Icons.folderOpen
                                    title:  "No files yet"
                                    action: "Upload file"
                                }
                            }
                        }

                        // ── Table ─────────────────────────────────────────────────────────
                        Text {
                            text: "Table"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }

                        Table {
                            id: _table
                            Layout.fillWidth: true
                            striped: true
                            sortKey: "name"

                            columns: [
                                { key: "name",   label: "Name",   width: 160, sortable: true  },
                                { key: "role",   label: "Role",   width: 110                  },
                                { key: "status", label: "Status", width: 90                   },
                                { key: "email",  label: "Email",              sortable: true  },
                            ]

                            rows: [
                                { name: "Alice Chen",    role: "Admin",   status: "Active",   email: "alice@example.com"   },
                                { name: "Bob Martins",   role: "Editor",  status: "Active",   email: "bob@example.com"     },
                                { name: "Carol Santos",  role: "Viewer",  status: "Inactive", email: "carol@example.com"   },
                                { name: "David Oliveira",role: "Editor",  status: "Active",   email: "david@example.com"   },
                                { name: "Eve Silva",     role: "Admin",   status: "Active",   email: "eve@example.com"     },
                                { name: "Frank Costa",   role: "Viewer",  status: "Pending",  email: "frank@example.com"   },
                            ]

                            onSortChanged: (key, asc) => { sortKey = key; sortAscending = asc }
                            onRowClicked:  (i, row) => console.log("Row:", row.name)
                        }

                        Item { height: Theme.sp8 }

                        // ── ModelTable ─────────────────────────────────────────────────────
                        Text {
                            text: "ModelTable"
                            color: Theme.textPrimary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "Backed by QAbstractItemModel — rows stay in the C++ model, nothing is copied to JS. The model must expose \"display\" and \"isNull\" roles; click a header to sort. Note NULL (italic) renders differently from an empty string."
                            color: Theme.textSecondary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textSm; wrapMode: Text.WordWrap
                        }

                        ModelTable {
                            Layout.fillWidth: true
                            height: 260
                            striped: true
                            model: DemoTableModel {}
                            onRowClicked: (row) => console.log("ModelTable row selected:", row)
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 6 — Extended Components
                Flickable {
                    contentWidth:  width
                    contentHeight: _page6.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id: _page6
                        width: parent.width
                        anchors.top:        parent.top
                        anchors.topMargin:  Theme.sp8
                        anchors.left:       parent.left
                        anchors.leftMargin: Theme.sp8
                        spacing: Theme.sp8

                        // ── Stats ────────────────────────────────────────────────
                        Text { text: "Stats"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            Card { Stat { label: "Total Revenue"; value: "$48,295"; trend: 12.5; trendLabel: "vs last month"; icon: Icons.currencyDollar } }
                            Card { Stat { label: "Active Users";  value: "3,241";  trend: -4.2; trendLabel: "vs last week";  icon: Icons.users } }
                            Card { Stat { label: "Uptime";        value: "99.9%";  icon: Icons.chartLine } }
                            Item { Layout.fillWidth: true }
                        }

                        // ── Ratings ──────────────────────────────────────────────
                        Text { text: "Rating"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        ColumnLayout { spacing: Theme.sp3
                            RowLayout { spacing: Theme.sp4
                                Rating { id: _rating1; value: 3 }
                                Text { text: _rating1.value + " / " + _rating1.max; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            }
                            RowLayout { spacing: Theme.sp4
                                Rating { id: _rating2; value: 4.5; allowHalf: true; size: 28 }
                                Text { text: _rating2.value + " / " + _rating2.max; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            }
                            Rating { value: 4; readOnly: true; max: 10 }
                        }

                        // ── RangeSlider ──────────────────────────────────────────
                        Text { text: "Range Slider"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        ColumnLayout { spacing: Theme.sp4
                            RangeSlider { id: _rs1; width: 320; label: "Price range"; from: 0; to: 1000; first.value: 200; second.value: 800; showValues: true; decimals: 0 }
                            RangeSlider { width: 320; label: "Opacity"; showValues: true; decimals: 2 }
                        }

                        // ── DataList ─────────────────────────────────────────────
                        Text { text: "DataList"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            Card {
                                DataList {
                                    width: 340
                                    model: [
                                        { label: "Name",    value: "Alice Chen"           },
                                        { label: "Role",    value: "Administrator", badge: true },
                                        { label: "Email",   value: "alice@example.com"    },
                                        { label: "Joined",  value: "January 2024"         },
                                        { label: "Plan",    value: "Pro",          badge: true },
                                    ]
                                }
                            }
                            Card {
                                DataList {
                                    width: 340
                                    striped: true
                                    model: [
                                        { label: "Version", value: "1.0.0"    },
                                        { label: "License", value: "MIT"      },
                                        { label: "Author",  value: "Jr"       },
                                        { label: "Qt",      value: "6.7.0"    },
                                    ]
                                }
                            }
                            Item { Layout.fillWidth: true }
                        }

                        // ── Timeline ─────────────────────────────────────────────
                        Text { text: "Timeline"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Card {
                            Timeline {
                                width: 380
                                model: [
                                    { title: "Account created",  description: "Welcome aboard! Your account is ready.", time: "2 hours ago",  icon: Icons.userPlus, color: "success" },
                                    { title: "Plan upgraded",    description: "Switched from Free to Pro plan.",         time: "1 day ago",    color: "primary"                     },
                                    { title: "Login from Paris", description: "New device detected via web browser.",    time: "3 days ago",   icon: Icons.signIn                   },
                                    { title: "Password changed", description: "Security update applied.",                time: "2 weeks ago",  icon: Icons.lock,  color: "warning"  },
                                ]
                            }
                        }

                        // ── Tree ─────────────────────────────────────────────────
                        Text { text: "Tree"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Card {
                            Tree {
                                id:    _tree
                                width: 280
                                model: [
                                    { label: "src", icon: Icons.folder, children: [
                                        { label: "components", icon: Icons.folder, children: [
                                            { label: "Button.qml", icon: Icons.file },
                                            { label: "Input.qml",  icon: Icons.file },
                                            { label: "Card.qml",   icon: Icons.file },
                                        ]},
                                        { label: "Theme.qml",  icon: Icons.file },
                                        { label: "Icons.qml",  icon: Icons.file },
                                    ]},
                                    { label: "assets", icon: Icons.folder, children: [
                                        { label: "fonts", icon: Icons.folder, children: [
                                            { label: "Phosphor.ttf", icon: Icons.file },
                                        ]},
                                    ]},
                                    { label: "CMakeLists.txt", icon: Icons.file },
                                ]
                                onNodeClicked: (n) => toaster.show("Clicked: " + n.label, Toaster.Type.Info, 2000)
                            }
                        }

                        // ── DatePicker + ColorPicker ──────────────────────────────
                        Text { text: "Date &amp; Color Pickers"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            DatePicker { label: "Start date"; width: 240 }
                            DatePicker { label: "End date"; width: 240; helper: "Leave blank for open-ended" }
                            ColorPicker { label: "Brand color"; width: 200 }
                            Item { Layout.fillWidth: true }
                        }

                        // ── ScrollArea ───────────────────────────────────────────
                        Text { text: "ScrollArea"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp4; Layout.fillWidth: true
                            Card {
                                ScrollArea { width: 240; height: 160
                                    Column { spacing: Theme.sp1
                                        Repeater { model: 20; delegate: Item { width: 200; height: 30
                                            Rectangle { anchors.fill: parent; anchors.margins: 2; radius: Theme.radiusSm; color: Theme.panel
                                                Text { anchors.centerIn: parent; text: "Item " + (index + 1); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                                            }
                                        }}
                                    }
                                }
                            }
                            Card {
                                ScrollArea { width: 240; height: 60; horizontal: true; vertical: false
                                    Row { spacing: Theme.sp2
                                        Repeater { model: 12; delegate: Chip { text: "tag " + (index + 1) } }
                                    }
                                }
                            }
                            Item { Layout.fillWidth: true }
                        }

                        // ── AlertDialog + Drawer + Toaster triggers ───────────────
                        Text { text: "Overlays"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp3; Layout.fillWidth: true
                            Button { text: "Toast Info";    onClicked: toaster.show("File saved successfully.", Toaster.Type.Info)    }
                            Button { text: "Toast Success"; onClicked: toaster.show("Upload complete!", Toaster.Type.Success)          }
                            Button { text: "Toast Warning"; onClicked: toaster.show("Disk space low.", Toaster.Type.Warning, 6000)    }
                            Button { text: "Toast Error";   onClicked: toaster.show("Connection refused.", Toaster.Type.Error)        }
                            Button { text: "Alert Dialog";  variant: Button.Variant.Outlined; onClicked: _alert.open()                }
                            Button { text: "Open Drawer";   variant: Button.Variant.Outlined; onClicked: _drawer.open()               }
                            Button { text: "⌘K Palette";   variant: Button.Variant.Outlined; onClicked: _cmdPalette.open()           }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 7 — More Components
                Flickable {
                    contentWidth:  width
                    contentHeight: _page7.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id: _page7
                        x:       Theme.sp8
                        y:       Theme.sp8
                        width:   parent.width - Theme.sp8 * 2
                        spacing: Theme.sp6

                        // ── Alert ─────────────────────────────────────────────────
                        Text { text: "Alert"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ColumnLayout { spacing: Theme.sp3; Layout.fillWidth: true
                            Alert { Layout.fillWidth: true; type: Alert.Type.Info;    title: "Heads up";     message: "Your trial expires in 7 days. Upgrade to keep access." }
                            Alert { Layout.fillWidth: true; type: Alert.Type.Success; message: "Changes saved successfully to your account." }
                            Alert { Layout.fillWidth: true; type: Alert.Type.Warning; title: "Storage warning"; message: "You are at 90% of your quota."; dismissible: true }
                            Alert { Layout.fillWidth: true; type: Alert.Type.Error;   message: "Unable to connect to the server. Please try again."; dismissible: true }
                        }

                        // ── Callout ───────────────────────────────────────────────
                        Text { text: "Callout"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp4; Layout.fillWidth: true
                            Callout { type: Callout.Type.Note;    message: "This API is experimental and may change."; Layout.fillWidth: true }
                            Callout { type: Callout.Type.Tip;     message: "Press Ctrl+K to open the command palette."; Layout.fillWidth: true }
                            Callout { type: Callout.Type.Warning; message: "Changing this requires a restart."; Layout.fillWidth: true }
                            Callout { type: Callout.Type.Danger;  message: "This action permanently deletes data."; Layout.fillWidth: true }
                        }

                        // ── CircularProgress ──────────────────────────────────────
                        Text { text: "CircularProgress"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6
                            CircularProgress { value: 0.25; size: 48 }
                            CircularProgress { value: 0.5;  size: 64; strokeWidth: 6; showValue: true }
                            CircularProgress { value: 0.75; size: 80; strokeWidth: 8; showValue: true; color: Theme.success }
                            CircularProgress { value: 1.0;  size: 64; color: Theme.primary; trackColor: Theme.primarySubtle }
                            CircularProgress { indeterminate: true; size: 48 }
                            CircularProgress { indeterminate: true; size: 32; color: Theme.success }
                        }

                        // ── HoverCard ──────────────────────────────────────────────
                        Text { text: "HoverCard"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp4
                            Button {
                                id:   _hcBtn1
                                text: "Alice Chen"
                                variant: Button.Variant.Outlined
                                iconName: Icons.user
                            }
                            HoverCard {
                                anchor: _hcBtn1; title: "Alice Chen"; delay: 300
                                ColumnLayout { spacing: Theme.sp1
                                    Text { text: "Administrator"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                                    Text { text: "alice@example.com"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                                }
                            }

                            Button { id: _hcBtn2; text: "Ctrl+K"; variant: Button.Variant.Ghost; iconName: Icons.keyboard }
                            HoverCard {
                                anchor: _hcBtn2; delay: 200
                                Text { text: "Open the command palette to search all actions."; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; wrapMode: Text.WordWrap; width: 200 }
                            }
                        }

                        // ── SegmentedControl ──────────────────────────────────────
                        Text { text: "SegmentedControl"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ColumnLayout { spacing: Theme.sp4
                            SegmentedControl {
                                id: _seg1
                                model: ["Day", "Week", "Month", "Year"]
                                onSelectionChanged: (i) => console.log("Period:", model[i])
                            }
                            SegmentedControl {
                                model: [
                                    { label: "Grid",  icon: Icons.squaresFour },
                                    { label: "List",  icon: Icons.listBullets },
                                    { label: "Table", icon: Icons.table       },
                                ]
                                currentIndex: 1
                            }
                        }

                        // ── TagInput ──────────────────────────────────────────────
                        Text { text: "TagInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            TagInput {
                                label: "Topics"
                                tags: ["qml", "qt6", "ui"]
                                placeholder: "Add topic and press Enter…"
                                Layout.fillWidth: true
                            }
                            TagInput {
                                label: "Invites"
                                tags: []
                                placeholder: "Email address…"
                                maxTags: 3
                                helper: "Max 3 invites"
                                Layout.fillWidth: true
                            }
                        }

                        // ── OTPInput ──────────────────────────────────────────────
                        Text { text: "OTPInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp8
                            OTPInput { length: 6; label: "Verification code"; onCompleted: (v) => toaster.show("Code: " + v, Toaster.Type.Success, 2000) }
                            OTPInput { length: 4; label: "PIN"; masked: true }
                        }

                        // ── TimePicker ────────────────────────────────────────────
                        Text { text: "TimePicker"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6
                            TimePicker { label: "Start time"; hour: 9; minute: 0; width: 200 }
                            TimePicker { label: "End time";   hour: 17; minute: 30; use24h: false; width: 220 }
                        }

                        // ── FileUpload ────────────────────────────────────────────
                        Text { text: "FileUpload"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            FileUpload { multiple: true; Layout.fillWidth: true; onFileAdded: (u) => toaster.show("Added: " + u.toString().split("/").pop(), Toaster.Type.Info, 2000) }
                            FileUpload { accept: [".png", ".jpg", ".svg"]; helper: "Images only"; Layout.fillWidth: true }
                        }

                        // ── SplitPane ─────────────────────────────────────────────
                        Text { text: "SplitPane"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        SplitPane {
                            Layout.fillWidth: true
                            height: 180; ratio: 0.35
                            firstItem: Rectangle {
                                color: Theme.panel
                                ColumnLayout {
                                    anchors { fill: parent; margins: Theme.sp4 }
                                    spacing: Theme.sp2
                                    Text { text: "Left panel"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Theme.weightSemibold }
                                    Repeater { model: 4; delegate: Rectangle {
                                        width: parent.width; height: 28; radius: Theme.radiusSm; color: Theme.surface
                                        Text { anchors { left: parent.left; leftMargin: Theme.sp2; verticalCenter: parent.verticalCenter }
                                            text: "Item " + (index + 1); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                                    }}
                                }
                            }
                            secondItem: Rectangle {
                                color: Theme.surface
                                Text {
                                    anchors.centerIn: parent
                                    text: "Right panel\n(drag the divider)"
                                    horizontalAlignment: Text.AlignHCenter
                                    color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                }
                            }
                        }

                        // ── ContextMenu ───────────────────────────────────────────
                        Text { text: "ContextMenu"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Item {
                            id:               _cmTarget
                            Layout.fillWidth: true
                            height:           90
                            Rectangle {
                                anchors.fill: parent
                                color: Theme.panel; radius: Theme.radiusMd
                                border.color: Theme.border; border.width: 1
                                Column {
                                    anchors.centerIn: parent; spacing: Theme.sp1
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Right-click anywhere here"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "to open the context menu"; color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                                }
                            }
                            ContextMenu {
                                anchor: _cmTarget
                                model: [
                                    { label: "Edit",      icon: Icons.pencil                },
                                    { label: "Duplicate", icon: Icons.copy                  },
                                    { label: "Share",     icon: Icons.shareNetwork           },
                                    null,
                                    { label: "Delete",    icon: Icons.trash, danger: true   },
                                ]
                                onTriggered: (i, item) => toaster.show(item.label, Toaster.Type.Info, 1500)
                            }
                        }

                        // ── Carousel ──────────────────────────────────────────────
                        Text { text: "Carousel"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 160; radius: Theme.radiusMd; clip: true

                            Carousel {
                                anchors.fill: parent

                                Rectangle {
                                    color: "#4f46e5"; radius: Theme.radiusMd
                                    Column { anchors.centerIn: parent; spacing: Theme.sp2
                                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Component Library"; color: "#ffffff"; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightBold }
                                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "52 production-ready components"; color: "#c7d2fe"; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                                    }
                                }
                                Rectangle {
                                    color: "#16a34a"; radius: Theme.radiusMd
                                    Column { anchors.centerIn: parent; spacing: Theme.sp2
                                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Qt6 QML"; color: "#ffffff"; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightBold }
                                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "AOT-compatible, CMake-native"; color: "#bbf7d0"; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                                    }
                                }
                                Rectangle {
                                    color: "#0284c7"; radius: Theme.radiusMd
                                    Column { anchors.centerIn: parent; spacing: Theme.sp2
                                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Phosphor Icons"; color: "#ffffff"; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightBold }
                                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "6 weights, 1000+ icons built-in"; color: "#bae6fd"; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                                    }
                                }
                            }
                        }

                        // ── VirtualList ───────────────────────────────────────────
                        Text { text: "VirtualList"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            Rectangle {
                                width: 320; height: 220
                                color: Theme.surface; radius: Theme.radiusMd
                                border.color: Theme.border; border.width: 1; clip: true

                                VirtualList {
                                    anchors.fill: parent
                                    itemHeight: 44
                                    model: ListModel {
                                        Component.onCompleted: {
                                            for (var i = 1; i <= 200; i++)
                                                append({ label: "Contact #" + i, sub: "contact" + i + "@example.com" })
                                        }
                                    }
                                    delegate: Rectangle {
                                        required property string label
                                        required property string sub
                                        width: ListView.view.width; height: 44
                                        color: "transparent"
                                        Rectangle { x: 8; y: 43; width: parent.width - 16; height: 1; color: Theme.border }
                                        Row {
                                            anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp4 }
                                            spacing: Theme.sp3
                                            Avatar { name: label; size: Avatar.Size.Sm; anchors.verticalCenter: parent.verticalCenter }
                                            ColumnLayout {
                                                anchors.verticalCenter: parent.verticalCenter; spacing: 1
                                                Text { text: label; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Theme.weightMedium }
                                                Text { text: sub;   color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                                            }
                                        }
                                    }
                                }
                            }

                            VirtualList {
                                width: 240; height: 220
                                emptyTitle:  "No contacts"
                                emptyBody:   "Add someone to get started."
                                emptyIcon:   Icons.users
                                model:       ListModel {}
                                delegate:    Rectangle { width: 200; height: 40 }
                            }
                        }

                        // ── BottomSheet + Tour triggers ───────────────────────────
                        Text { text: "BottomSheet & Tour"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp3
                            Button { text: "Open BottomSheet"; iconName: Icons.arrowUp;    onClicked: _bottomSheet.open() }
                            Button { text: "Start Tour";       iconName: Icons.path; variant: Button.Variant.Outlined; onClicked: _tour.start() }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 8 — Advanced Components
                Flickable {
                    contentWidth:  width
                    contentHeight: _page8.implicitHeight + Theme.sp8 * 2
                    clip: true

                    ColumnLayout {
                        id: _page8
                        x:       Theme.sp8
                        y:       Theme.sp8
                        width:   parent.width - Theme.sp8 * 2
                        spacing: Theme.sp6

                        // ── Banner ────────────────────────────────────────────────
                        Text { text: "Banner"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ColumnLayout { spacing: Theme.sp3; Layout.fillWidth: true
                            Banner { Layout.fillWidth: true; type: Banner.Type.Announcement; message: "Mahina 1.0 is out! Check the changelog for new components."; actionText: "See what's new"; dismissible: true }
                            Banner { Layout.fillWidth: true; type: Banner.Type.Warning; message: "Your free trial ends in 3 days."; actionText: "Upgrade"; dismissible: true }
                            Banner { Layout.fillWidth: true; type: Banner.Type.Error; message: "Payment failed. Please update your billing info." }
                        }

                        // ── Tabs ──────────────────────────────────────────────────
                        Text { text: "Tabs"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ColumnLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            // Underline variant
                            Rectangle { Layout.fillWidth: true; height: 160; color: Theme.panel; radius: Theme.radiusMd; border.color: Theme.border; border.width: 1; clip: true
                                Tabs {
                                    anchors.fill: parent
                                    model: ["Overview", "Activity", "Settings"]
                                    Rectangle { color: "transparent"
                                        Text { anchors.centerIn: parent; text: "Overview content"; color: Theme.textSecondary; font.family: Theme.fontFamily }
                                    }
                                    Rectangle { color: "transparent"
                                        Text { anchors.centerIn: parent; text: "Activity feed"; color: Theme.textSecondary; font.family: Theme.fontFamily }
                                    }
                                    Rectangle { color: "transparent"
                                        Text { anchors.centerIn: parent; text: "Settings panel"; color: Theme.textSecondary; font.family: Theme.fontFamily }
                                    }
                                }
                            }

                            // Pill variant
                            Rectangle { Layout.fillWidth: true; height: 160; color: Theme.panel; radius: Theme.radiusMd; border.color: Theme.border; border.width: 1; clip: true
                                Tabs {
                                    anchors.fill: parent; variant: "pill"
                                    model: [{ label: "Docs", icon: Icons.book }, { label: "API", icon: Icons.codeBlock }, { label: "Examples", icon: Icons.code }]
                                    Rectangle { color: "transparent"; Text { anchors.centerIn: parent; text: "Documentation"; color: Theme.textSecondary; font.family: Theme.fontFamily } }
                                    Rectangle { color: "transparent"; Text { anchors.centerIn: parent; text: "API Reference";  color: Theme.textSecondary; font.family: Theme.fontFamily } }
                                    Rectangle { color: "transparent"; Text { anchors.centerIn: parent; text: "Code examples"; color: Theme.textSecondary; font.family: Theme.fontFamily } }
                                }
                            }
                        }

                        // ── PasswordInput ─────────────────────────────────────────
                        Text { text: "PasswordInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            PasswordInput { label: "Password"; placeholder: "Min 8 characters"; Layout.fillWidth: true }
                            PasswordInput { label: "Confirm"; showStrength: false; Layout.fillWidth: true }
                        }

                        // ── ComboBox ──────────────────────────────────────────────
                        Text { text: "ComboBox"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            ComboBox {
                                label: "Country (searchable)"
                                model: ["Australia", "Brazil", "Canada", "Denmark", "Egypt", "France", "Germany", "Hungary", "India", "Japan"]
                                placeholder: "Search a country…"
                                Layout.fillWidth: true
                            }
                            ComboBox {
                                label: "Role"
                                searchable: false
                                clearable: true
                                model: [
                                    { label: "Administrator", value: "admin"  },
                                    { label: "Editor",        value: "editor" },
                                    { label: "Viewer",        value: "viewer" },
                                ]
                                currentIndex: 1
                                Layout.fillWidth: true
                            }
                        }

                        // ── MultiSelect ───────────────────────────────────────────
                        Text { text: "MultiSelect"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            MultiSelect {
                                label: "Skills"
                                model: ["Design", "Engineering", "Marketing", "Product", "Sales", "Support"]
                                selectedIndices: [0, 2]
                                Layout.fillWidth: true
                            }
                            MultiSelect {
                                label: "Permissions (max 2)"
                                model: ["Read", "Write", "Delete", "Admin"]
                                maxSelections: 2
                                Layout.fillWidth: true
                            }
                        }

                        // ── AutoComplete ──────────────────────────────────────────
                        Text { text: "AutoComplete"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            AutoComplete {
                                label: "City"
                                model: ["Amsterdam", "Barcelona", "Cairo", "Delhi", "Edinburgh", "Florence", "Geneva", "Helsinki", "Istanbul", "Jakarta"]
                                placeholder: "Type a city…"
                                Layout.fillWidth: true
                                onSelected: (item) => toaster.show("Selected: " + item, Toaster.Type.Info, 2000)
                            }
                            AutoComplete {
                                label: "Component"
                                model: [
                                    { label: "Button",      description: "Trigger actions",    icon: Icons.cursor   },
                                    { label: "Input",       description: "Text entry field",   icon: Icons.textAa   },
                                    { label: "ComboBox",    description: "Searchable dropdown",icon: Icons.caretDown},
                                    { label: "DatePicker",  description: "Calendar picker",    icon: Icons.calendar },
                                ]
                                Layout.fillWidth: true
                            }
                        }

                        // ── Gauge ─────────────────────────────────────────────────
                        Text { text: "Gauge"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6
                            Gauge { value: 0.72; size: 140; label: "CPU Load"; unit: "%"; max: 100; color: Theme.primary }
                            Gauge { value: 0.45; size: 140; label: "Memory";   unit: " GB"; max: 16; decimals: 1; color: Theme.primary }
                            Gauge { value: 0.91; size: 140; label: "Uptime";   unit: "%"; max: 100; color: Theme.success; ticks: 4 }
                            Gauge { value: 0.15; size: 100; showValue: false; color: Theme.error }
                            Item { Layout.fillWidth: true }
                        }

                        // ── Sparkline ─────────────────────────────────────────────
                        Text { text: "Sparkline"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6
                            Card {
                                ColumnLayout { spacing: Theme.sp2
                                    RowLayout {
                                        Text { text: "Revenue"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; Layout.fillWidth: true }
                                        Text { text: "$12,480"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Theme.weightSemibold }
                                    }
                                    Sparkline { values: [3,5,2,8,6,9,4,7,8,10]; width: 160; height: 40; type: "area"; color: Theme.primary }
                                }
                            }
                            Card {
                                ColumnLayout { spacing: Theme.sp2
                                    RowLayout {
                                        Text { text: "Users"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; Layout.fillWidth: true }
                                        Text { text: "3,241"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Theme.weightSemibold }
                                    }
                                    Sparkline { values: [10,8,12,9,15,11,14,13,16,18]; width: 160; height: 40; type: "bar"; color: Theme.success }
                                }
                            }
                            Card {
                                ColumnLayout { spacing: Theme.sp2
                                    RowLayout {
                                        Text { text: "Errors"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; Layout.fillWidth: true }
                                        Text { text: "24"; color: Theme.error; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; font.weight: Theme.weightSemibold }
                                    }
                                    Sparkline { values: [2,1,4,3,6,2,8,4,3,5]; width: 160; height: 40; type: "line"; color: Theme.error; strokeWidth: 2 }
                                }
                            }
                        }

                        // ── CodeBlock ─────────────────────────────────────────────
                        Text { text: "CodeBlock"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            CodeBlock {
                                language: "qml"
                                showTrafficLights: true
                                Layout.fillWidth: true
                                code: 'import QtQuick\nimport Mahina\n\nButton {\n    text: "Hello, Mahina!"\n    variant: Button.Variant.Filled\n    onClicked: console.log("clicked")\n}'
                            }
                            CodeBlock {
                                language: "js"
                                showLineNumbers: true
                                Layout.fillWidth: true
                                code: 'function greet(name) {\n    const msg = "Hello, " + name\n    console.log(msg)\n    return msg\n}\n\ngreet("world")'
                            }
                        }

                        // ── Sortable ──────────────────────────────────────────────
                        Text { text: "Sortable"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6; Layout.fillWidth: true
                            Sortable {
                                width: 280
                                items: ["Design system", "Component audit", "Accessibility pass", "Dark mode", "Documentation"]
                                onReordered: (list) => toaster.show("Reordered: " + list.join(", "), Toaster.Type.Info, 3000)
                            }
                            Sortable {
                                width: 280
                                items: [
                                    { label: "Critical",  description: "P0 issues",   icon: Icons.xCircle      },
                                    { label: "High",      description: "P1 issues",   icon: Icons.warningCircle},
                                    { label: "Medium",    description: "P2 issues",   icon: Icons.info         },
                                    { label: "Low",       description: "P3 issues",   icon: Icons.checkCircle  },
                                ]
                            }
                        }

                        // ── Sheet trigger ─────────────────────────────────────────
                        Text { text: "Sheet"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp3
                            Button { text: "Open Right Sheet"; iconName: Icons.sidebarSimple; onClicked: _sheet.open() }
                        }

                        // ── FloatingActionButton ──────────────────────────────────
                        Text { text: "FloatingActionButton"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RowLayout { spacing: Theme.sp6
                            Item {
                                width: 200; height: 120
                                Rectangle { anchors.fill: parent; color: Theme.panel; radius: Theme.radiusMd; border.color: Theme.border; border.width: 1 }
                                FloatingActionButton {
                                    anchors { right: parent.right; bottom: parent.bottom; margins: Theme.sp3 }
                                    icon: Icons.plus; buttonSize: 44
                                    onClicked: toaster.show("FAB clicked", Toaster.Type.Info, 1500)
                                }
                            }
                            Item {
                                width: 200; height: 200
                                Rectangle { anchors.fill: parent; color: Theme.panel; radius: Theme.radiusMd; border.color: Theme.border; border.width: 1 }
                                FloatingActionButton {
                                    anchors { right: parent.right; bottom: parent.bottom; margins: Theme.sp3 }
                                    icon: Icons.plus; buttonSize: 44
                                    actions: [
                                        { icon: Icons.pencil,  label: "Edit",   color: Theme.primary },
                                        { icon: Icons.copy,    label: "Duplicate"                    },
                                        { icon: Icons.trash,   label: "Delete", color: Theme.error   },
                                    ]
                                    onActionTriggered: (i, a) => toaster.show(a.label, Toaster.Type.Info, 1500)
                                }
                            }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 9 — Settings (placeholder)
                Item {
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.sp3

                        Icon { name: Icons.gear; size: 40; color: Theme.textDisabled; Layout.alignment: Qt.AlignHCenter }
                        Text {
                            text: "Settings"
                            color: Theme.textSecondary; font.family: Theme.fontFamily
                            font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Page 10 — Display & Data
                ScrollArea {
                    clip: true

                    Column {
                        width: parent.width
                        padding: Theme.sp6
                        spacing: Theme.sp8

                        // ── CopyButton ─────────────────────────────────────────────
                        Text { text: "CopyButton"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            CopyButton { text: "npm install glow"; onCopyRequested: toaster.show("Copied: " + text, Toaster.Type.Info, 2000) }
                            CopyButton { text: "secret-token-123"; label: "Copy token"; onCopyRequested: toaster.show("Copied token", Toaster.Type.Info, 2000) }
                            CopyButton { text: "sm variant"; label: "Copy"; size: "sm"; onCopyRequested: toaster.show("Copied", Toaster.Type.Info, 2000) }
                        }

                        Divider {}

                        // ── StatusBar ──────────────────────────────────────────────
                        Text { text: "StatusBar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        StatusBar {
                            width: parent.width - Theme.sp6 * 2
                            leftItems:   [{ icon: Icons.checkCircle, text: "Ready",    color: Theme.success },
                                          { icon: Icons.wifiHigh,    text: "Connected" }]
                            centerItems: [{ text: "Line 42, Col 8" }]
                            rightItems:  [{ icon: Icons.gitBranch, text: "main" },
                                          { text: "UTF-8" }]
                        }

                        Divider {}

                        // ── Marquee ────────────────────────────────────────────────
                        Text { text: "Marquee"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Marquee {
                            width: parent.width - Theme.sp6 * 2
                            text:  "Breaking: Mahina 1.0 ships with 254 components  •  Dark mode, theming, AOT-compiled  •  Built for Qt 6.5+"
                            speed: 50
                            color: Theme.textSecondary
                        }

                        Divider {}

                        // ── InfiniteScroll ─────────────────────────────────────────
                        Text { text: "InfiniteScroll"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp2
                            InfiniteScroll {
                                width: 400; height: 200
                                model: ListModel {
                                    id: _infiniteModel
                                    Component.onCompleted: {
                                        for (var i = 0; i < 12; i++)
                                            append({ label: "Item " + (i + 1), value: Math.floor(Math.random() * 100) })
                                    }
                                }
                                delegate: Rectangle {
                                    required property var model
                                    required property int index
                                    width: ListView.view.width; height: 44
                                    color: index % 2 === 0 ? Theme.surface : Theme.surfaceVariant
                                    Row {
                                        anchors { left: parent.left; leftMargin: Theme.sp4; verticalCenter: parent.verticalCenter }
                                        spacing: Theme.sp3
                                        Text { text: model.label; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                                        Badge { text: String(model.value) }
                                    }
                                }
                                loading:    _p10LoadTimer.running
                                onLoadMore: _p10LoadTimer.start()
                            }
                            Timer {
                                id: _p10LoadTimer; interval: 1500
                                onTriggered: {
                                    var base = _infiniteModel.count
                                    for (var i = 0; i < 8; i++)
                                        _infiniteModel.append({ label: "Item " + (base + i + 1), value: Math.floor(Math.random() * 100) })
                                }
                            }
                        }

                        Divider {}

                        // ── PropertyGrid ───────────────────────────────────────────
                        Text { text: "PropertyGrid"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        PropertyGrid {
                            width: 460
                            model: [
                                { key: "Status",   value: "Active",    type: "badge",   badgeColor: Theme.success },
                                { key: "Version",  value: "2.4.1" },
                                { key: "Released", value: "2025-06-12" },
                                { key: "Dark mode",value: true,        type: "boolean" },
                                { key: "Accent",   value: "#5B8DF6",   type: "color" },
                                { key: "Docs",     value: "glow.dev",  type: "link" },
                            ]
                            onLinkClicked: (i, v) => toaster.show("Link: " + v, Toaster.Type.Info, 2000)
                        }

                        Divider {}

                        // ── Chat ───────────────────────────────────────────────────
                        Text { text: "Chat"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Chat {
                            width: 460; height: 300
                            selfId: "alice"
                            messages: [
                                { sender: "bob",   text: "Hey! Have you tried Mahina yet?",             timestamp: "10:41 AM" },
                                { sender: "alice", text: "Yes! Just shipped a dashboard with it.",    timestamp: "10:42 AM" },
                                { sender: "bob",   text: "How was the AOT compilation experience?",   timestamp: "10:43 AM" },
                                { sender: "alice", text: "Smooth once you learn the property rules.", timestamp: "10:44 AM" },
                                { sender: "bob",   text: "Agreed. Dark mode is a nice touch too.",    timestamp: "10:45 AM" },
                            ]
                        }

                        Divider {}

                        // ── IrcTextView ────────────────────────────────────────────
                        Text { text: "IrcTextView"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        IrcTextView {
                            id:     _ircDemo
                            width:  parent.width - Theme.sp6 * 2
                            height: 300
                            selfNick: "alice"
                            highlightWords: ["release"]
                            markerIndex: 7
                            lines: [
                                { kind: "topic",   time: "12:01", text: "Topic is: Mahina — QML components for Qt 6" },
                                { kind: "join",    time: "12:02", nick: "bob",   text: "has joined #mahina" },
                                { kind: "message", time: "12:03", nick: "bob",   prefix: "@", text: "morning all" },
                                { kind: "message", time: "12:03", nick: "alice", text: "morning! pushed the AOT fixes last night" },
                                { kind: "action",  time: "12:04", nick: "carol", text: "waves from the couch" },
                                { kind: "message", time: "12:04", nick: "carol", text: "docs are at https://github.com/ajunior/mahina" },
                                { kind: "message", time: "12:05", nick: "dave",  text: "\x02bold\x02, \x1Funderline\x1F, \x0304red\x03, \x0309,01green on black\x03" },
                                { kind: "message", time: "12:06", nick: "bob",   text: "alice: can you cut the release today?" },
                                { kind: "notice",  time: "12:07", nick: "NickServ", text: "This nickname is registered." },
                                { kind: "mode",    time: "12:08", nick: "bob",   text: "sets mode +o alice" },
                                { kind: "part",    time: "12:09", nick: "carol", text: "has left #mahina (afk)" },
                                { kind: "quit",    time: "12:10", nick: "dave",  text: "has quit (Ping timeout: 240 seconds)" },
                            ]
                            onLinkClicked: (url) => toaster.show("Link: " + url, Toaster.Type.Info, 2000)
                        }
                        Row {
                            spacing: Theme.sp2
                            Button {
                                text: "Simulate message"
                                variant: Button.Variant.Outlined
                                onClicked: _ircDemo.appendLine({
                                    kind: "message",
                                    time: Qt.formatTime(new Date(), "hh:mm"),
                                    nick: ["bob", "carol", "dave"][Math.floor(Math.random() * 3)],
                                    text: "another line of channel traffic"
                                })
                            }
                            Button {
                                text: "Highlight me"
                                variant: Button.Variant.Outlined
                                onClicked: _ircDemo.appendLine({
                                    kind: "message",
                                    time: Qt.formatTime(new Date(), "hh:mm"),
                                    nick: "bob",
                                    text: "alice: ping"
                                })
                            }
                            Button {
                                text: "Clear"
                                variant: Button.Variant.Ghost
                                onClicked: _ircDemo.clear()
                            }
                        }

                        Divider {}

                        // ── IrcNickList ────────────────────────────────────────────
                        Text { text: "IrcNickList"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        IrcNickList {
                            width:  220
                            height: 300
                            channelName: "#mahina"
                            selfNick:    "alice"
                            nicks: [
                                { nick: "alice",    mode: "@" },
                                { nick: "bob",      mode: "@" },
                                { nick: "carol",    mode: "+" },
                                { nick: "dave" },
                                { nick: "erin",     away: true },
                                { nick: "_owner",   mode: "~" },
                                { nick: "adminguy", mode: "&" },
                                { nick: "helper",   mode: "%" },
                                { nick: "aardvark", away: true },
                                { nick: "mike" },
                                { nick: "nancy" },
                                { nick: "oscar" },
                                { nick: "Xylophone" },
                                { nick: "zebedee" },
                            ]
                            onNickActivated: (n) => toaster.show("Open query with " + n, Toaster.Type.Info, 2000)
                            onNickRightClicked: (n, x, y) => toaster.show("Context menu for " + n, Toaster.Type.Info, 2000)
                        }

                        Divider {}

                        // ── IrcInput ───────────────────────────────────────────────
                        Text { text: "IrcInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Text {
                            text: "Tab cycles nick completion (try \"ca\"), Shift+Tab reverses, ↑/↓ walk history, /jo completes commands."
                            color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                        }
                        IrcInput {
                            width:  parent.width - Theme.sp6 * 2
                            prompt: "[alice]"
                            nicks:  ["alice", "bob", "carol", "carla", "dave", "erin", "mike"]
                            commands: ["/join", "/msg", "/me", "/part", "/quit", "/topic", "/nick"]
                            onSent: (line) => toaster.show("Sent: " + line, Toaster.Type.Success, 2500)
                        }

                        Divider {}

                        // ── MediaPlayer ────────────────────────────────────────────
                        Text { text: "MediaPlayer"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Item {
                            id:     _mpState
                            width:  1; height: 1
                            property bool mpPlaying: false
                            property real mpPos:     0.35
                            property real mpVol:     0.8
                            Timer {
                                running:  _mpState.mpPlaying
                                interval: 500; repeat: true
                                onTriggered: _mpState.mpPos = Math.min(1, _mpState.mpPos + 0.002)
                            }
                        }
                        MediaPlayer {
                            width:    460
                            title:    "Blue Ridge Mountains"
                            artist:   "Fleet Foxes"
                            position: _mpState.mpPos
                            duration: 247
                            playing:  _mpState.mpPlaying
                            volume:   _mpState.mpVol
                            onPlayPauseClicked: _mpState.mpPlaying = !_mpState.mpPlaying
                            onSeeked:  (p) => { _mpState.mpPos = p }
                            onVolumeRequested: (v) => { _mpState.mpVol = v }
                            onShuffleToggled: (on) => toaster.show("Shuffle " + (on ? "on" : "off"), Toaster.Type.Info, 1500)
                            onLoopToggled:    (on) => toaster.show("Loop " + (on ? "on" : "off"), Toaster.Type.Info, 1500)
                        }

                        Divider {}

                        // ── LogViewer ──────────────────────────────────────────────
                        Text { text: "LogViewer"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        LogViewer {
                            width: parent.width - Theme.sp6 * 2; height: 260
                            log: [
                                { level: "info",  message: "Application started",              timestamp: "12:00:01", tag: "app"   },
                                { level: "info",  message: "Database connected to :5432",       timestamp: "12:00:01", tag: "db"    },
                                { level: "debug", message: "Cache warm-up: 2048 entries",       timestamp: "12:00:02", tag: "cache" },
                                { level: "info",  message: "Server listening on :8080",         timestamp: "12:00:02", tag: "http"  },
                                { level: "warn",  message: "Slow query detected: 1.24s",        timestamp: "12:00:03", tag: "db"    },
                                { level: "debug", message: "Cache hit ratio: 0.87",             timestamp: "12:00:04", tag: "cache" },
                                { level: "error", message: "Connection refused: redis:6379",    timestamp: "12:00:05", tag: "redis" },
                                { level: "warn",  message: "Retrying in 5s (attempt 1/3)",      timestamp: "12:00:05", tag: "redis" },
                                { level: "info",  message: "Request POST /api/v1/users 201",    timestamp: "12:00:06", tag: "http"  },
                                { level: "error", message: "Panic: nil pointer dereference",    timestamp: "12:00:07", tag: "app"   },
                            ]
                        }

                        Divider {}

                        // ── HeatMap ────────────────────────────────────────────────
                        Text { text: "HeatMap"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        HeatMap {
                            startDate: "2025-01-01"; endDate: "2025-06-30"
                            heatData: ({
                                "2025-01-05": 3,  "2025-01-12": 7, "2025-01-19": 2, "2025-01-26": 5,
                                "2025-02-02": 4,  "2025-02-09": 8, "2025-02-16": 1, "2025-02-23": 6,
                                "2025-03-01": 9,  "2025-03-08": 3, "2025-03-15": 7, "2025-03-22": 2,
                                "2025-03-29": 5,  "2025-04-05": 4, "2025-04-12": 8, "2025-04-19": 6,
                                "2025-04-26": 3,  "2025-05-03": 9, "2025-05-10": 1, "2025-05-17": 7,
                                "2025-05-24": 4,  "2025-05-31": 5, "2025-06-07": 8, "2025-06-14": 3,
                            })
                            onCellClicked: (key, val) => toaster.show(key + ": " + val + " commits", Toaster.Type.Info, 2000)
                        }

                        Divider {}

                        // ── Resizable ──────────────────────────────────────────────
                        Text { text: "Resizable"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Text { text: "Drag the edges and corners of the panel below"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                        Resizable {
                            width: 300; height: 160
                            edges: ["e", "s", "se", "sw", "ne"]
                            minWidth: 120; maxWidth: 560
                            minHeight: 80; maxHeight: 320
                            onResized: (w, h) => _resizableLbl.text = Math.round(w) + " × " + Math.round(h)

                            Rectangle {
                                anchors.fill: parent
                                color:  Theme.surface
                                radius: Theme.radiusMd
                                border.color: Theme.border; border.width: 1
                                Text {
                                    id: _resizableLbl
                                    anchors.centerIn: parent
                                    text:           "300 × 160"
                                    color:          Theme.textSecondary
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.textSm
                                }
                            }
                        }

                        Divider {}

                        // ── MasonryGrid ────────────────────────────────────────────
                        Text { text: "MasonryGrid"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        MasonryGrid {
                            width:   parent.width - Theme.sp6 * 2
                            columns: 3
                            spacing: Theme.sp3
                            model:   ListModel {
                                ListElement { cardH: 100; cardTitle: "Design tokens";  cardColor: "#5B8DF6" }
                                ListElement { cardH: 140; cardTitle: "Dark mode";       cardColor: "#59A14F" }
                                ListElement { cardH:  80; cardTitle: "AOT compiled";    cardColor: "#F28E2B" }
                                ListElement { cardH: 120; cardTitle: "42 components";   cardColor: "#E15759" }
                                ListElement { cardH:  90; cardTitle: "Qt 6.5+";          cardColor: "#2196E8" }
                                ListElement { cardH: 110; cardTitle: "Phosphor icons";  cardColor: "#7c3aed" }
                            }
                            delegate: Rectangle {
                                required property int    cardH
                                required property string cardTitle
                                required property string cardColor
                                width:  parent ? parent.width : 100
                                height: cardH
                                radius: Theme.radiusMd
                                color:  Qt.rgba(Qt.color(cardColor).r, Qt.color(cardColor).g, Qt.color(cardColor).b, 0.15)
                                border.color: cardColor; border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text:           cardTitle
                                    color:          Theme.textPrimary
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.textSm
                                    font.weight:    Theme.weightSemibold
                                }
                            }
                        }

                        Divider {}

                        // ── JsonViewer ─────────────────────────────────────────────
                        Text { text: "JsonViewer"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: 460; height: 240
                            color: Theme.surface; radius: Theme.radiusMd
                            border.color: Theme.border; border.width: 1
                            clip: true
                            ScrollArea {
                                anchors { fill: parent; margins: Theme.sp3 }
                                JsonViewer {
                                    id: _jv
                                    width: parent.width
                                    value: ({
                                        name: "Mahina UI",
                                        version: "1.0.0",
                                        components: ["Button", "Input", "Card", "Badge"],
                                        meta: { dark: false, accent: "#5B8DF6", radius: 8 },
                                        license: "MIT",
                                        downloads: 4201
                                    })
                                }
                            }
                        }

                        Divider {}

                        // ── DiffViewer ─────────────────────────────────────────────
                        Text { text: "DiffViewer"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        DiffViewer {
                            width: parent.width - Theme.sp6 * 2; height: 280
                            original: "import QtQuick\nimport Mahina\n\nButton {\n    text: \"Click me\"\n    variant: Button.Variant.Primary\n    onClicked: console.log(\"clicked\")\n}"
                            modified: "import QtQuick\nimport QtQuick.Layouts\nimport Mahina\n\nButton {\n    text: \"Click me\"\n    variant: Button.Variant.Filled\n    size: Button.Size.Lg\n    onClicked: handler()\n}"
                        }

                        Divider {}

                        // ── EditableTable ──────────────────────────────────────────
                        Text { text: "EditableTable"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        EditableTable {
                            width: parent.width - Theme.sp6 * 2
                            columns: [
                                { key: "name",  label: "Name",    width: 160 },
                                { key: "email", label: "Email",   width: 220, editable: false },
                                { key: "role",  label: "Role",    width: 100 },
                            ]
                            rows: [
                                { name: "Alice Chen",  email: "alice@example.com", role: "Admin" },
                                { name: "Bob Smith",   email: "bob@example.com",   role: "User"  },
                                { name: "Carol White", email: "carol@example.com", role: "Editor" },
                                { name: "Dan Brown",   email: "dan@example.com",   role: "User"  },
                            ]
                            onCellEdited: (row, key, val) => toaster.show("Row " + row + " → " + key + " = " + val, Toaster.Type.Info, 2000)
                        }

                        Divider {}

                        // ── QRCode ─────────────────────────────────────────────────
                        Text { text: "QRCode"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp6
                            Column {
                                spacing: Theme.sp3
                                QRCode { text: "https://example.com"; size: 160 }
                                Text { text: "https://example.com"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; horizontalAlignment: Text.AlignHCenter; width: 160 }
                            }
                            Column {
                                spacing: Theme.sp3
                                QRCode { text: "Hello, Mahina!"; size: 160; darkColor: Theme.primary; lightColor: Theme.surface }
                                Text { text: "Hello, Mahina!"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; horizontalAlignment: Text.AlignHCenter; width: 160 }
                            }
                            Column {
                                spacing: Theme.sp3
                                QRCode { text: "GLOW UI COMPONENT LIBRARY"; size: 160 }
                                Text { text: "GLOW UI COMPONENT LIBRARY"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs; horizontalAlignment: Text.AlignHCenter; width: 160; wrapMode: Text.Wrap }
                            }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 11 — Charts & Layout
                ScrollArea {
                    clip: true

                    Column {
                        width: parent.width
                        padding: Theme.sp6
                        spacing: Theme.sp8

                        // ── ShortcutHint ───────────────────────────────────────────
                        Text { text: "ShortcutHint"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            ShortcutHint { keys: ["Ctrl", "K"] }
                            ShortcutHint { keys: ["⌘", "Shift", "P"] }
                            ShortcutHint { keys: ["Alt", "F4"]; size: "sm" }
                            ShortcutHint { keys: ["Esc"] }
                        }

                        Divider {}

                        // ── ContextualHelp ─────────────────────────────────────────
                        Text { text: "ContextualHelp"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            ContextualHelp {
                                title: "What is this?"
                                body:  "This field accepts a valid email address. We'll send a confirmation link to verify ownership."
                            }
                            ContextualHelp {
                                title: "API key"
                                body:  "Your secret API key — never share it. Rotate it in Settings > Security if compromised."
                            }
                        }

                        Divider {}

                        // ── AvatarGroup ────────────────────────────────────────────
                        Text { text: "AvatarGroup"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp6
                            AvatarGroup {
                                model: [
                                    { name: "Alice",   color: Theme.primary  },
                                    { name: "Bob",     color: Theme.success  },
                                    { name: "Charlie", color: Theme.warning  },
                                    { name: "Diana",   color: Theme.error   },
                                    { name: "Eve",     color: Theme.primary     },
                                ]
                                max: 3
                            }
                            AvatarGroup {
                                model: [
                                    { name: "Frank", color: Theme.primary },
                                    { name: "Grace", color: Theme.success },
                                ]
                                size: 44
                            }
                        }

                        Divider {}

                        // ── Typewriter ─────────────────────────────────────────────
                        Text { text: "Typewriter"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp3
                            Typewriter {
                                text: "Building beautiful UIs with Qt and QML."
                                loop: true; speed: 60; pauseMs: 1800
                                pixelSize: Theme.textLg; color: Theme.textPrimary
                            }
                            Typewriter {
                                text: "Hello, world!"
                                loop: false; showCursor: false
                                pixelSize: Theme.textSm; color: Theme.textSecondary
                            }
                        }

                        Divider {}

                        // ── Confetti ───────────────────────────────────────────────
                        Text { text: "Confetti"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            Confetti { id: _confetti; width: 300; height: 160 }
                            Button {
                                text: "Burst!"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: _confetti.burst()
                            }
                        }

                        Divider {}

                        // ── RadarChart ─────────────────────────────────────────────
                        Text { text: "RadarChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RadarChart {
                            width: 320; height: 320
                            axes: ["Speed", "Strength", "Intelligence", "Agility", "Stamina"]
                            series: [
                                { label: "Hero A",  color: Theme.primary, values: [0.9, 0.6, 0.7, 0.8, 0.75] },
                                { label: "Hero B",  color: Theme.success, values: [0.5, 0.9, 0.4, 0.6, 0.85] },
                            ]
                        }

                        Divider {}

                        // ── Candlestick ────────────────────────────────────────────
                        Text { text: "Candlestick"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Candlestick {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            candles: [
                                { date: "Mon", open: 100, high: 115, low:  95, close: 110 },
                                { date: "Tue", open: 110, high: 120, low: 105, close: 108 },
                                { date: "Wed", open: 108, high: 130, low: 102, close: 125 },
                                { date: "Thu", open: 125, high: 128, low: 112, close: 115 },
                                { date: "Fri", open: 115, high: 135, low: 113, close: 132 },
                            ]
                        }

                        Divider {}

                        // ── BubbleChart ────────────────────────────────────────────
                        Text { text: "BubbleChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        BubbleChart {
                            width: parent.width - Theme.sp6 * 2; height: 240
                            xLabel: "Revenue ($k)"; yLabel: "Growth (%)"
                            series: [
                                { label: "APAC",    color: Theme.primary, points: [{ x: 20, y: 35, r: 12 }, { x: 55, y: 65, r: 20 }, { x: 80, y: 45, r: 8  }] },
                                { label: "EMEA",    color: Theme.success, points: [{ x: 35, y: 20, r: 16 }, { x: 65, y: 80, r: 14 }, { x: 90, y: 25, r: 18 }] },
                            ]
                        }

                        Divider {}

                        // ── FunnelChart ────────────────────────────────────────────
                        Text { text: "FunnelChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        FunnelChart {
                            width: parent.width - Theme.sp6 * 2
                            stages: [
                                { label: "Visitors",   value: 10000 },
                                { label: "Sign-ups",   value:  4200 },
                                { label: "Activated",  value:  2100 },
                                { label: "Paying",     value:   840 },
                                { label: "Retained",   value:   310 },
                            ]
                        }

                        Divider {}

                        // ── MaskInput ──────────────────────────────────────────────
                        Text { text: "MaskInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp3
                            MaskInput { mask: "(###) ###-####"; placeholder: "Phone number"; width: 220 }
                            MaskInput { mask: "##/##/####";     placeholder: "MM/DD/YYYY";   width: 220 }
                            MaskInput { mask: "AAA-####";       placeholder: "Plate number";  width: 220 }
                        }

                        Divider {}

                        // ── CurrencyInput ──────────────────────────────────────────
                        Text { text: "CurrencyInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            CurrencyInput { symbol: "$"; value: 1234.56 }
                            CurrencyInput { symbol: "€"; decimals: 0; value: 9900 }
                        }

                        Divider {}

                        // ── PhoneInput ─────────────────────────────────────────────
                        Text { text: "PhoneInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            PhoneInput { countryCode: "+1" }
                            PhoneInput { countryCode: "+44" }
                        }

                        Divider {}

                        // ── MarkdownEditor ─────────────────────────────────────────
                        Text { text: "MarkdownEditor"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        MarkdownEditor {
                            width: parent.width - Theme.sp6 * 2; height: 260
                            text: "# Welcome to Mahina\n\nThis is a **markdown** editor with *live* preview.\n\n## Features\n\n- Syntax highlighting\n- `Inline code`\n- Real-time rendering\n\n> Blockquotes work too!"
                        }

                        Divider {}

                        // ── KPICard ────────────────────────────────────────────────
                        Text { text: "KPICard"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            KPICard {
                                label: "Monthly Revenue"; value: "$48,290"; trend: "+12.4%"; trendUp: true
                                sparkValues: [30, 45, 28, 60, 55, 72, 68, 80]
                                subtitle: "vs last month"
                            }
                            KPICard {
                                label: "Churn Rate"; value: "3.2%"; trend: "-0.8%"; trendUp: false
                                sparkValues: [12, 10, 14, 9, 8, 11, 7, 6]
                            }
                            KPICard {
                                label: "Active Users"; value: "12,847"; trend: "+5.1%"; trendUp: true
                                sparkValues: [200, 240, 210, 280, 320, 300, 350, 380]
                            }
                        }

                        Divider {}

                        // ── DashboardGrid ──────────────────────────────────────────
                        Text { text: "DashboardGrid"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        DashboardGrid {
                            width: parent.width - Theme.sp6 * 2
                            columns: 3; cellHeight: 80; gap: 8

                            Rectangle { property int _dashColSpan: 1; color: Theme.primary;    radius: Theme.radiusMd; Text { anchors.centerIn: parent; text: "1 col"; color: "#fff"; font.pixelSize: Theme.textSm } }
                            Rectangle { property int _dashColSpan: 2; color: Theme.success;    radius: Theme.radiusMd; Text { anchors.centerIn: parent; text: "2 col"; color: "#fff"; font.pixelSize: Theme.textSm } }
                            Rectangle { property int _dashColSpan: 3; color: Theme.warning;    radius: Theme.radiusMd; Text { anchors.centerIn: parent; text: "3 col (full width)"; color: "#fff"; font.pixelSize: Theme.textSm } }
                            Rectangle { property int _dashColSpan: 2; color: Theme.primary;       radius: Theme.radiusMd; Text { anchors.centerIn: parent; text: "2 col"; color: "#fff"; font.pixelSize: Theme.textSm } }
                            Rectangle { property int _dashColSpan: 1; color: Theme.error;     radius: Theme.radiusMd; Text { anchors.centerIn: parent; text: "1 col"; color: "#fff"; font.pixelSize: Theme.textSm } }
                        }

                        Divider {}

                        // ── PageLayout ─────────────────────────────────────────────
                        Text { text: "PageLayout"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        PageLayout {
                            width: parent.width - Theme.sp6 * 2; height: 300
                            title: "My Dashboard"
                            actions: Row {
                                spacing: Theme.sp2
                                Button { text: "Export"; variant: Button.Variant.Ghost; size: Button.Size.Sm }
                                Button { text: "New";    size: Button.Size.Sm }
                            }
                            content: Column {
                                width: parent.width; spacing: Theme.sp3
                                Text { text: "Main content area"; color: Theme.textSecondary; font.pixelSize: Theme.textSm; font.family: Theme.fontFamily }
                                Skeleton { width: parent.width; height: 40 }
                                Skeleton { width: parent.width; height: 40 }
                                Skeleton { width: parent.width * 0.6; height: 40 }
                            }
                        }

                        Divider {}

                        // ── CommandBar ─────────────────────────────────────────────
                        Text { text: "CommandBar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            Button {
                                text: "Open CommandBar (Ctrl+Shift+K)"
                                variant: Button.Variant.Outlined
                                onClicked: _cmdBar.show()
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "or press Ctrl+Shift+K"
                                color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                            }
                        }
                        CommandBar {
                            id: _cmdBar
                            commands: [
                                { label: "Toggle dark mode",   icon: Icons.moonStars,    shortcut: "D",          action: function() { Theme.dark = !Theme.dark }  },
                                { label: "Go to Components",   icon: Icons.squaresFour,                          action: function() { _stack.currentIndex = 0 }   },
                                { label: "Go to Forms",        icon: Icons.textT,                                action: function() { _stack.currentIndex = 4 }   },
                                { label: "Toast success",      icon: Icons.checkCircle,                          action: function() { toaster.show("Success!", Toaster.Type.Success) } },
                                { label: "Open drawer",        icon: Icons.sidebarSimple,                        action: function() { _drawer.open() }            },
                            ]
                        }
                        Shortcut { sequence: "Ctrl+Shift+K"; onActivated: _cmdBar.show() }

                        Divider {}

                        // ── ImageGallery ───────────────────────────────────────────
                        Text { text: "ImageGallery"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ImageGallery {
                            columns: 4; thumbSize: 100; gap: Theme.sp2
                            images: [
                                { src: "", caption: "No image (placeholder)" },
                                { src: "", caption: "Photo 2" },
                                { src: "", caption: "Photo 3" },
                                { src: "", caption: "Photo 4" },
                                { src: "", caption: "Photo 5" },
                                { src: "", caption: "Photo 6" },
                                { src: "", caption: "Photo 7" },
                                { src: "", caption: "Photo 8" },
                            ]
                        }

                        Divider {}

                        // ── VideoPlayer ────────────────────────────────────────────
                        Text { text: "VideoPlayer"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Item {
                            id: _vpState
                            property bool   vpPlaying: false
                            property real   vpPos:     42
                            property real   vpVol:     0.8
                        }
                        VideoPlayer {
                            width: 480; height: 270
                            playing:  _vpState.vpPlaying
                            position: _vpState.vpPos
                            duration: 240
                            volume:   _vpState.vpVol
                            onPlayPauseClicked: _vpState.vpPlaying = !_vpState.vpPlaying
                            onSeekRequested:    (s) => _vpState.vpPos = s
                            onVolumeAdjusted:   (v) => _vpState.vpVol = v
                        }

                        Divider {}

                        // ── ActivityFeed ───────────────────────────────────────────
                        Text { text: "ActivityFeed"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ActivityFeed {
                            width: 400; height: 280
                            events: [
                                { user: "Alice",   action: "pushed 3 commits to main",      time: "2m ago",  color: Theme.success  },
                                { user: "Bob",     action: "opened a pull request #42",      time: "14m ago", color: Theme.primary  },
                                { user: "CI Bot",  action: "build failed on PR #42",         time: "15m ago", color: Theme.error   },
                                { user: "Charlie", action: "reviewed and approved PR #41",   time: "32m ago", color: Theme.primary     },
                                { user: "Diana",   action: "closed issue #99: Layout bug",   time: "1h ago",  color: Theme.warning  },
                            ]
                        }

                        Divider {}

                        // ── PricingCard ────────────────────────────────────────────
                        Text { text: "PricingCard"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            PricingCard {
                                tier: "Starter"; price: "Free"; period: ""
                                tagline: "For individuals and hobbyists"
                                features: ["5 projects", "Community support", "Basic analytics"]
                                ctaLabel: "Get started free"
                                onCtaClicked: toaster.show("Starter selected", Toaster.Type.Info)
                            }
                            PricingCard {
                                tier: "Pro"; price: "$29"; period: "/ mo"
                                tagline: "For growing teams"
                                features: ["Unlimited projects", "Priority support", "Advanced analytics", "SSO"]
                                ctaLabel: "Start free trial"
                                highlighted: true; badge: "Popular"
                                onCtaClicked: toaster.show("Pro selected", Toaster.Type.Success)
                            }
                            PricingCard {
                                tier: "Enterprise"; price: "$99"; period: "/ mo"
                                tagline: "For large organisations"
                                features: ["Everything in Pro", "Dedicated CSM", "SLA guarantee", "Custom contracts"]
                                ctaLabel: "Contact sales"
                                onCtaClicked: toaster.show("Enterprise — contacting sales", Toaster.Type.Info)
                            }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 12 — Charts & Nav
                ScrollArea {
                    clip: true

                    Column {
                        width: parent.width
                        padding: Theme.sp6
                        spacing: Theme.sp8

                        // ── AreaChart ──────────────────────────────────────────────
                        Text { text: "AreaChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        AreaChart {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            xLabels: ["Jan","Feb","Mar","Apr","May","Jun","Jul"]
                            series: [
                                { label: "Revenue",  color: Theme.primary, values: [10,18,14,22,28,24,32] },
                                { label: "Expenses", color: Theme.error,   values: [ 8,10,12,11,15,14,18] },
                            ]
                        }

                        Divider {}

                        // ── TreeMap ────────────────────────────────────────────────
                        Text { text: "TreeMap"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        TreeMap {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            nodes: [
                                { label: "React",   value: 42, color: Theme.primary },
                                { label: "Vue",     value: 28, color: Theme.success },
                                { label: "Angular", value: 18, color: Theme.warning },
                                { label: "Svelte",  value: 12, color: Theme.error   },
                            ]
                        }

                        Divider {}

                        // ── WaterfallChart ─────────────────────────────────────────
                        Text { text: "WaterfallChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        WaterfallChart {
                            width: parent.width - Theme.sp6 * 2; height: 220
                            bars: [
                                { label: "Start",   value: 1000, type: "total"    },
                                { label: "Revenue", value:  500, type: "positive" },
                                { label: "Refunds", value: -120, type: "negative" },
                                { label: "OpEx",    value: -300, type: "negative" },
                                { label: "Net",     value: 1080, type: "total"    },
                            ]
                        }

                        Divider {}

                        // ── Histogram ──────────────────────────────────────────────
                        Text { text: "Histogram"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Histogram {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            values: [12,15,22,18,35,42,38,22,19,14,28,31,44,17,25,33,29,21,16,40,37,23,11,45,30,26,20,13,36,41]
                            bins: 8; xLabel: "Response time (ms)"
                        }

                        Divider {}

                        // ── GanttChart ─────────────────────────────────────────────
                        Text { text: "GanttChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        GanttChart {
                            width: parent.width - Theme.sp6 * 2
                            xMin: 0; xMax: 10
                            xLabels: ["W1","W2","W3","W4","W5","W6","W7","W8","W9","W10"]
                            tasks: [
                                { label: "Design",   start: 0, end: 3, color: Theme.primary },
                                { label: "Backend",  start: 2, end: 7, color: Theme.success },
                                { label: "Frontend", start: 4, end: 9, color: Theme.warning },
                                { label: "QA",       start: 8, end: 10, color: Theme.error  },
                            ]
                        }

                        Divider {}

                        // ── SignaturePad ───────────────────────────────────────────
                        Text { text: "SignaturePad"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        SignaturePad {
                            width: 400; height: 160
                            onSigned:   toaster.show("Signature captured", Toaster.Type.Info, 1500)
                            onCleared:  toaster.show("Signature cleared", Toaster.Type.Info, 1500)
                        }

                        Divider {}

                        // ── RichTextEditor ─────────────────────────────────────────
                        Text { text: "RichTextEditor"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        RichTextEditor {
                            width: parent.width - Theme.sp6 * 2; height: 240
                            html: "<b>Bold</b> and <i>italic</i> text with <u>underline</u>.<br><br>Start typing to edit."
                        }

                        Divider {}

                        // ── SliderWithInput ────────────────────────────────────────
                        Text { text: "SliderWithInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp3
                            SliderWithInput { min: 0;   max: 100; value: 42; unit: "%"; width: 300 }
                            SliderWithInput { min: 0.0; max: 1.0; step: 0.01; decimals: 2; value: 0.65; width: 300 }
                            SliderWithInput { min: 8;   max: 72;  step: 1; value: 16; unit: "px"; width: 300 }
                        }

                        Divider {}

                        // ── AddressInput ───────────────────────────────────────────
                        Text { text: "AddressInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        AddressInput {
                            width: 360
                            address: ({ street: "123 Main St", city: "Springfield", state: "IL", zip: "62701", country: "United States" })
                        }

                        Divider {}

                        // ── MultiRangeSlider ───────────────────────────────────────
                        Text { text: "MultiRangeSlider"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp3
                            MultiRangeSlider { values: [20, 80]; min: 0; max: 100; width: 300 }
                            MultiRangeSlider { values: [10, 40, 70]; min: 0; max: 100; width: 300 }
                        }

                        Divider {}

                        // ── ColorSwatch ────────────────────────────────────────────
                        Text { text: "ColorSwatch"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            ColorSwatch { color: Theme.primary }
                            ColorSwatch { color: Theme.success }
                            ColorSwatch { color: Theme.warning }
                            ColorSwatch { color: Theme.error;   showHex: false }
                        }

                        Divider {}

                        // ── LoadingOverlay ─────────────────────────────────────────
                        Text { text: "LoadingOverlay"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            Item {
                                id: _loHost
                                width: 200; height: 100
                                property bool loading: false
                                Rectangle { anchors.fill: parent; color: Theme.surface; radius: Theme.radiusMd; border.color: Theme.border; border.width: 1
                                    Text { anchors.centerIn: parent; text: "Content area"; color: Theme.textSecondary; font.pixelSize: Theme.textSm; font.family: Theme.fontFamily } }
                                LoadingOverlay { anchors.fill: parent; visible: _loHost.loading; message: "Loading…"; cancelable: true; onCancelClicked: _loHost.loading = false }
                            }
                            Button {
                                text: "Show overlay"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: _loHost.loading = true
                            }
                        }

                        Divider {}

                        // ── ProgressDialog ─────────────────────────────────────────
                        Text { text: "ProgressDialog"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Item {
                            id: _pdState
                            property real pdProg: 0.0
                            property bool pdOpen: false
                        }
                        ProgressDialog {
                            id:       _pd
                            title:    "Uploading files"
                            message:  "Uploading " + Math.round(_pdState.pdProg * 12) + " of 12…"
                            progress: _pdState.pdProg
                            open:     _pdState.pdOpen
                            cancelable: true
                            onCancelClicked: { _pdState.pdOpen = false; _pdAnim.stop(); _pdState.pdProg = 0 }
                        }
                        NumberAnimation { id: _pdAnim; target: _pdState; property: "pdProg"; from: 0; to: 1; duration: 4000; onFinished: _pdState.pdOpen = false }
                        Button {
                            text: "Start upload"
                            onClicked: { _pdState.pdProg = 0; _pdState.pdOpen = true; _pdAnim.restart() }
                        }

                        Divider {}

                        // ── CountdownTimer ─────────────────────────────────────────
                        Text { text: "CountdownTimer"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp6
                            Column {
                                spacing: Theme.sp2
                                CountdownTimer { id: _ct1; seconds: 10; size: 80; color: Theme.primary }
                                Row { spacing: Theme.sp2
                                    Button { text: "Start"; size: Button.Size.Sm; onClicked: _ct1.running = true }
                                    Button { text: "Stop";  size: Button.Size.Sm; variant: Button.Variant.Ghost; onClicked: _ct1.running = false }
                                }
                            }
                            Column {
                                spacing: Theme.sp2
                                CountdownTimer { id: _ct2; seconds: 30; size: 80; color: Theme.success; onFinished: toaster.show("Timer done!", Toaster.Type.Success) }
                                Button { text: "30s"; size: Button.Size.Sm; onClicked: { _ct2.seconds = 30; _ct2.running = true } }
                            }
                            Column {
                                spacing: Theme.sp2
                                CountdownTimer { id: _ct3; seconds: 5; size: 64; color: Theme.error; strokeWidth: 7; showLabel: false }
                                Button { text: "5s"; size: Button.Size.Sm; onClicked: { _ct3.seconds = 5; _ct3.running = true } }
                            }
                        }

                        Divider {}

                        // ── NotificationCenter ─────────────────────────────────────
                        Text { text: "NotificationCenter"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Item {
                            id: _ncState
                            property bool ncOpen: true
                            property var  notifs: [
                                { id: "n1", title: "Build succeeded", body: "main branch is green",  time: "2m ago",  type: "success", read: false },
                                { id: "n2", title: "PR #42 approved",  body: "Bob approved your PR", time: "8m ago",  type: "info",    read: false },
                                { id: "n3", title: "Deploy failed",    body: "prod deploy timed out",time: "1h ago",  type: "error",   read: true  },
                            ]
                        }
                        Row {
                            spacing: Theme.sp3
                            Button { text: "Toggle panel"; variant: Button.Variant.Outlined; onClicked: _ncState.ncOpen = !_ncState.ncOpen }
                            NotificationCenter {
                                open:          _ncState.ncOpen
                                notifications: _ncState.notifs
                                panelWidth:    300
                                onDismiss:     (id) => { _ncState.notifs = _ncState.notifs.filter(function(n){ return n.id !== id }) }
                                onDismissAll:  _ncState.notifs = []
                            }
                        }

                        Divider {}

                        // ── StepWizard ─────────────────────────────────────────────
                        Text { text: "StepWizard"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        StepWizard {
                            width: parent.width - Theme.sp6 * 2; height: 280
                            steps: [
                                { title: "Account",  content: _sw1 },
                                { title: "Profile",  content: _sw2 },
                                { title: "Confirm",  content: _sw3 },
                            ]
                            onFinished: toaster.show("Wizard complete!", Toaster.Type.Success)
                        }
                        Item {
                            id: _sw1; width: 1; height: 1
                            Column { anchors.centerIn: parent; spacing: Theme.sp3
                                Text { text: "Step 1: Enter your account details"; color: Theme.textSecondary; font.pixelSize: Theme.textSm; font.family: Theme.fontFamily }
                                Input { placeholderText: "Email"; width: 260 }
                                Input { placeholderText: "Password"; width: 260 }
                            }
                        }
                        Item {
                            id: _sw2; width: 1; height: 1
                            Column { anchors.centerIn: parent; spacing: Theme.sp3
                                Text { text: "Step 2: Set up your profile"; color: Theme.textSecondary; font.pixelSize: Theme.textSm; font.family: Theme.fontFamily }
                                Input { placeholderText: "Display name"; width: 260 }
                            }
                        }
                        Item {
                            id: _sw3; width: 1; height: 1
                            Column { anchors.centerIn: parent; spacing: Theme.sp3
                                Text { text: "Step 3: Confirm your details"; color: Theme.textSecondary; font.pixelSize: Theme.textSm; font.family: Theme.fontFamily }
                                Text { text: "Click Finish to complete setup."; color: Theme.textDisabled; font.pixelSize: Theme.textXs; font.family: Theme.fontFamily }
                            }
                        }

                        Divider {}

                        // ── MegaMenu ───────────────────────────────────────────────
                        Text { text: "MegaMenu"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp2
                            Button {
                                text: "Products ▾"
                                variant: Button.Variant.Ghost
                                onClicked: _mega.open = !_mega.open
                            }
                            MegaMenu {
                                id: _mega
                                columnWidth: 180
                                sections: [
                                    { heading: "Products", items: [
                                        { label: "Analytics",  icon: Icons.chartBar,  desc: "Dashboards & reports"  },
                                        { label: "Database",   icon: Icons.database,  desc: "Managed PostgreSQL"    },
                                    ]},
                                    { heading: "Resources", items: [
                                        { label: "Docs",   icon: Icons.book,    desc: "API reference"   },
                                        { label: "Blog",   icon: Icons.article, desc: "News & updates"  },
                                    ]},
                                ]
                                onItemSelected: (item) => { toaster.show("Selected: " + item.label, Toaster.Type.Info) }
                            }
                        }

                        Divider {}

                        // ── AppSwitcher ────────────────────────────────────────────
                        Text { text: "AppSwitcher"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp2
                            Button { text: "⊞ Apps"; variant: Button.Variant.Ghost; onClicked: _appSw.open = !_appSw.open }
                            AppSwitcher {
                                id: _appSw
                                columns: 3; tileSize: 80
                                apps: [
                                    { label: "Analytics", icon: Icons.chartBar,  color: Theme.primary },
                                    { label: "Calendar",  icon: Icons.calendar,  color: Theme.success },
                                    { label: "Inbox",     icon: Icons.envelope,  color: Theme.warning },
                                    { label: "Files",     icon: Icons.folder,    color: Theme.error   },
                                    { label: "Settings",  icon: Icons.gear,      color: Theme.primary },
                                    { label: "Docs",      icon: Icons.book,      color: Theme.success },
                                ]
                                onAppSelected: (app) => toaster.show("Opened: " + app.label, Toaster.Type.Info)
                            }
                        }

                        Divider {}

                        // ── TestimonialCard ────────────────────────────────────────
                        Text { text: "TestimonialCard"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            TestimonialCard {
                                width: 260
                                quote:       "Mahina cut our UI development time in half."
                                name:        "Alice Chen"
                                role:        "CTO, Acme Corp"
                                rating:      5
                                avatarColor: Theme.primary
                            }
                            TestimonialCard {
                                width: 260
                                quote:       "Best QML component library I've used. Clean and fast."
                                name:        "Bob Müller"
                                role:        "Lead Developer"
                                rating:      4
                                avatarColor: Theme.success
                            }
                        }

                        Divider {}

                        // ── FeatureGrid ────────────────────────────────────────────
                        Text { text: "FeatureGrid"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        FeatureGrid {
                            width: parent.width - Theme.sp6 * 2
                            columns: 3; gap: Theme.sp3
                            features: [
                                { icon: Icons.lightning,    title: "AOT Compiled",     desc: "Full qmlsc type checking at build time."   },
                                { icon: Icons.palette,      title: "Dark Mode",        desc: "One property toggle for the entire tree."  },
                                { icon: Icons.sparkle,      title: "150+ Components",  desc: "Everything you need, nothing you don't."   },
                                { icon: Icons.rocket,       title: "Zero C++",         desc: "Pure QML — no plugin required."            },
                                { icon: Icons.shieldCheck,  title: "Type Safe",        desc: "Required properties, no implicit var."     },
                                { icon: Icons.chartBar,     title: "Data Viz",         desc: "Charts, maps, gauges, sparklines."         },
                            ]
                        }

                        Divider {}

                        // ── KeyboardShortcutsPanel ─────────────────────────────────
                        Text { text: "KeyboardShortcutsPanel"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            Button {
                                text: "Show shortcuts (?)"
                                variant: Button.Variant.Outlined
                                onClicked: _ksp.show()
                            }
                        }
                        KeyboardShortcutsPanel {
                            id: _ksp
                            sections: [
                                { heading: "Navigation", shortcuts: [
                                    { keys: ["Ctrl", "K"],      desc: "Open command bar"   },
                                    { keys: ["Ctrl", "Shift", "K"], desc: "Open CommandBar" },
                                    { keys: ["?"],              desc: "Keyboard shortcuts" },
                                    { keys: ["D"],              desc: "Toggle dark mode"   },
                                ]},
                                { heading: "Editing", shortcuts: [
                                    { keys: ["Ctrl", "Z"],      desc: "Undo"               },
                                    { keys: ["Ctrl", "Shift", "Z"], desc: "Redo"           },
                                    { keys: ["Ctrl", "S"],      desc: "Save"               },
                                ]},
                            ]
                        }
                        Shortcut { sequence: "?"; onActivated: _ksp.show() }

                        Divider {}

                        // ── OnboardingChecklist ────────────────────────────────────
                        Text { text: "OnboardingChecklist"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        OnboardingChecklist {
                            width: 320
                            title: "Get started with Mahina"
                            tasks: [
                                { label: "Read the docs",              done: true  },
                                { label: "Install the library",        done: true  },
                                { label: "Add your first component",   done: false },
                                { label: "Customize the theme",        done: false },
                                { label: "Ship to production",         done: false },
                            ]
                            onDismissed: toaster.show("Checklist dismissed", Toaster.Type.Info)
                        }

                        Divider {}

                        // ── SliderWithInput (bonus) ────────────────────────────────
                        Text { text: "StickySection (scroll to see)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Text { text: "StickySection is designed for use inside a Flickable — the header sticks to the top as you scroll past it."; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; wrapMode: Text.Wrap; width: parent.width - Theme.sp6 * 2 }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 13 — Inputs & Charts
                ScrollArea {
                    clip: true

                    Column {
                        width: parent.width
                        padding: Theme.sp6
                        spacing: Theme.sp8

                        // ── AnimatedCounter ────────────────────────────────────────
                        Text { text: "AnimatedCounter"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp6
                            AnimatedCounter { value: 42381; duration: 900; suffix: " users" }
                            AnimatedCounter { value: 99.7; duration: 800; suffix: "%"; decimals: 1; pixelSize: Theme.textLg; color: Theme.success }
                            AnimatedCounter { value: 1200; duration: 1100; prefix: "$"; suffix: "K"; pixelSize: Theme.textXl; color: Theme.primary }
                        }

                        Divider {}

                        // ── PulseIndicator ─────────────────────────────────────────
                        Text { text: "PulseIndicator"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp5
                            PulseIndicator { status: "online";    size: 12; showLabel: true }
                            PulseIndicator { status: "away";      size: 12; showLabel: true }
                            PulseIndicator { status: "offline";   size: 12; showLabel: true }
                            PulseIndicator { status: "recording"; size: 12; showLabel: true }
                        }

                        Divider {}

                        // ── Ripple ─────────────────────────────────────────────────
                        Text { text: "Ripple"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            Ripple {
                                width: 140; height: 44; radius: Theme.radiusMd
                                onClicked: toaster.show("Ripple clicked!", Toaster.Type.Info)
                                Rectangle { anchors.fill: parent; radius: Theme.radiusMd; color: Theme.primary }
                                Text { anchors.centerIn: parent; text: "Click me"; color: Theme.textOnPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            }
                            Ripple {
                                width: 140; height: 44; radius: Theme.radiusMd
                                rippleColor: Qt.rgba(Qt.color(Theme.primary).r, Qt.color(Theme.primary).g, Qt.color(Theme.primary).b, 0.2)
                                onClicked: toaster.show("Outlined ripple!", Toaster.Type.Success)
                                Rectangle { anchors.fill: parent; radius: Theme.radiusMd; color: Theme.panel; border.color: Theme.border; border.width: 1 }
                                Text { anchors.centerIn: parent; text: "Outlined"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            }
                        }

                        Divider {}

                        // ── SkeletonPage ───────────────────────────────────────────
                        Text { text: "SkeletonPage"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 260
                            border.color: Theme.border; border.width: 1; radius: Theme.radiusMd; clip: true
                            SkeletonPage { anchors.fill: parent; loading: true }
                        }

                        Divider {}

                        // ── SplashScreen ───────────────────────────────────────────
                        Text { text: "SplashScreen"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Button {
                            text: "Show Splash (auto-dismisses)"
                            onClicked: { _splash.opacity = 1; _splash.progress = 0; _splashTimer.stepProgress = 0; _splashTimer.start() }
                        }

                        Divider {}

                        // ── NetworkGraph ───────────────────────────────────────────
                        Text { text: "NetworkGraph"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        NetworkGraph {
                            width: parent.width - Theme.sp6 * 2; height: 260
                            nodes: [
                                { id: 0, label: "API",    color: Theme.primary },
                                { id: 1, label: "Auth",   color: Theme.success },
                                { id: 2, label: "DB",     color: Theme.warning },
                                { id: 3, label: "Cache",  color: Theme.info    },
                                { id: 4, label: "Queue",  color: Theme.error   },
                                { id: 5, label: "Worker", color: Theme.success },
                            ]
                            edges: [
                                { source: 0, target: 1 }, { source: 0, target: 2 },
                                { source: 0, target: 3 }, { source: 2, target: 3 },
                                { source: 0, target: 4 }, { source: 4, target: 5 },
                                { source: 1, target: 2 },
                            ]
                            onNodeSelected: (n) => toaster.show("Node: " + n.label, Toaster.Type.Info)
                        }

                        Divider {}

                        // ── CalendarHeatmap ────────────────────────────────────────
                        Text { text: "CalendarHeatmap"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        CalendarHeatmap {
                            weeks: 26; color: Theme.success; label: "Commits — last 26 weeks"
                            values: {
                                var today2 = new Date(); var obj2 = {}
                                for (var dd = 0; dd < 182; dd++) {
                                    var dt2 = new Date(today2); dt2.setDate(today2.getDate() - dd)
                                    if (Math.random() > 0.45) {
                                        var k2 = dt2.getFullYear() + "-" + String(dt2.getMonth()+1).padStart(2,"0") + "-" + String(dt2.getDate()).padStart(2,"0")
                                        obj2[k2] = Math.floor(Math.random() * 8) + 1
                                    }
                                }
                                return obj2
                            }
                        }

                        Divider {}

                        // ── BoxPlot ────────────────────────────────────────────────
                        Text { text: "BoxPlot"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        BoxPlot {
                            width: parent.width - Theme.sp6 * 2; height: 220
                            series: [
                                { label: "Q1", color: Theme.primary, values: [42,55,61,38,49,72,58,45,67,51,44,63,57,41,68,53] },
                                { label: "Q2", color: Theme.success, values: [48,62,71,52,65,78,59,69,74,55,60,83,71,49,75,64] },
                                { label: "Q3", color: Theme.warning, values: [35,44,52,29,41,58,47,38,55,33,40,62,48,31,57,42] },
                                { label: "Q4", color: Theme.error,   values: [60,75,82,68,79,91,72,84,87,65,77,96,80,62,88,74] },
                            ]
                        }

                        Divider {}

                        // ── SankeyDiagram ──────────────────────────────────────────
                        Text { text: "SankeyDiagram"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        SankeyDiagram {
                            width: parent.width - Theme.sp6 * 2; height: 220
                            nodes: [
                                { id: "visits",  label: "Visits",   group: 0, color: Theme.primary },
                                { id: "signup",  label: "Sign-ups", group: 1, color: Theme.success },
                                { id: "skip",    label: "Skipped",  group: 1, color: Theme.border  },
                                { id: "paid",    label: "Paid",     group: 2, color: Theme.info    },
                                { id: "churned", label: "Churned",  group: 2, color: Theme.error   },
                            ]
                            links: [
                                { source: "visits", target: "signup",  value: 800 },
                                { source: "visits", target: "skip",    value: 400 },
                                { source: "signup", target: "paid",    value: 320 },
                                { source: "signup", target: "churned", value: 480 },
                            ]
                        }

                        Divider {}

                        // ── PolarChart ─────────────────────────────────────────────
                        Text { text: "PolarChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        PolarChart {
                            width: 300; height: 300
                            labels: ["N","NE","E","SE","S","SW","W","NW"]
                            series: [
                                { label: "Calm",     color: Theme.primary, values: [5,3,8,4,6,2,7,3]    },
                                { label: "Moderate", color: Theme.success, values: [12,9,15,8,11,6,13,8] },
                            ]
                        }

                        Divider {}

                        // ── CreditCardInput ────────────────────────────────────────
                        Text { text: "CreditCardInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        CreditCardInput {
                            width: 340
                            onCardNumberEntered: (num, brand) => toaster.show(brand.toUpperCase() + " card detected", Toaster.Type.Success)
                        }

                        Divider {}

                        // ── TimeDurationInput ──────────────────────────────────────
                        Text { text: "TimeDurationInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        TimeDurationInput {
                            totalSeconds: 3665
                            onDurationEdited: (s) => toaster.show("Duration: " + s + "s", Toaster.Type.Info, 1000)
                        }

                        Divider {}

                        // ── DateRangePicker ────────────────────────────────────────
                        Text { text: "DateRangePicker"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        DateRangePicker {
                            width: parent.width - Theme.sp6 * 2; height: 300
                            onRangeSelected: (s, e) => toaster.show("Range selected", Toaster.Type.Success)
                        }

                        Divider {}

                        // ── MentionInput ───────────────────────────────────────────
                        Text { text: "MentionInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        MentionInput {
                            width: 360; height: 100
                            suggestions: ["alice","bob","charlie","diana","evan","fiona"]
                            placeholderText: "Type @ to mention someone…"
                            onMentionInserted: (name) => toaster.show("Mentioned @" + name, Toaster.Type.Info)
                        }

                        Divider {}

                        // ── ColorGradientPicker ────────────────────────────────────
                        Text { text: "ColorGradientPicker"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ColorGradientPicker {
                            width: 380
                            stops: [{ pos: 0.0, color: "#6366f1" }, { pos: 0.5, color: "#a855f7" }, { pos: 1.0, color: "#ec4899" }]
                            onStopsEdited: (s) => toaster.show(s.length + " stops", Toaster.Type.Info, 800)
                        }

                        Divider {}

                        // ── Kanban ─────────────────────────────────────────────────
                        Text { text: "Kanban"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Kanban {
                            columns: [
                                { title: "Backlog",     color: Theme.border,   cards: [
                                    { id: "t1", title: "Research competitors",  tag: "research" },
                                    { id: "t2", title: "Update design system",  tag: "design"   },
                                ]},
                                { title: "In Progress", color: Theme.warning, cards: [
                                    { id: "t3", title: "Implement auth flow",   tag: "backend"  },
                                    { id: "t4", title: "Build dashboard cards", tag: "frontend" },
                                ]},
                                { title: "Done",        color: Theme.success, cards: [
                                    { id: "t5", title: "Set up CI/CD",          tag: "devops"   },
                                ]},
                            ]
                            onCardMoved: (id, from, to) => toaster.show("Moved " + id, Toaster.Type.Info)
                        }

                        Divider {}

                        // ── EventCalendar ──────────────────────────────────────────
                        Text { text: "EventCalendar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        EventCalendar {
                            width: parent.width - Theme.sp6 * 2; height: 340
                            year: 2026; month: 5
                            events: [
                                { date: "2026-06-03", title: "Sprint review", color: Theme.primary },
                                { date: "2026-06-10", title: "All-hands",     color: Theme.success },
                                { date: "2026-06-15", title: "Off-site",      color: Theme.warning },
                                { date: "2026-06-28", title: "Launch day!",   color: Theme.error   },
                            ]
                            onDayClicked: (date, evs) => {
                                if (evs.length > 0) toaster.show(evs.length + " event(s)", Toaster.Type.Info)
                            }
                        }

                        Divider {}

                        // ── CropTool ───────────────────────────────────────────────
                        Text { text: "CropTool"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Item {
                            width: 360; height: 240
                            Rectangle {
                                id:      _cropBg
                                anchors.fill: parent; radius: Theme.radiusMd; clip: true
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0; color: Theme.primary }
                                    GradientStop { position: 1; color: Theme.info    }
                                }
                            }
                            CropTool {
                                anchors.fill: _cropBg
                                onCropChanged: (x, y, w, h) => toaster.show(
                                    (w*100).toFixed(0) + "×" + (h*100).toFixed(0) + "% crop", Toaster.Type.Info, 600
                                )
                            }
                        }

                        Divider {}

                        // ── ZoomPan ────────────────────────────────────────────────
                        Text { text: "ZoomPan"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 220
                            border.color: Theme.border; border.width: 1; radius: Theme.radiusMd; clip: true
                            ZoomPan {
                                anchors.fill: parent
                                Grid {
                                    columns: 6; spacing: 8; padding: 16
                                    Repeater {
                                        model: 18
                                        delegate: Rectangle {
                                            required property int index
                                            width: 80; height: 60; radius: Theme.radiusSm
                                            color: Qt.hsva(index / 18, 0.6, 0.85, 1)
                                            Text { anchors.centerIn: parent; text: "#" + (index+1); color: "white"; font.family: Theme.fontFamily; font.pixelSize: Theme.textXs }
                                        }
                                    }
                                }
                            }
                        }

                        Divider {}

                        // ── EmojiPicker ────────────────────────────────────────────
                        Text { text: "EmojiPicker"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        EmojiPicker {
                            width: 300; height: 320
                            onEmojiSelected: (e) => toaster.show("Emoji: " + e, Toaster.Type.Info, 1200)
                        }

                        Divider {}

                        // ── DebugPanel ─────────────────────────────────────────────
                        Text { text: "DebugPanel"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            DebugPanel { id: _debugPanel; open: true; appVersion: "1.0.0" }
                            Column {
                                spacing: Theme.sp2; anchors.verticalCenter: parent.verticalCenter
                                Button { text: "Log info";  onClicked: _debugPanel.log("INFO: User loaded dashboard") }
                                Button { text: "Log error"; onClicked: _debugPanel.log("ERR: Connection refused (ECONNREFUSED)") }
                            }
                        }

                        Divider {}

                        // ── Terminal ───────────────────────────────────────────────
                        Text { text: "Terminal"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Terminal {
                            id:    _term
                            width: parent.width - Theme.sp6 * 2; height: 240
                            onCommandEntered: (cmd) => {
                                if (cmd === "help")    _term.appendLine("Commands: help, version, ping, clear")
                                else if (cmd === "version") _term.appendLine("Mahina UI Kit v1.0.0")
                                else if (cmd === "ping")    _term.appendLine("PONG")
                                else _term.appendError("Unknown command: " + cmd)
                            }
                        }

                        Divider {}

                        // ── DataGrid ───────────────────────────────────────────────
                        Text { text: "DataGrid"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        DataGrid {
                            width: parent.width - Theme.sp6 * 2; height: 300
                            columns: [
                                { key: "name",   label: "Name",   width: 160 },
                                { key: "email",  label: "Email",  width: 200 },
                                { key: "role",   label: "Role",   width: 100 },
                                { key: "status", label: "Status", width: 90  },
                                { key: "joined", label: "Joined", width: 110 },
                            ]
                            rows: [
                                { name: "Alice Chen",   email: "alice@glow.dev",  role: "Admin",  status: "Active",   joined: "2024-01" },
                                { name: "Bob Torres",   email: "bob@glow.dev",    role: "Member", status: "Away",     joined: "2024-03" },
                                { name: "Carol Smith",  email: "carol@glow.dev",  role: "Editor", status: "Active",   joined: "2024-05" },
                                { name: "David Kim",    email: "david@glow.dev",  role: "Viewer", status: "Inactive", joined: "2024-07" },
                                { name: "Eva Müller",   email: "eva@glow.dev",    role: "Member", status: "Active",   joined: "2024-09" },
                                { name: "Frank Okafor", email: "frank@glow.dev",  role: "Admin",  status: "Active",   joined: "2025-01" },
                            ]
                            onRowSelected: (row) => toaster.show("Selected: " + row.name, Toaster.Type.Info)
                        }

                        Divider {}

                        // ── Dock ───────────────────────────────────────────────────
                        Text { text: "Dock"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Item {
                            width: parent.width - Theme.sp6 * 2; height: 120
                            Dock {
                                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
                                apps: [
                                    { label: "Files",    icon: Icons.folder,   color: "#4299e1" },
                                    { label: "Mail",     icon: Icons.envelope, color: "#e53e3e" },
                                    { label: "Code",     icon: Icons.code,     color: "#1a202c" },
                                    { label: "Terminal", icon: Icons.terminal, color: "#2d3748" },
                                    { label: "Calendar", icon: Icons.calendar, color: "#48bb78" },
                                    { label: "Settings", icon: Icons.gear,     color: "#718096" },
                                ]
                                onAppActivated: (app) => toaster.show("Opened " + app.label, Toaster.Type.Info)
                            }
                        }

                        Divider {}

                        // ── FloatingToolbar ────────────────────────────────────────
                        Text { text: "FloatingToolbar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Item {
                            id:     _ftContainer
                            width: parent.width - Theme.sp6 * 2; height: 120
                            Rectangle {
                                id:    _ftTarget
                                width: parent.width; height: 64; radius: Theme.radiusMd
                                color: Theme.panel; border.color: Theme.border; border.width: 1
                                Text {
                                    anchors.centerIn: parent; text: "Hover to show floating toolbar"
                                    color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                }
                                HoverHandler { id: _ftHover }
                            }
                            FloatingToolbar {
                                open:   _ftHover.hovered
                                target: _ftTarget
                                parent: _ftContainer
                                actions: [
                                    { icon: Icons.textBolder, label: "Bold"      },
                                    { icon: Icons.textItalic, label: "Italic"    },
                                    { icon: Icons.link,       label: "Link"      },
                                    { icon: Icons.copy,       label: "Copy"      },
                                    { icon: Icons.trash,      label: "Delete"    },
                                ]
                            }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 14 — Social & Feedback
                ScrollArea {
                    clip: true

                    Column {
                        width: parent.width
                        padding: Theme.sp6
                        spacing: Theme.sp8

                        // ── ScatterPlot ────────────────────────────────────────────
                        Text { text: "ScatterPlot"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ScatterPlot {
                            width: parent.width - Theme.sp6 * 2; height: 280
                            xLabel: "Revenue ($k)"; yLabel: "Growth (%)"
                            series: [
                                { label: "Group A", color: Theme.primary,
                                  points: [{x:1.2,y:3.4},{x:2.1,y:1.8,size:14},{x:3.5,y:2.9},{x:1.8,y:4.2}] },
                                { label: "Group B", color: Theme.success,
                                  points: [{x:3.5,y:4.1},{x:4.2,y:2.9,size:12},{x:5.1,y:3.8},{x:2.9,y:5.2}] },
                            ]
                        }

                        Divider {}

                        // ── ComboChart ────────────────────────────────────────────
                        Text { text: "ComboChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ComboChart {
                            width: parent.width - Theme.sp6 * 2; height: 280
                            labels: ["Jan","Feb","Mar","Apr","May","Jun"]
                            bars:  [{ label: "Revenue", color: Theme.primary,  values: [120,145,98,200,175,220] }]
                            lines: [{ label: "Growth%", color: Theme.success,  values: [12,21,-8,35,15,28]      }]
                        }

                        Divider {}

                        // ── BulletChart ───────────────────────────────────────────
                        Text { text: "BulletChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        BulletChart {
                            width: parent.width - Theme.sp6 * 2
                            suffix: "%"
                            items: [
                                { label: "Revenue",  value: 75, target: 80,
                                  ranges: [{value:40,color:"#fca5a5"},{value:70,color:"#fde68a"},{value:100,color:"#bbf7d0"}] },
                                { label: "Visitors", value: 58, target: 65,
                                  ranges: [{value:30,color:"#fca5a5"},{value:55,color:"#fde68a"},{value:100,color:"#bbf7d0"}] },
                                { label: "NPS",      value: 42, target: 50,
                                  ranges: [{value:20,color:"#fca5a5"},{value:40,color:"#fde68a"},{value:100,color:"#bbf7d0"}] },
                            ]
                        }

                        Divider {}

                        // ── TreeGraph ─────────────────────────────────────────────
                        Text { text: "TreeGraph"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2
                            height: Math.min(_tg.implicitHeight + 2, 260)
                            border.color: Theme.border; border.width: 1; radius: Theme.radiusMd; clip: true
                            TreeGraph {
                                id:    _tg
                                width: parent.width - 2
                                treeModel: [
                                    { label: "Root", _expanded: true, children: [
                                        { label: "Frontend", _expanded: true, children: [
                                            { label: "Components", children: [] },
                                            { label: "Pages",      children: [] },
                                        ]},
                                        { label: "Backend", children: [
                                            { label: "API",      children: [] },
                                            { label: "Database", children: [] },
                                        ]},
                                    ]}
                                ]
                                onNodeClicked: (n) => toaster.show("Node: " + n.label, Toaster.Type.Info, 1500)
                            }
                        }

                        Divider {}

                        // ── WordCloud ─────────────────────────────────────────────
                        Text { text: "WordCloud"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            border.color: Theme.border; border.width: 1; radius: Theme.radiusMd; clip: true
                            WordCloud {
                                anchors { fill: parent; margins: 4 }
                                words: [
                                    {text:"design",weight:100},{text:"components",weight:80},{text:"QML",weight:70},
                                    {text:"animation",weight:60},{text:"theme",weight:55},{text:"layout",weight:50},
                                    {text:"canvas",weight:45},{text:"signals",weight:40},{text:"bindings",weight:35},
                                    {text:"properties",weight:30},{text:"states",weight:25},{text:"transitions",weight:20},
                                ]
                                onWordClicked: (w) => toaster.show("Word: " + w, Toaster.Type.Info, 1500)
                            }
                        }

                        Divider {}

                        // ── FormField ─────────────────────────────────────────────
                        Text { text: "FormField"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp4
                            width: parent.width - Theme.sp6 * 2

                            FormField {
                                label: "Email address"; hint: "We'll never share your email."; required: true
                                width: parent.width
                                Input { width: parent.width; placeholderText: "alice@example.com" }
                            }
                            FormField {
                                label: "Username"; errorMsg: "Username already taken."
                                width: parent.width
                                Input { width: parent.width; placeholderText: "choose a username"; text: "alice123" }
                            }
                        }

                        Divider {}

                        // ── FilterBar ─────────────────────────────────────────────
                        Text { text: "FilterBar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        FilterBar {
                            filterItems: [
                                { key: "all",    label: "All",      active: true  },
                                { key: "open",   label: "Open",     active: false },
                                { key: "closed", label: "Closed",   active: false },
                                { key: "merged", label: "Merged",   active: false },
                            ]
                            onFilterToggled: (f, a) => toaster.show(f.label + ": " + a, Toaster.Type.Info, 1200)
                        }

                        Divider {}

                        // ── JsonEditor ────────────────────────────────────────────
                        Text { text: "JsonEditor"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        JsonEditor {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            jsonText: '{\n  "name": "Alice",\n  "age": 30,\n  "tags": ["designer","developer"]\n}'
                            onJsonEdited: (t, v) => {}
                        }

                        Divider {}

                        // ── SearchResultItem ──────────────────────────────────────
                        Text { text: "SearchResultItem"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            width: parent.width - Theme.sp6 * 2
                            spacing: 4
                            SearchResultItem {
                                width: parent.width
                                icon: Icons.file; title: "Getting Started with Mahina"
                                excerpt: "Learn how to install and configure the Mahina component library…"
                                url: "docs.glow.dev/start"; meta: "3 min read"; badge: "Guide"
                                onActivated: toaster.show("Opened result", Toaster.Type.Info, 1200)
                            }
                            SearchResultItem {
                                width: parent.width
                                icon: Icons.sparkle; title: "Component API Reference"
                                excerpt: "Full API docs for every Mahina component with examples."
                                url: "docs.glow.dev/api"; meta: "Updated today"
                                onActivated: toaster.show("Opened result", Toaster.Type.Info, 1200)
                            }
                        }

                        Divider {}

                        // ── RatingInput ───────────────────────────────────────────
                        Text { text: "RatingInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp6
                            RatingInput { value: 3; maxStars: 5; onRatingSelected: (r) => toaster.show("Rated " + r + " stars", Toaster.Type.Success, 1500) }
                            RatingInput { value: 4; maxStars: 5; readOnly: true; starSize: 20 }
                        }

                        Divider {}

                        // ── WindowFrame ───────────────────────────────────────────
                        Text { text: "WindowFrame"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 220
                            color: Theme.surfaceVariant; radius: Theme.radiusMd
                            WindowFrame {
                                title: "My Window"; width: 320; height: 160
                                anchors.centerIn: parent
                                onCloseRequested: toaster.show("Close requested", Toaster.Type.Info, 1200)
                                Text {
                                    anchors.centerIn: parent
                                    text: "Drag the title bar to move\nDrag corners to resize"
                                    color: Theme.textSecondary
                                    font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        Divider {}

                        // ── GridStack ─────────────────────────────────────────────
                        Text { text: "GridStack"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        GridStack {
                            width: parent.width - Theme.sp6 * 2
                            columns: 4; rowHeight: 80; gap: 8
                            gridItems: [
                                { x:0, y:0, w:2, h:1, label:"Active Users",  value:"12,483", color:Theme.primary   },
                                { x:2, y:0, w:2, h:1, label:"Revenue",       value:"$84.2k", color:Theme.success   },
                                { x:0, y:1, w:1, h:1, label:"Errors",        value:"3",      color:Theme.error     },
                                { x:1, y:1, w:3, h:1, label:"Requests / hr", value:"41,200", color:Theme.warning   },
                            ]
                        }

                        Divider {}

                        // ── NavigationRail ────────────────────────────────────────
                        Text { text: "NavigationRail"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            NavigationRail {
                                height: 240
                                navItems: [
                                    { icon: Icons.house,    label: "Home",     badge: 0  },
                                    { icon: Icons.envelope, label: "Messages", badge: 4  },
                                    { icon: Icons.bell,     label: "Alerts",   badge: 12 },
                                    { icon: Icons.gear,     label: "Settings", badge: 0  },
                                ]
                                onItemSelected: (i) => toaster.show("Nav: " + i, Toaster.Type.Info, 1000)
                            }
                            NavigationRail {
                                height: 240; collapsed: true
                                navItems: [
                                    { icon: Icons.house,    label: "Home",  badge: 0 },
                                    { icon: Icons.envelope, label: "Mail",  badge: 2 },
                                    { icon: Icons.gear,     label: "Settings", badge: 0 },
                                ]
                            }
                        }

                        Divider {}

                        // ── CommandMenu ───────────────────────────────────────────
                        Text { text: "CommandMenu"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Button {
                            text: "Open Command Menu  ⌘K"
                            onClicked: _r7Cmd.isOpen = true
                        }

                        Divider {}

                        // ── SwipeToDelete ─────────────────────────────────────────
                        Text { text: "SwipeToDelete"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            width: parent.width - Theme.sp6 * 2
                            spacing: 8
                            Repeater {
                                model: ["Design system meeting","Deploy to staging","Review pull requests"]
                                delegate: SwipeToDelete {
                                    required property string modelData
                                    width: parent.width
                                    actionLabel: "Delete"
                                    actionColor: Theme.error
                                    onActionTriggered: toaster.show("Deleted: " + modelData, Toaster.Type.Warning, 1500)
                                    Rectangle {
                                        width: parent.width; height: 48; radius: Theme.radiusMd
                                        color: Theme.surface; border.color: Theme.border; border.width: 1
                                        Text {
                                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                            text: modelData; color: Theme.textPrimary
                                            font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                                        }
                                    }
                                }
                            }
                        }

                        Divider {}

                        // ── LoadingBar ────────────────────────────────────────────
                        Text { text: "LoadingBar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            width: parent.width - Theme.sp6 * 2; spacing: Theme.sp3
                            LoadingBar { width: parent.width; running: true; progress: 0.65 }
                            LoadingBar { width: parent.width; running: true; progress: -1; barColor: Theme.success }
                            LoadingBar { width: parent.width; running: true; progress: 1.0; barColor: Theme.warning }
                        }

                        Divider {}

                        // ── SystemStatus ──────────────────────────────────────────
                        Text { text: "SystemStatus"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        SystemStatus {
                            width: parent.width - Theme.sp6 * 2
                            services: [
                                { name: "API Gateway",  status: "operational" },
                                { name: "Database",     status: "degraded"    },
                                { name: "CDN",          status: "operational" },
                                { name: "Auth Service", status: "operational" },
                                { name: "Scheduler",    status: "maintenance" },
                            ]
                        }

                        Divider {}

                        // ── AlertStack ────────────────────────────────────────────
                        Text { text: "AlertStack"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        AlertStack {
                            width: parent.width - Theme.sp6 * 2
                            stackAlerts: [
                                { type: "error",   title: "Upload failed",   message: "File size exceeds 10 MB limit.", dismissible: true  },
                                { type: "warning", title: "Storage warning", message: "90% of quota used.",             dismissible: true  },
                                { type: "success", title: "Changes saved",   message: "All edits have been applied.",   dismissible: true  },
                                { type: "info",    title: "Update ready",    message: "Restart to apply v2.1.0.",       dismissible: false },
                            ]
                            onDismissed: (i) => toaster.show("Dismissed alert " + i, Toaster.Type.Info, 1000)
                        }

                        Divider {}

                        // ── FeedbackWidget ────────────────────────────────────────
                        Text { text: "FeedbackWidget"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        FeedbackWidget {
                            onSubmitted: (r, m) => toaster.show("Thanks! Rating: " + r, Toaster.Type.Success, 2000)
                        }

                        Divider {}

                        // ── ProfileCard ───────────────────────────────────────────
                        Text { text: "ProfileCard"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            ProfileCard {
                                name: "Alice Nguyen"; role: "Senior Designer"; bio: "Crafting beautiful interfaces one pixel at a time."
                                avatarInitials: "AN"; avatarColor: "#6366f1"
                                stats: [{ label: "Posts", value: "128" }, { label: "Followers", value: "4.2k" }, { label: "Following", value: "312" }]
                                onFollowToggled: (f) => toaster.show(f ? "Following!" : "Unfollowed", Toaster.Type.Info, 1200)
                            }
                            ProfileCard {
                                name: "Bob Chen"; role: "Backend Engineer"; bio: "Building resilient APIs."
                                avatarInitials: "BC"; avatarColor: "#0ea5e9"; isFollowing: true
                                stats: [{ label: "PRs", value: "847" }, { label: "Stars", value: "1.1k" }]
                                onFollowToggled: (f) => toaster.show(f ? "Following!" : "Unfollowed", Toaster.Type.Info, 1200)
                            }
                        }

                        Divider {}

                        // ── CommentThread ─────────────────────────────────────────
                        Text { text: "CommentThread"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2
                            height: _ct.implicitHeight + 2
                            border.color: Theme.border; border.width: 1; radius: Theme.radiusMd
                            CommentThread {
                                id: _ct
                                anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp3 }
                                threadComments: [
                                    { id:"1", author:"Alice", initials:"AL", avatarColor:"#6366f1",
                                      time:"2h ago", body:"Great component library! The animations are really smooth.", likes: 8,
                                      replies: [
                                        { id:"1a", author:"Bob", initials:"BO", avatarColor:"#0ea5e9",
                                          time:"1h ago", body:"Agreed, especially the Ripple effect.", likes:3, replies:[] },
                                      ]
                                    },
                                    { id:"2", author:"Carol", initials:"CR", avatarColor:"#22c55e",
                                      time:"45m ago", body:"The Canvas-based charts look fantastic.", likes:5, replies:[] },
                                ]
                                onReplyClicked: (c) => toaster.show("Reply to: " + c.author, Toaster.Type.Info, 1200)
                            }
                        }

                        Divider {}

                        // ── ReactionBar ───────────────────────────────────────────
                        Text { text: "ReactionBar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ReactionBar {
                            reactionItems: [
                                { emoji: "👍", count: 12, active: true  },
                                { emoji: "❤️", count: 5,  active: false },
                                { emoji: "😂", count: 3,  active: false },
                                { emoji: "🚀", count: 8,  active: true  },
                            ]
                            onReactionToggled: (e, a) => toaster.show(e + " " + (a ? "added" : "removed"), Toaster.Type.Info, 1000)
                        }

                        Divider {}

                        // ── GradientText ──────────────────────────────────────────
                        Text { text: "GradientText"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp3
                            GradientText {
                                displayText: "Hello, Mahina!"; fontSize: 48
                                gradientStops: [{pos:0.0,color:Theme.primary},{pos:1.0,color:Theme.error}]
                            }
                            GradientText {
                                displayText: "Social & Feedback"; fontSize: 28
                                gradientStops: [
                                    {pos:0.0,color:"#6366f1"},{pos:0.5,color:"#a855f7"},{pos:1.0,color:"#ec4899"}
                                ]
                            }
                        }

                        Divider {}

                        // ── TypingIndicator ───────────────────────────────────────
                        Text { text: "TypingIndicator"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp3
                            TypingIndicator { typing: true }
                            TypingIndicator { typing: true; username: "Alice" }
                            TypingIndicator { typing: false }
                        }

                        Divider {}

                        // ── ParticleField ─────────────────────────────────────────
                        Text { text: "ParticleField"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            radius: Theme.radiusMd; color: Theme.surface
                            border.color: Theme.border; border.width: 1; clip: true
                            ParticleField {
                                anchors.fill: parent
                                particleCount: 50; particleColor: Theme.primary; speed: 0.6; connect: true
                            }
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 15 — Social & Charts
                ScrollArea {
                    clip: true

                    Column {
                        width: parent.width
                        padding: Theme.sp6
                        spacing: Theme.sp8

                        // ── LiveChart ──────────────────────────────────────────────
                        Text { text: "LiveChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        LiveChart {
                            id: _liveChart
                            width: parent.width - Theme.sp6 * 2; height: 200
                            lineColor: Theme.primary; showDots: false; showFill: true
                        }
                        Timer {
                            interval: 400; repeat: true; running: _stack.currentIndex === 15
                            onTriggered: _liveChart.push(50 + 40 * Math.sin(Date.now() / 2000) + (Math.random() - 0.5) * 20)
                        }

                        Divider {}

                        // ── MetricCard ────────────────────────────────────────────
                        Text { text: "MetricCard"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            MetricCard {
                                width: 190
                                cardLabel: "Revenue"; metricValue: "$12.4k"; delta: 8.3; deltaLabel: "vs last month"
                                sparkData: [45,52,48,61,58,71,65,74,68,80]
                            }
                            MetricCard {
                                width: 190
                                cardLabel: "Churn"; metricValue: "2.1%"; delta: -2.1; deltaLabel: "vs last week"
                                sparkData: [80,72,68,74,61,58,52,49,44,40]
                                accentColor: Theme.error
                            }
                        }

                        Divider {}

                        // ── CorrelationMatrix ─────────────────────────────────────
                        Text { text: "CorrelationMatrix"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        CorrelationMatrix {
                            width: parent.width - Theme.sp6 * 2; height: 280
                            matrixLabels: ["Revenue","Clicks","Sessions","Bounces","Conv"]
                            matrixData: [
                                [1.0,  0.82, -0.31,  0.54,  0.21],
                                [0.82, 1.0,  -0.12,  0.63,  0.33],
                                [-0.31,-0.12, 1.0,  -0.48, -0.71],
                                [0.54, 0.63, -0.48,  1.0,   0.45],
                                [0.21, 0.33, -0.71,  0.45,  1.0 ]
                            ]
                        }

                        Divider {}

                        // ── DataTimeline ──────────────────────────────────────────
                        Text { text: "DataTimeline"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        DataTimeline {
                            width: parent.width - Theme.sp6 * 2; height: 160
                            timelineEvents: [
                                { time: "09:00", label: "Project kickoff", type: "milestone", color: Theme.primary },
                                { time: "10:30", label: "Design review",   type: "event",     color: Theme.info },
                                { time: "12:00", label: "Lunch break",     type: "break",     color: Theme.textDisabled },
                                { time: "14:00", label: "Sprint planning", type: "meeting",   color: Theme.warning },
                                { time: "16:00", label: "Code freeze",     type: "milestone", color: Theme.error },
                            ]
                        }

                        Divider {}

                        // ── GaugeCluster ──────────────────────────────────────────
                        Text { text: "GaugeCluster"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        GaugeCluster {
                            gaugeSize: 110
                            gauges: [
                                { label: "CPU",    value: 67, min: 0, max: 100, color: Theme.primary, unit: "%" },
                                { label: "Memory", value: 42, min: 0, max: 100, color: Theme.success,  unit: "%" },
                                { label: "Disk",   value: 88, min: 0, max: 100, color: Theme.error,    unit: "%" },
                                { label: "Net",    value: 23, min: 0, max: 100, color: Theme.warning,  unit: "%" },
                            ]
                        }

                        Divider {}

                        // ── ThreadedMessage ───────────────────────────────────────
                        Text { text: "ThreadedMessage"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            width: parent.width - Theme.sp6 * 2
                            spacing: Theme.sp2
                            ThreadedMessage {
                                width: parent.width
                                author: "Alice"; initials: "AL"; avatarColor: Theme.primary
                                body: "Hey team, the new build is looking great!"
                                time: "10:32 AM"; replyCount: 3
                                msgReactions: [{emoji:"👍",count:2,active:true},{emoji:"🎉",count:1,active:false}]
                            }
                            ThreadedMessage {
                                width: parent.width
                                author: "Assistant"; initials: "A"; avatarColor: Theme.info
                                body: "Build #142 passed all tests. Deploying to staging…"; isBot: true
                                time: "10:33 AM"
                            }
                        }

                        Divider {}

                        // ── PresenceList ──────────────────────────────────────────
                        Text { text: "PresenceList"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        PresenceList {
                            width: parent.width - Theme.sp6 * 2
                            heading: "Online Now"
                            members: [
                                { name: "Alice Chen",  initials: "AC", avatarColor: Theme.primary, status: "online",  lastSeen: "" },
                                { name: "Bob Smith",   initials: "BS", avatarColor: Theme.success,  status: "away",    lastSeen: "5m ago" },
                                { name: "Carol Davis", initials: "CD", avatarColor: Theme.warning,  status: "busy",    lastSeen: "" },
                                { name: "Dan Wilson",  initials: "DW", avatarColor: Theme.error,    status: "offline", lastSeen: "2h ago" },
                            ]
                        }

                        Divider {}

                        // ── NotificationBell ──────────────────────────────────────
                        Text { text: "NotificationBell"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp6
                            NotificationBell { bellCount: 0 }
                            NotificationBell { bellCount: 3; hasNew: true }
                            NotificationBell { bellCount: 12; hasNew: false }
                        }

                        Divider {}

                        // ── VideoCallTile ─────────────────────────────────────────
                        Text { text: "VideoCallTile"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp3
                            VideoCallTile {
                                width: 160; height: 120
                                participantName: "Alice Chen"; initials: "AC"; avatarColor: Theme.primary
                                muted: false; videoOff: false; isSpeaking: true
                            }
                            VideoCallTile {
                                width: 160; height: 120
                                participantName: "Bob Smith"; initials: "BS"; avatarColor: Theme.success
                                muted: true; videoOff: true; isLocal: true
                            }
                        }

                        Divider {}

                        // ── StatusMessage ─────────────────────────────────────────
                        Text { text: "StatusMessage"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            width: parent.width - Theme.sp6 * 2
                            spacing: Theme.sp2
                            StatusMessage { body: "Alice joined the channel"; icon: "👤"; time: "10:45 AM" }
                            StatusMessage { body: "Channel topic was updated"; icon: "📌"; time: "11:02 AM"; statusType: "topic" }
                        }

                        Divider {}

                        // ── InlineEdit ────────────────────────────────────────────
                        Text { text: "InlineEdit"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            width: parent.width - Theme.sp6 * 2
                            spacing: Theme.sp3
                            InlineEdit { editValue: "Click to edit this label"; width: 340 }
                            InlineEdit { editValue: "Project title"; fontSize: Theme.textLg; width: 340 }
                        }

                        Divider {}

                        // ── ColorTokenPicker ──────────────────────────────────────
                        Text { text: "ColorTokenPicker"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ColorTokenPicker {
                            width: parent.width - Theme.sp6 * 2
                            selectedToken: "primary"
                            tokens: [
                                { name: "primary",   color: Theme.primary   },
                                { name: "secondary", color: Theme.secondary },
                                { name: "success",   color: Theme.success   },
                                { name: "warning",   color: Theme.warning   },
                                { name: "error",     color: Theme.error     },
                                { name: "info",      color: Theme.info      },
                            ]
                        }

                        Divider {}

                        // ── FileTree ──────────────────────────────────────────────
                        Text { text: "FileTree"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: 300; height: 260
                            color: Theme.surface; radius: Theme.radiusMd
                            border.color: Theme.border; border.width: 1; clip: true
                            FileTree {
                                anchors.fill: parent
                                selectedPath: "src/main.qml"
                                treeFiles: [
                                    { name: "src", isDir: true, _expanded: true, children: [
                                        { name: "main.qml",  isDir: false },
                                        { name: "Theme.qml", isDir: false },
                                        { name: "components", isDir: true, _expanded: false, children: [
                                            { name: "Button.qml", isDir: false },
                                            { name: "Input.qml",  isDir: false }
                                        ]}
                                    ]},
                                    { name: "example", isDir: true, _expanded: false, children: [
                                        { name: "main.qml", isDir: false }
                                    ]},
                                    { name: "CMakeLists.txt", isDir: false },
                                    { name: "README.md",      isDir: false },
                                ]
                            }
                        }

                        Divider {}

                        // ── MultiStepForm ─────────────────────────────────────────
                        Text { text: "MultiStepForm"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        MultiStepForm {
                            width: parent.width - Theme.sp6 * 2
                            formSteps: [
                                { title: "Account",  valid: true  },
                                { title: "Profile",  valid: false },
                                { title: "Billing",  valid: false },
                                { title: "Confirm",  valid: false },
                            ]
                        }

                        Divider {}

                        // ── FormulaInput ──────────────────────────────────────────
                        Text { text: "FormulaInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        FormulaInput {
                            width: parent.width - Theme.sp6 * 2
                            formulaVars: ({ x: 5, y: 3 })
                            formulaText: "x * y + 1"
                        }

                        Divider {}

                        // ── FloatingIsland ────────────────────────────────────────
                        Text { text: "FloatingIsland"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            FloatingIsland {
                                islandIcon: "🎵"; islandTitle: "Now Playing"; islandSubtitle: "Bohemian Rhapsody"
                            }
                            FloatingIsland {
                                islandIcon: "📍"; islandTitle: "Location"; islandSubtitle: "San Francisco"
                                accentColor: Theme.success
                            }
                        }

                        Divider {}

                        // ── StickyHeader ──────────────────────────────────────────
                        Text { text: "StickyHeader"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            color: Theme.surface; radius: Theme.radiusMd
                            border.color: Theme.border; border.width: 1; clip: true

                            Flickable {
                                id:           _stickyFlick
                                anchors.fill: parent
                                contentWidth: width; contentHeight: 540

                                Column {
                                    width: _stickyFlick.width

                                    Item { width: 1; height: 80 }

                                    Repeater {
                                        model: 12
                                        delegate: Rectangle {
                                            required property int index
                                            width: _stickyFlick.width; height: 40
                                            color: index % 2 === 0 ? Theme.surface : Theme.surfaceVariant
                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: parent.left; anchors.leftMargin: Theme.sp4
                                                text: "Row " + (index + 1)
                                                color: Theme.textPrimary; font.family: Theme.fontFamily
                                                font.pixelSize: Theme.textSm
                                            }
                                        }
                                    }
                                }

                                StickyHeader {
                                    scrollTarget: _stickyFlick
                                    expandedHeight: 80; compressedHeight: 44
                                    width: _stickyFlick.width
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Sticky Header Demo"
                                        color: Theme.textPrimary; font.family: Theme.fontFamily
                                        font.pixelSize: Theme.textBase; font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }

                        Divider {}

                        // ── TabDock ───────────────────────────────────────────────
                        Text { text: "TabDock"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        TabDock {
                            width: parent.width - Theme.sp6 * 2
                            tabItems: [
                                { id: "home",     label: "Home",     closable: false },
                                { id: "files",    label: "Files",    closable: true  },
                                { id: "search",   label: "Search",   closable: true  },
                                { id: "settings", label: "Settings", closable: true  },
                                { id: "help",     label: "Help",     closable: false },
                            ]
                        }

                        Divider {}

                        // ── OverflowMenu ──────────────────────────────────────────
                        Text { text: "OverflowMenu"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        OverflowMenu {
                            maxVisible: 3
                            menuItems: [
                                { label: "Edit",   icon: Icons.pencil   },
                                { label: "Share",  icon: Icons.share    },
                                { label: "Delete", icon: Icons.trash    },
                                { label: "Export", icon: Icons.download },
                                { label: "Print",  icon: Icons.printer  },
                            ]
                        }

                        Divider {}

                        // ── AudioWaveform ─────────────────────────────────────────
                        Text { text: "AudioWaveform"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        AudioWaveform {
                            width: parent.width - Theme.sp6 * 2; height: 80
                            animating: true
                            amplitudes: [0.3,0.7,0.5,0.9,0.4,0.6,0.8,0.3,0.5,0.7,0.4,0.9,0.6,0.3,0.7,0.5,
                                         0.8,0.4,0.6,0.9,0.3,0.7,0.5,0.4,0.8,0.6,0.3,0.9,0.5,0.7,0.4,0.6]
                        }

                        Divider {}

                        // ── ImageComparison ───────────────────────────────────────
                        Text { text: "ImageComparison"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ImageComparison {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            beforeSrc: ""; afterSrc: ""
                            beforeLabel: "Before"; afterLabel: "After"
                        }

                        Divider {}

                        // ── ConnectionStatus ──────────────────────────────────────
                        Text { text: "ConnectionStatus"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp3
                            ConnectionStatus { netStatus: "online" }
                            ConnectionStatus { netStatus: "offline" }
                            ConnectionStatus { netStatus: "reconnecting" }
                        }

                        Divider {}

                        // ── SyncStatus ────────────────────────────────────────────
                        Text { text: "SyncStatus"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Column {
                            spacing: Theme.sp3
                            SyncStatus { syncState: "saved" }
                            SyncStatus { syncState: "syncing" }
                            SyncStatus { syncState: "error"; errorMessage: "Network unavailable" }
                            SyncStatus { syncState: "modified" }
                        }

                        Divider {}

                        // ── PermissionGate ────────────────────────────────────────
                        Text { text: "PermissionGate"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        PermissionGate {
                            width: parent.width - Theme.sp6 * 2; height: 180
                            locked: true
                            lockMessage: "Pro plan required"; lockCta: "Upgrade to Pro"
                            Column {
                                anchors.centerIn: parent
                                spacing: Theme.sp2
                                Text { text: "Premium Analytics Dashboard"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textBase }
                                Text { text: "Deep insights and custom reports"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            }
                        }

                        Divider {}

                        // ── SidePanel ─────────────────────────────────────────────
                        Text { text: "SidePanel"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Button {
                            text: "Open Side Panel"
                            onClicked: _r8SidePanel.panelOpen = true
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // Page 16 — Nav & Inputs
                ScrollArea {
                    clip: true

                    Column {
                        width: parent.width
                        padding: Theme.sp6
                        spacing: Theme.sp8

                        // ── MenuBar ───────────────────────────────────────────────
                        Text { text: "MenuBar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 40
                            color: Theme.surfaceVariant; radius: Theme.radiusMd
                            border.color: Theme.border; border.width: 1
                            MenuBar {
                                anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                                menus: [
                                    { label: "File", items: [
                                        { label: "New File",   shortcut: "Ctrl+N" },
                                        { label: "Open…",      shortcut: "Ctrl+O" },
                                        { separator: true },
                                        { label: "Save",       shortcut: "Ctrl+S" },
                                        { separator: true },
                                        { label: "Quit",       shortcut: "Ctrl+Q" },
                                    ]},
                                    { label: "Edit", items: [
                                        { label: "Undo",  shortcut: "Ctrl+Z" },
                                        { label: "Redo",  shortcut: "Ctrl+Y" },
                                        { separator: true },
                                        { label: "Cut",   shortcut: "Ctrl+X" },
                                        { label: "Copy",  shortcut: "Ctrl+C" },
                                        { label: "Paste", shortcut: "Ctrl+V" },
                                    ]},
                                    { label: "View", items: [
                                        { label: "Zoom In",  shortcut: "Ctrl+=" },
                                        { label: "Zoom Out", shortcut: "Ctrl+-" },
                                    ]},
                                    { label: "Help", items: [
                                        { label: "About Mahina" },
                                    ]},
                                ]
                            }
                        }

                        Divider {}

                        // ── ToolBar ───────────────────────────────────────────────
                        Text { text: "ToolBar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        ToolBar {
                            width: parent.width - Theme.sp6 * 2
                            toolActions: [
                                { icon: Icons.file,       label: "New"    },
                                { icon: Icons.folder,     label: "Open"   },
                                { icon: Icons.floppyDisk, label: "Save"   },
                                { separator: true },
                                { icon: Icons.arrowCounterClockwise, label: "Undo" },
                                { icon: Icons.arrowClockwise,        label: "Redo" },
                                { separator: true },
                                { icon: Icons.magnifyingGlass, label: "Find" },
                            ]
                        }

                        Divider {}

                        // ── TitleBar ──────────────────────────────────────────────
                        Text { text: "TitleBar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        TitleBar {
                            width: parent.width - Theme.sp6 * 2
                            windowTitle: "My Application — document.txt"
                        }

                        Divider {}

                        // ── BreadcrumbEditor ──────────────────────────────────────
                        Text { text: "BreadcrumbEditor"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        BreadcrumbEditor {
                            width: parent.width - Theme.sp6 * 2
                            crumbPath: "/home/user/projects/mahina/qml/Mahina"
                        }

                        Divider {}

                        // ── DragDropList ──────────────────────────────────────────
                        Text { text: "DragDropList"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        DragDropList {
                            width: parent.width - Theme.sp6 * 2
                            listItems: [
                                { label: "Design mockups"      },
                                { label: "Write unit tests"    },
                                { label: "Review pull request" },
                                { label: "Deploy to staging"   },
                                { label: "Update changelog"    },
                            ]
                        }

                        Divider {}

                        // ── TagInput ──────────────────────────────────────────────
                        Text { text: "TagInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        TagInput {
                            width: parent.width - Theme.sp6 * 2
                            tags: ["qml", "desktop", "qt6"]
                        }

                        Divider {}

                        // ── NumberStepper ─────────────────────────────────────────
                        Text { text: "NumberStepper"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            NumberStepper { stepperValue: 10; from: 0; to: 100; stepSize: 5; suffix: "%" }
                            NumberStepper { stepperValue: 1.5; from: 0; to: 10; stepSize: 0.5; decimals: 1 }
                            NumberStepper { stepperValue: 42; from: -100; to: 100; stepSize: 1 }
                        }

                        Divider {}

                        // ── AutoComplete ──────────────────────────────────────────
                        Text { text: "AutoComplete"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        AutoComplete {
                            width: parent.width - Theme.sp6 * 2
                            model: ["Alabama","Alaska","Arizona","Arkansas","California",
                                    "Colorado","Connecticut","Delaware","Florida","Georgia"]
                        }

                        Divider {}

                        // ── FilePicker ────────────────────────────────────────────
                        Text { text: "FilePicker"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        FilePicker {
                            width: parent.width - Theme.sp6 * 2
                            filePath: "/home/user/documents/report-2025.pdf"
                        }

                        Divider {}

                        // ── KeybindingInput ───────────────────────────────────────
                        Text { text: "KeybindingInput"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            KeybindingInput { keybinding: "Ctrl+Shift+P" }
                            KeybindingInput { keybinding: "" }
                        }

                        Divider {}

                        // ── VirtualList ───────────────────────────────────────────
                        Text { text: "VirtualList"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        VirtualList {
                            width: parent.width - Theme.sp6 * 2; height: 200
                            model: 10000
                        }

                        Divider {}

                        // ── ContextMenu ───────────────────────────────────────────
                        Text { text: "ContextMenu"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 80
                            color: Theme.surfaceVariant; radius: Theme.radiusMd
                            border.color: Theme.border; border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "Right-click for context menu"
                                color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                            }
                            ContextMenu {
                                anchor: parent
                                model: [
                                    { label: "Copy",   icon: Icons.copy   },
                                    { label: "Paste",  icon: Icons.clipboard },
                                    null,
                                    { label: "Delete", icon: Icons.trash  },
                                ]
                            }
                        }

                        Divider {}

                        // ── ConfirmDialog ─────────────────────────────────────────
                        Text { text: "ConfirmDialog"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            Button {
                                text: "Show Confirm"
                                onClicked: _r9ConfirmDlg.open()
                            }
                            Button {
                                text: "Destructive"
                                variant: Button.Variant.Outlined
                                onClicked: _r9DestructDlg.open()
                            }
                        }

                        Divider {}

                        // ── SelectionRect ─────────────────────────────────────────
                        Text { text: "SelectionRect"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 160
                            color: Theme.surfaceVariant; radius: Theme.radiusMd
                            border.color: Theme.border; border.width: 1; clip: true
                            Text {
                                anchors.centerIn: parent
                                text: "Drag to select"
                                color: Theme.textDisabled; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm
                            }
                            SelectionRect { anchors.fill: parent }
                        }

                        Divider {}

                        // ── PreferencesLayout ─────────────────────────────────────
                        Text { text: "PreferencesLayout"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 260
                            radius: Theme.radiusMd; border.color: Theme.border; border.width: 1; clip: true
                            color: Theme.surface
                            PreferencesLayout {
                                anchors.fill: parent
                                currentSection: "general"
                                prefSections: [
                                    { id: "general",     label: "General",     icon: "⚙" },
                                    { id: "appearance",  label: "Appearance",  icon: "🎨" },
                                    { id: "keybindings", label: "Keybindings", icon: "⌨" },
                                    { id: "privacy",     label: "Privacy",     icon: "🔒" },
                                    { id: "about",       label: "About",       icon: "ℹ" },
                                ]
                                Column {
                                    anchors { left: parent.left; top: parent.top; leftMargin: Theme.sp4; topMargin: Theme.sp4 }
                                    spacing: Theme.sp3
                                    Text { text: "General Settings"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textBase; font.weight: Font.DemiBold }
                                    Text { text: "Configure language, region and startup behaviour."; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; wrapMode: Text.Wrap; width: 280 }
                                }
                            }
                        }

                        Divider {}

                        // ── TreeMap ───────────────────────────────────────────────
                        Text { text: "TreeMap"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        TreeMap {
                            width: parent.width - Theme.sp6 * 2; height: 260
                            nodes: [
                                { label: "JavaScript", value: 420, color: Theme.warning },
                                { label: "QML",        value: 310, color: Theme.primary },
                                { label: "C++",        value: 280, color: Theme.info    },
                                { label: "Python",     value: 195, color: Theme.success },
                                { label: "Rust",       value: 140, color: Theme.error   },
                                { label: "Go",         value: 95,  color: "#00ADD8"     },
                                { label: "Swift",      value: 78,  color: "#F05138"     },
                                { label: "Kotlin",     value: 62,  color: "#7F52FF"     },
                            ]
                        }

                        Divider {}

                        // ── CandlestickChart ──────────────────────────────────────
                        Text { text: "CandlestickChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        CandlestickChart {
                            width: parent.width - Theme.sp6 * 2; height: 240
                            candles: [
                                { label: "Mon", open: 142, high: 158, low: 138, close: 151 },
                                { label: "Tue", open: 151, high: 163, low: 148, close: 145 },
                                { label: "Wed", open: 145, high: 150, low: 136, close: 139 },
                                { label: "Thu", open: 139, high: 155, low: 137, close: 153 },
                                { label: "Fri", open: 153, high: 168, low: 149, close: 162 },
                                { label: "Mon", open: 162, high: 170, low: 157, close: 158 },
                                { label: "Tue", open: 158, high: 165, low: 145, close: 148 },
                                { label: "Wed", open: 148, high: 156, low: 143, close: 155 },
                            ]
                        }

                        Divider {}

                        // ── WaterfallChart ────────────────────────────────────────
                        Text { text: "WaterfallChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        WaterfallChart {
                            width: parent.width - Theme.sp6 * 2; height: 240
                            bars: [
                                { label: "Revenue",    value: 850,  total: false },
                                { label: "COGS",       value: -320, total: false },
                                { label: "Gross",      value: 0,    total: true  },
                                { label: "OpEx",       value: -180, total: false },
                                { label: "Marketing",  value: -90,  total: false },
                                { label: "EBIT",       value: 0,    total: true  },
                                { label: "Tax",        value: -65,  total: false },
                                { label: "Net",        value: 0,    total: true  },
                            ]
                        }

                        Divider {}

                        // ── GanttChart ────────────────────────────────────────────
                        Text { text: "GanttChart"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        GanttChart {
                            width: parent.width - Theme.sp6 * 2; height: 220
                            xMin: 0; xMax: 12
                            xLabels: ["Wk1","Wk2","Wk3","Wk4","Wk5","Wk6","Wk7","Wk8","Wk9","Wk10","Wk11","Wk12"]
                            tasks: [
                                { label: "Research", start: 0,  end: 3,  color: Theme.info    },
                                { label: "Design",   start: 2,  end: 6,  color: Theme.primary },
                                { label: "Build",    start: 5,  end: 11, color: Theme.success },
                                { label: "QA",       start: 9,  end: 12, color: Theme.warning },
                                { label: "Deploy",   start: 11, end: 12, color: Theme.error   },
                            ]
                        }

                        Divider {}

                        // ── HeatMapCalendar ───────────────────────────────────────
                        Text { text: "HeatMapCalendar"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        HeatMapCalendar {
                            cellColor: Theme.primary
                            heatData: ({
                                "2026-06-01": 2, "2026-06-03": 7, "2026-06-05": 3,
                                "2026-06-08": 12,"2026-06-10": 5, "2026-06-12": 8,
                                "2026-06-15": 4, "2026-06-17": 9, "2026-06-18": 6,
                                "2026-05-28": 3, "2026-05-20": 11,"2026-05-10": 7,
                                "2026-04-15": 5, "2026-03-22": 8, "2026-02-14": 6,
                            })
                        }

                        Divider {}

                        // ── DiffViewer ────────────────────────────────────────────
                        Text { text: "DiffViewer"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        DiffViewer {
                            width: parent.width - Theme.sp6 * 2; height: 260
                            original: "function greet(name) {\n  console.log('Hello ' + name)\n  return true\n}\n\nconst result = greet('World')\nconsole.log(result)"
                            modified: "function greet(name, greeting = 'Hello') {\n  const msg = greeting + ', ' + name + '!'\n  console.log(msg)\n  return msg\n}\n\nconst result = greet('World', 'Hi')\nconsole.log(result)"
                        }

                        Divider {}

                        // ── MiniMap ───────────────────────────────────────────────
                        Text { text: "MiniMap"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp4
                            Flickable {
                                id:           _mmFlick
                                width:  400; height: 200
                                contentWidth: 1200; contentHeight: 800
                                clip: true
                                Rectangle {
                                    width: 1200; height: 800
                                    color: Theme.surfaceVariant
                                    Grid {
                                        anchors.fill: parent
                                        columns: 6; rows: 4; spacing: Theme.sp4
                                        Repeater {
                                            model: 24
                                            delegate: Rectangle {
                                                required property int index
                                                width: 180; height: 180
                                                radius: Theme.radiusMd
                                                color: Qt.hsla(index / 24, 0.5, Theme.dark ? 0.3 : 0.7, 1)
                                            }
                                        }
                                    }
                                }
                            }
                            MiniMap {
                                scrollTarget: _mmFlick
                                width: 80; height: 200
                                thumbColor: Theme.primary
                            }
                        }

                        Divider {}

                        // ── ObjectInspector ───────────────────────────────────────
                        Text { text: "ObjectInspector"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width: parent.width - Theme.sp6 * 2; height: 260
                            color: Theme.surface; radius: Theme.radiusMd
                            border.color: Theme.border; border.width: 1; clip: true
                            ObjectInspector {
                                anchors.fill: parent
                                inspectData: ({
                                    name: "Alice Chen",
                                    age: 32,
                                    active: true,
                                    address: { city: "Berlin", zip: "10115", country: "DE" },
                                    tags: ["ux", "design", "research"],
                                    score: 9.4,
                                })
                            }
                        }

                        Divider {}

                        // ── LogConsole ────────────────────────────────────────────
                        Text { text: "LogConsole"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        LogConsole {
                            id:    _logConsole
                            width: parent.width - Theme.sp6 * 2; height: 280
                        }
                        Timer {
                            interval: 900; repeat: true; running: _stack.currentIndex === 16
                            property int _tick: 0
                            onTriggered: {
                                var msgs = [
                                    ["info",  "Server started on port 8080"],
                                    ["debug", "Received GET /api/users"],
                                    ["info",  "Query executed in 4ms"],
                                    ["warn",  "Memory usage above 80%"],
                                    ["error", "Connection to DB refused"],
                                    ["info",  "Retry succeeded"],
                                    ["debug", "Cache hit ratio: 0.94"],
                                ]
                                var m = msgs[_tick % msgs.length]
                                _logConsole.append(m[0], m[1])
                                _tick++
                            }
                        }

                        Divider {}

                        // ── NetworkGraph ──────────────────────────────────────────
                        Text { text: "NetworkGraph"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textXl; font.weight: Theme.weightSemibold }
                        NetworkGraph {
                            width: parent.width - Theme.sp6 * 2; height: 280
                            nodes: [
                                { label: "Auth",    color: Theme.primary   },
                                { label: "API",     color: Theme.info      },
                                { label: "DB",      color: Theme.success   },
                                { label: "Cache",   color: Theme.warning   },
                                { label: "Worker",  color: Theme.error     },
                                { label: "Storage", color: Theme.secondary },
                            ]
                            edges: [
                                { source: 0, target: 1 }, { source: 1, target: 2 },
                                { source: 1, target: 3 }, { source: 1, target: 4 },
                                { source: 4, target: 5 }, { source: 2, target: 3 },
                            ]
                        }

                        Item { height: Theme.sp8 }
                    }
                }

                // ── Page 17 — Editors & Tools ────────────────────────────────────
                Item {
                    Flickable {
                        anchors.fill: parent
                        contentWidth: parent.width
                        contentHeight: _r10Col.implicitHeight + Theme.sp8
                        clip: true
    
                        Column {
                            id: _r10Col
                            width: parent.width
                            padding: Theme.sp6
                            spacing: Theme.sp8
    
                            Text {
                                text: "Editors & Tools"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textXl
                                font.weight: Font.Bold
                            }
    
                            // ── NotesPad ────────────────────────────────────────
                            Text { text: "NotesPad"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            NotesPad {
                                width: 360; height: 200
                                noteTitle: "Meeting Notes"
                                noteText: "- Discuss component library progress\n- Review latest additions"
                                onNoteSaved: (t) => toaster.show("Notes saved", Toaster.Type.Success, 1200)
                            }
    
                            // ── TimezoneSelector ────────────────────────────────
                            Text { text: "TimezoneSelector"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            TimezoneSelector {
                                width: 280
                                selectedZone: "America/New_York"
                                onZoneSelected: (tz) => toaster.show("Selected: " + tz, Toaster.Type.Info, 1200)
                            }
    
                            // ── RulerBar ────────────────────────────────────────
                            Text { text: "RulerBar"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            Column {
                                spacing: Theme.sp2
                                RulerBar { width: parent.width - Theme.sp6 * 2; height: 24; horizontal: true; rulerScale: 1.5; majorStep: 100; minorStep: 10 }
                                RulerBar { width: 24; height: 120; horizontal: false; rulerScale: 1.5; majorStep: 100; minorStep: 10 }
                            }
    
                            // ── TableOfContents ─────────────────────────────────
                            Text { text: "TableOfContents"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            TableOfContents {
                                width: 240; height: 200
                                tocItems: [
                                    { id: "intro",    level: 1, title: "Introduction"     },
                                    { id: "setup",    level: 1, title: "Getting Started"  },
                                    { id: "install",  level: 2, title: "Installation"     },
                                    { id: "config",   level: 2, title: "Configuration"    },
                                    { id: "advanced", level: 1, title: "Advanced Usage"   },
                                    { id: "api",      level: 2, title: "API Reference"    },
                                    { id: "hooks",    level: 3, title: "Lifecycle Hooks"  },
                                ]
                                activeId: "setup"
                                onItemSelected: (id) => toaster.show("ToC: " + id, Toaster.Type.Info, 800)
                            }
    
                            // ── FontPicker ──────────────────────────────────────
                            Text { text: "FontPicker"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            FontPicker {
                                width: parent.width - Theme.sp6 * 2
                                onFontPicked: (f, s, w, i) => toaster.show(f + " " + s + "pt", Toaster.Type.Info, 1200)
                            }
    
                            // ── TransferList ────────────────────────────────────
                            Text { text: "TransferList"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            TransferList {
                                width: parent.width - Theme.sp6 * 2; height: 260
                                available: ["Reports", "Analytics", "Users", "Settings", "Billing", "Support"]
                                selected:  ["Dashboard", "Notifications"]
                                onSelectionChanged: (s) => toaster.show("Selected: " + s.length, Toaster.Type.Info, 800)
                            }
    
                            // ── LayerPanel ──────────────────────────────────────
                            Text { text: "LayerPanel"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            LayerPanel {
                                width: 260; height: 280
                                layers: [
                                    { id: "g1", name: "Background", type: "group", visible: true, locked: false,
                                      children: [
                                        { id: "l1", name: "Sky gradient",  type: "shape", visible: true,  locked: false },
                                        { id: "l2", name: "Ground",        type: "shape", visible: true,  locked: true  },
                                      ]},
                                    { id: "g2", name: "Content",    type: "group", visible: true, locked: false,
                                      children: [
                                        { id: "l3", name: "Headline",  type: "text",  visible: true,  locked: false },
                                        { id: "l4", name: "Hero image",type: "image", visible: false, locked: false },
                                      ]},
                                ]
                                activeLayerId: "l3"
                                onLayerSelected:      (id) => toaster.show("Layer: " + id, Toaster.Type.Info, 800)
                                onVisibilityToggled:  (id, v) => toaster.show(id + (v ? " shown" : " hidden"), Toaster.Type.Info, 800)
                            }
    
                            // ── PluginManager ───────────────────────────────────
                            Text { text: "PluginManager"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            PluginManager {
                                width: parent.width - Theme.sp6 * 2; height: 300
                                plugins: [
                                    { id: "p1", name: "Git Integration",  version: "2.1.0", description: "Inline git blame, diff, and status", author: "Mahina Team", enabled: true,  official: true  },
                                    { id: "p2", name: "Vim Keybindings",  version: "1.4.2", description: "Modal editing with Vim motions",      author: "community",  enabled: false, official: false },
                                    { id: "p3", name: "Theme Studio",     version: "1.0.0", description: "Visual theme editor and exporter",    author: "Mahina Team", enabled: true,  official: true  },
                                    { id: "p4", name: "Spell Check",      version: "3.0.1", description: "Real-time spell checking in editors", author: "community",  enabled: false, official: false },
                                ]
                                onPluginToggled: (id, e) => toaster.show(id + (e ? " enabled" : " disabled"), Toaster.Type.Info, 1000)
                            }
    
                            // ── ShortcutManager ─────────────────────────────────
                            Text { text: "ShortcutManager"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            ShortcutManager {
                                width: parent.width - Theme.sp6 * 2; height: 280
                                shortcutCategories: [
                                    { category: "File", shortcuts: [
                                        { id: "new",   label: "New File",  binding: "Ctrl+N" },
                                        { id: "open",  label: "Open…",     binding: "Ctrl+O" },
                                        { id: "save",  label: "Save",      binding: "Ctrl+S" },
                                    ]},
                                    { category: "Edit", shortcuts: [
                                        { id: "undo",  label: "Undo",      binding: "Ctrl+Z" },
                                        { id: "redo",  label: "Redo",      binding: "Ctrl+Y" },
                                        { id: "find",  label: "Find",      binding: "Ctrl+F" },
                                    ]},
                                ]
                                onShortcutChanged: (id, b) => toaster.show(id + " → " + b, Toaster.Type.Info, 1200)
                            }
    
                            // ── ColorSchemeEditor ───────────────────────────────
                            Text { text: "ColorSchemeEditor"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            ColorSchemeEditor {
                                width: 400; height: 300
                                colorTokens: [
                                    { name: "primary",   value: "#5B8DF6", description: "Primary action color"   },
                                    { name: "success",   value: "#59A14F", description: "Success / positive"     },
                                    { name: "warning",   value: "#F28E2B", description: "Warning / caution"      },
                                    { name: "error",     value: "#E15759", description: "Error / destructive"    },
                                    { name: "info",      value: "#2196E8", description: "Informational"          },
                                    { name: "surface",   value: "#FFFFFF", description: "Card / panel background"},
                                ]
                                onTokenChanged: (n, v) => toaster.show(n + " → " + v, Toaster.Type.Info, 1000)
                            }
    
                            // ── InspectorPanel ──────────────────────────────────
                            Text { text: "InspectorPanel"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            InspectorPanel {
                                width: 280; height: 300
                                element: ({
                                    tag: "Rectangle",
                                    id: "myRect",
                                    properties: [
                                        { name: "x",       value: 120,      type: "number",  category: "Layout"     },
                                        { name: "y",       value: 80,       type: "number",  category: "Layout"     },
                                        { name: "width",   value: 200,      type: "number",  category: "Layout"     },
                                        { name: "height",  value: 100,      type: "number",  category: "Layout"     },
                                        { name: "color",   value: "#5B8DF6",type: "color",   category: "Appearance" },
                                        { name: "radius",  value: 8,        type: "number",  category: "Appearance" },
                                        { name: "visible", value: true,     type: "boolean", category: "Appearance" },
                                        { name: "opacity", value: 1.0,      type: "number",  category: "Appearance" },
                                    ]
                                })
                                onPropertyClicked: (n, v) => toaster.show(n + ": " + v, Toaster.Type.Info, 800)
                            }
    
                            // ── FileManager ─────────────────────────────────────
                            Text { text: "FileManager"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            FileManager {
                                width: parent.width - Theme.sp6 * 2; height: 300
                                currentPath: "/home/user/projects"
                                fileEntries: [
                                    { name: "glow",       type: "dir",  size: 0,       modified: "2026-06-18" },
                                    { name: "README.md",  type: "file", size: 4096,    modified: "2026-06-15" },
                                    { name: "package.json",type: "file",size: 1200,    modified: "2026-06-14" },
                                    { name: ".gitignore", type: "file", size: 256,     modified: "2026-06-01" },
                                    { name: "src",        type: "dir",  size: 0,       modified: "2026-06-18" },
                                    { name: "dist",       type: "dir",  size: 0,       modified: "2026-06-17" },
                                ]
                                onFileActivated:  (n) => toaster.show("Open: " + n, Toaster.Type.Info, 800)
                                onDirectoryChanged:(p) => toaster.show("cd: " + p, Toaster.Type.Info, 800)
                            }
    
                            // ── CronEditor ──────────────────────────────────────
                            Text { text: "CronEditor"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            CronEditor {
                                width: 440
                                cronExpression: "0 9 * * 1-5"
                                onExpressionChanged: (e) => toaster.show("Cron: " + e, Toaster.Type.Info, 800)
                            }
    
                            // ── ThemePreview ─────────────────────────────────────
                            Text { text: "ThemePreview"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            ThemePreview {
                                width: parent.width - Theme.sp6 * 2; height: 420
                            }
    
                            // ── CodeEditor ──────────────────────────────────────
                            Text { text: "CodeEditor"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            CodeEditor {
                                width: parent.width - Theme.sp6 * 2; height: 200
                                language: "qml"
                                code: "import QtQuick\nimport Mahina\n\nButton {\n    text: \"Hello, Mahina!\"\n    variant: Button.Variant.Filled\n    onClicked: console.log(\"clicked\")\n}"
                            }
    
                            // ── HexViewer ────────────────────────────────────────
                            Text { text: "HexViewer"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            HexViewer {
                                width: parent.width - Theme.sp6 * 2; height: 200
                                hexBytes: {
                                    var b = []
                                    // PNG header + some data
                                    var raw = [0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,
                                               0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
                                               0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,
                                               0x08,0x02,0x00,0x00,0x00,0x90,0x77,0x53,
                                               0x48,0x65,0x6C,0x6C,0x6F,0x20,0x57,0x6F,
                                               0x72,0x6C,0x64,0x21,0x00,0x00,0x00,0x00,
                                               0xFF,0xFE,0xFD,0xFC,0x7F,0x80,0x81,0x82]
                                    for (var i = 0; i < raw.length; i++) b.push(raw[i])
                                    return b
                                }
                                onByteSelected: (off, v) => toaster.show("Byte " + off + " = 0x" + v.toString(16).toUpperCase(), Toaster.Type.Info, 1200)
                            }
    
                            // ── RegexTester ──────────────────────────────────────
                            Text { text: "RegexTester"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            RegexTester {
                                width: parent.width - Theme.sp6 * 2; height: 280
                                pattern:    "\\b\\w+@\\w+\\.\\w+\\b"
                                testString: "Contact us at hello@glow.dev or support@example.com for assistance."
                                flags:      "gi"
                            }
    
                            // ── DiffEditor ───────────────────────────────────────
                            Text { text: "DiffEditor"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            DiffEditor {
                                width: parent.width - Theme.sp6 * 2; height: 220
                                leftLabel:  "v1.0"
                                rightLabel: "v2.0"
                                leftText:   "function greet(name) {\n  return 'Hello ' + name\n}\n\nconst x = 1"
                                rightText:  "function greet(name, title) {\n  return `Hello ${title} ${name}!`\n}\n\nconst x = 42\nconst y = 10"
                            }
    
                            // ── Ribbon ───────────────────────────────────────────
                            Text { text: "Ribbon"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            Ribbon {
                                width: parent.width - Theme.sp6 * 2
                                ribbonTabs: [
                                    { label: "File", groups: [
                                        { label: "Clipboard", actions: [
                                            { icon: "📋", label: "Paste",  action: function() { toaster.show("Paste", Toaster.Type.Info, 600) } },
                                            { icon: "✂️", label: "Cut",    action: function() { toaster.show("Cut",   Toaster.Type.Info, 600) } },
                                            { icon: "📄", label: "Copy",   action: function() { toaster.show("Copy",  Toaster.Type.Info, 600) } },
                                        ]},
                                        { label: "File", actions: [
                                            { icon: "💾", label: "Save",   action: function() { toaster.show("Save", Toaster.Type.Success, 800) } },
                                            { icon: "📂", label: "Open",   action: function() { toaster.show("Open", Toaster.Type.Info, 600) } },
                                            { icon: "🖨️", label: "Print",  action: function() { toaster.show("Print",Toaster.Type.Info, 600) } },
                                        ]},
                                    ]},
                                    { label: "Edit", groups: [
                                        { label: "Undo", actions: [
                                            { icon: "↩", label: "Undo", action: function() { toaster.show("Undo", Toaster.Type.Info, 600) } },
                                            { icon: "↪", label: "Redo", action: function() { toaster.show("Redo", Toaster.Type.Info, 600) } },
                                        ]},
                                        { label: "Find", actions: [
                                            { icon: "🔍", label: "Find",    action: function() { toaster.show("Find",    Toaster.Type.Info, 600) } },
                                            { icon: "🔄", label: "Replace", action: function() { toaster.show("Replace", Toaster.Type.Info, 600) } },
                                        ]},
                                    ]},
                                    { label: "View", groups: [
                                        { label: "Zoom", actions: [
                                            { icon: "+",  label: "Zoom In",  action: function() {} },
                                            { icon: "−",  label: "Zoom Out", action: function() {} },
                                            { icon: "⊡",  label: "Fit",      action: function() {} },
                                        ]},
                                    ]},
                                ]
                            }
    
                            // ── VirtualTable ──────────────────────────────────────
                            Text { text: "VirtualTable"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            VirtualTable {
                                id: _r10VT
                                width: parent.width - Theme.sp6 * 2; height: 280
                                tableColumns: [
                                    { id: "id",    label: "ID",      width: 60  },
                                    { id: "name",  label: "Name",    width: 160 },
                                    { id: "email", label: "Email",   width: 200 },
                                    { id: "role",  label: "Role",    width: 100 },
                                    { id: "score", label: "Score",   width: 80  },
                                ]
                                rowCount: 1000
                                getCellData: function(row, colId) {
                                    var names  = ["Alice","Bob","Carol","David","Eva","Frank","Grace","Henry"]
                                    var roles  = ["Admin","Editor","Viewer","Manager"]
                                    var name   = names[row % names.length] + " " + String.fromCharCode(65 + (row % 26))
                                    if (colId === "id")    return row + 1
                                    if (colId === "name")  return name
                                    if (colId === "email") return name.toLowerCase().replace(" ", ".") + "@example.com"
                                    if (colId === "role")  return roles[row % roles.length]
                                    if (colId === "score") return Math.round((Math.sin(row) + 1) * 50)
                                    return ""
                                }
                                sortColId: "name"
                                onHeaderClicked: (c) => toaster.show("Sort by " + c, Toaster.Type.Info, 600)
                                onRowClicked:    (r) => toaster.show("Row " + r, Toaster.Type.Info, 600)
                            }
    
                            // ── SpreadsheetGrid ───────────────────────────────────
                            Text { text: "SpreadsheetGrid"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            SpreadsheetGrid {
                                rowCount: 8; colCount: 6
                                cellValues: ({
                                    "0,0": "Product", "0,1": "Q1",    "0,2": "Q2",    "0,3": "Q3",    "0,4": "Q4",    "0,5": "Total",
                                    "1,0": "Widget A","1,1": "12400", "1,2": "15600", "1,3": "18200", "1,4": "21000", "1,5": "67200",
                                    "2,0": "Widget B","2,1": "8900",  "2,2": "9200",  "2,3": "11500", "2,4": "13800", "2,5": "43400",
                                    "3,0": "Widget C","3,1": "5400",  "3,2": "6100",  "3,3": "7300",  "3,4": "8900",  "3,5": "27700",
                                })
                                onCellEdited: (r, c, v) => toaster.show("[" + r + "," + c + "] = " + v, Toaster.Type.Info, 800)
                            }
    
                            // ── SchemaBrowser ──────────────────────────────────────
                            Text { text: "SchemaBrowser"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            SchemaBrowser {
                                width: 280; height: 320
                                databaseName: "myapp_production"
                                schemas: [
                                    { name: "public", tables: [
                                        { name: "users",   type: "table", columns: [
                                            { name: "id",       type: "INTEGER",  pk: true,  nullable: false },
                                            { name: "email",    type: "TEXT",     pk: false, nullable: false },
                                            { name: "name",     type: "TEXT",     pk: false, nullable: true  },
                                            { name: "created",  type: "DATETIME", pk: false, nullable: false },
                                        ]},
                                        { name: "posts",   type: "table", columns: [
                                            { name: "id",       type: "INTEGER",  pk: true,  nullable: false },
                                            { name: "user_id",  type: "INTEGER",  pk: false, nullable: false, fk: true },
                                            { name: "title",    type: "TEXT",     pk: false, nullable: false },
                                            { name: "body",     type: "TEXT",     pk: false, nullable: true  },
                                        ]},
                                        { name: "user_stats", type: "view", columns: [
                                            { name: "user_id",   type: "INTEGER" },
                                            { name: "post_count",type: "INTEGER" },
                                        ]},
                                    ]},
                                ]
                                onTableSelected:  (t) => toaster.show("Table: " + t, Toaster.Type.Info, 800)
                                onColumnClicked:  (t, c) => toaster.show(t + "." + c, Toaster.Type.Info, 800)
                            }
    
                            // ── KeyframeEditor ────────────────────────────────────
                            Text { text: "KeyframeEditor"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            KeyframeEditor {
                                width: parent.width - Theme.sp6 * 2; height: 200
                                duration: 8.0
                                tracks: [
                                    { label: "Position X", color: Theme.primary, keyframes: [
                                        { time: 0.0, value: 0.0 }, { time: 2.5, value: 100.0 },
                                        { time: 5.0, value: 250.0 }, { time: 8.0, value: 400.0 },
                                    ]},
                                    { label: "Opacity",    color: Theme.info, keyframes: [
                                        { time: 0.0, value: 1.0 }, { time: 3.0, value: 0.5 },
                                        { time: 6.0, value: 0.0 }, { time: 8.0, value: 1.0 },
                                    ]},
                                    { label: "Scale",      color: Theme.success, keyframes: [
                                        { time: 1.0, value: 1.0 }, { time: 4.0, value: 1.5 },
                                        { time: 7.0, value: 0.8 },
                                    ]},
                                ]
                            }
    
                            // ── NodeEditor ────────────────────────────────────────
                            Text { text: "NodeEditor"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            NodeEditor {
                                width: parent.width - Theme.sp6 * 2; height: 340
                                graphNodes: [
                                    { id: "n1", label: "Input",    x: 30,  y: 60,  color: Theme.info,
                                      inputs: [], outputs: [{label: "data"}] },
                                    { id: "n2", label: "Transform",x: 210, y: 30,  color: Theme.primary,
                                      inputs: [{label: "in"}], outputs: [{label: "out"}, {label: "err"}] },
                                    { id: "n3", label: "Filter",   x: 210, y: 160, color: Theme.warning,
                                      inputs: [{label: "data"}], outputs: [{label: "pass"}, {label: "fail"}] },
                                    { id: "n4", label: "Output",   x: 430, y: 80,  color: Theme.success,
                                      inputs: [{label: "a"}, {label: "b"}], outputs: [] },
                                ]
                                graphEdges: [
                                    { fromNode: "n1", fromPort: 0, toNode: "n2", toPort: 0 },
                                    { fromNode: "n1", fromPort: 0, toNode: "n3", toPort: 0 },
                                    { fromNode: "n2", fromPort: 0, toNode: "n4", toPort: 0 },
                                    { fromNode: "n3", fromPort: 0, toNode: "n4", toPort: 1 },
                                ]
                                onNodeSelected: (id) => toaster.show("Node: " + id, Toaster.Type.Info, 600)
                            }
    
                            // ── PrintPreview ──────────────────────────────────────
                            Text { text: "PrintPreview"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            PrintPreview {
                                width: parent.width - Theme.sp6 * 2; height: 360
                                pageCount: 3
                                previewScale: 0.6
    
                                Column {
                                    x: 40; y: 40; spacing: 16; width: 400
                                    Text { text: "Invoice #1042"; font.pixelSize: 24; font.weight: Font.Bold; color: "#1a1a2e" }
                                    Text { text: "Mahina Component Library Ltd."; font.pixelSize: 14; color: "#444" }
                                    Text { text: "Date: 2026-06-18"; font.pixelSize: 12; color: "#666" }
                                    Rectangle { width: 400; height: 1; color: "#ddd" }
                                    Text { text: "Description          Qty    Price"; font.pixelSize: 12; color: "#444"; font.family: "monospace" }
                                    Text { text: "Editors & Tools  25     $2,500"; font.pixelSize: 12; color: "#222"; font.family: "monospace" }
                                    Text { text: "Premium Support       1     $500";   font.pixelSize: 12; color: "#222"; font.family: "monospace" }
                                    Rectangle { width: 400; height: 1; color: "#ddd" }
                                    Text { text: "TOTAL: $3,000"; font.pixelSize: 16; font.weight: Font.Bold; color: "#1a1a2e" }
                                }
                            }
    
                            Item { height: Theme.sp8 }
                        }
                    }
                }

                // ── Page 18 — Odds & Ends ────────────────────────────────────────
                // Every component the other pages happen not to use. The demo is
                // what CI boots, so a component missing from it is a component
                // nothing checks — that is how TabView shipped unable to load.
                ScrollArea {
                    clip: true

                    Column {
                        id: _r11Col
                        width:   parent.width
                        padding: Theme.sp6
                        spacing: Theme.sp8

                        Text {
                            text: "Odds & Ends"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textXl
                            font.weight: Font.Bold
                        }

                        // ── Tabs, panels supplied as a list ─────────────────
                        // The form the retired TabView existed for: panels that
                        // already exist elsewhere, handed over as a list. Tabs
                        // reparents them into its StackLayout.
                        Text { text: "Tabs (panels as a list)"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Item {
                            id: _r11Pool
                            visible: false   // emptied at completion; keeps the Column from spacing it
                            Rectangle {
                                id: _r11PanelA
                                color: Theme.panel; radius: Theme.radiusMd
                                Text { anchors.centerIn: parent; text: "Overview panel"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            }
                            Rectangle {
                                id: _r11PanelB
                                color: Theme.panel; radius: Theme.radiusMd
                                Text { anchors.centerIn: parent; text: "Activity panel"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                            }
                        }
                        Tabs {
                            width:   parent.width - Theme.sp6 * 2
                            height:  160
                            model:   ["Overview", "Activity"]
                            content: [_r11PanelA, _r11PanelB]
                        }

                        // ── TabBar ──────────────────────────────────────────
                        Text { text: "TabBar"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        TabBar {
                            id:     _r11TabBar
                            width:  parent.width - Theme.sp6 * 2
                            model:  ["Inbox", "Drafts", "Sent"]
                            onTabClicked: (i) => _r11TabBar.currentIndex = i
                        }

                        // ── BarChart ────────────────────────────────────────
                        Text { text: "BarChart"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        BarChart {
                            width:  parent.width - Theme.sp6 * 2
                            height: 220
                            xLabels: ["Q1", "Q2", "Q3", "Q4", "Q5"]
                            series: [
                                { label: "Revenue",  color: Theme.primary, values: [10, 18, 14, 22, 28] },
                                { label: "Expenses", color: Theme.error,   values: [ 8, 10, 12, 11, 15] },
                            ]
                        }

                        // ── Radio ───────────────────────────────────────────
                        Text { text: "Radio"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp5
                            Radio { text: "Daily";   checked: true }
                            Radio { text: "Weekly" }
                            Radio { text: "Monthly"; errorText: "Not on your plan" }
                        }

                        // ── ListRow ─────────────────────────────────────────
                        Text { text: "ListRow"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Column {
                            width:   parent.width - Theme.sp6 * 2
                            spacing: 1

                            Repeater {
                                model: [
                                    { title: "alice@glow.dev", subtitle: "Admin · last seen 2h ago"    },
                                    { title: "bob@glow.dev",   subtitle: "Member · last seen 3d ago"   },
                                ]
                                delegate: ListRow {
                                    id: _r11Row
                                    required property var modelData
                                    // Local state rather than a toast: a delegate is its own
                                    // component, so reaching the page's toaster id from in here
                                    // would be an unqualified access the lint gate counts.
                                    property bool starred: false
                                    width:    parent.width
                                    title:    _r11Row.modelData.title
                                    subtitle: _r11Row.modelData.subtitle
                                    onClicked: _r11Row.starred = !_r11Row.starred
                                    Badge {
                                        text:        _r11Row.starred ? "starred" : "active"
                                        colorScheme: _r11Row.starred ? Badge.Color.Warning : Badge.Color.Success
                                    }
                                }
                            }
                        }

                        // ── SidebarSection / SidebarEntry ───────────────────
                        Text { text: "SidebarSection & SidebarEntry"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width:  320
                            height: _r11Side.implicitHeight + Theme.sp4
                            color:  Theme.panel
                            radius: Theme.radiusMd

                            Column {
                                id: _r11Side
                                anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.sp2 }

                                SidebarSection {
                                    width: parent.width
                                    title: "Connections"
                                    SidebarEntry { width: parent.width; label: "production"; detail: "12 ms";   severity: "success" }
                                    SidebarEntry { width: parent.width; label: "staging";    detail: "310 ms";  severity: "warning" }
                                    SidebarEntry { width: parent.width; label: "legacy";     detail: "timeout"; severity: "error"   }
                                }
                            }
                        }

                        // ── ExpandableLog ───────────────────────────────────
                        Text { text: "ExpandableLog"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        ExpandableLog {
                            width:  parent.width - Theme.sp6 * 2
                            height: 220
                            log: [
                                { id: 1, level: "info",  message: "Connected to production", timestamp: "10:02:11", tag: "db",   detail: "TLS 1.3 · pool size 8" },
                                { id: 2, level: "warn",  message: "Slow query: 1.4s",        timestamp: "10:02:40", tag: "db",   detail: "SELECT * FROM orders" },
                                { id: 3, level: "error", message: "Connection refused",      timestamp: "10:03:02", tag: "net",  detail: "ECONNREFUSED 10.0.0.4:5432" },
                            ]
                        }

                        // ── MarkdownView ────────────────────────────────────
                        Text { text: "MarkdownView"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        MarkdownView {
                            width: parent.width - Theme.sp6 * 2
                            text: "## Release notes\n\nMarkdownView renders **bold**, _italic_ and `code`, and only follows links whose scheme is allowed.\n\n- one\n- two\n"
                        }

                        // ── StickySection ───────────────────────────────────
                        Text { text: "StickySection"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Rectangle {
                            width:  parent.width - Theme.sp6 * 2
                            height: 200
                            color:  Theme.surface
                            radius: Theme.radiusMd
                            border.color: Theme.border; border.width: 1
                            clip:   true

                            Flickable {
                                id: _r11Flick
                                anchors { fill: parent; margins: 1 }
                                contentWidth:  width
                                contentHeight: _r11Months.implicitHeight

                                Column {
                                    id:    _r11Months
                                    width: parent.width

                                    // Written out rather than repeated: a StickySection needs the
                                    // Flickable's id, and a Repeater delegate is a separate
                                    // component that cannot see it without pragma
                                    // ComponentBehavior: Bound, which this file does not set.
                                    StickySection { width: parent.width; flickable: _r11Flick; label: "January" }
                                    Repeater { model: 4; delegate: _r11Entry }

                                    StickySection { width: parent.width; flickable: _r11Flick; label: "February" }
                                    Repeater { model: 4; delegate: _r11Entry }

                                    StickySection { width: parent.width; flickable: _r11Flick; label: "March" }
                                    Repeater { model: 4; delegate: _r11Entry }
                                }

                                Component {
                                    id: _r11Entry
                                    Text {
                                        required property int index
                                        leftPadding:   Theme.sp4
                                        topPadding:    Theme.sp2
                                        bottomPadding: Theme.sp2
                                        text:  "Entry " + (index + 1)
                                        color: Theme.textSecondary
                                        font.family:    Theme.fontFamily
                                        font.pixelSize: Theme.textSm
                                    }
                                }
                            }
                        }

                        // ── BlurOverlay ─────────────────────────────────────
                        Text { text: "BlurOverlay"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Rectangle {
                            id:     _r11Blurred
                            width:  parent.width - Theme.sp6 * 2
                            height: 140
                            radius: Theme.radiusMd
                            clip:   true
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Theme.primary }
                                GradientStop { position: 1.0; color: Theme.error }
                            }

                            BlurOverlay {
                                anchors { fill: parent; margins: Theme.sp6 }
                                source: _r11Blurred
                                Text {
                                    anchors.centerIn: parent
                                    text:  "Frosted panel"
                                    color: Theme.textPrimary
                                    font.family:    Theme.fontFamily
                                    font.pixelSize: Theme.textSm
                                }
                            }
                        }

                        // ── IrcPalette ──────────────────────────────────────
                        // A singleton, so it is exercised by reading it rather
                        // than by instantiating anything.
                        Text { text: "IrcPalette"; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textLg; font.weight: Theme.weightSemibold }
                        Row {
                            spacing: Theme.sp2
                            Repeater {
                                model: IrcPalette.mircColors.slice(0, 16)
                                delegate: Rectangle {
                                    required property color modelData
                                    width: 24; height: 24; radius: Theme.radiusSm
                                    color: modelData
                                    border.color: Theme.border; border.width: 1
                                }
                            }
                        }

                        Item { height: Theme.sp8 }
                    }
                }
            }
        }
    }

    // Social & Feedback — Command Menu overlay
    CommandMenu {
        id:           _r7Cmd
        anchors.fill: parent
        sections: [
            { heading: "Navigation",
              items: [
                { icon: Icons.house,     label: "Go to Components", shortcut: "G C", action: function() { _stack.currentIndex = 0 } },
                { icon: Icons.chat,      label: "Go to Social & Feedback", shortcut: "G 7", action: function() { _stack.currentIndex = 14 } },
                { icon: Icons.moonStars, label: "Toggle dark mode",  shortcut: "D",   action: function() { Theme.dark = !Theme.dark } },
              ]
            },
            { heading: "Actions",
              items: [
                { icon: Icons.bell,    label: "Show notification",  action: function() { toaster.show("Hello from CommandMenu!", Toaster.Type.Success, 2000) } },
                { icon: Icons.warning, label: "Show error toast",   action: function() { toaster.show("Something went wrong", Toaster.Type.Error, 2000) } },
              ]
            }
        ]
        onCommandRan: (label) => toaster.show("Ran: " + label, Toaster.Type.Info, 1000)
    }

    // Nav & Inputs — Confirm Dialogs
    ConfirmDialog {
        id:           _r9ConfirmDlg
        dialogTitle:  "Save changes?"
        dialogMessage: "Your unsaved changes will be lost if you leave without saving."
        confirmText:  "Save"
        onConfirmed:  toaster.show("Saved!", Toaster.Type.Success, 1500)
        onCancelled:  toaster.show("Discarded", Toaster.Type.Info, 1000)
    }
    ConfirmDialog {
        id:            _r9DestructDlg
        dialogTitle:   "Delete permanently?"
        dialogMessage: "This will delete all selected files and cannot be undone."
        confirmText:   "Delete"
        isDestructive: true
        dialogIcon:    "🗑"
        onConfirmed:   toaster.show("Deleted", Toaster.Type.Error, 1500)
        onCancelled:   toaster.show("Cancelled", Toaster.Type.Info, 1000)
    }

    // Social & Charts — Side Panel overlay
    SidePanel {
        id:           _r8SidePanel
        panelTitle:   "Settings Panel"
        panelWidth:   300
        onCloseRequested: panelOpen = false
        Column {
            width: parent.width
            padding: Theme.sp4
            spacing: Theme.sp3
            Text { text: "Panel Content"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textBase; font.weight: Font.DemiBold }
            Text {
                text: "This panel slides in from the right edge.\nResize it by dragging the left handle."
                color: Theme.textSecondary; font.family: Theme.fontFamily
                font.pixelSize: Theme.textSm; wrapMode: Text.Wrap
                width: parent.width - Theme.sp4 * 2
            }
        }
    }

    SplashScreen {
        id:       _splash
        anchors.fill: parent
        title:    "Mahina"; subtitle: "UI Component Library"; version:  "1.0.0"
        progress: 0; opacity: 0
        onDismissed: _splash.opacity = 0
    }

    Timer {
        id:       _splashTimer
        interval: 600; repeat: true
        property real stepProgress: 0
        onTriggered: {
            stepProgress += 0.25
            _splash.progress = Math.min(1.0, stepProgress)
            if (stepProgress >= 1.0) { stop(); stepProgress = 0 }
        }
    }

    // ── Global overlays ───────────────────────────────────────────────────────
    Toaster { id: toaster; anchors.fill: parent }

    AlertDialog {
        id:          _alert
        anchors.fill: parent
        title:       "Delete project?"
        message:     "This action is permanent. All associated data will be removed."
        confirmText: "Delete"
        danger:      true
        onConfirmed: toaster.show("Project deleted", Toaster.Type.Error)
        onCancelled: toaster.show("Cancelled", Toaster.Type.Info, 2000)
    }

    Drawer {
        id:           _drawer
        anchors.fill: parent
        title:        "Navigation"
        panelWidth:   260

        Column {
            anchors { fill: parent; margins: Theme.sp4 }
            spacing: Theme.sp2
            Repeater {
                model: ["Dashboard", "Projects", "Team", "Reports", "Settings"]
                delegate: Rectangle {
                    required property string modelData
                    required property int    index
                    width:  parent.width; height: 40; radius: Theme.radiusSm; color: "transparent"
                    Text { anchors { left: parent.left; leftMargin: Theme.sp3; verticalCenter: parent.verticalCenter }
                        text: modelData; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                }
            }
        }
    }

    CommandPalette {
        id:           _cmdPalette
        anchors.fill: parent
        model: [
            { label: "Toggle dark mode",  icon: Icons.moonStars,   shortcut: "D",    group: "Theme"    },
            { label: "Open drawer",       icon: Icons.sidebarSimple,                  group: "UI"       },
            { label: "Show alert dialog", icon: Icons.warning,                        group: "UI"       },
            { label: "Toast success",     icon: Icons.checkCircle,                    group: "Toast"    },
            { label: "Toast error",       icon: Icons.xCircle,                        group: "Toast"    },
            { label: "Go to Components",  icon: Icons.squaresFour,                    group: "Navigate" },
            { label: "Go to Forms",       icon: Icons.textT,                          group: "Navigate" },
            { label: "Go to Data",        icon: Icons.table,                          group: "Navigate" },
        ]
        onTriggered: (item) => {
            switch (item.label) {
                case "Toggle dark mode":  Theme.dark = !Theme.dark; break
                case "Open drawer":       _drawer.open(); break
                case "Show alert dialog": _alert.open();  break
                case "Toast success":     toaster.show("Success!", Toaster.Type.Success); break
                case "Toast error":       toaster.show("An error occurred", Toaster.Type.Error); break
                case "Go to Components":  _stack.currentIndex = 0; break
                case "Go to Forms":       _stack.currentIndex = 4; break
                case "Go to Data":        _stack.currentIndex = 5; break
            }
        }
    }

    Shortcut { sequence: "Ctrl+K"; onActivated: _cmdPalette.open() }

    BottomSheet {
        id:    _bottomSheet
        title: "Share project"

        Column {
            width:   parent.width
            spacing: Theme.sp2

            Repeater {
                model: [
                    { label: "Copy link",     icon: Icons.link      },
                    { label: "Send via email",icon: Icons.envelope   },
                    { label: "Export as PDF", icon: Icons.filePdf   },
                ]
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: parent.width; height: 48; radius: Theme.radiusSm; color: _bsH.containsMouse ? Theme.panel : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    HoverHandler { id: _bsH }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { _bottomSheet.close(); toaster.show(modelData.label, Toaster.Type.Info, 2000) } }
                    Row {
                        anchors { fill: parent; leftMargin: Theme.sp4 }
                        spacing: Theme.sp3
                        Icon { name: modelData.icon; size: 18; color: Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter }
                        Text { anchors.verticalCenter: parent.verticalCenter; text: modelData.label; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm }
                    }
                }
            }
        }
    }

    Sheet {
        id:    _sheet
        title: "Component Details"

        ColumnLayout {
            width:   parent.width
            spacing: Theme.sp4
            DataList {
                width: parent.width
                model: [
                    { label: "Component", value: "Sheet"            },
                    { label: "Type",      value: "Overlay"          },
                    { label: "Backdrop",  value: "None"             },
                    { label: "Side",      value: "Right"            },
                ]
            }
            Text { text: "A Sheet slides in from the side without dimming the background, keeping main content visible and interactive."; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.textSm; wrapMode: Text.WordWrap; width: parent.width }
        }
    }

    Tour {
        id:    _tour
        steps: [
            { target: null, title: "Welcome to Mahina",  body: "This is a quick tour of the UI kit. Use Next to continue or Skip to exit." },
            { target: null, title: "52 Components",    body: "Mahina ships with buttons, inputs, overlays, data displays, and much more." },
            { target: null, title: "Dark mode",        body: "Press D at any time or click the toggle in the nav bar to switch themes." },
            { target: null, title: "Command Palette",  body: "Press Ctrl+K to open the command palette and jump anywhere instantly." },
            { target: null, title: "All done!",        body: "Explore the sidebar to see every component in action. Happy building!" },
        ]
        onFinished: toaster.show("Tour complete!", Toaster.Type.Success, 3000)
    }
}
