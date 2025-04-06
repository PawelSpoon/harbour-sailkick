from bs4 import BeautifulSoup

def parse_artist_events(html_content, base_url):
    """Parse artist events from HTML content
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
    artist_header = soup.find('h1', class_='h0')
    if artist_header:
        artist_name = artist_header.text.strip()

    # Save parsed HTML for debugging
    with open("parsed_html.html", "w", encoding="utf-8") as f:
        f.write(str(soup.prettify()))

    # Find the main calendar listings container  event-listings artist-calendar-summary 
    calendar_listings = soup.find('ol', class_='event-listings artist-calendar-summary')
    if not calendar_listings:
        print("No calendar listings found.")
        return results

    # Find all event listings elements
    events = calendar_listings.find_all('li', class_='event-listing')
    
    for event in events:
        try:
            # Get date from time element
            time_elem = event.find('time')
            date = time_elem.get('datetime') if time_elem else 'N/A'

            # Get event link and details
            event_link = event.find('a')
            if event_link:
                url = base_url + event_link.get('href') if event_link.get('href') else None
                
                # Get location and venue from event details div
                event_details = event_link.find('div', class_='event-details')
                if event_details:
                    primary_detail = event_details.find('strong', class_='primary-detail')
                    location = primary_detail.text.strip() if primary_detail else 'N/A'
                    
                    secondary_detail = event_details.find('p', class_='secondary-detail')
                    venue = secondary_detail.text.strip() if secondary_detail else 'N/A'
                else:
                    location = 'N/A'
                    venue = 'N/A'

#          ({"title": name, "type": events[i].metroAreaName, "venue": events[i].venueName ,"date": dateWithDay(events[i].date), "uri" : events[i].uri })
            event_data = {
                'name': '',   # event name
                'artists': [artist_name] if artist_name else [],  # Use extracted artist name
                'venueName': venue,
                'metroAreaName': '',
                'date': date,
                'url': url
            }
            results.append(event_data)

        except Exception as e:
            print(f"Error parsing artists event: {str(e)}")
            continue

    return results
