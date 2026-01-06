#! /usr/bin/env bash

show_help() {
    echo
    echo "Usage: $(basename "$0") [-h]"
    echo
    echo "This script wgets the 'dwagent.sh' file into the home directory and makes it executable."
    echo "After running this you need to run 'dwagent.sh' and provide the setup code to link this device to an agent in dwservice."
    echo "Once dwservice is installed you can optionally delete 'dwagent.sh' as it is no longer used."
    echo
    echo "Options:"
    echo "  -h, --help       Show this help message and exit"
    echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Invalid option '$1'"
            show_help
            exit 1
            ;;
    esac
done

wget -O $HOME/dwagent.sh https://www.dwservice.net/download/dwagent.sh
chmod +x $HOME/dwagent.sh

echo "all done"
echo
