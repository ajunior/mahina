import QtQuick
import Mahina

// Full-page loading skeleton layout. Hides when loading = false.
//
// Usage:
//   SkeletonPage { loading: _vm.isLoading }
Item {
    id: root

    property bool loading: true

    visible:  loading
    implicitWidth:  600
    implicitHeight: 500

    // Top nav bar skeleton
    Rectangle {
        id:     _nav
        width:  parent.width
        height: 56
        color:  Theme.panel

        Row {
            anchors { fill: parent; leftMargin: Theme.sp5; rightMargin: Theme.sp5 }
            spacing: Theme.sp3

            Skeleton { width: 28; height: 28; anchors.verticalCenter: parent.verticalCenter }
            Skeleton { width: 80; height: 16; anchors.verticalCenter: parent.verticalCenter }
            Item { width: 1; height: 1 }
            Skeleton { width: 120; height: 28; anchors.verticalCenter: parent.verticalCenter }
            Skeleton { width: 28; height: 28; shape: Skeleton.Shape.Circle; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    Row {
        anchors { left: parent.left; right: parent.right; top: _nav.bottom; bottom: parent.bottom }

        // Sidebar skeleton
        Column {
            id:      _sidebar
            width:   180
            height:  parent.height
            padding: Theme.sp3
            spacing: Theme.sp2

            Rectangle { width: parent.width - Theme.sp3*2; height: 1; color: Theme.border }

            Repeater {
                model: 8
                delegate: Row {
                    id: _rq1
                    required property int index
                    spacing: Theme.sp3
                    padding: Theme.sp2
                    Skeleton { width: 18; height: 18; anchors.verticalCenter: parent.verticalCenter }
                    Skeleton { width: 60 + (_rq1.index % 3) * 20; height: 13; anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }

        Rectangle { width: 1; height: parent.height; color: Theme.border }

        // Main content skeleton
        Column {
            width:   parent.width - _sidebar.width - 1
            padding: Theme.sp6
            spacing: Theme.sp5

            // Page title
            Skeleton { width: 200; height: 24 }

            // Stats row
            Row {
                spacing: Theme.sp4
                Repeater {
                    model: 3
                    delegate: Rectangle {
                        id: _rq2
                        required property int index
                        width: 140; height: 80; radius: Theme.radiusMd; color: Theme.panel
                        Column {
                            anchors { fill: parent; margins: Theme.sp4 }
                            spacing: Theme.sp3
                            Skeleton { width: 60;              height: 12 }
                            Skeleton { width: 80 + _rq2.index * 10; height: 28 }
                        }
                    }
                }
            }

            // Content card
            Rectangle {
                width: parent.width - Theme.sp6 * 2; height: 180; radius: Theme.radiusMd; color: Theme.panel
                Column {
                    anchors { fill: parent; margins: Theme.sp4 }
                    spacing: Theme.sp3
                    Skeleton { width: parent.width * 0.4;  height: 16 }
                    Skeleton { width: parent.width * 0.9;  height: 12 }
                    Skeleton { width: parent.width * 0.75; height: 12 }
                    Skeleton { width: parent.width * 0.85; height: 12 }
                    Item { height: Theme.sp2 }
                    Skeleton { width: parent.width; height: 60 }
                }
            }

            // List rows
            Repeater {
                model: 4
                delegate: Rectangle {
                    id: _rq3
                    required property int index
                    width: parent.width - Theme.sp6 * 2; height: 44; radius: Theme.radiusSm; color: Theme.panel
                    Row {
                        anchors { fill: parent; leftMargin: Theme.sp4; rightMargin: Theme.sp4 }
                        spacing: Theme.sp3
                        Skeleton { width: 28; height: 28; shape: Skeleton.Shape.Circle; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6
                            Skeleton { width: 100 + _rq3.index * 20; height: 12 }
                            Skeleton { width: 60 + _rq3.index * 10;  height: 10 }
                        }
                    }
                }
            }
        }
    }
}
