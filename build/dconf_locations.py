#!/usr/bin/python3

import sys
import xml.etree.ElementTree

LOCATIONS_PACKAGE = "libgweather-common"
LOCATIONS_FILE = '/usr/share/libgweather/Locations.xml'

class City:
    def __init__(self, name, timezone, latitude, longitude, code, current=False):
        self.name = name
        self.timezone = timezone
        self.latitude = latitude
        self.longitude = longitude
        self.code = code
        self.current = current

def get_city(root, name, current=False):
    # root.find("/region/country//city/[name='{}']/../tz-hint").text
    prefix = "./region/country//city/[name='{}']/".format(name)
    try:
        tz_hint = root.find(prefix + "../../tz-hint").text
    except:
        tz_hint = root.find(prefix + "../tz-hint").text
    code = root.find(prefix + "location/code").text
    latitude, longitude = root.find(prefix + "coordinates").text.split()
    return City(name, tz_hint, latitude, longitude, code, current)

def city_to_str(city):
    return '<location name="' \
            + '" city="' + city.name \
            + '" timezone="' + city.timezone \
            + '" latitude="' + city.latitude \
            + '" longitude="' + city.longitude \
            + '" code="' + city.code \
            + '" current="' + str(city.current).lower() \
            + '"/>'

def list_to_str(l):
    prefix = '['
    separator = ""
    suffix = ']'

    res = prefix
    for e in l:
        res += separator + str(e)
        separator = ", "
    res += suffix
    return res

def cities_to_matepanel_str(cities):
    l = map(lambda city: "'" + city_to_str(city) + "'", cities)
    return list_to_str(l)

def eprint(s):
   print(s, file=sys.stderr)

try:
    tree = xml.etree.ElementTree.parse(LOCATIONS_FILE)
    root = tree.getroot()
except:
    eprint("make sure the package {} is installed.".format(LOCATIONS_PACKAGE))
    sys.exit(1)

if not sys.argv[1]:
    sys.exit(0)

try:
    cities = []
    for city_name in sys.argv[1].split(':'):
        if city_name[0] == '~':
            current = True
            city_name = city_name[1:]
        else:
            current = False
        city = get_city(root, city_name, current)
        cities.append(city)

    print(cities_to_matepanel_str(cities))
except:
    eprint("make sure all named cities appear in {}.".format(LOCATIONS_FILE))
    sys.exit(1)
