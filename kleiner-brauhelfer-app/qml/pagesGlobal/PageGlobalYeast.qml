import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../common"
import brauhelfer 1.0
import SortFilterProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Rohstoff Hefe")
    icon: "yeast.png"

    component: ListView {
        id: listView
        clip: true
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: SortFilterProxyModel {
            sourceModel: Brauhelfer.modelHefe
            filterKeyColumn: sourceModel.fieldIndex("Menge")
            filterRegExp: app.settings.ingredientsFilter === 0 ? /(?:)/ : /[^0]+/
        }
        headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
        ScrollIndicator.vertical: ScrollIndicator {}
        header: Rectangle {
            z: 2
            width: parent.width
            height: header.height
            color: Material.background
            ColumnLayout {
                id: header
                width: parent.width
                RowLayout {
                    Layout.fillWidth: true
                    LabelPrim {
                        Layout.fillWidth: true
                        leftPadding: 8
                        font.bold: true
                        text: qsTr("Beschreibung")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        rightPadding: 8
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                        text: qsTr("Menge")
                    }
                }
                HorizontalDivider {}
            }
        }
        footerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackFooter : ListView.OverlayFooter
        footer: Rectangle {
            z: 2
            width: parent.width
            height: btnAdd.height + 12
            color: Material.background
            Flow {
                width: parent.width
                RadioButton {
                    checked: app.settings.ingredientsFilter === 0
                    text: qsTr("alle")
                    onClicked: app.settings.ingredientsFilter = 0
                }
                RadioButton {
                    checked: app.settings.ingredientsFilter === 1
                    text: qsTr("vorhanden")
                    onClicked: app.settings.ingredientsFilter = 1
                }
            }
        }
        delegate: ItemDelegate {
            id: rowDelegate
            width: parent.width
            height: dataColumn.implicitHeight
            padding: 0
            text: " "
            onClicked: {
                listView.currentIndex = index
                popuploader.active = true
            }

            NumberAnimation {
                id: removeFake
                target: rowDelegate
                property: "height"
                to: 0
                easing.type: Easing.InOutQuad
                onStopped: rowDelegate.visible = false
            }

            function remove() {
                removeFake.start()
                listView.model.sourceModel.remove(index)
            }

            ColumnLayout {
                id: dataColumn
                parent: rowDelegate.contentItem
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                RowLayout {
                    Layout.fillWidth: true
                    LabelPrim {
                        Layout.fillWidth: true
                        leftPadding: 8
                        opacity: model.Menge > 0 ? app.config.textOpacityFull : app.config.textOpacityHalf
                        text: model.Beschreibung
                    }
                    LabelNumber {
                        Layout.fillWidth: true
                        rightPadding: 8
                        horizontalAlignment: Text.AlignRight
                        opacity: model.Menge > 0 ? app.config.textOpacityFull : app.config.textOpacityHalf
                        precision: 0
                        value: model.Menge
                    }
                }
                HorizontalDivider {}
            }
        }

        Loader {
            id: popuploader
            active: false
            onLoaded: item.open()
            sourceComponent: PopupBase {
                onClosed: popuploader.active = false

                function remove() {
                    listView.currentItem.remove()
                    close()
                }

                SwipeView {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    spacing: 16
                    height: contentChildren[currentIndex].implicitHeight
                    clip: true
                    currentIndex: listView.currentIndex
                    Repeater {
                        model: listView.model
                        Loader {
                            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                            sourceComponent: Item {
                                property variant _model: model
                                implicitHeight: layout.height
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: 0
                                    onClicked: forceActiveFocus()
                                }
                                GridLayout {
                                    id: layout
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    columns: 3
                                    columnSpacing: 0
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.columnSpan: 3

                                        Item {
                                            width: btnRemove.width
                                        }

                                        Item {
                                            property bool editing: false
                                            id: itBeschreibung
                                            Layout.fillWidth: true
                                            height: children[1].height
                                            LabelSubheader {
                                                anchors.fill: parent
                                                visible: !itBeschreibung.editing
                                                text: model.Beschreibung
                                                horizontalAlignment: Text.AlignHCenter
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: itBeschreibung.editing = true
                                                }
                                            }
                                            TextField {
                                                anchors.fill: parent
                                                visible: itBeschreibung.editing
                                                horizontalAlignment: Text.AlignHCenter
                                                text: model.Beschreibung
                                                onTextChanged: if (activeFocus) model.Beschreibung = text
                                                onEditingFinished: itBeschreibung.editing = false
                                                onVisibleChanged: if (visible) forceActiveFocus()
                                            }

                                            Component.onCompleted: if (model.Beschreibung === "") editing = true
                                        }

                                        ToolButton {
                                            id: btnRemove
                                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                            onClicked: remove()
                                            contentItem: Image {
                                                source: "qrc:/images/ic_delete.png"
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Menge")
                                        font.weight: Font.DemiBold
                                    }

                                    SpinBoxReal {
                                        Layout.fillWidth: true
                                        decimals: 0
                                        realValue: model.Menge
                                        onRealValueChanged: model.Menge = realValue
                                    }

                                    LabelUnit {
                                        text: ""
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Würzemenge")
                                        font.weight: Font.DemiBold
                                    }

                                    SpinBoxReal {
                                        Layout.fillWidth: true
                                        decimals: 0
                                        realValue: model.Wuerzemenge
                                        onRealValueChanged: model.Wuerzemenge = realValue
                                    }

                                    LabelUnit {
                                        text: qsTr("Liter")
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("OG / UG")
                                        font.weight: Font.DemiBold
                                    }

                                    ComboBox {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        Layout.rightMargin: 4
                                        model: [ "", qsTr("obergärig"), qsTr("untergärig")]
                                        currentIndex: _model.TypOGUG
                                        onActivated: _model.TypOGUG = index
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Trocken / flüssig")
                                        font.weight: Font.DemiBold
                                    }

                                    ComboBox {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        Layout.rightMargin: 4
                                        model: [ "", qsTr("trocken"), qsTr("flüssig")]
                                        currentIndex: _model.TypTrFl
                                        onActivated: _model.TypTrFl = index
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Verpackung")
                                        font.weight: Font.DemiBold
                                    }

                                    TextField {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        text: model.Verpackungsmenge
                                        onTextChanged: if (activeFocus) model.Verpackungsmenge = text
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Sedimentation")
                                        font.weight: Font.DemiBold
                                    }

                                    ComboBox {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        Layout.rightMargin: 4
                                        model: [ "", qsTr("hoch"), qsTr("mittel"), qsTr("niedrig")]
                                        currentIndex: _model.SED
                                        onActivated: _model.SED = index
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Vergärungsgrad")
                                        font.weight: Font.DemiBold
                                    }

                                    TextField {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        text: model.EVG
                                        onTextChanged: if (activeFocus) model.EVG = text
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Temperatur")
                                        font.weight: Font.DemiBold
                                    }

                                    TextField {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        text: model.Temperatur
                                        onTextChanged: if (activeFocus) model.Temperatur = text
                                    }

                                    LabelPrim {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                        rightPadding: 8
                                        text: qsTr("Eigenschaften")
                                        font.weight: Font.DemiBold
                                    }

                                    TextArea {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                        wrapMode: TextArea.Wrap
                                        placeholderText: qsTr("Eigenschaften")
                                        text: model.Eigenschaften
                                        onTextChanged: if (activeFocus) model.Eigenschaften = text
                                    }

                                    LabelPrim {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                        rightPadding: 8
                                        text: qsTr("Bemerkung")
                                        font.weight: Font.DemiBold
                                    }

                                    TextArea {
                                        Layout.columnSpan: 3
                                        Layout.fillWidth: true
                                        wrapMode: TextArea.Wrap
                                        placeholderText: qsTr("Bemerkung")
                                        text: model.Bemerkung
                                        onTextChanged: if (activeFocus) model.Bemerkung = text
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Preis")
                                        font.weight: Font.DemiBold
                                    }

                                    SpinBoxReal {
                                        Layout.fillWidth: true
                                        decimals: 2
                                        realValue: model.Preis
                                        onRealValueChanged: model.Preis = realValue
                                    }

                                    LabelUnit {
                                        text: Qt.locale().currencySymbol() + "/" + qsTr("kg")
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Eingelagert")
                                        font.weight: Font.DemiBold
                                    }

                                    TextFieldDate {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        date: model.Eingelagert
                                        onNewDate: model.Eingelagert = date
                                    }

                                    LabelPrim {
                                        rightPadding: 8
                                        text: qsTr("Haltbar")
                                        font.weight: Font.DemiBold
                                    }

                                    TextFieldDate {
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        date: model.Mindesthaltbar
                                        onNewDate: model.Mindesthaltbar = date
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        FloatingButton {
            id: btnAdd
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: listView.bottom
            anchors.bottomMargin: 8
            imageSource: "qrc:/images/ic_add_white.png"
            visible: !page.readOnly
            onClicked: {
                listView.model.sourceModel.append()
                listView.currentIndex = listView.count - 1
                popuploader.active = true
            }
        }
    }
}
