import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import QtQuick.Dialogs 1.0

import QtMultimedia 5.12
import Qt.labs.settings 1.0
import Qt.labs.folderlistmodel 2.12

import com.avatarify.desktop 1.0

ApplicationWindow {
    id: window
    visible: true
    minimumWidth: 800
    minimumHeight: 540
    width: minimumWidth
    height: minimumHeight
    title: "Avatarify Desktop"

    Settings {
        id: window_settings
        category: "Window"
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }

    Settings {
        id: input_settings
        category: "Input"
        property alias cam_id: cameraSelector.currentValue
        property alias mirror: cameraMirrorCheckbox.checked
        property alias smartCrop: cameraSmartCropCheckbox.checked
        property alias vcam: cameraVCamCheckbox.checked
    }

    AsyncCameraCapture {
        id: cam
        deviceId: input_settings.cam_id
        smartCrop: input_settings.smartCrop
    }

    VCam {
        id: vcam
        stream: input_settings.vcam
    }

    InferenceManager {
        id: manager
        camera: cam
        virtualCamera: vcam
        mirror: input_settings.mirror
    }

    ColumnLayout {
        spacing: 0
        anchors.fill: parent
        anchors.rightMargin: 5
        anchors.topMargin: 0
        anchors.leftMargin: 5
        anchors.bottomMargin: 5

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent

                GroupBox {
                    id: settingsGroup
                    width: 270
                    Layout.maximumWidth: 270
                    Layout.preferredWidth: 270
                    Layout.minimumWidth: 270
                    topPadding: 40
                    Layout.fillHeight: false
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    title: "Settings"

                    ColumnLayout {
                        anchors.fill: parent
                        visible: true

                        Label {
                            text: "Choose your cam:"
                        }
                        ComboBox {
                            id: cameraSelector
                            Layout.fillWidth: true
                            width: 250
                            Layout.maximumWidth: 250
                            Layout.preferredWidth: 250
                            Layout.minimumWidth: 250

                            model: QtMultimedia.availableCameras
                            valueRole: 'deviceId'
                            textRole: 'displayName'
                        }

                        Switch {
                            id: cameraMirrorCheckbox
                            Layout.fillWidth: true
                            text: "Flip video preview"
                        }

                        Switch {
                            id: cameraSmartCropCheckbox
                            Layout.fillWidth: true
                            text: "Smart crop"
                        }

                        Label {
                            width: 260
                            Layout.maximumWidth: 260
                            Layout.preferredWidth: 260
                            Layout.minimumWidth: 260
                            text: "You can use Avatarify as a virtual cam for Skype/Zoom calls:"
                            wrapMode: Text.WordWrap
                            visible: vcam.available
                        }

                        Switch {
                            id: cameraVCamCheckbox
                            Layout.fillWidth: true
                            text: "Virtual cam"
                            enabled: vcam.available
                            visible: vcam.available
                        }

                        Label {
                            width: 260
                            Layout.maximumWidth: 260
                            Layout.preferredWidth: 260
                            Layout.minimumWidth: 260
                            text: "Create avatar from image file:"
                            wrapMode: Text.WordWrap
                        }

                        Button {
                            text: "Open image file"
                            onClicked: {
                                addImageDialog.open();
                            }
                        }

                        Label {
                            width: 260
                            Layout.maximumWidth: 260
                            Layout.preferredWidth: 260
                            Layout.minimumWidth: 260
                            text: "Right-click on avatar to show the calibration overlay:"
                            wrapMode: Text.WordWrap
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Button {
                                text: "Calibrate"
                                onClicked: {
                                    manager.requestCalibration();
                                }
                            }
                            Switch {
                                id: overlayCheckbox
                                Layout.fillWidth: true
                                text: "Overlay"
                                visible: (manager.avatarPath === "none") && (overlayImage.source.toString() !== "")
                            }
                        }
                    }
                }

                GroupBox {
                    id: previewGroup
                    padding: 5
                    topPadding: 35
                    rightPadding: 5
                    bottomPadding: 5
                    leftPadding: 5
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    title: "Preview"

                    ColumnLayout {
                        spacing: 0
                        anchors.fill: parent

                        VideoOutput {
                            id: videoOutput
                            source: manager
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Image {
                                id: overlayImage
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                height: videoOutput.contentRect.height
                                fillMode: Image.PreserveAspectFit//.PreserveAspectCrop
                                opacity: 0.5
                                visible: overlayCheckbox.checked && (manager.avatarPath === "none")
                            }
                        }
                    }
                }
            }
        }

        GroupBox {
            id: avatarGroup
            Layout.maximumHeight: 184
            Layout.minimumHeight: 184
            Layout.preferredHeight: 184
            padding: 5
            topPadding: 35
            rightPadding: 5
            bottomPadding: 5
            leftPadding: 5
            Layout.fillHeight: false
            Layout.fillWidth: true
            title: "Choose your avatar:"

            ColumnLayout {
                spacing: 0
                anchors.fill: parent

                ListView {
                    id: avatarSelector
                    spacing: 2
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    orientation: ListView.Horizontal
                    flickableDirection: Flickable.HorizontalFlick
                    clip: true
                    highlightFollowsCurrentItem: false
                    currentIndex: -1

                    model: FolderListModel {
                        id: avatarModel
                        folder: "file:///" + manager.rootFolder + "/.avatarify/avatars"
                        nameFilters: ['*.jpg', '*.jpeg', '*.png']
                    }
                    delegate: Component {
                        Item {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            width: 144
                            height: 144

                            ColumnLayout {
                                spacing: 0
                                anchors.fill: parent

                                Image {
                                    id: avatarImage
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                    width: 138
                                    height: 138
                                    Layout.maximumWidth: 138
                                    Layout.minimumWidth: 138
                                    Layout.preferredWidth: 138
                                    Layout.maximumHeight: 138
                                    Layout.minimumHeight: 138
                                    Layout.preferredHeight: 138
                                    fillMode: Image.PreserveAspectCrop
                                    source: avatarModel.folder + "/" + model.fileName
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: {
                                    if (mouse.button == Qt.LeftButton) {
                                        if (avatarSelector.currentIndex != index) {
                                            avatarSelector.currentIndex = index;
                                            manager.avatarPath = model.fileName;
                                        } else {
                                            avatarSelector.currentIndex = -1;
                                            manager.avatarPath = "none";
                                        }
                                    } else {
                                        if (manager.avatarPath !== "none") {
                                            return;
                                        }
                                        if (overlayImage.source !== avatarImage.source) {
                                            overlayImage.source = avatarImage.source;
                                            overlayCheckbox.checked = true;
                                        } else {
                                            overlayCheckbox.checked = !overlayCheckbox.checked;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    highlight: Rectangle {
                        border.color: "steelblue"
                        border.width: 3
                        color: "transparent"
                        radius: 5
                        width: 144
                        height: 144
                        x: avatarSelector.currentItem != null ? avatarSelector.currentItem.x : -1000
                        z: Infinity
                    }
                }
            }

            FileDialog {
                id: addImageDialog
                title: "Please choose an image"
                folder: shortcuts.home
                nameFilters: [ "Image files (*.jpg *.png)", "All files (*)" ]
                onAccepted: {
                    console.log("You chose: " + fileUrl)
                    cropImageWindow.open(fileUrl);
                }
                onRejected: {
                    console.log("Canceled")
                }
            }
        }
    }
    CropImageWindow {
        id: cropImageWindow
    }
}


