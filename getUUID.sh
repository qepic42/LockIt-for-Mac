#!/bin/bash
# Durch Namen des Hosts die IP und die MAC ermitteln

UUID=`system_profiler SPHardwareDataType | grep Serial | tr -d "Serial Number (system): "`

echo $UUID