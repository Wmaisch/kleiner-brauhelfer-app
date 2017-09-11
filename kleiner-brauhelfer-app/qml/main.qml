import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "common"
import "pagesGlobal"
import "pagesSud"
import "pagesTools"
import "pagesOthers"

import brauhelfer 1.0

ApplicationWindow {

    property bool loaded: false
    property bool isLandscape: width > height
    property bool brewForceEditable: false

    id: app
    title: Qt.application.name
    width: 360
    height: 640
    visible: true

    // scheduler to do stuff in the background, use run() or runExt()
    Timer {
        // tasks
        readonly property int connect: 0
        readonly property int save: 1
        readonly property int discard: 2
        readonly property int loadBrew: 3

        property int schedule: -1
        property var param: null

        id: scheduler
        interval: 10
        onTriggered: {
            switch (schedule) {
            case connect:
                Brauhelfer.connect()
                break
            case save:
                Brauhelfer.save()
                brewForceEditable = false
                break
            case discard:
                Brauhelfer.discard()
                brewForceEditable = false
                break
            case loadBrew:
                Brauhelfer.sud.load(param)
                buildMenus()
                navPane.goTo(viewSud, 0)
                brewForceEditable = false
                break
            }
            busyIndicator.running = false
        }

        function run(schedule) {
            this.schedule = schedule
            busyIndicator.running = true
            start()
        }

        function runExt(schedule, param) {
            this.param = param
            run(schedule)
        }
    }

    function connect() {
        scheduler.run(scheduler.connect)
    }

    function save() {
        scheduler.run(scheduler.save)
    }

    function discard() {
        scheduler.run(scheduler.discard)
    }

    function loadBrew(id) {
        if (Brauhelfer.sud.id !== id) {
            busyIndicator.running = true
            navPane.goHome()
            for (var i = 0; i < viewSud.count; ++i)
                viewSud.itemAt(i).unload()
            scheduler.runExt(scheduler.loadBrew, id)
        }
        else {
            navPane.goTo(viewSud, 0)
        }
    }

    function buildMenus() {
        viewSud.build()
        navigation.build()
    }

    Component.onCompleted: {
        // build navigation menu
        buildMenus()

        // connect to database
        Brauhelfer.connect()
        app.loaded = true

        // trigger focus to load content of first page, after app.loaded is set
        navPane.currentItem.currentItem.focus = false
        navPane.currentItem.currentItem.focus = true

        // done initialising
        busyIndicator.running = false

        // synchronization message
        switch (Brauhelfer.syncState)
        {
        case Brauhelfer.UpToDate:
            toast.start(qsTr("Datenbank aktuell."))
            break;
        case Brauhelfer.Updated:
            toast.start(qsTr("Datenbank aktualisiert."))
            break;
        case Brauhelfer.Offline:
            toast.start(qsTr("Gerät ist nicht mit dem Internet verbunden."))
            break;
        case Brauhelfer.NotFound:
            toast.start(qsTr("Datenbank nicht gefunden."))
            break;
        case Brauhelfer.OutOfSync:
            toast.start(qsTr("Datenbank nicht synchron."))
            break;
        case Brauhelfer.Failed:
            toast.start(qsTr("Synchronisation fehlgeschlagen."))
            break;
        }

        // check if everything ok
        if (Brauhelfer.readonly)
            messageDialog.show(qsTr("Synchronisationsdienst ist nicht verfügbar."),
                               qsTr("Datenbank wird nur lesend geöffnet."))
        if (!Brauhelfer.connected) {
            messageDialogGotoSettings.show(qsTr("Verbindung mit der Datenbank fehlgeschlagen."),
                                           qsTr("Einstellungen überprüfen."))
        }
    }

    // connect debug message to console
    Connections {
        target: Brauhelfer
        onNewMessage: console.info(msg)
    }

    // toast messages
    Toast{
        id: toast
    }

    // generic message dialog, use show() to open dialog
    MessageDialog {
        id: messageDialog
        function show(text, details) {
            messageDialog.text = text
            messageDialog.informativeText = details
            messageDialog.open()
        }
    }

    // message dialog going to the settings, use show() to open dialog
    MessageDialog {
        id: messageDialogGotoSettings
        onAccepted: navPane.goSettings()
        function show(text, details) {
            messageDialogGotoSettings.text = text
            messageDialogGotoSettings.informativeText = details
            messageDialogGotoSettings.open()
        }
    }

    // message dialog to ask for quit
    MessageDialog {
        id: messageDialogQuit
        text: qsTr("Soll das Programm geschlossen werden?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        //buttons: MessageDialog.Ok | MessageDialog.Cancel
        onAccepted: Qt.quit()
    }

    // header
    header: Header {
        text: navPane.currentItem.currentItem.title
        textSub: Brauhelfer.sud.loaded ? Brauhelfer.sud.Sudname : Qt.application.name
        iconLeft: "ic_menu_white.png"
        onClickedLeft: navigation.open()
        iconRight: navPane.isHome() ? "" : "ic_home_white.png"
        onClickedRight: navPane.goHome()
    }

    // global pages
    SwipeView {
        id: viewGlobal
        visible: false
        //Testarea {}
        PageGlobalAuswahl { onClicked: loadBrew(id) }
    }

    // brew pages
    SwipeView {
        id: viewSud
        visible: false
        function build() {
            while (count > 0)
                removeItem(0)
            if (Brauhelfer.sud.loaded) {
                addItem(pageSudHome)
                addItem(pageSudBrauen)
                addItem(pageSudGaerverlauf_1)
                addItem(pageSudGaerverlauf_2)
                addItem(pageSudAbfuellen)
                addItem(pageSudGaerverlauf_3)
                addItem(pageSudBewertung)
            }
            if (count > 0)
                itemAt(0).unload()
        }
    }
    PageSudHome { id: pageSudHome }
    PageSudBrauen { id: pageSudBrauen }
    PageSudGaerverlauf_1 { id: pageSudGaerverlauf_1 }
    PageSudGaerverlauf_2 { id: pageSudGaerverlauf_2 }
    PageSudAbfuellen { id: pageSudAbfuellen }
    PageSudGaerverlauf_3 { id: pageSudGaerverlauf_3 }
    PageSudBewertung { id: pageSudBewertung }

    // tools pages
    SwipeView {
        id: viewTools
        visible: false
        PageToolBieranalyse {}
    }

    // other pages
    SwipeView {
        id: viewOthers
        visible: false
        PageSettings {}
        PageAbout {}
    }

    // main view containing the swipe views
    StackView {

        property var lastView : null
        property int lastIndex : -1

        id: navPane
        anchors.fill: parent
        initialItem: viewGlobal
        focus: true

        Keys.onReleased: {
            if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
                if (isHome()) {
                    messageDialogQuit.open()
                }
                if (lastView === null || currentItem === viewGlobal || currentItem == viewSud) {
                    goHome()
                }
                else {
                    goTo(lastView, lastIndex)
                    lastView = null
                    lastIndex = -1
                }
                event.accepted = true
            }
        }

        function goTo(view, index)
        {
            lastView = currentItem
            lastIndex = currentItem.currentIndex
            if (index >= 0)
                view.currentIndex = index
            if (currentItem !== view) {
                pop(viewGlobal)
                if (view !== viewGlobal)
                    push(view)
            }
            setFocus()
        }

        function next()
        {
            if (currentItem.currentIndex < currentItem.count - 1)
                currentItem.currentIndex = currentItem.currentIndex + 1
        }

        function previous()
        {
            if (currentItem.currentIndex > 0)
                currentItem.currentIndex = currentItem.currentIndex - 1
        }

        function goHome()
        {
            lastView = null
            lastIndex = -1
            if (currentItem == viewSud && viewSud.currentIndex !== 0) {
                viewSud.currentIndex = 0
            }
            else {
                viewGlobal.currentIndex = 0
                if (currentItem !== viewGlobal)
                    pop(viewGlobal)
            }
            setFocus()
        }

        function goSettings()
        {
            goTo(viewOthers, 0)
        }

        function isCurrentPage(view, index)
        {
            return currentItem === view && view.currentIndex === index
        }

        function isHome()
        {
            return isCurrentPage(viewGlobal, 0)
        }

        function setFocus()
        {
            focus = true
        }
    }

    // footer
    footer: Footer {
        swipeView: navPane.currentItem
        onClickedLeft: navPane.previous()
        onClickedRight: navPane.next()
    }

    // busy indicator
    BusyIndicator {
        id: busyIndicator
        running: true
        anchors.centerIn: parent
    }

    // discard button
    FloatingButton {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        visible: Brauhelfer.modified
        imageSource: "qrc:/images/ic_clear_white.png"
        onClicked: app.discard()
    }

    // save button
    FloatingButton {
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        visible: Brauhelfer.modified
        imageSource: "qrc:/images/ic_save_white.png"
        onClicked: app.save()
    }

    // navigation menu
    NavMenu {
        id: navigation
        model: ListModel {}
        onClosed: navPane.setFocus()
        function build()
        {
            var i
            model.clear()
            for (i = 0; i < viewGlobal.count; ++i)
                model.append({"type": "NavMenuItem.qml",
                              "view": viewGlobal,
                              "index": i})
            if (viewSud.count > 0)
                model.append({"type": "NavMenuDivider.qml"})
            for (i = 0; i < viewSud.count; ++i)
                model.append({"type": "NavMenuItem.qml",
                              "view": viewSud,
                              "index": i})
            if (viewTools.count > 0)
                model.append({"type": "NavMenuDivider.qml"})
            for (i = 0; i < viewTools.count; ++i)
                model.append({"type": "NavMenuItem.qml",
                              "view": viewTools,
                              "index": i})
            if (viewOthers.count > 0)
                model.append({"type": "NavMenuDivider.qml"})
            for (i = 0; i < viewOthers.count; ++i)
                model.append({"type": "NavMenuItem.qml",
                              "view": viewOthers,
                              "index": i})
        }
    }
}