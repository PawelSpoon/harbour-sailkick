from bs4 import BeautifulSoup

def parse_user_locations(html_content, base_url):
    """Parse users tracked areas from HTML content
    Args:
        html_content (str): HTML content to parse
        base_url (str): Base URL for completing relative URLs
    Returns:
        list: List of parsed events
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    results = []

    # Save parsed HTML for debugging
    with open("parsed_user_locations_html.html", "w", encoding="utf-8") as f:
        f.write(str(soup.prettify()))

    # Find the main calendar listings container  event-listings artist-calendar-summary
    tracked_listings = soup.find('ul', class_='un-tracker') # metro-area')
    if not tracked_listings:
        print("No tracked listings found.")
        return results

    # Find all artist elements
    artists = tracked_listings.find_all('li')
    if not artists:
        print("No locations found.")
        return results
    
    for artist in artists:
        try:
            # Get artist link which contains name and url
            artist_link = artist.find('a')
            if not artist_link:
                continue

            # Get artist name and clean it
            name = artist_link.get_text(strip=True)
            name = name.split(',')[0].strip()
            
            # Get artist URL
            url = artist_link.get('href')
            if url and not url.startswith('http'):
                url = base_url + url

            # Get artist image if available
            img = artist_link.find('img')
            image_url = img.get('src') if img else None
            if image_url and not image_url.startswith('http'):
                image_url = 'https:' + image_url

            # Get artist ID from tracking info
            # Get artist image and name from alt text
            img = artist_link.find('img')
            if img:
                #alt_text = img.get('alt', '')
                #alt_text = img.get_text(strip=True)
                #name = alt_text.split(',')[0].strip()
                image_url = img.get('src')
                if image_url and image_url.startswith('//'):
                    image_url = 'https:' + image_url
            else:
                continue

            # Get artist URL and extract ID
            url = artist_link.get('href')
            if url:
                if not url.startswith('http'):
                    url = base_url + url
                # Extract ID from URL (e.g., /artists/549892-a-perfect-circle -> 549892)
                artist_id = url.split('/')[-1]
            else:
                artist_id = None

            #uid:undefined, title:undefined, type:location
            artist_data = {
                'name': name,
                'title': name,
                'url': url,
                'image_url': image_url,
                'id': artist_id,
                'uid': artist_id,
                'body' : None
            }
            results.append(artist_data)

        except Exception as e:
            print(f"Error parsing artist: {str(e)}")
            continue

    print(f"Found {len(results)} tracked artists")
    return results
