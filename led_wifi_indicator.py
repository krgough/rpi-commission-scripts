#! /usr/bin/env python3

import subprocess
import time
import RPi.GPIO as GPIO

LED_PIN = 11
ON_TIME = 0.1
OFF_TIME = 1.9

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

        if net_up:
            GPIO.output(LED_PIN, True)
            time.sleep(ON_TIME + OFF_TIME)

        else:
            GPIO.output(LED_PIN, True)
            time.sleep(ON_TIME)
            GPIO.output(LED_PIN, False)
            time.sleep(OFF_TIME)
            
    GPIO.cleanup()


if __name__ == "__main__":
    main()

