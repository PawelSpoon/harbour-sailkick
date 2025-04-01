import QtQuick 2.0
import io.thp.pyotherside 1.5

Item {
    id: root

    // Login/Auth Signale
    signal loginSuccess()
    signal loginFailed()

    // Properties für die Suche
    property string artistsResults

    Python {
        id: pythonSkApi

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.'))

            // Login Handler
            setHandler('login_success', function() {
                console.log("login_success")
                root.loginSuccess()
            })
            setHandler('login_failed', function() {
                console.log("login_failed")
                root.loginFailed()
            })

            importModule('songkick_bridge', function() {
                console.log("songkick bridge module imported successfully")
            })
        }

    }

    onLoginSuccess: {
        //loginTrue = true
    }

    onLoginFailed: {
        /*loginTrue = false
        if (authManager) {
            authManager.clearTokens()
        }*/
    }


    // Function to call Python function for login
    function logIn(username, pwd) {
        console.log("logIn")
        pythonSkApi.call('songkick_bridge.Bridge.logIn', [username, pwd])
    }
}
