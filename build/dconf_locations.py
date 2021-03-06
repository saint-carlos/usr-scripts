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
    tz_hint = None
    for fmt in [ "./region/country//city/[name='{}']/", "./region/country//city/[_name='{}']/" ]:
        prefix = fmt.format(name)
        for tz_hint_loc in [ "../../tz-hint", "../tz-hint" ]:
            try:
                tz_hint = root.find(prefix + tz_hint_loc).text
                break
            except:
                continue
        if tz_hint:
            break
    if not tz_hint:
        raise Exception("no timzeone found for city '{}'".format(name))
    code = "-"
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
    cities = [ City("GMT", "GMT", "-0.000000", "-0.000000", "-", "false") ]
    for city_name in sys.argv[1].split(':'):
        if city_name[0] == '~':
            current = True
            city_name = city_name[1:]
        else:
            current = False
        city = get_city(root, city_name, current)
        cities.append(city)

    print(cities_to_matepanel_str(cities))
except Exception as e:
    eprint(e);
    eprint("make sure all named cities appear in {}.".format(LOCATIONS_FILE))
    sys.exit(1)
