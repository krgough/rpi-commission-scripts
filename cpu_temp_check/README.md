# CPU Temperature Check

Check the temperature periodically and send a notification if the CPU temp is greater than a limit
We limit the motifications to once an hour

There are 2 implementations:

`cpu_temp_chech.sh` - Bash implementation. Notification via email.  Requires mail client to be setup on RPi
`cpu_temp_check.py` - Python implementation. Slack notification.  Specify slack webhooks in `.env` file.

## Setup Instructions

1. Edit `setup_led_service.sh` to use your preferred implementation
2. If using the pythin implementation set the wanted slack webhook in the .env file.
2. Run `./setup_led_service.sh` to setup the service.