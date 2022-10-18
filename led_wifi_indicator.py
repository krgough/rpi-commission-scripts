#! /usr/bin/env python3

import subprocess
import time
import RPi.GPIO as GPIO

LED_PIN = 11

ON_TIME = 0.1
OFF_TIME = 2.9

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(LED_PIN, GPIO.OUT)


def check_for_ssid():
    """ Check that we are connected to a WLAN network
        We use iwgetid which returns the ssid of the current wifi net
    """
    subprocess_result = subprocess.Popen('iwgetid',shell=True,stdout=subprocess.PIPE)
    subprocess_output = subprocess_result.communicate()[0],subprocess_result.returncode
    network_name = subprocess_output[0].decode('utf-8')
    if not network_name:
        return False
    return True


def main():
    """ Flash LED whie on but no ssid
        Turn LED on solid if ssid (i.e. connected to a network)
    """

    while True:

        net_up = check_for_ssid()

        if not net_up:
            GPIO.output(LED_PIN, True)
            time.sleep(0.15)
            GPIO.output(LED_PIN, False)
            time.sleep(0.2)
            GPIO.output(LED_PIN, True)
            time.sleep(0.15)
            GPIO.output(LED_PIN, False)
            time.sleep(1.5)
        else:
            GPIO.output(LED_PIN, True)
            time.sleep(0.1)
            GPIO.output(LED_PIN, False)
            time.sleep(2.9)
            
    GPIO.cleanup()


if __name__ == "__main__":
    main()

