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
TARGET = harbour-sailkick

CONFIG += sailfishapp

SOURCES += src/harbour-sailkick.cpp

OTHER_FILES += qml/harbour-sailkick.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-sailkick.changes.in \
    rpm/harbour-sailkick.spec \
    rpm/harbour-sailkick.yaml \
    translations/*.ts \
    harbour-sailkick.desktop
    icons/*.png

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-sailkick-de.ts \
                translations/harbour-sailkick-en.ts \
                translations/harbour-sailkick-cs.ts \
                translations/harbour-sailkick-sv.ts \
                translations/harbour-sailkick-es.ts \
                translations/harbour-sailkick-hu.ts \
                translations/harbour-sailkick-nl.ts


# Python dependencies deployment
pythondeps.files = python-deps/*
pythondeps.path = /usr/share/harbour-sailkick/python

# Python files deployment
python.files = python/*.py
python.path = /usr/share/harbour-sailkick/python

# skapi folder deployment
skapi.files = python/skapi/*.py
skapi.path = /usr/share/harbour-sailkick/python/skapi

INSTALLS += python pythondeps skapi



DISTFILES += \
    qml/common/AuthManager.qml \
    qml/pages/Concerts4DatePage.qml \
    qml/pages/TabedMainPageX.qml \
    qml/sf-docked-tab-bar/*.qml \
    qml/Persistance.js \
    qml/ApplicationControler.qml \
    qml/pages/ConcertsPage.qml \
    qml/pages/EventListView.qml \
    qml/sk-badge-white.png \
    qml/sk-badge-black.png \
    qml/sk-badge-pink.png \
    qml/common/InfoPopup.qml \
    qml/common/PageHeaderExtended.qml \
    qml/common/QueryDialog.qml \
    qml/common/SilicaCoverPlaceholder.qml \
    qml/common/SilicaLabel.qml \
    qml/common/SilicaMenuLabel.qml \
    qml/common/Tracer.qml \
    qml/common/ViewSearchPlaceholder.qml \
    qml/pages/HelpMainPage.qml \
    qml/pages/HelpPage.qml \
    qml/pages/PlansPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/TrackedItemPage.qml \
    qml/pages/TrackedItemsPage.qml \
    translations/harbour-sailkick-es.ts \
    qml/pages/EventWebViewPage.qml \
    qml/pages/EventPage.qml \
    python/songkick_api.py \
    python/songkick_bridge.py \
    python/parse_user_artists.py 

COPIES += future dateutil

libs.path = /usr/share/$${TARGET}
libs.files = external
INSTALLS += libs

RESOURCES +=

