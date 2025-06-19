# 🚀 Dotfiles

Una configurazione moderna e ottimizzata per macOS con strumenti CLI avanzati e automazione completa.

## ✨ Caratteristiche

- 🤖 **Installazione automatizzata** con [Dotbot](https://github.com/anishathalye/dotbot)
- 🛠️ **Strumenti CLI moderni**: bat, eza, ripgrep, fzf, starship e molti altri
- ⚡ **Performance ottimizzate**: lazy loading di NVM, completamenti cached
- 🎨 **Esperienza utente migliorata**: prompt personalizzato, alias intelligenti
- 🔒 **Sicurezza integrata**: ClamAV manager, configurazioni SSH sicure
- 🍎 **Setup macOS automatizzato**: configurazioni di sistema ottimizzate

## 📋 Prerequisiti

- macOS (testato su macOS 13+)
- [Homebrew](https://brew.sh/) installato
- Git

## 🚀 Installazione Rapida

```bash
# Clona il repository
git clone https://github.com/tuousername/dotfiles.git ~/dotfiles

# Entra nella directory
cd ~/dotfiles

# Esegui l'installazione
./install
```

L'installer:

1. Crea i link simbolici per tutte le configurazioni
2. Installa tutti i pacchetti Homebrew dal Brewfile
3. Configura VS Code con estensioni
4. Imposta i permessi corretti per file sensibili

## 🛠️ Strumenti Inclusi

### Shell e Terminal

- **zsh** - Shell con configurazioni ottimizzate
- **starship** - Prompt cross-shell veloce e personalizzabile
- **warp/wave** - Terminal emulator moderni

### Strumenti CLI Migliorati

- **bat** - `cat` con syntax highlighting
- **eza** - `ls` moderno con icone e git integration
- **ripgrep** - `grep` ultra-veloce
- **fd** - `find` user-friendly
- **fzf** - Fuzzy finder per navigazione veloce
- **zoxide** - `cd` intelligente che impara dalle tue abitudini

### Development

- **helix** - Editor modale post-moderno
- **git-delta** - Diff viewer migliorato per git
- **lazygit/gitui** - TUI per git
- **direnv** - Gestione variabili d'ambiente per progetto

### System Monitoring

- **btop** - Monitor risorse bellissimo
- **htop** - Process viewer interattivo
- **duf** - Disk usage moderno
- **dust** - `du` in Rust

### Networking

- **httpie/curlie** - HTTP client user-friendly
- **doggo** - DNS client moderno
- **gping** - Ping con grafico
- **bandwhich** - Monitor bandwidth

### Utilities

- **just** - Command runner per progetti
- **hyperfine** - Benchmarking tool
- **tealdeer** - `tldr` pages veloce
- **tokei** - Conta linee di codice

## 📁 Struttura

```
dotfiles/
├── config/           # Configurazioni varie
│   ├── bat/         # Bat (cat migliorato)
│   └── nano/        # Nano editor
├── helix/           # Helix editor config
├── htop/            # htop config
├── nnn/             # nnn file manager
├── scripts/         # Script utili
│   └── clamav-manager.sh
├── setup/           # Script di setup
│   └── setup_macos.zsh
├── ssh/             # SSH config (gitignored per sicurezza)
├── starship/        # Starship prompt
├── vscode/          # VS Code settings
├── waveterm/        # Wave terminal
├── zshrc            # Zsh config principale
├── zshenv           # Zsh environment
├── gitconfig        # Git config globale
├── Brewfile         # Homebrew packages
└── install.conf.yaml # Dotbot config
```

## ⚙️ Configurazioni Principali

### Zsh

- Alias intelligenti per comandi comuni
- Funzioni utility (mkcd, up, brewup)
- Lazy loading di NVM per performance
- Integrazione FZF per ricerca veloce
- Syntax highlighting

### Git

- Configurazioni globali sensate
- Alias per workflow comuni
- Delta per diff migliorati

### macOS

Esegui lo script di setup per applicare ottimizzazioni di sistema:

```bash
./setup/setup_macos.zsh
```

Questo configura:

- Finder: mostra path bar, estensioni, file nascosti
- Trackpad: three finger drag, tap to click
- Tastiera: velocità ripetizione ottimizzata
- Sicurezza: richiesta password immediata

## 🔧 Personalizzazione

### Aggiungere nuove configurazioni

1. Aggiungi i file di configurazione nella struttura appropriata
2. Modifica `install.conf.yaml` per creare i link simbolici
3. Esegui `./install` per applicare le modifiche

### Modificare alias/funzioni

Modifica `zshrc` per aggiungere i tuoi alias e funzioni personalizzati.

### Aggiungere pacchetti Homebrew

Modifica `Brewfile` e poi esegui:

```bash
brew bundle --file=Brewfile
```

## 🔒 Sicurezza

- I file sensibili (SSH, 1Password) hanno permessi restrittivi automatici
- ClamAV manager incluso per scansioni antivirus facili
- Le configurazioni SSH sono gitignored di default

## 🐛 Troubleshooting

### Permessi SSH

Se hai problemi con SSH:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_*
```

### Ricarica configurazioni

Dopo modifiche:

```bash
source ~/.zshrc
```

### Reset completo

Per reinstallare tutto da zero:

```bash
cd ~/dotfiles
./install -c install.conf.yaml
```

## 📝 Note

- Le configurazioni sono pensate per macOS ma molte funzionano anche su Linux
- Alcuni tool richiedono configurazioni aggiuntive post-installazione
- Controlla i log di installazione per eventuali errori

## 🤝 Contributi

Sentiti libero di:

- Segnalare bug
- Suggerire miglioramenti
- Condividere le tue configurazioni

## 📜 Licenza

MIT - Usa liberamente queste configurazioni!

---

Ispirato da [dotfiles.github.io](https://dotfiles.github.io/) e dalla community dotfiles.
