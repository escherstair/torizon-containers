#!/bin/bash

if [[ "$SOC_UDT" == *am62* ]]; then
  PLATFORM_FILTER="platform:am62"
elif [[ "$SOC_UDT" == *imx8* ]]; then
  PLATFORM_FILTER="platform:imx8"
elif [[ "$SOC_UDT" == *imx95* ]]; then
  PLATFORM_FILTER="platform:imx95"
else
  PLATFORM_FILTER="platform:upstream"
fi

export PLATFORM_FILTER

# It's ok if bats fails, we just care about the report, hence the || true
bats --report-formatter junit --output /home/torizon --verbose-run --show-output-of-passing-tests --trace --recursive --timing --filter-tags "$PLATFORM_FILTER" . || true

# Reports may contain escape codes from program logs which breaks parsers, so remove any escape code
sed -i 's/\x1b\[[0-9;]*[a-zA-Z]//g' /home/torizon/report.xml
