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
        cls.email = "pawel@ich-habe-fertig.com"
        cls.password = "spoonman"
        # Ensure we're logged in for tests
        cls.assertTrue(cls.api.login(cls.email, cls.password), "Login failed")
    
    @classmethod
    def tearDownClass(cls):
        """Clean up after all tests are done."""
        session_file = os.path.join(cls.test_session_dir, "songkick_session.pkl")
        if os.path.exists(session_file):
            os.remove(session_file)
        if os.path.exists(cls.test_data_dir):
            import shutil
            shutil.rmtree(cls.test_data_dir)

    def test_get_user_plans(self):
        """Test getting tracked artists for logged-in user"""
        results = self.api.get_user_plans()
        self.assertIsNotNone(results)
        self.assertIsInstance(results, list)
        self.assertGreater(len(results), 0, "No tracked artists for user found")



if __name__ == '__main__':
    unittest.main()