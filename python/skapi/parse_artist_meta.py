from bs4 import BeautifulSoup
from .event import Event
import json

'''<div class="col-8 primary artist-overview">
    <h1 class="h0 image-padding word-break">A Perfect Circle<span class="no-break">&nbsp;<span class="verified-artist"></span></span>
    </h1>

    <ul>
      <li>On tour: <strong>yes</strong></li>'''

'''
when tracked:
    <div class="track-artist">
      <div class="tracking">
  <form data-analytics-category="track_artist_button" data-analytics-action="artist:on_tour:track_artist_button" data-analytics-label="untrack" data-tracking-text="Track artist" data-stop-tracking-text="Tracking" class="app-store-redirect" action="/trackings/untrack" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" autocomplete="off" /><input type="hidden" name="authenticity_token" value="IUxDIUCdFE2/yiaxqJA6w3g2r2XXBmU0A8e03I4OObV6DI8p2Ge2XChJ3CU/kJwdEv+604x+IJnX7TUBqk4d5w==" autocomplete="off" />
    <input type="hidden" name="relationship_type" value="concerts">
    <input type="hidden" name="tracking_context" value="default">
    <input type="hidden" name="subject_id" value="549892">
    <input type="hidden" name="subject_type" value="Artist">
    <input type="hidden" name="success_url" value="/artists/549892-a-perfect-circle">
    <button type="submit" class="selected artist track" value="Tracking">Tracking</button>
when not tracked:
    artist">Track artist</butto
</form></div>'''

def parse_artist_meta(html_content, base_url):
    """Parse artist events from HTML content
    Args:
        html_content (str): HTML content to parse
        base_url (str): Base URL for completing relative URLs
    Returns:
        list: List of parsed events
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    result = {'imageUrl':'', 'onTour': False, 'tracking': False}

    # Get artist name from header
    artist_ontour = False
    artist_header = soup.find('div', class_='col-8 primary artist-overview')
    if artist_header:
        try:
            ontour = artist_header.find('ul').find('li').find('strong').text.strip()
            if ontour.lower() == 'yes':
                artist_ontour = True
        except Exception as e:
            print(f"Error parsing artists event: {str(e)}")
    
        result['onTour'] = artist_ontour

    # Get tracking status from form
    tracking = soup.find('button', class_='artist track').text.strip()
    if tracking.lower() == 'tracking':
        result['tracking'] = True
    else:
        result['tracking'] = False

    return result
