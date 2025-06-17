# ==========================
# 📌 OPZIONI DI ZSH
# ==========================
# setopt/unsetopt imposta alcuni comportamenti di Zsh.

setopt no_beep              # Disabilita il beep del terminale.
unsetopt correct_all        # Disabilita la correzione automatica dei comandi.
setopt hist_ignore_dups     # Non salva comandi duplicati se consecutivi.
setopt hist_ignore_all_dups # Non salva comandi che esistono già nella cronologia.
setopt ignore_eof           # Evita che Ctrl+D chiuda accidentalmente la shell.

# ==========================
# 📌 CRONOLOGIA
# ==========================
# Variabili che influenzano dimensione e file della cronologia.

HISTFILE=~/.zsh_history     # File fisico della cronologia.
HISTSIZE=10000              # Numero massimo di comandi nella cronologia attuale.
SAVEHIST=10000              # Numero massimo di comandi salvati nel file.

# ==========================
# 📌 PATH E VARIABILI D'AMBIENTE
# ==========================
# Aggiunge /opt/homebrew/bin all’inizio del PATH (utile su macOS con Homebrew).
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Configura bat come pager per le pagine man con colori
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Se fzf è installato in /opt/homebrew/opt/fzf/bin, assicurati sia nel PATH.
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# ==========================
# 📌 INIZIALIZZAZIONE FZF
# ==========================
# Carica le funzionalità di fzf solo se la shell è interattiva.

if [[ $- == *i* ]]; then
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"    # Keybindings (Ctrl+T, Ctrl+R, ecc.)
  source "/opt/homebrew/opt/fzf/shell/completion.zsh"      # Completamenti fuzzy
fi

# ==========================
# 📌 COMPLETAMENTO (Ottimizzato)
# ==========================
# Abilita il sistema di completamento di Zsh.

autoload -Uz compinit
if [ -z "$_compinit_done" ]; then
  compinit
  _compinit_done=1
fi

# ==========================
# 📌 NVM (Auto Load)
# ==========================
# Carica NVM automaticamente quando necessario, senza usare alias
# riducendo i tempi di startup della shell.

export NVM_DIR="$HOME/.nvm"

# Definisci una funzione per caricare NVM solo quando necessario
function nvm_auto_load() {
  # Carica NVM se non è già caricato
  if [[ ! -v NVM_LOADED ]]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    export NVM_LOADED=1
  fi
  # Esegui il comando originale usando il PATH
  local cmd="$1"
  shift
  command "$cmd" "$@"
}

# Funzioni wrapper per comandi Node.js
function node() { nvm_auto_load node "$@"; }
function npm() { nvm_auto_load npm "$@"; }
function yarn() { nvm_auto_load yarn "$@"; }
function pnpm() { nvm_auto_load pnpm "$@"; }

# NVM command requires special handling
function nvm() {
  if [[ ! -v NVM_LOADED ]]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    export NVM_LOADED=1
    # After loading, nvm function is now available
    nvm "$@"
  else
    # NVM is already loaded, call it directly
    command nvm "$@" 2>/dev/null || { [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm "$@"; }
  fi
}

# ==========================
# 📌 COMANDI UTILI
# ==========================
# Enhanced aliases leveraging your existing tools

# Enhanced file operations
alias cat='bat --paging=never'
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -l --git'
alias la='eza --icons --group-directories-first -la --git'
alias tree='eza --tree --icons'
alias grep='rg'
alias find='fd'
alias ps='procs'
alias top='btop'
alias du='dust'
alias df='duf'

# Git workflow optimization
alias gd='git diff --name-only --diff-filter=d | xargs bat --diff'
alias glg='git log --oneline --graph --decorate --all'
alias gst='git status -sb'

# Quick system info
alias sysinfo='fastfetch'
alias ports='netstat -an | grep LISTEN'

# Git enhanced tools
alias ggui='gitui'
alias glog='gitui'

# Performance testing
alias bench='hyperfine'

# JSON processing
alias jsonpp='jq .'

# Quick help
alias help='tldr'

# ==========================
# 📌 FUNZIONI
# ==========================
# Funzioni utili per snellire operazioni multiple

# Crea una directory e ci entra
function mkcd() {
	mkdir -p "$@" && cd "$_"
}

# Navigazione directory migliorata
function up() {
    local d=""
    local limit=$1

    # Navigazione predefinita: una cartella in su
    if [[ -z "$limit" ]] || [[ "$limit" -le 0 ]]; then
        limit=1
    fi

    for ((i=1;i<=limit;i++)); do
        d="../$d"
    done

    # -P risolve i link simbolici
    cd -P "$d"
}

# Gestione aggiornamenti Homebrew
function brewup() {
    echo "📦 Aggiornamento Homebrew..."
    brew update
    echo "📋 Pacchetti aggiornabili:"
    brew outdated
    echo "🔄 Aggiornamento pacchetti..."
    brew upgrade
    echo "🧹 Pulizia..."
    brew cleanup
    echo "✅ Aggiornamento completato!"
}

# Open current directory in Finder
function finder() {
    open "${1:-.}"
}

# Empty trash
function emptytrash() {
    sudo rm -rfv /Volumes/*/.Trashes
    sudo rm -rfv ~/.Trash
    echo "🗑️ Trash emptied"
}

# Get public IP address
function myip() {
    curl -s ifconfig.me
    echo
}

# ==========================
# 📌 STRUMENTI DI SICUREZZA
# ==========================
# Alias e funzioni per strumenti di sicurezza

# Alias per gestire ClamAV in modo efficiente
alias clamav="$HOME/clamav-manager.sh"

# ==========================
# 📌 PLUGIN OPZIONALI (Autosuggestions e Syntax Highlighting)
# ==========================
# Se preferisci attivarli, rimuovi il commento e assicurati che i plugin siano installati.
# Per installarli: brew install zsh-autosuggestions zsh-syntax-highlighting

# source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# ==========================
# 📌 STARSHIP PROMPT (Caricato alla fine)
# ==========================
# Inizializza il prompt Starship (assicurati che starship sia installato).

export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# ==========================
# 📌 AUTO-WARPIFY (specifico per Warp)
# ==========================
# Invia un segnale a Warp per indicare che il file di configurazione è stato caricato.

printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'
# Modern CLI tool initialization
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
