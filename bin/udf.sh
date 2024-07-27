#!/usr/bin/bash

rm -rf ~/.gnome
rm -rf ~/.local/share/applications/chrome-*.desktop

if ! grep -q ozone /usr/share/applications/code-insiders.desktop; then
  replacement="s|\(Exec=[^%]*\)\(%.*\)|\1--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations \2|"
  sed -i "$replacement" /usr/share/applications/code-insiders.desktop
  sed -i "$replacement" /usr/share/applications/code-insiders-url-handler.desktop
fi

if ! grep -q ozone /usr/share/applications/vesktop.desktop; then
  sed -i 's|Exec=.*|\0 --enable-features=UseOzonePlatform --ozone-platform=wayland|' /usr/share/applications/vesktop.desktop
fi

if ! grep -q ozone /usr/share/applications/obsidian.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --disable-gpu \2|' /usr/share/applications/obsidian.desktop
fi

if ! grep -q ozone /usr/share/applications/mongodb-compass.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --ignore-additional-command-line-flags \2|' /usr/share/applications/mongodb-compass.desktop
fi

if ! grep -q ozone /usr/share/applications/redisinsight.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--enable-features=UseOzonePlatform --ozone-platform=wayland \2|' /usr/share/applications/redisinsight.desktop
fi

if ! grep -q ozone /usr/share/applications/postman.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--enable-features=UseOzonePlatform --ozone-platform=wayland \2|' /usr/share/applications/postman.desktop
fi

if ! grep -q ozone /usr/share/applications/1password.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--enable-features=UseOzonePlatform --ozone-platform=wayland \2|' /usr/share/applications/1password.desktop
fi

if ! grep -q ozone /usr/share/applications/cider.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--ozone-platform=wayland --enable-features=UseOzonePlatform --disable-gpu \2|' /usr/share/applications/cider.desktop
fi

if ! grep -q sandbox /usr/share/applications/r2modman.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--no-sandbox \2|' /usr/share/applications/r2modman.desktop
fi
