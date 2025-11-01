from bs4 import BeautifulSoup
from .event import Event
import json

def parse_artist_events(html_content, base_url):
    """Parse artist events from HTML content with calendar format
    Args:
        html_content (str): HTML content to parse
        base_url (str): Base URL for completing relative URLs
    Returns:
        list: List of parsed events
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    results = []

    # Get artist name from header
    artist_name = None
    artist_header = soup.find('div', class_='brief')
    if artist_header:
        title = artist_header.find('h1', class_='title-copy')
        if title:
            full_text = title.text.strip()
            artist_name = full_text.split('tour dates')[0].strip()

    # Find the upcoming events section
    calendar_listings = soup.find('ol', class_='event-listings tour-calendar-summary dynamic-ad-container')
    if not calendar_listings:
        print("No calendar listings found.")
        return results

    # Find all event listings elements
    events = calendar_listings.find_all('li', class_='event-listing')
    
    for event in events:
        try:
            myEvent = Event()
            
            # Get event data from microformat JSON-LD
            microformat = event.find('div', class_='microformat')
            if microformat and microformat.script:
                try:
                    json_data = json.loads(microformat.script.string)[0]
                    
                    # Extract event details
                    myEvent['eventUrl'] = json_data.get('url', '').split('?')[0]  # Remove tracking parameters
                    myEvent['artists'] = [artist_name] if artist_name else []
                    myEvent['artistName'] = artist_name
                    myEvent['date'] = json_data.get('startDate', 'N/A')
                    
                    # Extract venue details
                    location = json_data.get('location', {})
                    myEvent['venueName'] = location.get('name', 'N/A')
                    address = location.get('address', {})
                    myEvent['venueCity'] = address.get('addressLocality', 'N/A')
                    myEvent['venueCountry'] = address.get('addressCountry', 'N/A')
                    myEvent['venueStreet'] = address.get('streetAddress', 'N/A')
                    myEvent['venuePostalCode'] = address.get('postalCode', 'N/A')
                    
                    # Extract time from startDate if available
                    if 'T' in myEvent['date']:
                        myEvent['startTime'] = myEvent['date'].split('T')[1]
                    else:
                        myEvent['startTime'] = 'N/A'
                        
                    myEvent['name'] = myEvent['venueCity']
                    myEvent['metroAreaName'] = myEvent['venueCity']
                    myEvent['attendance'] = 'N/A'

                except json.JSONDecodeError as e:
                    print(f"Error parsing JSON-LD: {str(e)}")
                    continue

            results.append(myEvent)

        except Exception as e:
            print(f"Error parsing event: {str(e)}")
            continue

    return results