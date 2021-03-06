import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtCharts 2.2
import QtQuick.Dialogs 1.3

import "../common"
import brauhelfer 1.0
import ProxyModel 1.0

PageBase {
    id: page
    title: qsTr("Hauptgärung")
    icon: "hauptgaerung.png"
    readOnly: Brauhelfer.readonly || ((!Brauhelfer.sud.BierWurdeGebraut || Brauhelfer.sud.BierWurdeAbgefuellt) && !app.brewForceEditable)

    ColumnLayout {
        property alias listView: listView
        anchors.fill: parent

        Chart {
            id: chart
            Layout.fillWidth: true
            Layout.fillHeight: true
            title1: qsTr("Alkohol")
            color1: "#741EA6"
            title2: qsTr("Extrakt")
            color2: "#2E4402"
            should2: Brauhelfer.sud.SchnellgaerprobeAktiv ? Brauhelfer.sud.Gruenschlauchzeitpunkt : null
            title3: qsTr("Temp")
            color3: "#780000"
            legend.visible: false
            VXYModelMapper {
                model: listView.model
                series: chart.series1
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Alc")
            }
            VXYModelMapper {
                model: listView.model
                series: chart.series2
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("SW")
            }
            VXYModelMapper {
                model: listView.model
                series: chart.series3
                xColumn: model.fieldIndex("Zeitstempel")
                yColumn: model.fieldIndex("Temp")
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.OvershootBounds
            model: Brauhelfer.sud.modelHauptgaerverlauf
            headerPositioning: listView.height < app.config.headerFooterPositioningThresh ? ListView.PullBackHeader : ListView.OverlayHeader
            Component.onCompleted: if (!readOnly) positionViewAtEnd()
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
                            text: qsTr("Datum")
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title2
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title3
                        }
                        LabelPrim {
                            Layout.preferredWidth: 70
                            font.bold: true
                            text: chart.title1
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                        height: 2
                    }
                }
            }

            footerPositioning: ListView.InlineFooter
            footer: Item {
                height: !page.readOnly ? btnAdd.height + 12 : 0
            }

            delegate: ItemDelegate {
                property variant values: model
                id: rowDelegate
                width: parent.width
                height: dataColumn.implicitHeight
                padding: 0
                visible: !model.deleted
                text: " "

                NumberAnimation {
                    id: removeFake
                    target: rowDelegate
                    property: "height"
                    to: 0
                    easing.type: Easing.InOutQuad
                    onStopped: rowDelegate.visible = false
                }

                onClicked: {
                    listView.currentIndex = index
                    if (!page.readOnly)
                        popuploader.active = true
                }

                function remove() {
                    removeFake.start()
                    chart.removeFake(index)
                    listView.model.removeRow(index)
                }

                ColumnLayout {
                    id: dataColumn
                    parent: rowDelegate.contentItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                        LabelDateTime {
                            Layout.fillWidth: true
                            leftPadding: 8
                            date: Zeitstempel
                        }
                        LabelPlato {
                            Layout.preferredWidth: 70
                            unit: "°P"
                            value: model.SW
                            color: chart.color2
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: "°C"
                            value: model.Temp
                            color: chart.color3
                        }
                        LabelNumber {
                            Layout.preferredWidth: 70
                            precision: 1
                            unit: "%"
                            value: model.Alc
                            color: chart.color1
                        }
                    }
                    HorizontalDivider {
                        Layout.fillWidth: true
                    }
                }
            }

            FloatingButton {
                id: btnAdd
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                imageSource: "qrc:/images/ic_add_white.png"
                visible: !page.readOnly
                onClicked: {
                    listView.model.append({"SudID": Brauhelfer.sud.id})
                    listView.currentIndex = listView.count - 1
                    popuploader.active = true
                }
            }
        }

        HorizontalDivider {
            Layout.fillWidth: true
            visible: listViewWeitereZutaten.count > 0
        }
        LabelSubheader {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            visible: listViewWeitereZutaten.count > 0
            text: qsTr("Weitere Zutaten")
        }
        ListView {
            id: listViewWeitereZutaten
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            height: Math.min(contentHeight, 80)
            clip: true
            boundsBehavior: Flickable.OvershootBounds
            ScrollIndicator.vertical: ScrollIndicator {}
            model: ProxyModel {
                sourceModel: Brauhelfer.sud.modelWeitereZutatenGaben
                filterKeyColumn: fieldIndex("Zeitpunkt")
                filterRegExp: /0/
            }
            delegate: ItemDelegate {
                width: parent.width
                height: dataColumn2.implicitHeight
                enabled: !page.readOnly && Brauhelfer.sud.BierWurdeGebraut
                onClicked: {
                    listViewWeitereZutaten.currentIndex = index
                    popuploaderWeitereZutaten.active = true
                }
                ColumnLayout {
                    id: dataColumn2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    RowLayout {
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                        Layout.fillWidth: true
                        LabelPrim {
                            Layout.fillWidth: true
                            text: model.Name
                        }
                        LabelPrim {
                            text: {
                                switch (model.Zugabestatus)
                                {
                                case 0: return qsTr("nicht zugegeben")
                                case 1: return model.Entnahmeindex === 0 ? qsTr("zugegeben seit") : qsTr("zugegeben")
                                case 2: return qsTr("entnommen nach")
                                default: return ""
                                }
                            }
                        }
                        LabelNumber {
                            visible: model.Zugabestatus > 0 && model.Entnahmeindex === 0
                            precision: 0
                            value: {
                                switch (model.Zugabestatus)
                                {
                                case 1: return (new Date().getTime() - model.Zeitpunkt_von.getTime()) / 1440 / 60000
                                case 2: return model.Zugabedauer/ 1440
                                default: return 0.0
                                }
                            }
                            unit: qsTr("Tage")
                        }
                    }
                }
            }

            Loader {
                id: popuploaderWeitereZutaten
                active: false
                onLoaded: item.open()
                sourceComponent: PopupWeitereZutatenGaben {
                    model: listViewWeitereZutaten.model
                    currentIndex: listViewWeitereZutaten.currentIndex
                    onClosed: popuploaderWeitereZutaten.active = false
                }
            }
        }

        Loader {
            id: popuploader
            active: false
            focus: true
            onLoaded: item.open()
            sourceComponent: PopupBase {
                property variant model: listView.currentItem.values
                maxWidth: 240
                y: page.height * 0.1
                onOpened: tfSW.forceActiveFocus()
                onClosed: popuploader.active = false

                function remove() {
                    listView.currentItem.remove()
                    close()
                }

                GridLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    columns: 3
                    columnSpacing: 16

                    Image {
                        source: "qrc:/images/baseline_date_range.png"
                    }

                    TextFieldDate {
                        id: tfDate
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        date: model.Zeitstempel
                        onNewDate: model.Zeitstempel = date
                    }

                    Image {
                        source: "qrc:/images/refractometer.png"
                    }

                    TextFieldPlato {
                        id: tfBrix
                        Layout.alignment: Qt.AlignHCenter
                        onNewValue: {
                            this.value = value
                            var brix = value
                            if (!isNaN(brix)) {
                                var density = Brauhelfer.calc.brixToDichte(Brauhelfer.sud.SWIst, brix)
                                var sre = Brauhelfer.calc.dichteToPlato(density)
                                tfDensity.value = density
                                model.SW = sre
                            }
                            else {
                                tfDensity.value = NaN
                                model.SW = NaN
                            }
                        }
                    }

                    LabelUnit {
                        text: qsTr("°Brix")
                    }

                    Image {
                        source: "qrc:/images/spindel.png"
                    }

                    TextFieldNumber {
                        id: tfDensity
                        Layout.alignment: Qt.AlignHCenter
                        min: 0.0
                        max: 2.0
                        precision: 4
                        value: Brauhelfer.calc.platoToDichte(model.SW)
                        onNewValue: {
                            this.value = value
                            var density = value
                            if (!isNaN(density)) {
                                model.SW = Brauhelfer.calc.dichteToPlato(density)
                            }
                            else {
                                model.SW = NaN
                            }
                            tfBrix.value = NaN
                        }
                    }

                    LabelUnit {
                        text: qsTr("g/ml")
                    }

                    Image {
                        source: "qrc:/images/sugar.png"
                    }

                    TextFieldPlato {
                        id: tfSW
                        Layout.alignment: Qt.AlignHCenter
                        value: model.SW
                        onNewValue: {
                            model.SW = value
                            var sre = value
                            if (!isNaN(sre)) {
                                tfDensity.value = Brauhelfer.calc.platoToDichte(sre)
                            }
                            else {
                                tfDensity.value = NaN
                            }
                            tfBrix.value = NaN
                        }
                    }

                    LabelUnit {
                        text: qsTr("°P")
                    }

                    Image {
                        source: "qrc:/images/temperature.png"
                    }

                    TextFieldTemperature {
                        Layout.alignment: Qt.AlignHCenter
                        value: model.Temp
                        onNewValue: model.Temp = value
                    }

                    LabelUnit {
                        text: qsTr("°C")
                    }

                    ToolButton {
                        Layout.columnSpan: 3
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        onClicked: remove()
                        contentItem: Image {
                            source: "qrc:/images/ic_delete.png"
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }
}
