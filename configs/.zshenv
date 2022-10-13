# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# rust
. "$HOME/.cargo/env"

# go
export PATH="$PATH:$(/home/xenfo/.asdf/shims/go env GOPATH)/bin"

# bun completions
[ -s "/home/xenfo/.bun/_bun" ] && source "/home/xenfo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# deno
export DENO_INSTALL="/home/xenfo/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# bat
export BAT_THEME="Catppuccin-mocha"
