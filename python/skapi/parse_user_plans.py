from bs4 import BeautifulSoup
from .event import Event
import json
import pyotherside

def parse_user_plans(html_content, base_url):
    """Parse user events from HTML content
    Args:
        html_content (str): HTML content to parse
        base_url (str): Base URL for completing relative URLs
    Returns:
        list: List of parsed events
    """
    pyotherside.send('debug', f"parse_user_plans")

   # Log first part of HTML for debugging
    pyotherside.send('debug', f"HTML content preview: {html_content[:200]}")
        
    soup = BeautifulSoup(html_content, 'html.parser')
    results = []

    # Find events container
    events_container = soup.find('ul', class_='event-listings')
    if not events_container:
        pyotherside.send('debug', f"No calendar listings found.")
        return results

    # Process each event
    event_items = events_container.find_all('li', recursive=False)
    current_date = None

    for item in event_items:
        try:
            # Check if this is a date header
            time_elem = item.find('time')
            if 'with-date' in item.get('class', []):
                if time_elem:
                    current_date = time_elem.get('datetime')
                continue

            # Skip if no event data
            if not time_elem:
                continue

            # Get artist info
            artists = []
            _skid = 'N/A'
            artists_elem = item.find('p', class_='artists')
            if artists_elem:
                artist_strong = artists_elem.find('strong')   
                artist_href = artists_elem.find('a')
                _skid = artist_href.get('href') if artist_href else 'N/A'
                _skid = _skid.replace('/concerts/', '')

                if artist_strong:
                    artists.append(artist_strong.text.strip())

                # Get additional artists if present
                artist_span = artists_elem.find('span')
                if artist_span and artist_span.text and ',' in artist_span.text:
                    additional_artists = [a.strip() for a in artist_span.text.split(',') if a.strip()]
                    artists.extend(additional_artists)

            # Get venue info
            _venueName = 'N/A'
            _venueId = 'N/A'
            venue_elem = item.find('span', class_='venue-name')
            if venue_elem:
                venue_link = venue_elem.find('a')
                if venue_link:
                    _venueName = venue_link.text.strip()
                    _venueId = venue_link.get('href') if venue_link else 'N/A'

            # Get URL
            url = None
            event_link = item.find('a', href=True)
            if event_link:
                href = event_link.get('href')
                if href:
                    url = base_url + href if not href.startswith('http') else href

            # Get event status
            status = None
            attendance = item.find('div', class_='attendance')
            if attendance:
                selected_button = attendance.find('button', class_='selected')
                if selected_button:
                    status = selected_button.get('value')
            

            # New approach using microformat
            event = Event()
            mf = item.find('div', class_='microformat')
            if mf:
                scrpt = mf.find('script', type='application/ld+json')
            if scrpt:
                try:
                    mfdata = scrpt.string.strip()
                    json_data = json.loads(mfdata)
                    event['name'] = json_data[0]['name']
                    event['date'] = json_data[0]['startDate'] if 'startDate' in json_data[0] else current_date 
                    event['artistUrl'] = json_data[0]['performer'][0]['sameAs'].split('?')[0] if 'performer' in json_data[0] else None
                    event['artistImageUrl'] = json_data[0]['image'] if 'image' in json_data[0] else None
                    event['metroAreaName'] = json_data[0]['location']['address']['addressLocality'] if 'location' in json_data[0] else None
                    event['venueCity'] = json_data[0]['location']['address']['addressLocality'] if 'location' in json_data[0] else None 
                    event['venueCountry'] = json_data[0]['location']['address']['addressCountry'] if 'location' in json_data[0] else None
                    event['venuePostalCode'] = json_data[0]['location']['address']['postalCode'] if 'location' in json_data[0] else None    
                    event['venueStreetAddress'] = json_data[0]['location']['address']['streetAddress'] if 'location' in json_data[0] else None
                except json.JSONDecodeError as e:
                    pyotherside.send('debug', f"JSON decode error: {str(e)}")           
            starttime = None
            if current_date.__contains__('T'):
                starttime = current_date.split('T')[1]
            event['skid'] = _skid
            event['eventUrl'] = url
            event['eventType'] = 'concert'  # Placeholder for event type
            event['date'] = current_date
            event['startTime'] = starttime
            event['attendance'] = status
            event['artists'] = artists
            event['artistName'] = artists[0] if artists else 'N/A'
            event['artistId'] = event['artistUrl'].replace('https://www.songkick.com/artists/', '') if event['artistImageUrl'] else 'N/A'
            event['venueName'] = _venueName
            event['venueId'] = _venueId.replace('/venues/', '') if _venueId else 'N/A'
            # metro area could be searched in these areas at bottom of page using microformat data
            results.append(event)

        except Exception as e:
            pyotherside.send('debug', f"Error parsing event: {str(e)}")
            continue

    return results