import unittest
import os
import sys

# Add project root to path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
python_dir = os.path.join(project_root, 'python')
sys.path.insert(0, python_dir)  # Insert at beginning of path

# Mock pyotherside before any imports that might use it
from unittest.mock import MagicMock
sys.modules['pyotherside'] = MagicMock()

from skapi.songkickapi import SongkickApi

class TestSongkickApi(unittest.TestCase):
    def setUp(self):
        """Set up test fixtures before each test method."""
        self.api = SongkickApi()
        self.email = "pawel@ich-habe-fertig.com"
        self.password = "spoonman"
        # Ensure we're logged in for tests
        self.assertTrue(self.api.login(self.email, self.password), "Login failed")

    def test_location_search(self):
        """Test searching for locations"""
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
        results = self.api.get_location_events(location_id)
        self.assertIsNotNone(results, "Get events returned None")
        self.assertGreater(len(results), 0, "No location events found")

    def test_get_artist_events(self):
        """Test getting events for a specific artist"""
        # Use A Perfect Circle as test case
        results = self.api.get_artist_events("549892-a-perfect-circle")
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        
        # If any events found, check their structure
        if results:
            event = results[0]
            self.assertIn('artists', event)
            self.assertIn('venue', event)
            self.assertIn('date', event)
            self.assertIn('url', event)

    def test_get_user_plans(self):
        """Test getting plans for logged in user"""
        # Use A Perfect Circle as test case
        results = self.api.get_user_plans()
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        
        # If any events found, check their structure
        if results:
            event = results[0]
            self.assertIn('artists', event)
            self.assertIn('venue', event)
            self.assertIn('date', event)
            self.assertIn('url', event)   

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
            self.assertIn('venue', event)
            self.assertIn('date', event)
            self.assertIn('url', event)  

    def test_get_user_artists(self):
        """Test getting tracked artists for logged-in user"""
        results = self.api.get_user_artists()
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)

    def test_get_user_locations(self):
        """Test getting tracked artists for logged-in user"""
        results = self.api.get_user_locations()
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)        

if __name__ == '__main__':
    unittest.main()