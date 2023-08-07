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

# Install omz
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
	sudo -k chsh -s "/usr/bin/zsh" "$USER"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Install Rust
if ! which rustup >/dev/null 2>&1; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	. "$HOME/.cargo/env"
	cargo install bore-cli cargo-update cargo-edit cargo-watch tokei topgrade fd-find bunyan just dotter
fi

# Install dotfiles
confirm_prompt Are you "done" editing .dotter/local.toml
dotter -qy --force

# Install rtx and friends
if ! which rtx >/dev/null 2>&1; then
	curl https://rtx.pub/install.sh | sh
	eval "$("$HOME/.local/share/rtx/bin/rtx" activate bash)"
	rtx install
	rtx x node -- npm i -g taze yarn pnpm npm@latest
	rtx x go -- go install github.com/cosmtrek/air@latest
fi

# Desktop package related stuff
if grep -q hypr .dotter/local.toml; then
	git submodule update --init

	# hyprfocus
	cd hypr/hyprfocus || exit 1
	git clone --recursive https://github.com/hyprwm/Hyprland && cd Hyprland || exit 1
	git checkout tags/"$(hyprctl version | grep Tag: | sed 's/\(Tag:\)//' | sed 's/-.*//')"
	sudo make pluginenv
	cd .. && make all
fi

# GPG
confirm_prompt Have you inserted your Yubikey
gpg --fetch-keys https://keys.openpgp.org/vks/v1/by-fingerprint/96EC38186D96F32EA362081F18113BC4A3C7C7D0
gpg --edit-key "18113BC4A3C7C7D0" trust

# Git
git config --global user.name "Samuel Corsi-House"
git config --global user.email "chouse.samuel@gmail.com"
git config --global commit.gpgsign true
git config --global user.signingkey "18113BC4A3C7C7D0"

# Pacman
paru -S starship yubikey-manager github-cli

# Repos
gh auth login

mkdir -p ~/Documents/projects
mkdir -p ~/Documents/projects/personal
mkdir -p ~/Documents/projects/work/aheeva

gh repo clone aheeva/aheeva-msg-center ~/Documents/projects/work/aheeva/msg-center

cd ~/Documents/projects/personal || exit 1
gh repo clone Xenfo/adrastos
