import re

def parse_message(message):
    regex = r"^([a-z-]+)?@?([a-z0-9]+)?(.*)$"
    return re.findall(regex, message)[0]
