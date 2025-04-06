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
        pyotherside.send('loadingStarted')
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
        finally:
            pyotherside.send('loadingFinished')

    def getUserPlans(self):
        action = 'getUserPlans'
        pyotherside.send('loadingStarted')
        try:
            result = self.api.get_user_plans()
            if result:
                pyotherside.send('plans_success', result)
            else:
                pyotherside.send('debug', f"failed in {action}")
                pyotherside.send('action_failed', action)
            return result
        except Exception as e:
            pyotherside.send('debug', f"exception in {action}: {e}")
            pyotherside.send('action_error', action, str(e))
            return []  
        finally:
            pyotherside.send('loadingFinished') 

    def getUserConcerts(self):
        action = 'getUserConcerts'
        pyotherside.send('loadingStarted')
        try:
            result = self.api.get_user_concerts()
            if result:
                pyotherside.send('concerts_success', result)
            else:
                pyotherside.send('debug', f"failed in getUserConcerts")
                pyotherside.send('action_failed', action)
            return result
        except Exception as e:
            pyotherside.send('debug', f"exception in getUserConcerts: {e}")
            pyotherside.send('action_error', action, str(e))
            return []  
        finally:
            pyotherside.send('loadingFinished') 

    def getUserTrackedArtists(self):
        action = 'getUserTrackedArtists'
        pyotherside.send('loadingStarted')
        try:
            result = self.api.get_user_artists()
            if result:
                pyotherside.send('artists_success', result)
            else:
                pyotherside.send('debug', f"failed in {action}")
                pyotherside.send('action_failed', action)
            return result
        except Exception as e:
            pyotherside.send('debug', f"exception in {action}: {e}")
            pyotherside.send('action_error', action, str(e))
            return []  
        finally:
            pyotherside.send('loadingFinished')  

    def getUserTrackedLocations(self):
        action = 'getUserTrackedLocations'
        pyotherside.send('loadingStarted')
        try:
            result = self.api.get_user_locations()
            if result:
                pyotherside.send('locations_success', result)
            else:
                pyotherside.send('debug', f"failed in {action}")
                pyotherside.send('action_failed', action)
            return result
        except Exception as e:
            pyotherside.send('debug', f"exception in {action}: {e}")
            pyotherside.send('action_error', action, str(e))
            return []  
        finally:
            pyotherside.send('loadingFinished')             

# Create single instance
Bridge = SongkickBridge()

pyotherside.send('debug', f"Module loaded. ")