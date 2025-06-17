# ==========================
# 📌 Impostazioni generali
# ==========================

# Editor di default (usato da git commit, crontab, ecc.)
export EDITOR='hx'
export GIT_EDITOR="$EDITOR"

# Disabilita le analytics di Homebrew
export HOMEBREW_NO_ANALYTICS=1

# Imposta lingua e locale (evita problemi di encoding)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Colori standard per ls/grep (fallback se eza non è disponibile)
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# ==========================
# 📌 PATH e Homebrew
# ==========================

# Aggiunge Homebrew al PATH (se non già presente)
export PATH="/opt/homebrew/bin:$PATH"

# Caricamento Homebrew (solo se necessario)
if ! command -v brew &>/dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ==========================
# 📌 Performance e caching
# ==========================

# Specifica la cache di Homebrew
export HOMEBREW_CACHE="$HOME/Library/Caches/Homebrew"