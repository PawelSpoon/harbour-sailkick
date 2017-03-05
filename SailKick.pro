# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = SailKick

CONFIG += sailfishapp

SOURCES += \
    src/SailKick.cpp

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    translations/*.ts
    icons/*.png


SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/SailKick-de.ts

DISTFILES += \
    qml/config.js \
    qml/common/InfoPopup.qml \
    qml/common/PageHeaderExtended.qml \
    qml/common/PasswordFieldCombo.qml \
    qml/common/SilicaCoverPlaceholder.qml \
    qml/common/SilicaLabel.qml \
    qml/common/SilicaMenuLabel.qml \
    qml/common/Tracer.qml \
    qml/common/ViewSearchPlaceholder.qml \
    qml/pages/MainPage.qml \
    qml/SailKick.qml \
    rpm/SailKick.yaml \
    rpm/SailKick.spec \
    rpm/SailKick.changes.in \
    SailKick.desktop \
    qml/pages/EditEntryDialog.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/HelpMainPage.qml \
    qml/pages/HelpPage.qml
