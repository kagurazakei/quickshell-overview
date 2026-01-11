import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../common"
import "../../common/functions"
import "../../services"

Item { // Window
    id: root
    property var toplevel
    property var windowData
    property var monitorData
    property var widgetMonitor
    property var widgetMonitorData
    property var scale
    property var availableWorkspaceWidth
    property var availableWorkspaceHeight
    property bool restrictToWorkspace: true
    
    // Calculate width/height ratios accounting for monitor transforms
    property real widthRatio: {
        const widgetWidth = (widgetMonitorData?.transform ?? 0) % 2 === 1 ? widgetMonitor?.height : widgetMonitor?.width
        const monitorWidth = (monitorData?.transform ?? 0) % 2 === 1 ? monitorData?.height : monitorData?.width
        return ((widgetWidth ?? 1920) * (monitorData?.scale ?? 1)) / ((monitorWidth ?? 1920) * (widgetMonitor?.scale ?? 1))
    }
    property real heightRatio: {
        const widgetHeight = (widgetMonitorData?.transform ?? 0) % 2 === 1 ? widgetMonitor?.width : widgetMonitor?.height
        const monitorHeight = (monitorData?.transform ?? 0) % 2 === 1 ? monitorData?.width : monitorData?.height
        return ((widgetHeight ?? 1080) * (monitorData?.scale ?? 1)) / ((monitorHeight ?? 1080) * (widgetMonitor?.scale ?? 1))
    }
    
    property real xOffset: 0
    property real yOffset: 0
    property int widgetMonitorId: 0
    property real initX: Math.max(((windowData?.at[0] ?? 0) - (monitorData?.x ?? 0) - (monitorData?.reserved?.[0] ?? 0)) * widthRatio * root.scale, 0) + xOffset
    property real initY: Math.max(((windowData?.at[1] ?? 0) - (monitorData?.y ?? 0) - (monitorData?.reserved?.[1] ?? 0)) * heightRatio * root.scale, 0) + yOffset
    
    property var targetWindowWidth: (windowData?.size[0] ?? 100) * scale * widthRatio
    property var targetWindowHeight: (windowData?.size[1] ?? 100) * scale * heightRatio
    property bool hovered: false
    property bool pressed: false

    property var iconToWindowRatio: 0.25
    property var xwaylandIndicatorToIconRatio: 0.35
    property var iconToWindowRatioCompact: 0.45
    property var entry: DesktopEntries.heuristicLookup(windowData?.class)
    property var iconPath: Quickshell.iconPath(entry?.icon ?? windowData?.class ?? "application-x-executable", "image-missing")
    property bool compactMode: Appearance.font.pixelSize.smaller * 4 > targetWindowHeight || Appearance.font.pixelSize.smaller * 4 > targetWindowWidth

    property bool indicateXWayland: windowData?.xwayland ?? false
    
    x: initX
    y: initY
    width: Math.min(targetWindowWidth, availableWorkspaceWidth)
    height: Math.min(targetWindowHeight, availableWorkspaceHeight)
    opacity: (windowData?.monitor ?? -1) == widgetMonitorId ? 1 : 0.4

    clip: true

    Behavior on x {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on y {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on width {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on height {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }

    ScreencopyView {
        id: windowPreview
        anchors.fill: parent
        captureSource: GlobalStates.overviewOpen ? root.toplevel : null
        live: true

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.windowRounding * root.scale
            color: pressed ? ColorUtils.transparentize(Appearance.colors.colLayer2Active, 0.5) : 
                hovered ? ColorUtils.transparentize(Appearance.colors.colLayer2Hover, 0.7) : 
                ColorUtils.transparentize(Appearance.colors.colLayer2)
            border.color : ColorUtils.transparentize(Appearance.m3colors.m3outline, 0.7)
            border.width : 1
        }

        ColumnLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.font.pixelSize.smaller * 0.5

            Image {
                id: windowIcon
                property var iconSize: {
                    return Math.min(targetWindowWidth, targetWindowHeight) * (root.compactMode ? root.iconToWindowRatioCompact : root.iconToWindowRatio) / (root.monitorData?.scale ?? 1);
                }
                Layout.alignment: Qt.AlignHCenter
                source: root.iconPath
                width: iconSize
                height: iconSize
                sourceSize: Qt.size(iconSize, iconSize)

                Behavior on width {
                    animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
                }
                Behavior on height {
                    animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
                }
            }
        }
    }
}
