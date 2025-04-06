import json

class Event(dict):

    def __init__(self):
        self['skid'] = None
        self['name'] = None
        self['artists'] = []
        self['metroAreaName'] = None
        self['metroAreaId'] = None
        self['venueId'] = None
        self['venueName'] = None
        self['venueCity'] = None
        self['venueCountry'] = None
        self['venuePostalCode'] = None
        self['venueStreetAddress'] = None
        self['eventUrl'] = None
        self['eventType'] = None
        self['date'] = None
        self['startTime'] = None
        self['attendance'] = None
        self['artistId'] = None
        self['artistUrl'] = None
        self['artistName'] = None
        self['artistImageUrl'] = None
 

    def __repr__(self):
        return f"Event(type={self['eventType']})"

    def __str__(self):
        return f"skid: {self['skid']}" \
               f"name: {self['name']}" \
               f"eventUrl: {self['eventUrl']}" \
               f"eventType: {self['eventType']}" \
               f"date: {self['date']}" \
               f"startTime: {self['startTime']}" \
               f"attendance: {self['attendance']}" \
               f"artists: {self['artists']}" \
               f"artistId: {self['artistId']}" \
               f"artistName: {self['artistName']}" \
               f"artistUrl: {self['artistUrl']}" \
               f"artistImageUrl: {self['artistImageUrl']}" \
               f"venueName: {self['venueName']}" \
               f"venueId: {self['venueId']}" \
               f"metroAreaName: {self['metroAreaName']}" \
               f"metroAreaId: {self['metroAreaId']}"

    def toJSON(self):
        return json.dumps(
            self,
            default=lambda o: o.__dict__, 
            sort_keys=True,
            indent=4)    
    
    def toMultilineString(self):
        return f"skid: {self['skid']}\n" \
               f"name: {self['name']}\n" \
               f"eventUrl: {self['eventUrl']}\n" \
               f"eventType: {self['eventType']}\n" \
               f"date: {self['date']}\n" \
               f"startTime: {self['startTime']}\n" \
               f"attendance: {self['attendance']}\n" \
               f"artists: {self['artists']}\n" \
               f"artistId: {self['artistId']}\n" \
               f"artistName: {self['artistName']}\n" \
               f"artistUrl: {self['artistUrl']}\n" \
               f"artistImageUrl: {self['artistImageUrl']}\n" \
               f"venueName: {self['venueName']}\n" \
               f"venueId: {self['venueId']}\n" \
               f"metroAreaName: {self['metroAreaName']}\n" \
               f"metroAreaId: {self['metroAreaId']}\n" \
               f"venueCity: {self['venueCity']}\n" \
               f"venueCountry: {self['venueCountry']}\n" \
               f"venuePostalCode: {self['venuePostalCode']}\n" \
               f"venueStreetAddress: {self['venueStreetAddress']}\n"    
    
        