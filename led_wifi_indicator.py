#! /usr/bin/env python3

"""

LED Indicator for WiFi Connection
This script uses a GPIO pin to control an LED that indicates the status of a WiFi connection.
If we have a slack channel set we also send a message to the channel.

"""
from argparse import ArgumentParser
import logging
import subprocess
import socket
import time

import dotenv
from RPi import GPIO

from send_slack_notifications import send_slack_message


LOGGER = logging.getLogger(__name__)
dotenv.load_dotenv()

GPIO.setwarnings(False)
# Use physical pin numbers on the GPIO connector
# e.g. pin11 (connector pin number) is gpio17 (BCM name)
GPIO.setmode(GPIO.BOARD)
LED_PIN = 11
GPIO.setup(LED_PIN, GPIO.OUT)

TEST_SERVER = "8.8.8.8"
TEST_PORT = 80


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


def check_cpu_temp(last_msg_sent, network, slack_webhooks):
    """ Check the rpi CPU temperature """
    try:
        with open("/sys/class/thermal/thermal_zone0/temp", "r", encoding='utf-8') as f:
            temp = int(f.read()) / 1000
            LOGGER.info("CPU temperature: %s", temp)
    except FileNotFoundError as error:
        temp = -99
        LOGGER.error("Error reading CPU temperature: %s", error)

    if temp > 70:
        LOGGER.warning("CPU temperature is high: %s", temp)
        if network and time.time() - last_msg_sent > 60:
            msg = {
                "hostname": network['hostname'],
                "message": f"CPU temperature is high: {temp}"
            }
            slack_notification(msg=msg, *slack_webhooks)
            last_msg_sent = time.time()

    return last_msg_sent


def slack_notification(msg: dict, *slack_webhooks):
    """ Send a message to slack """
    for hook in slack_webhooks:
        send_slack_message(msg=msg, slack_webhook=hook)


def double_flash():
    """ Flash LED twice """
    GPIO.output(LED_PIN, True)
    time.sleep(0.15)
    GPIO.output(LED_PIN, False)
    time.sleep(0.2)
    GPIO.output(LED_PIN, True)
    time.sleep(0.15)
    GPIO.output(LED_PIN, False)
    time.sleep(1.5)


def single_flash():
    """ Flash LED once """
    GPIO.output(LED_PIN, True)
    time.sleep(0.1)
    GPIO.output(LED_PIN, False)
    time.sleep(2.9)


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
    """ Indicate the status of the network connection """
    args = get_args()

    slack_webhooks = []

    if args.trading_slack_enabled:
        LOGGER.info("Trading Slack notifications enabled")
        trading_slack = dotenv.get_key(dotenv.find_dotenv(), "TRADING_INTRADAY_ALERTS_SLACK_WEBHOOK")
        slack_webhooks.append(trading_slack)

    if args.kg_slack_enabled:
        LOGGER.info("KG Slack notifications enabled")
        kg_slack = dotenv.get_key(dotenv.find_dotenv(), "KG_SLACK_WEBHOOK")
        slack_webhooks.append(kg_slack)

    network = get_ip_addr()
    last_check_time = time.time()
    last_cpu_temp_msg_time = 0

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
            # network_state = is_network_up()
            network = get_ip_addr()
            last_cpu_temp_msg_time = check_cpu_temp(
                last_msg_sent=last_cpu_temp_msg_time,
                network=network,
                slack_webhooks=slack_webhooks
            )

        if state == "network_down":
            double_flash()
            if network:
                state = "network_up"
                LOGGER.info("Network is up: %s", network)
                if args.slack_enabled:
                    msg = {"hostname": network['hostname'], "message": f"IP: {network['ip_addr']}"}
                    slack_notification(msg=msg, *slack_webhooks)

        elif state == "network_up":
            single_flash()
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
