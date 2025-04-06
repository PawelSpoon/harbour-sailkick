from bs4 import BeautifulSoup

def parse_location_events(html_content, base_url):
    """Parse location events from HTML content
    Args:
        html_content (str): HTML content to parse
        base_url (str): Base URL for completing relative URLs
    Returns:
        list: List of parsed events
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    results = []
    
    # Save parsed HTML for debugging
    with open("parsed_html.html", "w", encoding="utf-8") as f:
        f.write(str(soup.prettify()))

    # Find the main calendar listings container
    calendar_listings = soup.find('ul', class_='metro-area-calendar-listings')
    if not calendar_listings:
        return results
    
       # Find all event listings elements
    events = calendar_listings.find_all('li', class_='event-listings-element')
    
    for event in events:
        try:
            # Get date from time element
            time_elem = event.find('time')
            date = time_elem.get('datetime') if time_elem else 'N/A'

            # Get artist info
            artists_elem = event.find('p', class_='artists')
            artists = []
            if artists_elem:
                artist_name = artists_elem.find('strong')
                if artist_name:
                    artists = [artist_name.text.strip()]

            # Get venue info
            venue = 'N/A'
            location_elem = event.find('p', class_='location')
            if location_elem:
                venue_link = location_elem.find('a', class_='venue-link')
                if venue_link:
                    venue = venue_link.text.strip()

            # Get event URL
            url = None
            event_link = event.find('a', class_='event-link')
            if event_link and event_link.get('href'):
                url = base_url + event_link.get('href')

            if artists or venue != 'N/A':
                event_data = {
                    'artists': artists,
                    'venue': venue,
                    'date': date,
                    'url': url
                }
                results.append(event_data)

        except Exception as e:
            print(f"Error parsing location event: {str(e)}")
            continue

    return results