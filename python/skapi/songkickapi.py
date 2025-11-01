import sys
import os

# Add the application's Python path
sys.path.append('/usr/share/harbour-sailkick/python')

import requests
from bs4 import BeautifulSoup
import pickle
import pyotherside

from .parse_location_events import parse_location_events
from .parse_artist_events import parse_artist_events
from .parse_user_concerts import parse_user_concerts
from .parse_user_plans import parse_user_plans
from .parse_user_artists import parse_user_artists
from .parse_user_locations import parse_user_locations
from .parse_artist_meta import parse_artist_meta


class SongkickApi:
    def __init__(self, base_dir=None):
        # Use provided base_dir or default to user's home
        if base_dir is None:
            base_dir = os.path.join(os.path.expanduser('~'), '.local', 'share', 'harbour-sailkick')
 
        # Create debug and session directories in user's home
        pyotherside.send('debug', f"Base dir: {base_dir}")
        self.app_dir = base_dir
        self.session_dir = os.path.join(self.app_dir, 'session')
        self.debug_dir = os.path.join(self.app_dir, 'debug')
        
        # Create directories if they don't exist
        os.makedirs(self.session_dir, exist_ok=True)
        os.makedirs(self.debug_dir, exist_ok=True) 

        # Set session file path
        self.session_file = os.path.join(self.session_dir, "songkick_session.pkl")
        self.session_json_file = os.path.join(self.session_dir, "songkick_session.json")

        self.session = self.load_session() or requests.Session()
       
        self.base_url = "https://www.songkick.com"
        self.accounts_url = "https://accounts.songkick.com"

        # Base headers shared between both domains
        self.base_headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Cache-Control': 'max-age=0',
            'Upgrade-Insecure-Requests': '1'
        }
        
        # Specific headers for www.songkick.com
        self.sk_headers = {
            **self.base_headers,
            'authority': 'www.songkick.com',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Referer': 'https://www.songkick.com/',
            'sec-fetch-site': 'same-origin'
        }
        
        # Specific headers for accounts.songkick.com
        self.accounts_headers = {
            **self.base_headers,
            'authority': 'accounts.songkick.com',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
            'content-type': 'application/x-www-form-urlencoded',
            'origin': 'https://accounts.songkick.com',
            'sec-fetch-site': 'same-origin'
        }

    def save_session(self):
        """Save session to file with all cookies"""
        try:
            self.save_cookies(self.session, self.session_file)
            pyotherside.send('debug', f"Session saved with cookies: {self.session.cookies.get_dict()}")
        except Exception as e:
            pyotherside.send('debug', f"Error saving session: {e}")

    def _prepare_headers_with_cookies(self, base_headers=None):
        """Prepare headers with current cookies"""
        headers = base_headers.copy() if base_headers else self.sk_headers.copy()
        
        # Build cookie string from session cookies
        cookie_parts = []
        for name, value in self.session.cookies.items():
            cookie_parts.append(f"{name}={value}")
        #cookie_parts.append("auth_http_s=w_1z_bRUIkPoWT9avoQCMtPJnFaSy0Ld_Q7_RR6g8Ko0k40Sfi_yO_bHgX_P5WdhVOxTu1HqffMrY12XQC0LlSXOBi8tSmKWpM755UxBADXHx2pWTGmen0heG8KF8zSEu3m-Dg")
        
        if cookie_parts:
            headers['Cookie'] = '; '.join(cookie_parts)
            pyotherside.send('debug', f"Added cookies to headers: {headers['Cookie']}")
        
        return headers

    def load_session(self):
        """Load session from file if it exists"""
        if os.path.exists(self.session_file):
            try:
                session = requests.Session()
                self.load_cookies(session,self.session_file)
                return session
            except Exception as e:
                pyotherside.send('debug', f"Error loading session: {e}")
                return None
        return None
    
    def save_cookies(self,session, filename):
        if not os.path.isdir(os.path.dirname(filename)):
            return False
        with open(filename, 'wb') as f:
            f.truncate()
            pickle.dump(session.cookies._cookies, f)


    def load_cookies(self,session, filename):
        if not os.path.isfile(filename):
            return False

        with open(filename,'rb') as f:
            cookies = pickle.load(f)
            if cookies:
                jar = requests.cookies.RequestsCookieJar()
                jar._cookies = cookies
                session.cookies = jar
            else:
                return False

    def login(self, email, password):
        """Login to Songkick and save session"""
        #loaded_session = self.load_session()
        #if loaded_session:
        #    self.session = loaded_session
        password = 'spoonman'
        masked_pwd = '*' * len(password) if password else 'None'
        pyotherside.send('debug', f"Login attempt for user: {email}, pwd: {masked_pwd}")
 
        # First check if we have a valid session file
        if os.path.exists(self.session_file):
            pyotherside.send('debug', "Found existing session file, testing if valid")
            test_url = f"{self.base_url}/home"
            response = self.session.get(test_url, headers=self.sk_headers)
            
            if response.ok:
                soup = BeautifulSoup(response.text, 'html.parser')
                logged_in_indicators = [
                    soup.find('a', {'href': '/logout'}),
                    soup.find('a', href=lambda x: x and 'settings/account' in x),
                    not soup.find('a', class_='login-link'),
                    not soup.find('a', class_='signup-link')
                ]
                
                if any(logged_in_indicators):
                    pyotherside.send('debug', "Using existing valid session")
                    return True
                else:
                    pyotherside.send('debug', "Session file exists but is invalid")
        else:
            pyotherside.send('debug', "No session file found, performing fresh login")

        # If we get here, either no session exists or it was invalid
        self.session = requests.Session()
        
                    
        # Get the login page first
        login_url = f"{self.accounts_url}/session/new"
        params = {
            'source_product': 'skweb',
            'login_success_url': 'https://www.songkick.com/',
            'locale': 'en'
        }
        
        # Update headers for login request
        login_headers = {
            'authority': 'accounts.songkick.com',
            'method': 'POST',
            'scheme': 'https',
            'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'accept-encoding': 'gzip, deflate, br',
            'accept-language': 'en-US,en;q=0.9',
            'cache-control': 'max-age=0',
            'content-type': 'application/x-www-form-urlencoded',
            'eupubconsent-v2': 'CQGvIfAQGvIfAAcABBENBMFgAAAAAAAAAChQAAAU1gJAA4AM-AjwBKoDfAHbAO5AgoBIgCSgEowJkgTSAn2BRQCi0FGgUcApqAAA.YAAAAAAAAAAA',
            'origin': 'https://accounts.songkick.com',
            'referer':'https://accounts.songkick.com/session/new?source_product=skweb&login_success_url=https%3A%2F%2Fwww.songkick.com%2F&locale=en',
            'sec-ch-ua': '"Chromium";v="132", "Google Chrome";v="132", "Not A(Brand";v="8"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"Windows"',
            'sec-fetch-dest': 'document',
            'sec-fetch-mode': 'navigate',
            'sec-fetch-site': 'same-origin',
            'sec-fetch-user': '?1',
            'upgrade-insecure-requests': '1',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36'
        }
        
        # First get the login page
        response = self.session.get(login_url, params=params, headers=login_headers)
        pyotherside.send('debug', f"Login page response cookies: {dict(response.cookies)}")

        soup = BeautifulSoup(response.text, 'html.parser')

        # Save the page content for debugging
        with open("login_page.html", "w", encoding="utf-8") as f:
            f.write(response.text)
        print("Saved response to login_page.html")

        # Look for all hidden inputs in the form
        #<div class="component login-form accounts-form variant">
        #   <form id="login-form" action="/session" accept-charset="UTF-8" method="post">
        #     <input name="utf8" type="hidden" value="&#x2713;" autocomplete="off" />
        #     <input type="hidden" name="authenticity_token" value="ElbX/JefZeijexgJvSYQSmrxPzKXN/LobvwvoWPtgAaQCpW21ATaK91igscFijGjwQtzW4yzYhrXqg9MvdLOnQ==" autocomplete="off" />
     
        # Find the login form
        soup = BeautifulSoup(response.text, 'html.parser')
        login_form = soup.find('form', {'id': 'login-form'})
        pyotherside.send('debug', f"Login form found: {login_form is not None}")
        pyotherside.send('debug', f"Found form with action: {login_form.get('action', 'No action')}")

        # Extract the authenticity_token
        hidden_inputs = login_form.find_all('input', type='hidden')

        login_data = {}
        
        auth_token = None
        for hidden in hidden_inputs:
            name = hidden.get('name')
            value = hidden.get('value')
            if name:
                login_data[name] = value
                if (name == 'authenticity_token'):
                    auth_token = value

        if auth_token is None:
            pyotherside.send('debug', "No authenticity_token found!")
            return False    
        
        # Add login credentials and other required fields
        login_data.update({
            'username_or_email': email,
            'password': password,
            'source_product': 'skweb',
            'login_success_url': 'https://www.songkick.com/',
            'authenticity_token': auth_token,
        })
        
        # Use the correct POST URL from the form action
        post_url = f"{self.accounts_url}/session"
        
        # Perform login
        pyotherside.send('debug',f"Attempting login to: {post_url}")
        pyotherside.send('debug', {k: v for k, v in login_data.items() if 'password' not in k})  # Don't print password
        
        # Perform login POST request
        response = self.session.post('https://accounts.songkick.com/session', data=login_data, headers=login_headers)#, allow_redirects=True)
        #pyotherside.send('debug', f"Login response status: {response.status_code}")
        #pyotherside.send('debug', f"Login response URL: {response.url}")
        #pyotherside.send('debug', f"Login response HEADER: {response.headers}")
        #pyotherside.send('debug', f"Login response TEXT: {response.text}")
        #pyotherside.send('debug', f"Login response COOKIES: {response.cookies}")

        # Final cookie check
        auth_cookie = self.session.cookies.get('auth_http_s')
        session_cookie = self.session.cookies.get('_skweb_session')
        
        pyotherside.send('debug', f"Final auth_http_s: {auth_cookie[:10]}..." if auth_cookie else "No auth_http_s!")
        pyotherside.send('debug', f"Final _skweb_session: {session_cookie[:10]}..." if session_cookie else "No _skweb_session!")
       
        # Check if login was successful by checking final URL
        if response.ok:
            final_url = response.url
            if 'songkick.com' in final_url and '/login' not in final_url:
                # Debug all cookies after successful login
                pyotherside.send('debug', "Login successful, checking cookies")
                pyotherside.send('debug', f"Final cookies: {dict(self.session.cookies)}")
                
                # Verify specific cookies
                auth_cookie = self.session.cookies.get('auth_http_s')
                session_cookie = self.session.cookies.get('_skweb_session')
                
                if not auth_cookie or not session_cookie:
                    pyotherside.send('debug', "Warning: Required cookies not set!")
                    pyotherside.send('debug', f"auth_http_s: {auth_cookie is not None}")
                    pyotherside.send('debug', f"_skweb_session: {session_cookie is not None}")
                
                self.save_session()
                return True
            else:
                print("Login response OK but redirect indicates failure")
                pyotherside.send('debug', "Login response OK bur redirect indicates failure")
                # Save failed response for debugging
                with open("login_response.html", "w", encoding="utf-8") as f:
                    f.write(response.text)
                return False
        else:
            print("Login failed!")
            print("Response headers:", response.headers)
            pyotherside.send('debug', f"Login failed!")
            return False

    def is_logged_in(self):
        """Check if current session is valid"""
        test_url = f"{self.base_url}/home"
        response = self.session.get(test_url, headers=self.sk_headers)
        
        if response.ok:
            soup = BeautifulSoup(response.text, 'html.parser')
            logged_in_indicators = [
                soup.find('a', {'href': '/logout'}),
                soup.find('a', href=lambda x: x and 'settings/account' in x),
                not soup.find('a', class_='login-link'),
                not soup.find('a', class_='signup-link')
            ]
            return any(logged_in_indicators)
        return False

    def get_headers_for_url(self, url):
        """Get appropriate headers for a given URL
        Args:
            url (str): URL to get headers for
        Returns:
            dict: Headers appropriate for the URL"""
        if 'accounts.songkick.com' in url:
            headers = self.accounts_headers.copy()
        else:
            headers = self.sk_headers.copy()
        
        # Add cookies to headers
        cookie_parts = []
        for name, value in self.session.cookies.items():
            cookie_parts.append(f"{name}={value}")
        
        if cookie_parts:
            headers['Cookie'] = '; '.join(cookie_parts)
        
        pyotherside.send("debug", self.sk_headers)
        pyotherside.send("debug", self.accounts_headers)
        return headers
         
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
        response = self.session.get(search_url, params=params, headers=self.sk_headers)
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
                print(f"Error parsing search event: {e}")
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
    # ?filters%5BmaxDate%5D=&filters%5BminDate%5D=04%2F24%2F2025&page=2&utf8=✓#metro-area-calendar
    # ?page=2#metro-area-calendar
    # todo: date conversion
    def get_location_events(self, location_id, page, min_date=None):
        """Get events for a specific location
        Args:
            location_id (str): Location ID like '26766-austria-graz'
        """
        events_url = f"{self.base_url}/metro-areas/{location_id}"
        pyotherside.send('debug', f"Fetching events for location: {location_id} {page} {min_date}")
        
        # default page is 1
        if page is None:
            page = 1
        else :
            page = int(page)
        pyotherside.send('debug', f"Fetching events for location: {page} " + str(page > 1))

        # paging only    
        if min_date is None or min_date == '':
            if page > 1 : #and min_date is None:
                events_url += f"?page={page}"
        else:
            # mindate with/-out paging
            temp = min_date.split('-')
            min_date = temp[1] + '%2F' + temp[2] + '%2F' + temp[0]
            events_url += f"?filters%5BminDate%5D={min_date}"
            if page > 1:
                events_url += f"&page={page}"

        pyotherside.send('debug', f"Fetching events for location: {events_url}")
        response = self.session.get(events_url, headers=self.sk_headers)
        
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
        events_url = f"{self.base_url}/artists/{artist_id}/calendar"
        print(f"Fetching events for artist: {artist_id}/calendar")
        pyotherside.send('debug', f"Fetching events for artist: {artist_id}/calendar")

        response = self.session.get(events_url, headers=self.sk_headers)
        pyotherside.send('debug', f"Response status: {response.text}")
        
        if not response.ok:
            print("Failed to fetch events!")
            return []

        # Save response for debugging
        with open("get_artist_events_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_artist_events(response.text, self.base_url)
        print(f"Found {len(results)} events")

        # Extract artist meta like on-tour,  tracking status, track/untrack link
        meta = parse_artist_meta(response.text, self.base_url)

        # returning tupple with events and meta data
        return results, meta
    
    # shows events I am going to / or am interested in
    # probably paged but no date filtering is possible
    # https://www.songkick.com/calendar?filter=attendance
    def get_user_plans(self):
        """Get events users plans
        Args:
        Returns:
            list: List of events for the current user
        """
        if not self.is_logged_in():
            pyotherside.send('debug', "Not logged in when trying to get plans!")
            return []
        
        events_url = f"https://www.songkick.com/calendar?filter=attendance"
        print(f"Fetching plans for current user: {events_url}")
        pyotherside.send('debug', f"Fetching plans for current user: {events_url}")
  
        response = self.session.get(events_url, headers=self.sk_headers)
        pyotherside.send('debug', f"Response status: {response.status_code}")
        pyotherside.send('debug', f"URL: {response.url}")
         
        if not response.ok:
           pyotherside.send('debug', "Failed to fetch plans!")
           return []

        # Save response for debugging with proper path in home directory
        debug_dir = os.path.join(os.path.expanduser('~'), '.local', 'share', 'harbour-sailkick', 'debug')
        os.makedirs(debug_dir, exist_ok=True)
        
        debug_file = os.path.join(debug_dir, 'user_plans_response.html')
        with open(debug_file, "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_user_plans(response.text, self.base_url)
        pyotherside.send('debug', f"Found {len(results)} plans")

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
        
        #headers = self._prepare_headers_with_cookies(self.sk_headers)
        response = self.session.get(events_url, headers=self.sk_headers)
        print(f"Response status: {response.status_code}")
        print(f"URL: {response.url}")
        
        if not response.ok:
            print("Failed to fetch events!")
            return []

        # Save response for debugging
        with open("get_user_concerts_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_user_concerts(response.text, self.base_url)
        print(f"Found {len(results)} concerts")
        return results
    
    #https://www.songkick.com/tracker/artists
    #https://www.songkick.com/tracker/artists?page=2
    def get_user_artists(self,page=None):
        """Get tracked artists of current user
        Args:
        Returns:
            list: List of events for the current user
        """        
        events_url = f"https://www.songkick.com/tracker/artists"
        if page:
            events_url += f"?page={page}"

        pyotherside.send('debug', f"Fetching tracked artists for current user: {events_url},{self.sk_headers}")
        response = self.session.get(events_url, headers=self.sk_headers)
        
        if not response.ok:
            pyotherside.send('error', "Failed to fetch users arrtists!")
            return []

        # Save response for debugging
        with open("get_user_artists_response.html", "w", encoding="utf-8") as f:
            f.write(response.text)

        results = parse_user_artists(response.text, self.base_url)
        pyotherside.send('debug', f"Found {len(results)} tracked artists")
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
        
        response = self.session.get(events_url, headers=self.sk_headers)
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