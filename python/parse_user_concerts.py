from bs4 import BeautifulSoup

def parse_user_concerts(html_content, base_url):
    """Parse user concerts from HTML content
    Args:
        html_content (str): HTML content to parse
        base_url (str): Base URL for completing relative URLs
    Returns:
        list: List of parsed events
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    results = []

    # Find events container
    events_container = soup.find('ul', class_='event-listings')
    if not events_container:
        print("No calendar listings found.")
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
            artists_elem = item.find('p', class_='artists')
            if artists_elem:
                artist_strong = artists_elem.find('strong')
                if artist_strong:
                    artists.append(artist_strong.text.strip())
                # Get additional artists if present
                artist_span = artists_elem.find('span')
                if artist_span and artist_span.text and ',' in artist_span.text:
                    additional_artists = [a.strip() for a in artist_span.text.split(',') if a.strip()]
                    artists.extend(additional_artists)

            # Get venue info
            venue = 'N/A'
            venue_elem = item.find('span', class_='venue-name')
            if venue_elem:
                venue_link = venue_elem.find('a')
                if venue_link:
                    venue = venue_link.text.strip()

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

            event_data = {
                'artists': artists,
                'venue': venue,
                'date': current_date,
                'url': url,
                'status': status
            }
            results.append(event_data)

        except Exception as e:
            print(f"Error parsing event: {str(e)}")
            continue

    return results