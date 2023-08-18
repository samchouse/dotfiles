#!/usr/bin/bash

rm -rf ~/.gnome
rm -rf ~/.local/share/applications/chrome-*.desktop

if ! grep -q ozone /usr/share/applications/visual-studio-code-insiders.desktop; then
  replacement="s|\(Exec=[^%]*\)\(%F\)|\1--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations \2|"
  sed -i "$replacement" /usr/share/applications/visual-studio-code-insiders.desktop
  sed -i "$replacement" /usr/share/applications/visual-studio-code-insiders-url-handler.desktop
fi

if ! grep -q ozone /usr/share/applications/discord.desktop; then
  sed -i 's|Exec=.*|\0 --enable-features=UseOzonePlatform --ozone-platform=wayland|' /usr/share/applications/discord.desktop
fi

if ! grep -q ozone /usr/share/applications/obsidian.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations --disable-gpu \2|' /usr/share/applications/obsidian.desktop
fi

if ! grep -q ozone /usr/share/applications/mongodb-compass.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --ignore-additional-command-line-flags \2|' /usr/share/applications/mongodb-compass.desktop
fi

if ! grep -q ozone /usr/share/applications/redis-insight.desktop; then
  sed -i 's|Exec=.*|Exec=/opt/redis-insight-bin/redisinsight --enable-features=UseOzonePlatform --ozone-platform=wayland|' /usr/share/applications/redis-insight.desktop
fi

if ! grep -q ozone /usr/share/applications/postman.desktop; then
  sed -i 's|\(Exec=[^%]*\)\(%U\)|\1--enable-features=UseOzonePlatform --ozone-platform=wayland \2|' /usr/share/applications/postman.desktop
fi
