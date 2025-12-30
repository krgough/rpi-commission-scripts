#! /usr/bin/env python3

"""

LED Indicator for WiFi Connection
This script uses a GPIO pin to control an LED that indicates the status of a WiFi connection.
If we have a slack channel set we also send a message to the channel.

"""

import logging
import subprocess
import socket
import time

import dotenv
from RPi import GPIO

from utils import send_slack_notifications as slack


LOGGER = logging.getLogger(__name__)

GPIO.setwarnings(False)

# Server we try to connect to, in order to check network connectivity
TEST_SERVER = "8.8.8.8"
TEST_PORT = 53  # DNS port
CPU_TEMP_LIMIT = 80  # degrees C


def get_ssid():
    """ Check that we are connected to a WLAN network
    We can use `iwgetid -r` which returns the ssid of the current wifi net
    Note this only indicates wifi is connected.  See `is_network_up()` for a network check
    """
    essid = subprocess.check_output("iwgetid -r", shell=True).decode('utf-8').strip()
    LOGGER.debug("essid: %s", essid)
    return essid


def get_ip_addr(server: str = TEST_SERVER, port: int = TEST_PORT, timeout: int = 3) -> bool:
    """ping server"""
    try:
        socket.setdefaulttimeout(timeout)
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((server, port))
        ip_addr = s.getsockname()[0]
        hostname = socket.gethostname()
        s.close()
    except OSError as error:
        LOGGER.debug("Error connecting to %s:%s - %s", server, port, error)
        s.close()
        return None

    return {"hostname": hostname, "ip_addr": ip_addr}


def slack_notification(*slack_webhooks, msg: dict):
    """ Send a message to slack """
    for hook in slack_webhooks:
        slack.send_slack_message(msg=msg, slack_webhook=hook)


def double_flash(led_pin: int):
    """ Flash LED twice """
    GPIO.output(led_pin, True)
    time.sleep(0.15)
    GPIO.output(led_pin, False)
    time.sleep(0.2)
    GPIO.output(led_pin, True)
    time.sleep(0.15)
    GPIO.output(led_pin, False)
    time.sleep(1.5)


def single_flash(led_pin: int):
    """ Flash LED once """
    GPIO.output(led_pin, True)
    time.sleep(0.1)
    GPIO.output(led_pin, False)
    time.sleep(2.9)


def get_slack_webhooks():
    """ Get the webhooks from .env file """
    slack_webhooks = []
    slack_webhook_names = dotenv.get_key(
        dotenv.find_dotenv(raise_error_if_not_found=True),
        "SLACK_WEBHOOKS"
    )

    if slack_webhook_names:
        for webhook_name in slack_webhook_names.split(','):
            LOGGER.info("Adding slack notification webhook: %s", webhook_name)
            webhook = dotenv.get_key(dotenv.find_dotenv(), webhook_name)
            if webhook:
                slack_webhooks.append(webhook.strip())
    else:
        LOGGER.info("No slack webhooks found")
    return slack_webhooks


def main():
    """ Indicate the status of the network connection """
    slack_webhooks = get_slack_webhooks()

    led_pin = dotenv.get_key(dotenv.find_dotenv(), "LED_WIFI_INDICATOR_GPIO")
    if not led_pin:
        LOGGER.warning("No LED_WIFI_INDICATOR_GPIO found in .env file), exiting")
        return

    LOGGER.info("Using LED on GPIO pin: %s", led_pin)

    # Use physical pin numbers on the GPIO connector
    # e.g. pin11 (connector pin number) is gpio17 (BCM name)
    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(led_pin, GPIO.OUT)

    network = get_ip_addr()
    last_check_time = time.time()

    if network:
        LOGGER.info("Network is up: %s", network)
        state = "network_up"
    else:
        state = "network_down"
        LOGGER.info("Network is down")

    # State Machine
    while True:

        # Every so often check the network state and CPU temperature
        if time.time() - last_check_time > 30:
            last_check_time = time.time()
            network = get_ip_addr()

        if state == "network_down":
            double_flash(led_pin=led_pin)
            if network:
                state = "network_up"
                LOGGER.info("Network is up: %s", network)
                msg = {"hostname": network['hostname'], "message": f"IP: {network['ip_addr']}"}
                slack_notification(msg=msg, *slack_webhooks)

        elif state == "network_up":
            single_flash(led_pin=led_pin)
            if network is None:
                state = "network_down"
                LOGGER.info("Network is down")

        else:
            LOGGER.error("Unknown state: %s", state)
            break

    GPIO.cleanup()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
