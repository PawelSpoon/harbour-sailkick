import sys
import os

# Add the application's Python path
sys.path.append('/usr/share/harbour-sailkick/python')

import requests
from bs4 import BeautifulSoup
import pickle
from parse_location_events import parse_location_events
from parse_artist_events import parse_artist_events
from parse_user_concerts import parse_user_concerts
from parse_user_plans import parse_user_plans
from parse_user_artists import parse_user_artists
from parse_user_locations import parse_user_locations


class SongkickApi:
    def __init__(self):
        self.session_file = "songkick_session.pkl"
        self.session = self.load_session() or requests.Session()        
        self.base_url = "https://www.songkick.com"
        self.accounts_url = "https://accounts.songkick.com"
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Referer': 'https://www.songkick.com/'
        }

    def save_session(self):
        """Save session to file"""
        with open(self.session_file, 'wb') as f:
            pickle.dump(self.session.cookies, f)
        print(f"Session saved to {self.session_file}")

    def load_session(self):
        """Load session from file if it exists"""
        if os.path.exists(self.session_file):
            try:
                session = requests.Session()
                with open(self.session_file, 'rb') as f:
                    session.cookies.update(pickle.load(f))
                print(f"Session loaded from {self.session_file}")
                return session
            except Exception as e:
                print(f"Error loading session: {e}")
                return None
        return None
    
    def login(self, email, password):
        """Login to Songkick and save session"""
        #loaded_session = self.load_session()
        #if loaded_session:
        #    self.session = loaded_session
        # Test if session is still valid using a public page
        test_url = f"{self.base_url}/home"
        response = self.session.get(test_url, headers=self.headers)
        
        print(f"Session test response status: {response.status_code}")
        print(f"Session test URL: {response.url}")
        
        if response.ok:
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Look for elements that indicate we're logged in
            logged_in_indicators = [
                soup.find('a', {'href': '/logout'}),  # Logout link
                soup.find('a', href=lambda x: x and 'settings/account' in x),  # Account settings link
                not soup.find('a', class_='login-link'),  # No login link (means we're logged in)
                not soup.find('a', class_='signup-link')  # No signup link (means we're logged in)
            ]
            
            if any(logged_in_indicators):
                print("Using existing session")
                return True
            else:
                print("Session exists but appears invalid - elements found:")
                for i, indicator in enumerate(logged_in_indicators):
                    print(f"Indicator {i}: {indicator}")

        # If we get here, either no session was loaded or it was invalid
        self.session = requests.Session()   
                    
        # Get the login page first
        login_url = f"{self.accounts_url}/session/new"
        params = {
            'source_product': 'skweb',
            'login_success_url': 'https://www.songkick.com/',
            'locale': 'en'
        }
        
        # Update headers for login
        self.headers.update({
            'Origin': 'https://accounts.songkick.com',
            'Content-Type': 'application/x-www-form-urlencoded'
        })
        
        # First get the login page to extract csrf token
        print(f"Fetching login page: {login_url}")
        response = self.session.get(login_url, params=params, headers=self.headers)
        print(f"Status code: {response.status_code}")
        print(f"Final URL: {response.url}")
        
        soup = BeautifulSoup(response.text, 'html.parser')

        # Save the page content for debugging
        with open("login_page.html", "w", encoding="utf-8") as f:
            f.write(response.text)
        print("Saved response to login_page.html")

        # Look for the form
        form = soup.find('form')
        if not form:
            print("Could not find form")
            return False
            
        print(f"Found form with action: {form.get('action', 'No action')}")
        
        # Look for all hidden inputs in the form
        hidden_inputs = form.find_all('input', type='hidden')
        login_data = {}
        
        for hidden in hidden_inputs:
            name = hidden.get('name')
            value = hidden.get('value')
            if name:
                login_data[name] = value
                print(f"Found hidden input: {name}")
        
        # Add login credentials and other required fields
        login_data.update({
            'user[email]': email,
            'user[password]': password,
            'source_product': 'skweb',
            'login_success_url': 'https://www.songkick.com/'
        })
        
        # Use the correct POST URL from the form action
        post_url = f"{self.accounts_url}/session"
        
        # Perform login
        print(f"Attempting login to: {post_url}")
        print("Login data:", {k: v for k, v in login_data.items() if 'password' not in k})  # Don't print password
        
        response = self.session.post(post_url, data=login_data, headers=self.headers, allow_redirects=True)
        print(f"Login response status: {response.status_code}")
        print(f"Login response URL: {response.url}")
        
        # Check if login was successful by checking final URL
        if response.ok:
            final_url = response.url
            if 'songkick.com' in final_url and '/login' not in final_url:
                print("Login successful!")
                self.save_session()  # Save session after successful login
                return True
            else:
                print("Login response OK but redirect indicates failure")
                # Save failed response for debugging
                with open("login_response.html", "w", encoding="utf-8") as f:
                    f.write(response.text)
                return False
        else:
            print("Login failed!")
            print("Response headers:", response.headers)
            return False
        
    def search(self, query, search_type):
        """Search Songkick
        Args:
            query (str): Search term
            search_type (str): Type of search - 'locations', 'artists', or 'venues'
        """
        search_url = f"{self.base_url}/search"
        params = {
            'utf8': '✓',
            'type': search_type,
            'query': query,
            'commit': 'Search'
        }
        
        print(f"Searching for: {query}")
        response = self.session.get(search_url, params=params, headers=self.headers)
        print(f"Search response status: {response.status_code}")

        print(f"Search URL: {response.url}")
        
        if not response.ok:
            print("Search failed!")
            print("Response headers:", response.headers)
            return []

        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Save search response for debugging
        with open("search_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)
            
        # Select parser based on search type
        parser_map = {
            'events': self._parse_events,
            'artists': self._parse_artists,
            'locations': self._parse_locations
        }
        
        parser = parser_map.get(search_type)
        if not parser:
            print(f"Unsupported search type: {search_type}")
            return []
            
        results = parser(soup)
        print(f"Found {len(results)} {search_type}")
        return results
            
    def _parse_events(self, soup):
        """Parse event search results"""
        results = []
        events = soup.find_all('li', class_='event-listing')
        
        for event in events:
            try:
                event_data = {
                    'artist': event.find('p', class_='artists').text.strip() if event.find('p', class_='artists') else 'N/A',
                    'venue': event.find('p', class_='venue').text.strip() if event.find('p', class_='venue') else 'N/A',
                    'date': event.find('time').text.strip() if event.find('time') else 'N/A',
                    'link': self.base_url + event.find('a')['href'] if event.find('a') else None
                }
                results.append(event_data)
            except AttributeError as e:
                print(f"Error parsing event: {e}")
                continue
        return results

    def _parse_artists(self, soup):
        """Parse artist search results"""
        results = []
        artists = soup.find_all('li', class_='artist')
        
        for artist in artists:
            try:
                link_elem = artist.find('a', class_='search-link')
                subject = artist.find('div', class_='subject')
                
                artist_data = {
                    'name': subject.find('strong').text.strip() if subject.find('strong') else 'N/A',
                    'id': link_elem.get('data-id') if link_elem else None,
                    'url': self.base_url + link_elem.get('href') if link_elem else None,
                    'upcoming_events': subject.text.split('upcoming events')[0].strip().split('\n')[-1] if 'upcoming events' in subject.text else '0'
                }
                results.append(artist_data)
            except AttributeError as e:
                print(f"Error parsing artist: {e}")
                continue
        return results

    def _parse_locations(self, soup):
        """Parse location search results"""
        results = []
        # Looking for small-city class instead of location
        locations = soup.find_all('li', class_='small-city')
        
        for location in locations:
            try:
                # Get the link element which contains most of the data
                link_elem = location.find('a', class_='search-link')
                subject = location.find('div', class_='subject')
                summary = subject.find('p', class_='summary') if subject else None
                
                # Extract location data
                location_data = {
                    'name': summary.find('strong').text.strip() if summary and summary.find('strong') else 'N/A',
                    'id': link_elem.get('data-id') if link_elem else None,
                    'url': self.base_url + link_elem.get('href') if link_elem else None,
                    # Some locations include additional areas
                    'includes': summary.text.split('including ')[-1].strip() if summary and 'including' in summary.text else None
                }
                results.append(location_data)
            except AttributeError as e:
                print(f"Error parsing location: {e}")
                continue
                
        return results
    
    # this page has min and max date and filters for genre etc.
    # could be extended
    def get_location_events(self, location_id):
        """Get events for a specific location
        Args:
            location_id (str): Location ID like '26766-austria-graz'
        """
        events_url = f"{self.base_url}/metro-areas/{location_id}"
        print(f"Fetching events for location: {location_id}")
        
        response = self.session.get(events_url, headers=self.headers)
        print(f"Response status: {response.status_code}")
        print(f"URL: {response.url}")
        
        if not response.ok:
            print("Failed to fetch events!")
            return []

        # Save search response for debugging
        with open("get_location_events_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_location_events(response.text, self.base_url)
        print(f"Found {len(results)} events")
        return results

    # on tour yes/no
    # tracking on/off
    # upcoming events but no date filtering
    def get_artist_events(self, artist_id):
        """Get events for a specific artist
        Args:
            artist_id (str): Artist ID like '549892-a-perfect-circle'
        Returns:
            list: List of events for the artist
        """
        events_url = f"{self.base_url}/artists/{artist_id}"
        print(f"Fetching events for artist: {artist_id}")
        
        response = self.session.get(events_url, headers=self.headers)
        print(f"Response status: {response.status_code}")
        print(f"URL: {response.url}")
        
        if not response.ok:
            print("Failed to fetch events!")
            return []

        # Save response for debugging
        with open("get_artist_events_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_artist_events(response.text, self.base_url)
        print(f"Found {len(results)} events")
        return results
    
    # shows events I am going to / or am interested in
    # probably paged but no date filtering is possible
    # https://www.songkick.com/calendar?filter=attendance
    def get_user_plans(self):
        """Get events users plans
        Args:
        Returns:
            list: List of events for the current user
        """
        events_url = f"https://www.songkick.com/calendar?filter=attendance"
        print(f"Fetching plans for current user")
        
        response = self.session.get(events_url, headers=self.headers)
        print(f"Response status: {response.status_code}")
        print(f"URL: {response.url}")
        
        if not response.ok:
            print("Failed to fetch events!")
            return []

        # Save response for debugging
        with open("get_user_plans_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_user_plans(response.text, self.base_url)
        print(f"Found {len(results)} events")
        return results


    # shows events in my areas
    # paged but no date filtering is possible
    # https://www.songkick.com/calendar?filter=tracked_artist
    def get_user_concerts(self):
        """Get events users concerts
        Args:
        Returns:
            list: List of events for the current user
        """
        events_url = f"https://www.songkick.com/calendar?filter=tracked_artist"
        print(f"Fetching plans for current user")
        
        response = self.session.get(events_url, headers=self.headers)
        print(f"Response status: {response.status_code}")
        print(f"URL: {response.url}")
        
        if not response.ok:
            print("Failed to fetch events!")
            return []

        # Save response for debugging
        with open("get_user_concerts_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_user_concerts(response.text, self.base_url)
        print(f"Found {len(results)} events")
        return results
    
    #https://www.songkick.com/tracker/artists
    def get_user_artists(self):
        """Get tracked artists of current user
        Args:
        Returns:
            list: List of events for the current user
        """        
        events_url = f"https://www.songkick.com/tracker/artists"
        print(f"Fetching tracked artists for current user")
        
        response = self.session.get(events_url, headers=self.headers)
        print(f"Response status: {response.status_code}")
        print(f"URL: {response.url}")
        
        if not response.ok:
            print("Failed to fetch events!")
            return []

        # Save response for debugging
        with open("get_user_artists_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_user_artists(response.text, self.base_url)
        print(f"Found {len(results)} tracked artists")
        return results
    
    #https://www.songkick.com/tracker/metro_areas
    def get_user_locations(self):
        """Get tracked locations of current user
        Args:
        Returns:
            list: List of events for the current user
        """
        events_url = f"https://www.songkick.com/tracker/metro_areas"
        print(f"Fetching tracked locations for current user")
        
        response = self.session.get(events_url, headers=self.headers)
        print(f"Response status: {response.status_code}")
        print(f"URL: {response.url}")
        
        if not response.ok:
            print("Failed to fetch locations!")
            return []

        # Save response for debugging
        with open("get_user_locations_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_user_locations(response.text, self.base_url)
        print(f"Found {len(results)} tracked locations")
        return results