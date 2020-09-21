#!/usr/share/logstash/logstash-custom-plugin/venv/uap/bin/python
import json
import sys

from user_agents import parse


def parse_user_agent(ua_string):
    user_agent = parse(ua_string)

    device_type = "Other"
    if user_agent.is_mobile:
        device_type = "mobile"
    elif user_agent.is_pc:
        device_type = "pc"
    elif user_agent.is_tablet:
        device_type = "tablet"
    elif user_agent.is_bot:
        device_type = "bot"
    result = \
        {
           "device": "Other" if user_agent.device.family is None or user_agent.device.family == "" else user_agent.device.family,
           "brand": "Other" if user_agent.device.brand is None or user_agent.device.brand == "" else user_agent.device.brand,
           "os": "Other" if user_agent.os.family is None or user_agent.os.family == "" else user_agent.os.family,
           "os_version": "Other" if user_agent.os.version_string is None or user_agent.os.version_string == "" else user_agent.os.version_string,
           "browser": "Other" if user_agent.browser.family is None or user_agent.browser.family == "" else user_agent.browser.family,
           "browser_version": "Other" if user_agent.browser.version_string is None or user_agent.browser.version_string == "" else user_agent.browser.version_string,
           "device_type": device_type
        }

    print(json.dumps(result))


if __name__ == '__main__':
    ua_string = sys.argv[1]
    parse_user_agent(ua_string)
