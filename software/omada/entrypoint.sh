#!/bin/sh

#
# Copyright (c) 2021 Ademar Arvati Filho
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ
echo "INFO: Time zone set to '${TZ}'"

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')
export INTERNAL_IP

# Switch to the container's working directory
HOME=${HOME:-/home/container}
cd $HOME || exit 1

# make sure that the omada controller exists
if [ ! -d $HOME/lib ]
then
  # missing omada; extract from original
  echo "INFO: extracting backup to '$HOME/'"
  tar zxvf /omada.tar.gz -C $HOME
fi

# Set startup script file
if [ -e $HOME/.profile ]; then
    source $HOME/.profile
fi

# Include ./local/bin to path
if [ -d $HOME/.local/bin ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Set prompt text and color
export PS1='\033[1m\033[33mcontainer@pterodactyl:\w \033[0m'

# Print Java version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version

echo "INFO: Starting Omada Controller"

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
#exec env ${PARSED}

cd $HOME/lib || exit 1

exec env ${PARSED}