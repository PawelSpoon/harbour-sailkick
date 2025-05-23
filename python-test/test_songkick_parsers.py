import unittest
import os
import sys

# how to runL $env:PYTHONPATH = "python;$env:PYTHONPATH" before running tests
#tests from project root
#cd c:\Users\janst\Source\SailfishOS\PawelSpoon\harbour-sailkick
#python -m unittest python-test/test_songkick_parsers.py -v

# Add project root to path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
python_dir = os.path.join(project_root, 'python')
sys.path.insert(0, python_dir)  # Insert at beginning of path


# Mock pyotherside before any imports that might use it
from unittest.mock import MagicMock
sys.modules['pyotherside'] = MagicMock()

# Import skapi modules
try:
    from skapi.songkickapi import SongkickApi
    from skapi.parse_location_events import parse_location_events
    from skapi.parse_artist_events import parse_artist_events
    from skapi.parse_user_plans import parse_user_plans
    from skapi.parse_user_concerts import parse_user_concerts
    from skapi.parse_user_artists import parse_user_artists
    from skapi.parse_user_locations import parse_user_locations
    from skapi.parse_artist_meta import parse_artist_meta
except ImportError as e:    
    print(f"Import error: {e}")
    print(f"Python path: {sys.path}")
    raise

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
                f.write(event.toMultilineString())
                f.write("-" * 50 + "\n")

        # Verify parsing results
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0)
        
        # Check first event structure
        first_event = results[0]
        self.assertIn('artists', first_event)
        self.assertIn('venueName', first_event)
        self.assertIn('date', first_event)
        self.assertIn('eventUrl', first_event)
        
        # Verify some known test data
        self.assertIsInstance(first_event['artists'], list)
        #self.assertIsInstance(first_event['venueName'], str)
        #self.assertIsInstance(first_event['date'], str)

    def test_parse_artist_akne_events_meta(self):
        """this file has some issues"""
        # Load test data
        test_file = os.path.join(self.test_data_dir, 'get_artist_no_events_response.html')
        
        # Ensure test data directory exists
        os.makedirs(self.test_data_dir, exist_ok=True)

        with open(test_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
            
        # Parse test data
        results = parse_artist_events(html_content,"https://www.songkick.com")  

        # Verify parsing results
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)

        meta = parse_artist_meta(html_content,"https://www.songkick.com")
        self.assertIsNotNone(meta)
        self.assertIsInstance(meta, dict)
        self.assertIn('onTour', meta)
        self.assertIn('tracking', meta)
        self.assertIn('imageUrl', meta)
        self.assertEqual(meta['onTour'], False)
        self.assertEqual(meta['tracking'], True)
        

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
                f.write(event.toMultilineString())
                f.write("-" * 50 + "\n")

        # Verify parsing results
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0)
        
        # Check first event structure
        first_event = results[0]
        self.assertIn('artists', first_event)
        #self.assertIn('venueName', first_event)
        self.assertIn('date', first_event)
        self.assertIn('eventUrl', first_event)
        
        # Verify some known test data
        self.assertIsInstance(first_event['artists'], list)
        #self.assertIsInstance(first_event['venueName'], str)
        #self.assertIsInstance(first_event['date'], str)     

    def test_parse_artist_meta(self):
        """Test parsing of artist events from test data"""
        # Load test data
        test_file = os.path.join(self.test_data_dir, 'get_artist_events_response.html')
        
        # Ensure test data directory exists
        os.makedirs(self.test_data_dir, exist_ok=True)

        with open(test_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
            
        # Parse test data
        result = parse_artist_meta(html_content,"https://www.songkick.com")
        
        # Save results to file for debugging
        debug_file = os.path.join(self.test_data_dir, 'parse_artist_meta_results.txt')
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write("Parsed Artist Meta:\n")          
            f.write(f"imageUrl: {result['imageUrl']}\n")
            f.write(f"onTour: {result['onTour']}\n")
            f.write(f"tracking: {result['tracking']}\n")
            #    f.write(event.toMultilineString())
            #    f.write("-" * 50 + "\n")

        self.assertEqual(result['onTour'], True)
        self.assertEqual(result['tracking'], False)


    def test_parse_user_plans(self):
        """Test parsing of user plans from test data"""
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
                f.write(event.toMultilineString())
                f.write("-" * 50 + "\n")                

        # Verify parsing results
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0)
        
        # Check first event structure
        first_event = results[0]    
        # Verify some known test data
        #self.assertIsInstance(first_event['artists'], list)
        self.assertIsInstance(first_event['venueName'], str)
 

    def test_parse_user_concerts(self):
        """Test parsing of users concerts from test data"""
        # Load test data
        test_file = os.path.join(self.test_data_dir, 'get_user_concerts_response.html')
        
        # Ensure test data directory exists
        os.makedirs(self.test_data_dir, exist_ok=True)

        with open(test_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
            
        # Parse test data
        results = parse_user_concerts(html_content,"https://www.songkick.com")

        # Save results to file for debugging
        debug_file = os.path.join(self.test_data_dir, 'parse_user_concerts_results.txt')
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write("Parsed Events:\n")          
            for i, event in enumerate(results, 1):
                f.write(f"Event {i}:\n")
                f.write(event.toMultilineString())
                f.write("-" * 50 + "\n")                

        # Verify parsing results
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0)
        
        # Check first event structure
        first_event = results[0]
        self.assertIn('artists', first_event)
        self.assertIn('venueName', first_event)
        self.assertIn('date', first_event)
        self.assertIn('eventUrl', first_event)
        
        # Verify some known test data
        self.assertIsInstance(first_event['artists'], list)
        self.assertIsInstance(first_event['venueName'], str)
        self.assertIsInstance(first_event['date'], str)   

    def test_parse_user_artists(self):
        """Test parsing of users tracked artists"""
        # Load test data
        test_file = os.path.join(self.test_data_dir, 'get_user_artists_response.html')
        
        # Ensure test data directory exists
        os.makedirs(self.test_data_dir, exist_ok=True)

        with open(test_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
            
        # Parse test data
        results = parse_user_artists(html_content,"https://www.songkick.com")

        # Save results to file for debugging
        debug_file = os.path.join(self.test_data_dir, 'parse_user_artists_results.txt')
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write(f"Found {len(results)} tracked artists\n\n")
            for i, artist in enumerate(results, 1):
                f.write(f"Artist {i}:\n")
                f.write(f"name: {artist['name']}\n")
                f.write(f"url: {artist['url']}\n")
                f.write(f"image_url: {artist['image_url']}\n")
                f.write(f"id: {artist['id']}\n")
                f.write(f"body: {artist['body']}\n")
                f.write("-" * 50 + "\n")

        # Verify structure
        self.assertTrue(results)
        self.assertIsInstance(results, list)
        
        # Check first artist data
        if results:
            artist = results[0]
            self.assertIn('name', artist)
            self.assertIn('url', artist)
            self.assertIn('image_url', artist)
            self.assertIn('id', artist)
 
    def test_parse_user_locations(self):
        """Test parsing of users tracked locations"""
        # Load test data
        test_file = os.path.join(self.test_data_dir, 'get_user_locations_response.html')
        
        # Ensure test data directory exists
        os.makedirs(self.test_data_dir, exist_ok=True)

        with open(test_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
            
        # Parse test data
        results = parse_user_locations(html_content,"https://www.songkick.com")

        # Save results to file for debugging
        debug_file = os.path.join(self.test_data_dir, 'parse_user_locations_results.txt')
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write(f"Found {len(results)} tracked locations\n\n")
            for i, artist in enumerate(results, 1):
                f.write(f"Artist {i}:\n")
                f.write(f"name: {artist['name']}\n")
                f.write(f"url: {artist['url']}\n")
                f.write(f"image_url: {artist['image_url']}\n")
                f.write(f"id: {artist['id']}\n")
                f.write(f"body: {artist['body']}\n")
                f.write("-" * 50 + "\n")                

        # Verify structure
        self.assertTrue(results)
        self.assertIsInstance(results, list)
        
        # Check first artist data
        if results:
            artist = results[0]
            self.assertIn('name', artist)
            self.assertIn('url', artist)
            self.assertIn('id', artist)
 