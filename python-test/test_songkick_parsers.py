import unittest
import os
from python.songkick_api import SongkickApi
from python.parse_location_events import parse_location_events
from python.parse_artist_events import parse_artist_events
from python.parse_user_plans import parse_user_plans
#from python.parse_user_concerts import parse_user_concerts


class TestSongkickParsers(unittest.TestCase):
    def setUp(self):
        self.api = SongkickApi()
        self.test_data_dir = os.path.join(os.path.dirname(__file__), 'test-data')
  
        
    def test_parse_location_events(self):
        """Test parsing of location events from test data"""
        # Load test data
        test_file = os.path.join(self.test_data_dir, 'get_location_events_response.html')
        
        # Ensure test data directory exists
        os.makedirs(self.test_data_dir, exist_ok=True)

        with open(test_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
            
        # Parse test data
        results = parse_location_events(html_content,"https://www.songkick.com")
        
        # Save results to file for debugging
        debug_file = os.path.join(self.test_data_dir, 'parse_location_results.txt')
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write("Parsed Events:\n")          
            for i, event in enumerate(results, 1):
                f.write(f"Event {i}:\n")
                f.write(f"Artists: {event.get('artists', [])}\n")
                f.write(f"Venue: {event.get('venue', 'N/A')}\n")
                f.write(f"Date: {event.get('date', 'N/A')}\n")
                f.write(f"URL: {event.get('url', 'N/A')}\n")
                f.write("-" * 50 + "\n")

        # Verify parsing results
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0)
        
        # Check first event structure
        first_event = results[0]
        self.assertIn('artists', first_event)
        self.assertIn('venue', first_event)
        self.assertIn('date', first_event)
        self.assertIn('url', first_event)
        
        # Verify some known test data
        self.assertIsInstance(first_event['artists'], list)
        self.assertIsInstance(first_event['venue'], str)
        self.assertIsInstance(first_event['date'], str)

    def test_parse_artist_events(self):
        """Test parsing of artist events from test data"""
        # Load test data
        test_file = os.path.join(self.test_data_dir, 'get_artist_events_response.html')
        
        # Ensure test data directory exists
        os.makedirs(self.test_data_dir, exist_ok=True)

        with open(test_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
            
        # Parse test data
        results = parse_artist_events(html_content,"https://www.songkick.com")
        
        # Save results to file for debugging
        debug_file = os.path.join(self.test_data_dir, 'parse_artist_results.txt')
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write("Parsed Events:\n")          
            for i, event in enumerate(results, 1):
                f.write(f"Event {i}:\n")
                f.write(f"Artists: {event.get('artists', [])}\n")
                f.write(f"Venue: {event.get('venue', 'N/A')}\n")
                f.write(f"Date: {event.get('date', 'N/A')}\n")
                f.write(f"URL: {event.get('url', 'N/A')}\n")
                f.write("-" * 50 + "\n")

        # Verify parsing results
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0)
        
        # Check first event structure
        first_event = results[0]
        self.assertIn('artists', first_event)
        self.assertIn('venue', first_event)
        self.assertIn('date', first_event)
        self.assertIn('url', first_event)
        
        # Verify some known test data
        self.assertIsInstance(first_event['artists'], list)
        self.assertIsInstance(first_event['venue'], str)
        self.assertIsInstance(first_event['date'], str)     

    def test_parse_user_plans(self):
        """Test parsing of location events from test data"""
        # Load test data
        test_file = os.path.join(self.test_data_dir, 'get_user_plans_response.html')
        
        # Ensure test data directory exists
        os.makedirs(self.test_data_dir, exist_ok=True)

        with open(test_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
            
        # Parse test data
        results = parse_user_plans(html_content,"https://www.songkick.com")

        # Save results to file for debugging
        debug_file = os.path.join(self.test_data_dir, 'parse_user_plans_results.txt')
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write("Parsed Events:\n")          
            for i, event in enumerate(results, 1):
                f.write(f"Event {i}:\n")
                f.write(f"Artists: {event.get('artists', [])}\n")
                f.write(f"Venue: {event.get('venue', 'N/A')}\n")
                f.write(f"Date: {event.get('date', 'N/A')}\n")
                f.write(f"URL: {event.get('url', 'N/A')}\n")
                f.write("-" * 50 + "\n")                

        # Verify parsing results
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0)
        
        # Check first event structure
        first_event = results[0]
        self.assertIn('artists', first_event)
        self.assertIn('venue', first_event)
        self.assertIn('date', first_event)
        self.assertIn('url', first_event)
        
        # Verify some known test data
        self.assertIsInstance(first_event['artists'], list)
        self.assertIsInstance(first_event['venue'], str)
        self.assertIsInstance(first_event['date'], str)  