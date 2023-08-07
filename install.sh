#!/bin/bash

confirm_prompt() {
	while true; do
		read -rp "$*? [y/N] " yn

		case $yn in
		[yY])
			break
			;;
		[nN] | *) ;;
		esac
	done
}

eval "$(sed <install.conf -r 's/ = /=/' | sed "s|\(.*=\[\)\(.*\)|\1(\2)|" | sed -E "s/\[|\]|,//g")"

sudo -v
paru -Syu --noconfirm

if ! which paru >/dev/null 2>&1; then
	sudo pacman -S --needed base-devel git
	git clone https://aur.archlinux.org/paru-bin.git
	cd paru-bin || exit
	makepkg -si
	cd .. && rm -rf paru-bin
fi

# Install omz
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
	sudo -k chsh -s "/usr/bin/zsh" "$USER"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

# Install Rust
if ! which rustup >/dev/null 2>&1; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	# shellcheck disable=SC1091
	. "$HOME/.cargo/env"
	cargo install "${CARGO_PKGS[@]}"
fi

# Install dotfiles
if [ ! -f .dotter/local.toml ]; then
	confirm_prompt Have you created .dotter/local.toml
fi
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
KEY_ID="18113BC4A3C7C7D0"
if ! gpg --list-keys "$KEY_ID" >/dev/null 2>&1; then
	gpg --fetch-keys https://keys.openpgp.org/vks/v1/by-fingerprint/96EC38186D96F32EA362081F18113BC4A3C7C7D0
	gpg --edit-key "$KEY_ID" trust
fi

# Git
git config --global user.name "Samuel Corsi-House"
git config --global user.email "chouse.samuel@gmail.com"
git config --global init.defaultBranch main
git config --global commit.gpgsign true
git config --global user.signingkey "$KEY_ID"

# Pacman
paru -S --needed --noconfirm "${PACMAN_PKGS[@]}"
paru -U --needed --noconfirm "${PACMAN_PKGS_UPGRADES[@]}"

# Repos
gh auth login

mkdir -p ~/Documents/projects
mkdir -p ~/Documents/projects/personal
mkdir -p ~/Documents/projects/work/aheeva

gh repo clone aheeva/aheeva-msg-center ~/Documents/projects/work/aheeva/msg-center

cd ~/Documents/projects/personal || exit 1
for repo in "${PERSONAL_REPOS[@]}"; do
	gh repo clone "Xenfo/$repo"
done
cd ..

# Manual
for pkg in "${PACMAN_PKGS_MANUAL[@]}"; do
	# shellcheck disable=SC2001
	clean_pkg=$(echo "$pkg" | sed 's/ .*//')
	confirm_prompt "Have you installed $clean_pkg (paru -S --noconfirm $pkg)"
done
