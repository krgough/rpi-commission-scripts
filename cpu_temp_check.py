#! /usr/bin/env python3

"""

Check the CPU temperature and send a slack notification if it exceeds a threshold.

"""

import logging
import os
import socket
import time

import dotenv

from send_slack_notifications import send_slack_message

LOGGER = logging.getLogger(__name__)

CPU_TEMP_LIMIT = 80  # CPU temperature limit in Celsius
NOTIFICATION_LAST_SENT_FILE = "/tmp/cpu_temp_notification_last_sent"


def slack_notification(*slack_webhooks, msg: dict):
    """ Send a message to slack channel(s) """
    for hook in slack_webhooks:
        send_slack_message(msg=msg, slack_webhook=hook)


def check_cpu_temp(slack_webhooks):
    """ Check the rpi CPU temperature """
    try:
        with open("/sys/class/thermal/thermal_zone0/temp", "r", encoding='utf-8') as f:
            temp = int(f.read()) / 1000
    except FileNotFoundError as error:
        temp = -99
        LOGGER.error("Error reading CPU temperature: %s", error)

    if temp > CPU_TEMP_LIMIT:

        # Get the time of the last notification
        # Use the modification time of a blank file as our persistant
        # notification time
        if os.path.exists(NOTIFICATION_LAST_SENT_FILE):
            last_msg_sent = os.path.getmtime(NOTIFICATION_LAST_SENT_FILE)
        else:
            last_msg_sent = 0

        LOGGER.warning("CPU temperature is high: %s", temp)
        if time.time() - last_msg_sent > 60 * 60:
            msg = {
                "hostname": socket.gethostname(),
                "message": f"CPU temperature is high: {temp}"
            }
            slack_notification(msg=msg, *slack_webhooks)

            # Update the last sent time to now
            open(NOTIFICATION_LAST_SENT_FILE, "w", encoding='utf-8').close()
        else:
            LOGGER.info("Notification already sent within the last hour")

    elif temp != -99:
        LOGGER.info("CPU temperature: %s", temp)


def main():
    """ Entry point """
    logging.basicConfig(level=logging.INFO)

    LOGGER.info("Starting CPU temperature check")

    # Load webhooks from environment variables
    slack_webhooks = []

    slack_webhook_names = dotenv.get_key(
        dotenv.find_dotenv(raise_error_if_not_found=True),
        "SLACK_WEBHOOKS"
    )

    if slack_webhook_names:
        for webhook_name in slack_webhook_names.split(","):
            LOGGER.info("Adding slack notification webhook: %s", webhook_name)
            webhook = dotenv.get_key(dotenv.find_dotenv(), webhook_name.strip())
            if webhook:
                slack_webhooks.append(webhook)
    else:
        LOGGER.warning("No slack webhooks found in environment variables")

    check_cpu_temp(slack_webhooks)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
