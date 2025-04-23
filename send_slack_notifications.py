#! /usr/bin/env Python3

"""
Sends notification on Slack using a webhook URL

"""

from argparse import ArgumentParser
import json
import logging

import requests

LOGGER = logging.getLogger(__name__)


def send_slack_message(msg: dict, slack_webhook: str):
    """ Send a message to slack """

    if "message" not in msg or "hostname" not in msg:
        LOGGER.error("Invalid message format: %s", msg)
        LOGGER.error("Message must contain 'message' and 'hostname' keys")
        return

    LOGGER.info("Sending message to Slack: %s", msg)

    response = requests.post(
        url=slack_webhook,
        data=json.dumps(msg),
        headers={"Content-type": "application/json"},
        timeout=5
    )

    if response.status_code != 200:
        LOGGER.error(
            "Error sending message to Slack: %s, %s", response.status_code, response.text
        )
    else:
        LOGGER.info("Message sent to Slack: %s", msg)


def get_args():
    """ Get CLI arguments """
    parser = ArgumentParser(
        description="Send a message to Slack using a webhook URL"
    )
    parser.add_argument(
        "-m", "--msg",
        type=str,
        required=True,
        help="Message to send to Slack"
    )
    parser.add_argument(
        "-w", "--slack_webhook",
        type=str,
        required=True,
        help="Slack webhook URL"
    )

    return parser.parse_args()


def main():
    """ Main function """
    args = get_args()
    msg = json.loads(args.msg)
    send_slack_message(msg=msg, slack_webhook=args.slack_webhook)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
