#! /usr/bin/env python3

"""

Check the CPU temperature and send a slack notification if it exceeds a threshold.

"""

from argparse import ArgumentParser
import logging
import os
import socket
import time

import dotenv

from send_slack_notifications import send_slack_message

LOGGER = logging.getLogger(__name__)

CPU_TEMP_LIMIT = 50  # CPU temperature limit in Celsius
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


def get_args():
    """ Get command line arguments """
    parser = ArgumentParser(description="LED Indicator for WiFi Connection")
    parser.add_argument(
        "-t", "--trading_slack_enabled",
        action="store_true",
        help="Enable Slack notifications to trading slack webhook- put webhooks in .env file",
    )
    parser.add_argument(
        "-k", "--kg_slack_enabled",
        action="store_true",
        help="Enable Slack notifications to kg slack webhook- put webhooks in .env file",
    )
    return parser.parse_args()


def main():
    """ Entry point """
    args = get_args()
    logging.basicConfig(level=logging.INFO)

    LOGGER.info("Starting CPU temperature check")

    # Load webhooks from environment variables
    slack_webhooks = []
    if args.trading_slack_enabled:
        LOGGER.info("Trading Slack notifications enabled")
        trading_slack = dotenv.get_key(
            dotenv.find_dotenv(raise_error_if_not_found=True),
            "TRADING_INTRADAY_ALERTS_SLACK_WEBHOOK"
        )
        slack_webhooks.append(trading_slack)

    if args.kg_slack_enabled:
        LOGGER.info("KG Slack notifications enabled")
        kg_slack = dotenv.get_key(
            dotenv.find_dotenv(raise_error_if_not_found=True),
            "KG_SLACK_WEBHOOK"
        )
        slack_webhooks.append(kg_slack)

    check_cpu_temp(slack_webhooks)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
