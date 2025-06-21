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

# Ripgrep uses ~/.rgignore automatically for global ignores

# Se fzf è installato in /opt/homebrew/opt/fzf/bin, assicurati sia nel PATH.
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# ==========================
# 📌 INIZIALIZZAZIONE FZF
# ==========================
# Carica le funzionalità di fzf solo se la shell è interattiva.

if [[ $- == *i* ]]; then
  # Carica configurazione FZF avanzata se esiste
  [[ -f "$HOME/.config/fzf/fzf.zsh" ]] && source "$HOME/.config/fzf/fzf.zsh"

  # Fallback alle configurazioni base se la configurazione avanzata non esiste
  if [[ ! -f "$HOME/.config/fzf/fzf.zsh" ]]; then
    source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"    # Keybindings (Ctrl+T, Ctrl+R, ecc.)
    source "/opt/homebrew/opt/fzf/shell/completion.zsh"      # Completamenti fuzzy
  fi
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

# Centralized NVM loading function to avoid duplication
function _load_nvm() {
  if [[ ! -v NVM_LOADED ]]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    export NVM_LOADED=1
  fi
}

# Definisci una funzione per caricare NVM solo quando necessario
function nvm_auto_load() {
  _load_nvm
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
  _load_nvm
  # After loading, nvm function is now available
  command nvm "$@" 2>/dev/null || nvm "$@"
}

# ==========================
# 📌 MODERN CLI ALIASES
# ==========================
# Enhanced aliases with modern tools, organized by category
# Note: Some aliases are commented for compatibility with scripts

# ──────────────────────────────────────────────────────────────
# 📁 FILE & DIRECTORY OPERATIONS
# ──────────────────────────────────────────────────────────────
alias cat='bat --paging=never'                              # Syntax highlighted cat
alias ls='eza --icons --group-directories-first'            # Modern ls with icons
alias ll='eza --icons --group-directories-first -l --git'   # Detailed list with git status
alias la='eza --icons --group-directories-first -la --git'  # All files with git status
alias tree='eza --tree --icons'                             # Tree view with icons
# alias find='fd'  # Disabled - conflicts with nvm_find_nvmrc and scripts
# Use 'fd' directly for modern features
# alias grep='rg' # Disabled - causes compatibility issues with scripts

# ──────────────────────────────────────────────────────────────
# 🖥️ SYSTEM MONITORING & PROCESSES
# ──────────────────────────────────────────────────────────────
alias ps='procs'                                            # Modern process viewer
alias top='btop'                                            # Beautiful system monitor
alias du='dust'                                             # Disk usage analyzer
alias df='duf'                                              # Disk free with better formatting

# ──────────────────────────────────────────────────────────────
# 🌐 NETWORK TOOLS
# ──────────────────────────────────────────────────────────────
alias ping='gping'                                          # Visual ping with graphs
alias curl='curlie'                                         # Enhanced curl with better syntax
alias dig='doggo'                                           # Modern dig replacement
alias bandw='bandwhich'                                     # Network bandwidth monitoring

# ──────────────────────────────────────────────────────────────
# 🔍 SEARCH & TEXT PROCESSING
# ──────────────────────────────────────────────────────────────
alias diff='delta'                                          # Enhanced diff with syntax highlighting
# Note: sed alias removed - sd has different syntax, use directly
alias hex='hexyl'                                           # Modern hex viewer
# Note: rg available directly (no alias for compatibility)
# Note: Original sed available as /usr/bin/sed if needed

# ──────────────────────────────────────────────────────────────
# 🛠️ DEVELOPMENT TOOLS
# ──────────────────────────────────────────────────────────────
alias cloc='tokei'                                          # Count lines of code
alias bench='hyperfine'                                     # Command benchmarking
alias jsonpp='jq .'                                         # JSON pretty printing
# alias make='just'  # Commented - can break existing Makefiles
# Use 'just' directly for new projects

# ──────────────────────────────────────────────────────────────
# 📚 HELP & DOCUMENTATION
# ──────────────────────────────────────────────────────────────
alias help='tldr'                                           # Simplified man pages

# Smart help function: comprehensive documentation lookup
function help() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: help <command>"
        return 1
    fi
    
    # Try tldr first for quick examples
    if command -v tldr > /dev/null 2>&1 && tldr "$1" 2>/dev/null; then
        echo "\n📖 For detailed documentation, run: man $1"
        return 0
    else
        # Fallback to man pages
        command man "$@"
    fi
}

# Keep traditional man command unchanged
# Use 'help <command>' for tldr + man combo

# ──────────────────────────────────────────────────────────────
# 🔧 GIT WORKFLOW OPTIMIZATION
# ──────────────────────────────────────────────────────────────
alias gd='git diff --name-only --diff-filter=d | xargs delta'       # Enhanced git diff with delta
alias glg='git log --oneline --graph --decorate --all'              # Pretty git log
alias gst='git status -sb'                                          # Short git status
alias ggui='gitui'                                                  # Git TUI
alias glog='gitui'                                                  # Alternative git TUI alias

# ──────────────────────────────────────────────────────────────
# 📊 SYSTEM INFO & UTILITIES
# ──────────────────────────────────────────────────────────────
alias sysinfo='fastfetch'                                   # System information
alias ports='netstat -an | grep LISTEN'                     # Show listening ports

# ──────────────────────────────────────────────────────────────
# 🚀 PRODUCTIVITY ALIASES
# ──────────────────────────────────────────────────────────────
alias reload='source ~/.zshrc'                              # Reload zsh config
alias cls='clear'                                           # Clear screen (Windows muscle memory)
alias h='history'                                           # Quick history
alias path='echo -e ${PATH//:/\\n}'                        # Pretty print PATH
alias now='date +"%T"'                                       # Current time
alias today='date +"%A, %B %d, %Y"'                        # Today's date

# ──────────────────────────────────────────────────────────────
# 💻 DEVELOPMENT SHORTCUTS
# ──────────────────────────────────────────────────────────────
alias npmls='npm list --depth=0'                           # Show top-level npm packages
alias yarnls='yarn list --depth=0'                         # Show top-level yarn packages
alias serve='python3 -m http.server'                       # Quick HTTP server
alias localhost='open http://localhost'                     # Open localhost in browser

# ──────────────────────────────────────────────────────────────
# 🐳 DOCKER SHORTCUTS
# ──────────────────────────────────────────────────────────────
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'  # Pretty docker ps
alias dlog='docker logs -f'                                # Follow docker logs
alias dex='docker exec -it'                               # Execute in container
alias dstop='docker stop $(docker ps -q)'                # Stop all containers
alias dclean='docker system prune -f'                     # Clean up docker
alias dimg='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'  # Pretty images list

# ──────────────────────────────────────────────────────────────
# 🔒 SECURITY & CLEANUP
# ──────────────────────────────────────────────────────────────
alias lock='pmset displaysleepnow'                         # Lock screen immediately
alias flush='dscacheutil -flushcache'                      # Flush DNS cache

# ──────────────────────────────────────────────────────────────
# 🔒 COMPATIBILITY PRESERVED
# ──────────────────────────────────────────────────────────────
# These tools are available but NOT aliased to preserve compatibility:
# - grep (use 'rg' directly for modern features)
# - sed (use system version for script compatibility)
# - find (legacy scripts may depend on GNU find behavior)

# ==========================
# 📌 FUNZIONI
# ==========================
# Funzioni utili per snellire operazioni multiple

# Crea una directory e ci entra
function mkcd() {
	mkdir -p "$@" && cd "$_"
}

# Enhanced directory navigation (keeping your excellent up() function)
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

# Quick navigation shortcuts (complement to your up() function)
function ..() { cd ..; }           # Quick parent directory
function ...() { cd ../..; }       # Two levels up
function ....() { cd ../../..; }   # Three levels up

# cd + ls combo
function cdl() { 
    cd "$@" && ls 
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

# Get local IP address
function localip() {
    ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "No network connection"
}

# Quick project setup
function newproject() {
    if [[ -z "$1" ]]; then
        echo "Usage: newproject <project-name>"
        return 1
    fi
    mkcd ~/dev/"$1"
    git init
    echo "# $1" > README.md
    echo "node_modules/\n.env\n.DS_Store" > .gitignore
    echo "✅ Project '$1' created at ~/dev/$1"
}

# Extract any archive
function extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <archive>"
        return 1
    fi
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup of file
function backup() {
    if [[ -z "$1" ]]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$1" "$1.backup.$(date +%Y%m%d-%H%M%S)"
    echo "✅ Backup created: $1.backup.$(date +%Y%m%d-%H%M%S)"
}

# Kill process by name
function killp() {
    if [[ -z "$1" ]]; then
        echo "Usage: killp <process-name>"
        return 1
    fi
    ps aux | grep -v grep | grep "$1" | awk '{print $2}' | xargs kill -9
    echo "✅ Killed processes matching: $1"
}

# Enhanced Git functions
function gc() { 
    if [[ -z "$*" ]]; then
        echo "Usage: gc <commit message>"
        return 1
    fi
    git commit -m "$*" 
}

function gca() { 
    if [[ -z "$*" ]]; then
        echo "Usage: gca <commit message>"
        return 1
    fi
    git add -A && git commit -m "$*" 
}

# Git branch management
function gb() {
    if [[ -z "$1" ]]; then
        git branch -v  # Show all branches if no argument
    else
        git checkout -b "$1"  # Create and switch to new branch
    fi
}

# Git quick push
function gp() {
    local branch=$(git branch --show-current)
    if [[ -z "$branch" ]]; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    echo "🚀 Pushing to origin/$branch..."
    git push origin "$branch"
}

# Git quick pull
function gpl() {
    local branch=$(git branch --show-current)
    if [[ -z "$branch" ]]; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    echo "⬇️ Pulling from origin/$branch..."
    git pull origin "$branch"
}

# Git status with enhanced info
function gs() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    echo "📊 Repository Status:"
    echo "─────────────────────"
    
    # Show current branch and status
    git status -sb
    
    # Show recent commits
    echo "\n📝 Recent commits:"
    git log --oneline -5
    
    # Show stashes if any
    local stash_count=$(git stash list | wc -l | tr -d ' ')
    if [[ $stash_count -gt 0 ]]; then
        echo "\n💾 Stashes ($stash_count):"
        git stash list
    fi
}

# ==========================
# 📌 STRUMENTI DI SICUREZZA
# ==========================
# Alias e funzioni per strumenti di sicurezza

# Alias per gestire ClamAV in modo efficiente
alias clamav="$HOME/dotfiles/scripts/clamav-manager.sh"

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
eval "$(mcfly init zsh)"
unset RIPGREP_CONFIG_PATH

# Auto-switch Node.js version based on .nvmrc
# Auto-switch Node.js version based on .nvmrc (using centralized NVM loading)
autoload -U add-zsh-hook
load-nvmrc() {
  # Use centralized NVM loading function
  _load_nvm

  local node_version="$(nvm version)"
  # Use command to avoid alias conflicts
  local nvmrc_path="$(command -p find . -maxdepth 1 -name '.nvmrc' 2>/dev/null | head -1)"
  
  # If no .nvmrc in current dir, check if nvm_find_nvmrc exists and use it
  if [[ -z "$nvmrc_path" ]] && command -v nvm_find_nvmrc > /dev/null 2>&1; then
    nvmrc_path="$(nvm_find_nvmrc)"
  fi

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
