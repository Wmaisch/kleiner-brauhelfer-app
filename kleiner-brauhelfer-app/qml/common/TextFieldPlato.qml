import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import brauhelfer 1.0

TextFieldNumber {

    property bool useDialog: false
    property real sw: 0.0

    id: textfield
    min: 0.0
    max: 99.9
    precision: 2

    onPressed: if (useDialog) popuploader.active = true

    Loader {
        id: popuploader
        active: false
        focus: true
        onLoaded: item.open()
        sourceComponent: PopupBase {
            maxWidth: 240
            onOpened: {
                tfPlato.value = textfield.value
                tfDensity.value = Brauhelfer.calc.platoToDichte(tfPlato.value)
                tfBrix.value = (textfield.sw === 0.0) ? Brauhelfer.calc.platoToBrix(tfPlato.value) : ""
                tfPlato.forceActiveFocus()
            }
            onClosed: {
                if (tfPlato.value !== textfield.value)
                    newValue(tfPlato.value)
                textfield.focus = false
                popuploader.active = false
            }

            GridLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                columns: 3
                columnSpacing: 16

                Image {
                    source: "qrc:/images/refractometer.png"
                }

                TextFieldNumber {
                    id: tfBrix
                    min: 0.0
                    max: 99.9
                    precision: 2
                    onNewValue: {
                        this.value = value
                        if (tfBrix.focus) {
                            if (textfield.sw === 0.0) {
                                tfPlato.value = Brauhelfer.calc.brixToPlato(tfBrix.value)
                                tfDensity.value = Brauhelfer.calc.platoToDichte(tfPlato.value)
                            }
                            else {
                                tfDensity.value = Brauhelfer.calc.brixToDichte(textfield.sw, tfBrix.value)
                                tfPlato.value = Brauhelfer.calc.dichteToPlato(tfDensity.value)
                            }
                        }
                    }
                }

                LabelPrim {
                    text: qsTr("°Brix")
                    Layout.fillWidth: true
                }

                Image {
                    source: "qrc:/images/spindel.png"
                }

                TextFieldNumber {
                    id: tfDensity
                    min: 0.0
                    max: 99.9
                    precision: 4
                    onNewValue: {
                        this.value = value
                        if (tfDensity.focus) {
                            tfPlato.value = Brauhelfer.calc.dichteToPlato(tfDensity.value)
                            tfBrix.value = (textfield.sw === 0.0) ? Brauhelfer.calc.platoToBrix(tfPlato.value) : ""
                        }
                    }
                }

                LabelPrim {
                    text: qsTr("g/ml")
                    Layout.fillWidth: true
                }

                Image {
                    source: "qrc:/images/sugar.png"
                }

                TextFieldNumber {
                    id: tfPlato
                    min: 0.0
                    max: 99.9
                    precision: 2
                    onNewValue: {
                        this.value = value
                        if (tfPlato.focus) {
                            tfDensity.value = Brauhelfer.calc.platoToDichte(tfPlato.value)
                            tfBrix.value = (textfield.sw === 0.0) ? Brauhelfer.calc.platoToBrix(tfPlato.value) : ""
                        }
                    }
                }

                LabelPrim {
                    text: qsTr("°P")
                    Layout.fillWidth: true
                }
            }
        }
    }
}
