pragma ComponentBehavior: Bound
import QtQuick
import Mahina

// Emoji picker with categories and search.
//
// Usage:
//   EmojiPicker { onEmojiSelected: (e) => input.insert(input.cursorPosition, e) }
Item {
    id: root

    signal emojiSelected(string emoji)

    implicitWidth:  300
    implicitHeight: 320

    property string searchText: ""
    property int    activeCategory: 0

    readonly property var categories: [
        {
            label: "😀", title: "Smileys",
            emojis: ["😀","😃","😄","😁","😆","😅","🤣","😂","🙂","🙃","😉","😊","😇","🥰","😍","🤩","😘","😗","😚","😙","😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔","🤐","🤨","😐","😑","😶","😏","😒","🙄","😬","🤥","😌","😔","😪","🤤","😴","😷","🤒","🤕","🤢","🤮","🤧","🥵","🥶","😵","🤯","🤠","🥳","😎","🤓","🧐","😕","😟","🙁","☹️","😮","😯","😲","😳","🥺","😦","😧","😨","😰","😥","😢","😭","😱","😖","😣","😞","😓","😩","😫","🥱","😤","😡","😠","🤬","😈","👿","💀","☠️","💩","🤡","👹","👺","👻","👽","👾","🤖"]
        },
        {
            label: "👍", title: "Gestures",
            emojis: ["👋","🤚","🖐️","✋","🖖","👌","🤌","🤏","✌️","🤞","🤟","🤘","🤙","👈","👉","👆","🖕","👇","☝️","👍","👎","✊","👊","🤛","🤜","👏","🙌","👐","🤲","🤝","🙏","✍️","💅","🤳","💪","🦾","🦵","🦶","👂","🦻","👃","🧠","🫀","🫁","🦷","🦴","👀","👁️","👅","👄","👶","🧒","👦","👧","🧑","👱","👨","🧔","👩","👴","👵","🧓","👲","👳"]
        },
        {
            label: "❤️", title: "Hearts",
            emojis: ["❤️","🧡","💛","💚","💙","💜","🖤","🤍","🤎","💔","❤️‍🔥","❤️‍🩹","❣️","💕","💞","💓","💗","💖","💘","💝","💟","☮️","✝️","☪️","🕉️","☸️","✡️","🔯","🕎","☯️","☦️","🛐","⛎","♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓","🆔","⚛️","🉑","☢️","☣️","📴","📳"]
        },
        {
            label: "🌿", title: "Nature",
            emojis: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🙈","🙉","🙊","🐔","🐧","🐦","🐤","🦆","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🐝","🪱","🐛","🦋","🐌","🐞","🐜","🪲","🦟","🦗","🪳","🦂","🐢","🐍","🦎","🦖","🦕","🐙","🦑","🦐","🦞","🦀","🪸","🐡","🐠","🐟","🐬","🐳","🐋","🦈","🪼","🐊","🐅","🐆","🦓","🦍","🦧","🦣","🐘","🦛","🦏","🐪","🐫","🦒","🦘","🦬","🐃","🐂","🐄","🐎","🐖","🐏","🐑","🦙","🐐","🦌","🐕","🐩","🦮","🐕‍🦺","🐈","🐈‍⬛","🪶","🐓","🦃","🦤","🦚","🦜","🦢","🦩","🕊️","🐇","🦝","🦨","🦡","🦫","🦦","🦥","🐁","🐀","🐿️","🦔","🌵","🎄","🌲","🌳","🌴","🌱","🌿","☘️","🍀","🎍","🎋","🍃","🍂","🍁","🍄","🐚","🪸","🌾","💐","🌷","🌹","🥀","🌺","🌸","🌼","🌻","🌞","🌝","🌛","🌜","🌚","🌕","🌖","🌗","🌘","🌑","🌒","🌓","🌔","🌙","🌟","⭐","🌠","🌌","☀️","🌤️","⛅","🌥️","🌦️","🌧️","⛈️","🌩️","🌨️","❄️","☃️","⛄","🌬️","💨","💧","💦","🌊","🌈","☂️","☔"]
        },
        {
            label: "🍕", title: "Food",
            emojis: ["🍏","🍎","🍐","🍊","🍋","🍌","🍉","🍇","🍓","🫐","🍈","🍒","🍑","🥭","🍍","🥥","🥝","🍅","🍆","🥑","🥦","🥬","🥒","🌶️","🫑","🥕","🧄","🧅","🥔","🍠","🥐","🥯","🍞","🥖","🥨","🧀","🥚","🍳","🧈","🥞","🧇","🥓","🥩","🍗","🍖","🌭","🍔","🍟","🍕","🫓","🥪","🥙","🧆","🌮","🌯","🫔","🥗","🥘","🫕","🥫","🍝","🍜","🍲","🍛","🍣","🍱","🥟","🦪","🍤","🍙","🍚","🍘","🍥","🥮","🍢","🧁","🍰","🎂","🍮","🍭","🍬","🍫","🍿","🍩","🍪","🌰","🥜","🍯","🧃","🥤","🧋","🍵","☕","🫖","🍺","🍻","🥂","🍷","🫗","🥃","🍸","🍹","🧉","🍾","🧊","🥄","🍴","🍽️"]
        },
        {
            label: "⚽", title: "Activities",
            emojis: ["⚽","🏀","🏈","⚾","🥎","🎾","🏐","🏉","🥏","🎱","🪀","🏓","🏸","🏒","🏑","🥍","🏏","🪃","🥅","⛳","🪁","🎣","🤿","🎽","🎿","🛷","🥌","🎯","🪃","🎱","🎮","🕹️","🎲","🧩","🧸","🪆","♟️","🀄","🎭","🎨","🧵","🧶","🎼","🎤","🎧","🎷","🪗","🎸","🎹","🎺","🎻","🥁","🪘","🎬","🎥","📽️","🎞️","📹","📷","📸","📡","🔭","🔬","🧬","🧫","🧪","🧲","💡","🔦","🕯️","🪔"]
        },
        {
            label: "✈️", title: "Travel",
            emojis: ["🚗","🚕","🚙","🚌","🚎","🏎️","🚓","🚑","🚒","🚐","🛻","🚚","🚛","🚜","🏍️","🛵","🛺","🚲","🛴","🛹","🛼","🚏","🛣️","🛤️","⛽","🚧","🚦","🚥","🛞","⚓","🛟","⛵","🛶","🚤","🛥️","🛳️","⛴️","🚢","✈️","🛩️","🛫","🛬","🪂","💺","🚁","🛸","🚀","🛰️","🪐","🌍","🌎","🌏","🌐","🗺️","🧭","🗼","🗽","🗾","🎌","⛩️","🌁","🌃","🌄","🌅","🌆","🌇","🌉","🌌","🎑","🏞️","🎠","🎡","🎢","💈","🎪","🏟️","🏛️","🏗️","🏘️","🏚️","🏠","🏡","🏢","🏣","🏤","🏥","🏦","🏨","🏩","🏪","🏫","🏭","🏯","🏰","💒","⛪","🕌","🛕","🕍","⛩️"]
        },
        {
            label: "💡", title: "Objects",
            emojis: ["⌚","📱","💻","⌨️","🖥️","🖨️","🖱️","🖲️","🕹️","💾","💿","📀","📼","📷","📸","📹","🎥","📽️","🎞️","📞","☎️","📟","📠","📺","📻","🧭","⏱️","⏲️","⏰","🕰️","⌛","⏳","📡","🔋","🪫","🔌","💡","🔦","🕯️","🪔","🧯","🛢️","💵","💴","💶","💷","💸","💳","🪙","💹","📈","📉","📊","📋","📁","📂","🗂️","📅","📆","🗒️","🗓️","📇","📌","📍","🗺️","📏","📐","✂️","🗃️","🗄️","🗑️","🔒","🔓","🔏","🔐","🔑","🗝️","🔨","🪓","⛏️","⚒️","🛠️","🗡️","⚔️","🛡️","🪚","🔧","🪛","🔩","⚙️","🗜️","⚖️","🪝","🔗","⛓️","🪤","🧲","🔫","💣","🪃","🏹","🛡️","🪬","🪄","🔮","🪩","🔭","🔬","🩺","💊","🩹","🩼","🪜","🧲"]
        },
    ]

    readonly property var filteredEmojis: {
        var q = searchText.toLowerCase()
        if (q === "") return activeCategory < categories.length ? categories[activeCategory].emojis : []
        var result = []
        for (var ci = 0; ci < categories.length; ci++) {
            var emojis = categories[ci].emojis
            for (var ei = 0; ei < emojis.length; ei++) result.push(emojis[ei])
        }
        return result
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // Search bar
        Rectangle {
            width:  parent.width
            height: 40
            color:  Theme.panel
            border.color: Theme.border; border.width: 0

            Row {
                anchors { fill: parent; margins: Theme.sp2 }
                spacing: Theme.sp2

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:  "🔍"
                    font.pixelSize: 14
                }

                TextInput {
                    id:    _search
                    width: parent.width - 28 - Theme.sp2
                    anchors.verticalCenter: parent.verticalCenter
                    color:          Theme.textPrimary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.textSm
                    onTextChanged:  root.searchText = text
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        // Category tabs (hidden when searching)
        Row {
            id:      _cats
            width:   parent.width
            height:  root.searchText === "" ? 36 : 0
            visible: root.searchText === ""
            clip:    true

            Repeater {
                model: root.categories
                delegate: Rectangle {
                    id: _rq1
                    required property var modelData
                    required property int index
                    width:  root.width / root.categories.length
                    height: 36
                    color:  index === root.activeCategory ? Theme.surface : "transparent"
                    border.color: index === root.activeCategory ? Theme.border : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: _rq1.modelData.label
                        font.pixelSize: 16
                    }
                    MouseArea {
                        anchors.fill:  parent
                        cursorShape:   Qt.PointingHandCursor
                        onClicked:     root.activeCategory = _rq1.index
                    }
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border; visible: root.searchText === "" }

        // Emoji grid
        Rectangle {
            width:  parent.width
            height: root.height - 40 - (root.searchText === "" ? 37 : 0)
            color:  Theme.surface

            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: _emojiGrid.implicitHeight + Theme.sp2 * 2
                clip: true

                Grid {
                    id:       _emojiGrid
                    x:        Theme.sp2; y: Theme.sp2
                    width:    parent.width - Theme.sp2 * 2
                    columns:  8
                    spacing:  2

                    Repeater {
                        model: root.filteredEmojis
                        delegate: Rectangle {
                            id: _rq2
                            required property string modelData
                            width:  (root.width - Theme.sp2 * 2) / 8
                            height: width
                            radius: Theme.radiusSm
                            color:  _eH.hovered ? Theme.panel : "transparent"
                            HoverHandler { id: _eH }

                            Text {
                                anchors.centerIn: parent
                                text:  _rq2.modelData
                                font.pixelSize: 20
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    root.emojiSelected(_rq2.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
