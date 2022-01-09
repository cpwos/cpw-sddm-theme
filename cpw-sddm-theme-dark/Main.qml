
import QtQuick 2.0
import SddmComponents 2.0

import "./components"

Rectangle {
  id  : cpw_root

  property color primaryShade : config.primaryShade ? config.primaryShade : "#2a323c"
  property color primaryLight : config.primaryLight ? config.primaryLight : "#4cbce6"
  property color primaryDark  : config.primaryDark  ? config.primaryDark  : "#2a323c"

  property color primaryHue1  : config.primaryHue1  ? config.primaryHue1  : "#3b4654"
  property color primaryHue2  : config.primaryHue2  ? config.primaryHue2  : "#2a323c"
  property color primaryHue3  : config.primaryHue3  ? config.primaryHue3  : "#323c48"

  property color accentShade  : config.accentShade  ? config.accentShade  : "#3399FF"
  property color accentLight  : config.accentLight  ? config.accentLight  : "#cccccc"

  property color accentHue1   : config.accentHue1   ? config.accentHue1   : "#3399FF"
  property color accentHue2   : config.accentHue2   ? config.accentHue2   : "#3399FF"
  property color accentHue3   : config.accentHue3   ? config.accentHue3   : "#3399FF"

  property color normalText   : config.normalText   ? config.normalText   : "#cccccc"

  property color successText  : config.successText  ? config.successText  : "#43a047"
  property color failureText  : config.failureText  ? config.failureText  : "#e53935"
  property color warningText  : config.warningText  ? config.warningText  : "#ff8f00"

  property color rebootColor  : config.rebootColor  ? config.rebootColor  : "#3399FF"
  property color powerColor   : config.powerColor   ? config.powerColor   : "#cccccc"

  readonly property color defaultBg : primaryShade ? primaryShade : "#3399FF"

  //
  // Indicates one unit of measure (in pixels)
  //
  readonly property int spUnit: 64

  //
  // Symmetric (equal) padding on all sides
  //
  readonly property int padSym : (spUnit / 8)

  //
  // Asymmetric padding in horizontal & vertical directions
  //
  readonly property int padAsymH : (spUnit / 2)
  readonly property int padAsymV : (spUnit / 8)

  //
  // Font sizes
  //
  readonly property int spFontNormal  : 16
  readonly property int spFontSmall   : 14


  LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
  LayoutMirroring.childrenInherit: true

  TextConstants { id: textConstants }

  Connections {
    target: sddm

    onLoginSucceeded: {
      prompt_bg.color = successText
      prompt_txt.text = textConstants.loginSucceeded

      cpw_busy.visible = false;
      cpw_busy_anim.stop()

      anim_success.start()
    }
    onLoginFailed: {
      prompt_bg.color = failureText
      prompt_txt.text = textConstants.loginFailed

      cpw_busy.visible = false;
      cpw_busy_anim.stop()

      anim_failure.start()
    }
  }


  signal tryLogin()

  onTryLogin : {
    cpw_busy.visible = true;
    cpw_busy_anim.start()

    sddm.login(cpw_username.text, cpw_password.text, cpw_session.index);
  }


  FontLoader {
    id: opensans_cond_light
    source: "fonts/OpenSans_CondLight.ttf"
  }

  Repeater {
    model: screenModel

    Item {
      Rectangle {
        x       : geometry.x
        y       : geometry.y
        width   : geometry.width
        height  : geometry.height
        color   : defaultBg
      }
    }
  }

  //
  // Status bar on top
  //
  Rectangle {
    x       : 0
    y       : 0
    width   : parent.width
    height  : spUnit

    color   : primaryDark

    Row {
      x       : (parent.width  / 2) + padAsymH
      y       : padAsymV
      width   : ((parent.width  / 2) - (padAsymH * 2))
      height  : (parent.height - (padAsymV * 2))

      spacing : padAsymH

      layoutDirection : Qt.RightToLeft

      //
      // Current date & time
      //
      SpClock {
        height  : parent.height

        tColor  : normalText

        tFont.family    : opensans_cond_light.name
        tFont.pixelSize : spFontNormal
      }
    }
  }


  //
  // Header
  //
  Rectangle {
    x       : 0
    y       : spUnit
    width   : parent.width
    height  : spUnit

    color   : primaryShade

    Row {
      x       : padAsymH
      y       : padAsymV
      width   : (parent.width  - (padAsymH * 2))
      height  : (parent.height - (padAsymV * 2))

      //
      // Welcome Text
      //
      Text {
        id      : cpw_welcome

        width   : parent.width
        height  : parent.height

        text    : textConstants.welcomeText.arg(sddm.hostName)
        color   : normalText

        font.family         : opensans_cond_light.name
        font.pixelSize      : spFontNormal

        fontSizeMode        : Text.VerticalFit
        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignVCenter
      }
    }
  }

  //
  // Toolbar
  //
  Rectangle {
    x       : 0
    y       : (spUnit * 2)
    width   : parent.width
    height  : spUnit

    color   : primaryShade

    Row {
      x       : (parent.width  / 2) + padAsymH
      y       : padAsymV
      width   : ((parent.width  / 2) - (padAsymH * 2))
      height  : (parent.height - (padAsymV * 2))

      spacing : padAsymH

      layoutDirection : Qt.RightToLeft

      //
      // Layout selection
      //
      LayoutBox {
        id      : cpw_layout

        width   : spUnit * 2
        height  : parent.height

        color       : primaryHue1
        borderColor : primaryHue3
        focusColor  : accentLight
        hoverColor  : accentHue2
        textColor   : normalText
        menuColor   : primaryHue1

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontNormal

        arrowIcon: "images/ic_arrow_drop_down_white_24px.svg"
        arrowColor: primaryHue3

        KeyNavigation.tab     : cpw_username
        KeyNavigation.backtab : cpw_session
      }

      Text {
        height  : parent.height

        text    : textConstants.layout

        color   : normalText

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontNormal

        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignVCenter
      }

      //
      // Session selection
      //
      ComboBox {
        id      : cpw_session

        model   : sessionModel
        index   : sessionModel.lastIndex

        width   : spUnit * 3
        height  : parent.height

        color       : primaryHue1
        borderColor : primaryHue3
        focusColor  : accentLight
        hoverColor  : accentHue2
        textColor   : normalText
        menuColor   : primaryHue1

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontNormal

        arrowIcon: "images/ic_arrow_drop_down_white_24px.svg"
        arrowColor: primaryHue3

        KeyNavigation.tab     : cpw_layout
        KeyNavigation.backtab : cpw_shutdown
      }

      Text {
        height  : parent.height

        text    : textConstants.session

        color   : normalText

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontNormal

        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignVCenter
      }
    }
  }

  //
  // Footer
  //
  Rectangle {
    x       : 0
    y       : (parent.height - spUnit)
    width   : parent.width
    height  : spUnit

    color   : primaryHue3

    Row {
      x : padAsymH;
      y : padAsymV;

      width   : (parent.width  - (padAsymH * 2))
      height  : (parent.height - (padAsymV * 2))

      spacing: padAsymH

      layoutDirection : Qt.RightToLeft

      //
      // Shutdown button
      //
      SpButton {
        id      : cpw_shutdown

        height  : parent.height
        width   : (spUnit * 4)

        font.family : opensans_cond_light.name

        label       : textConstants.shutdown
        labelColor  : normalText

        icon        : "images/ic_power_settings_new_white_24px.svg"
        iconColor   : accentShade

        hoverIconColor  : powerColor
        hoverLabelColor : accentShade

        KeyNavigation.tab     : cpw_session
        KeyNavigation.backtab : cpw_reboot

        onClicked: sddm.powerOff()
      }

      //
      // Reboot button
      //
      SpButton {
        id      : cpw_reboot

        height  : parent.height
        width   : (spUnit * 4)

        font.family : opensans_cond_light.name

        label       : textConstants.reboot
        labelColor  : normalText

        icon        : "images/ic_refresh_white_24px.svg"
        iconColor   : accentLight

        hoverIconColor  : rebootColor
        hoverLabelColor : accentShade

        KeyNavigation.tab     : cpw_shutdown
        KeyNavigation.backtab : cpw_login

        onClicked: sddm.reboot()
      }
    }
  }

  //
  // Login container
  //
  Rectangle {
    x       : (parent.width  - (6 * spUnit)) / 2
    y       : (parent.height - (5 * spUnit)) / 2
    width   : (6 * spUnit)
    height  : (5 * spUnit)

    color   : primaryHue3

    Row {
      x       : padSym
      y       : padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      Text {
        width   : parent.width
        height  : parent.height

        text    : textConstants.userName
        color   : accentLight

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontSmall

        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignBottom
      }
    }

    Row {
      x       : padSym
      y       : spUnit + padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      TextBox {
        id      : cpw_username

        width   : parent.width
        height  : parent.height

        color       : primaryHue1
        borderColor : primaryDark
        focusColor  : accentShade
        hoverColor  : accentLight
        textColor   : normalText

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontSmall

        KeyNavigation.tab     : cpw_password
        KeyNavigation.backtab : cpw_layout
      }
    }

    Row {
      x       : padSym
      y       : (2 * spUnit) + padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      Text {
        width   : parent.width
        height  : parent.height

        text    : textConstants.password
        color   : accentLight

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontSmall

        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignBottom
      }
    }

    Row {
      x       : padSym
      y       : (3 * spUnit) + padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      PasswordBox {
        id      : cpw_password

        width   : parent.width
        height  : parent.height

        color       : primaryHue1
        borderColor : primaryDark
        focusColor  : accentShade
        hoverColor  : accentLight
        textColor   : normalText

        image       : "images/ic_warning_white_24px.svg"

        tooltipEnabled  : true
        tooltipText     : textConstants.capslockWarning
        tooltipFG       : normalText
        tooltipBG       : primaryHue3

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontNormal

        KeyNavigation.tab     : cpw_login
        KeyNavigation.backtab : cpw_username

        Keys.onPressed: {
          if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
            cpw_root.tryLogin()

            event.accepted = true;
          }
        }
      }
    }

    Row {
      x       : padSym
      y       : (4 * spUnit) + padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      Button {
        id      : cpw_login

        width   : parent.width
        height  : parent.height

        text    : textConstants.login

        color         : primaryDark
        textColor     : normalText

        borderColor   : primaryHue1

        pressedColor  : accentLight
        activeColor   : accentShade

        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontNormal
        font.weight     : Font.DemiBold

        KeyNavigation.tab     : cpw_reboot
        KeyNavigation.backtab : cpw_layout

        onClicked: cpw_root.tryLogin()

        Keys.onPressed: {
          if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
            cpw_root.tryLogin()

            event.accepted = true;
          }
        }
      }
    }
  }

  //
  // Busy animation (just above footer)
  //
  Rectangle {
    id      : cpw_busy

    x       : (parent.width  - (6 * spUnit)) / 2
    y       : (parent.height - (1.5 * spUnit))
    width   : (6 * spUnit)
    height  : (spUnit / 4)

    visible : false

    color   : "transparent"

    border.color  : accentHue1
    border.width  : 1

    Rectangle {
      id      : cpw_busy_indicator

      x       : 0
      y       : 0
      width   : (spUnit / 4)
      height  : parent.height

      color   : accentHue3
    }

    SequentialAnimation {
      id      : cpw_busy_anim

      running : false
      loops   : Animation.Infinite

      NumberAnimation {
        target    : cpw_busy_indicator
        property  : "x"
        from      : 0
        to        : (6 * spUnit) - (spUnit / 4)
        duration  : 2500
      }

      NumberAnimation {
        target    : cpw_busy_indicator
        property  : "x"
        to        : 0
        duration  : 2500
      }
    }
  }

  //
  // Prompt container
  //
  Rectangle {
    id      : prompt_bg

    x       : (parent.width / 4)
    y       : (parent.height - (3 * spUnit))
    width   : (parent.width / 2)
    height  : spUnit

    color   : "transparent"

    Text {
      id      : prompt_txt

      x       : padSym
      y       : padSym
      width   : (parent.width  - (padSym * 2))
      height  : (parent.height - (padSym * 2))

      color   : normalText

      text    : textConstants.prompt

      font.pixelSize  : spFontNormal

      horizontalAlignment : Text.AlignHCenter
      verticalAlignment   : Text.AlignVCenter
    }

    SequentialAnimation on color {
      id      : anim_success
      running : false

      ColorAnimation {
        from: "transparent"
        to: successText
        duration: 250
      }
    }

    SequentialAnimation on color {
      id      : anim_failure
      running : false

      ColorAnimation {
        from: "transparent"
        to: failureText
        duration: 250
      }

      PauseAnimation {
        duration: 500
      }

      ColorAnimation {
        from: failureText
        to: "transparent"
        duration: 500
      }

      onStopped: {
        cpw_password.text  = ""
        prompt_txt.text     = textConstants.prompt
      }
    }
  }


  Component.onCompleted: {
    if (cpw_username.text === "")
      cpw_username.focus = true
    else
      cpw_password.focus = true
  }
}
