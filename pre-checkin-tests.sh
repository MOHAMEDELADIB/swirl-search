#!/bin/bash
#
# Usage:
#   pre-checkin-tests.sh [<options>]
#
# Run unit tests and smoke integration tests
# Options:
#   -h, --help           Display this help message

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) print_help=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done
# Print help message if requested
if [ "$print_help" = true ]; then
    sed -n '/^# Usage:/,/^$/p' "$0"
    exit
fi

PROG=`basename $0`

set -e

# Unit tests
echo $PROG "running pytest unit tests"
pytest
echo $PROG "unit tests succeeded"

## Smoke integration tests
echo $PROG "running smoke integration  tests"
if [ ! -e ".swirl" ]; then
    python swirl.py start core

fi
docker run -e SWIRL_TEST_HOST=host.docker.internal --net=host -t swirlai/swirl-search:latest-smoke-test sh -c "behave **/docker_container/*.feature --tags=docker_api_smoke"

echo $PROG "smoke-integraion tests succeeded"