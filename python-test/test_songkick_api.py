import unittest
import os
import sys
import tempfile

# Add project root to path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
python_dir = os.path.join(project_root, 'python')
sys.path.insert(0, python_dir)  # Insert at beginning of path

# Mock pyotherside before any imports that might use it
from unittest.mock import MagicMock

# Create a mock that prints debug messages
class DebugMock:
    def __init__(self):
        self.messages = []    
    def send(self, type, message):
        if type == 'debug':
            print(f"DEBUG: {message}", file=sys.stderr, flush=True)
          
# Create singleton instance
debug_mock = DebugMock()
sys.modules['pyotherside'] = debug_mock

from skapi.songkickapi import SongkickApi

# Setup test environment
test_dir = os.path.dirname(os.path.abspath(__file__))
test_data_dir = os.path.join(test_dir, 'test_data')
os.makedirs(test_data_dir, exist_ok=True)

class TestSongkickApi(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up test fixtures once for all tests."""
        cls.test_dir = os.path.dirname(os.path.abspath(__file__))
        cls.test_data_dir = os.path.join(cls.test_dir, 'test_data')
        cls.test_session_dir = os.path.join(cls.test_data_dir, 'session')
        os.makedirs(cls.test_session_dir, exist_ok=True)
        print(f"Using temporary directory: {cls.test_data_dir}")
        cls.api = SongkickApi(base_dir=cls.test_session_dir)
    
    def setUp(self):
        """Set up test fixtures before each test method."""
        self.api = SongkickApi(base_dir=self.test_session_dir)
        self.email = "talk@ich-habe-fertig.com"
        self.password = "spoonman"
        # Ensure we're logged in for tests
        self.assertTrue(self.api.login(self.email, self.password), "Login failed")

    @classmethod
    def tearDownClass(cls):
        """Clean up after all tests are done."""
        session_file = os.path.join(cls.test_session_dir, "songkick_session.pkl")
        if os.path.exists(session_file):
            os.remove(session_file)
        if os.path.exists(cls.test_data_dir):
            import shutil
            shutil.rmtree(cls.test_data_dir)


    def test_location_search(self):
        """Test searching for locations"""
        self.api.login(self.email, self.password)
        results = self.api.search("Graz", "locations")
        self.assertIsNotNone(results, "Search returned None")
        self.assertGreater(len(results), 0, "No locations found")

    def test_artist_search(self):
        """Test searching for artists"""
        results = self.api.search("Pixies", "artists")
        self.assertIsNotNone(results, "Search returned None")
        self.assertGreater(len(results), 0, "No artists found")
        
    def test_location_events(self):
        """Test getting events for a location"""
        location_id = "26766-austria-graz"
        results = self.api.get_location_events(location_id,1)
        self.assertIsNotNone(results, "Get events returned None")
        self.assertGreater(len(results), 0, "No location events found")
        if results:
            event = results[0]
            self.assertIn('artists', event)
            self.assertIn('venueName', event)
            self.assertIn('date', event)
            self.assertIn('eventUrl', event)

    def test_get_artist_events(self):
        """Test getting events for a specific artist"""
        # Use A Perfect Circle as test case
        results, meta  = self.api.get_artist_events("549892-a-perfect-circle")
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0, "No artist events")
     
        # If any events found, check their structure
        if results:
            event = results[0]
            self.assertIn('artists', event)
            self.assertIn('venueName', event)
            self.assertIn('date', event)
            self.assertIn('eventUrl', event)

    def test_get_user_plans(self):
        """Test getting plans for logged in user"""
        # Use A Perfect Circle as test case
        results = self.api.get_user_plans()
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0, "No tracked artists for user found")
        
        # If any events found, check their structure
        if results:
            event = results[0]
            self.assertIn('artists', event)
            self.assertIn('venueName', event)
            self.assertIn('date', event)
            self.assertIn('eventUrl', event)   

    def test_get_user_concerts(self):
        """Test getting concerts for logged-in user"""
        # Use A Perfect Circle as test case
        results = self.api.get_user_concerts()
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        
        # If any events found, check their structure
        if results:
            event = results[0]
            self.assertIn('artists', event)
            self.assertIn('venueName', event)
            self.assertIn('date', event)
            self.assertIn('eventUrl', event)  

    def test_get_user_artists(self):
        """Test getting tracked artists for logged-in user"""
        results = self.api.get_user_artists()
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0, "No tracked artists for user found")

    def test_get_user_locations(self):
        """Test getting tracked artists for logged-in user"""
        results = self.api.get_user_locations()
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0, "No tracked locations for user found")


if __name__ == '__main__':
    unittest.main()