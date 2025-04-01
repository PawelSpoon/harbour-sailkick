# harbour-sailkick
a native sailfish os client for www.songkick.com


# python backend
- install beatiful soup into ubuntu (4 python3)
- find location with python3 -c "import bs4; print(bs4.__file__)
- cp bs4 content into python-deps

# python deployment
- at best check with ssh that all files get deployed into /usr/share/harbour-sailkick/python

# next steps
- search concert by date
- create weblate translation page
- notifications should go away and should not be added to events page
- persist log-level (easiest might be actually as standard settings)
- move more code to applicationcontroller
- add more tests
- merge concerts and plans page into one
- make attending events with pink icons
- at least plans could work also offline
- find solution for apk and bring to obs
