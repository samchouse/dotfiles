#!/bin/bash

confirm_prompt() {
	while true; do
		read -p "$*? [y/N] " yn

		case $yn in
		[yY])
			break
			;;
		[nN] | *) ;;
		esac
	done
}

git submodule update --init

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
cargo install bore-cli cargo-update cargo-edit cargo-watch tokei topgrade fd-find bunyan just dotter

# Install dotfiles
dotter init
confirm_prompt Are you "done" editing .dotter/local.toml
dotter -qy

# Install rtx and friends
curl https://rtx.pub/install.sh | sh
eval "$("$HOME/.local/share/rtx/bin/rtx" activate zsh)"
rtx install
npm i -g taze yarn pnpm
go install github.com/cosmtrek/air@latest

# Desktop package related stuff
if grep -q desktop .dotter/local.toml; then
	# hyprfocus
	cd hypr/hyprfocus
	git clone --recursive https://github.com/hyprwm/Hyprland && cd Hyprland
	git checkout tags/"$(hyprctl version | grep Tag: | sed 's/\(Tag:\)//' | sed 's/-.*//')"
	sudo make pluginenv
	cd .. && make all
fi
