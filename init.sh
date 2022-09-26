#!/usr/bin/env bash

RESET='\033[0m'

BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Install dependencies
sudo apt install -y unzip

# # Download the repo to /tmp as a zip file and extract it
# wget https://github.com/Xenfo/dotfiles/archive/refs/heads/main.zip -O /tmp/dotfiles.zip
# unzip /tmp/dotfiles.zip -d /tmp
# cd /tmp/dotfiles-main || exit 1

# # Wait for user to confirm that they setup the config file
# echo -e "${BOLD_CYAN}Please make sure you have setup the config file before continuing!${RESET}"
# read -rp "$(echo -e "${BOLD_WHITE}Press enter to continue:${RESET} [ENTER]")"

# Install Deno
curl -fsSL https://deno.land/install.sh | sh
export PATH="$HOME/.deno/bin:$PATH"

# Run the installer
deno run --allow-run --allow-read --allow-write --allow-env installer/src/index.ts
