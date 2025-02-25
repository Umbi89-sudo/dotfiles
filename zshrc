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

export PATH="/opt/homebrew/bin:$PATH"

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
# 📌 NVM (Lazy Load)
# ==========================
# Carica NVM solo al momento del primo utilizzo dei relativi comandi,
# riducendo i tempi di startup della shell.

export NVM_DIR="$HOME/.nvm"

load_nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

alias nvm="load_nvm && nvm"
alias node="load_nvm && node"
alias npm="load_nvm && npm"
alias yarn="load_nvm && yarn"
alias pnpm="load_nvm && pnpm"

# ==========================
# 📌 ALIAS POTENZIATI
# ==========================
# Alias utili per navigare, gestire file, Git e molto altro.

## 📂 Navigazione e gestione file
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"               # Vista dettagliata
alias la="eza --icons --group-directories-first -la"             # File nascosti inclusi
alias lt="eza --icons --group-directories-first -lT"             # Mostra in formato albero
alias lS="eza --icons --group-directories-first -l --sort=size"  # Ordina per dimensione
alias ..="cd .."                                                 # Torna indietro di una directory
alias ...="cd ../.."                                             # Torna indietro di due directory

## 🔍 Ricerca
alias grep="grep --color=auto -i"     # Ricerca case-insensitive con evidenziazione

## 🌿 Git
alias gs="git status"
alias gl="git log --oneline --graph --decorate"
alias gco="git checkout"
alias gb="git branch"
alias ga="git add . && git status"
alias gc="git commit -m"
alias gp="git push"
alias gpull="git pull"
alias gcl="git clone"

## 🖥️ Dev tools
alias code="open -a 'Visual Studio Code'"
alias serve="python3 -m http.server"   # Avvia un server HTTP locale
alias pjson="python3 -m json.tool"     # Formatta JSON in modo leggibile

## 🐳 Docker
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dps="docker ps"
alias dprune="docker system prune -f"

## 📦 Pacchetti e gestione progetti (npm)
alias ni="npm install"
alias nr="npm run"
alias nd="npm run dev"
alias ns="npm start"
alias nu="npm update"

## 🗂️ Extra utilità
alias cls="clear"
alias c="clear"
alias h="history"
alias ping="ping -c 5"                  # Fa 5 ping e poi esce
alias diff="diff --color=auto"
alias cat="bat"                         # Usa 'bat' per evidenziazione sintassi, se installato
alias tree="eza --tree --icons"         # Struttura a tree con icone

# ==========================
# 📌 FUNZIONI
# ==========================
# Funzioni utili per snellire operazioni multiple
function mkcd() {
	mkdir -p "$@" && cd "$_";
}

# ==========================
# 📌 PLUGIN OPZIONALI (Autosuggestions e Syntax Highlighting)
# ==========================
# Se preferisci attivarli, rimuovi il commento e assicurati che i plugin siano installati.

# source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ==========================
# 📌 STARSHIP PROMPT (Caricato alla fine)
# ==========================
# Inizializza il prompt Starship (assicurati che starship sia installato).

eval "$(starship init zsh)"

# ==========================
# 📌 AUTO-WARPIFY (specifico per Warp)
# ==========================
# Invia un segnale a Warp per indicare che il file di configurazione è stato caricato.

printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'