# Dotfiles

- To fix `xdg-open` not using the right mime default:
  - `busctl --user call org.freedesktop.impl.portal.PermissionStore /org/freedesktop/impl/portal/PermissionStore org.freedesktop.impl.portal.PermissionStore Lookup ss "desktop-used-apps" "example/mime"`
  - Ask AI how to set/delete this property
