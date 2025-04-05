import pyotherside

import sys
# Add Python directory to path
sys.path.append('/usr/share/harbour-sailkick/python')
sys.path.append('/usr/share/harbour-sailkick/python/skapi')

import skapi
from skapi.songkickapi import SongkickApi

# Use pyotherside.send for logging
pyotherside.send('debug', 'Loading songkick_bridge module')

class SongkickBridge:
    def __init__(self):
        self.api = SongkickApi()
        self.base_url = "https://www.songkick.com"
        pyotherside.send('debug', 'SongkickBridge instance created')

    def logIn(self, email, password):
        try:
            success = self.api.login(email, password)
            if success:
                pyotherside.send('login_success')
            else:
                pyotherside.send('login_failed')
            return success
        except Exception as e:
            pyotherside.send('debug', f"Login error: {e}")
            pyotherside.send('login_error', str(e))
            return False

    def getUserPlans(self):
        action = 'getUserPlans'
        pyotherside.send('loadingStarted')
        try:
            plans = self.api.get_user_plans()
            if plans:
                pyotherside.send('plans_success', plans)
            else:
                pyotherside.send('debug', f"failed in getUserPlans")
                pyotherside.send('action_failed', action)
            return plans
        except Exception as e:
            pyotherside.send('debug', f"exception in getUserPlans: {e}")
            pyotherside.send('action_error', action, str(e))
            return []  
        finally:
            pyotherside.send('loadingFinished') 

# Create single instance
Bridge = SongkickBridge()

pyotherside.send('debug', f"Module loaded. ")