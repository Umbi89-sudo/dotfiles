# 🚀 Guida Setup Dotfiles

## 📋 Panoramica

Questo repository contiene una configurazione completa per macOS con:

- **Gestione pacchetti** via Homebrew Brewfile
- **Configurazioni editor** (Helix, Nano, VS Code)
- **Tool CLI moderni** (bat, eza, btop, etc.)
- **Impostazioni macOS** ottimizzate
- **Sincronizzazione automatica** tra sistemi

## 🛠️ Installazione

### Setup Iniziale

```bash
git clone git@github.com:Umbi89-sudo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

### Configurazioni macOS (Opzionale)

```bash
./setup/setup_macos.zsh
```

## 📁 Struttura

```
dotfiles/
├── Brewfile                    # 📦 Pacchetti Homebrew
├── install.conf.yaml          # ⚙️ Configurazione dotbot
├── config/
│   ├── bat/config             # 🦇 Configurazione bat
│   └── nano/nanorc            # 📝 Configurazione nano
├── vscode/
│   ├── settings.json          # ⚙️ Impostazioni VS Code
│   └── extensions.txt         # 🔌 Estensioni VS Code
├── setup/
│   └── setup_macos.zsh        # 🍎 Configurazioni macOS
└── [altri file di config...]
```

## 🔧 Configurazioni Incluse

### 🦇 **bat** (cat migliorato)

- Tema: Catppuccin Mocha
- Syntax highlighting per file config
- Numerazione righe e git changes

### 📝 **nano** (editor di testo)

- Syntax highlighting completo
- Numerazione righe e mouse support
- Backup automatici in `~/.nano/backups`

### 💻 **VS Code**

- Sincronizzazione settings.json
- Auto-installazione estensioni
- Font: Hack Nerd Font Mono

### 🍎 **macOS**

- Finder ottimizzato (path bar, estensioni visibili)
- Trackpad three-finger drag
- Disabilita correzioni automatiche
- Dock e animazioni velocizzate

## 🔄 Aggiornamenti

### Aggiornare Brewfile

```bash
cd ~/dotfiles
brew bundle dump --describe --file=Brewfile --force
git add Brewfile && git commit -m "update: Brewfile packages"
```

### Aggiornare VS Code Extensions

```bash
cd ~/dotfiles
code --list-extensions > vscode/extensions.txt
git add vscode/extensions.txt && git commit -m "update: VS Code extensions"
```

### Sincronizzare su nuovo sistema

```bash
git pull origin main
./install
```

## 🎯 Tool CLI Inclusi

| Tool   | Descrizione                 | Alias            |
| ------ | --------------------------- | ---------------- |
| `bat`  | cat con syntax highlighting | `cat`            |
| `eza`  | ls moderno                  | `ls`, `ll`, `la` |
| `rg`   | grep veloce                 | `grep`           |
| `fd`   | find migliorato             | `find`           |
| `btop` | htop moderno                | `top`            |
| `dust` | du migliorato               | `du`             |
| `duf`  | df migliorato               | `df`             |

## 🔍 Troubleshooting

### Problemi con bat theme

```bash
bat --list-themes | grep -i catppuccin
# Se non presente, installare:
brew install bat-extras
```

### Problemi con VS Code extensions

```bash
# Reinstallare manualmente:
cat vscode/extensions.txt | xargs -L1 code --install-extension
```

### Reset configurazioni macOS

```bash
# Per ripristinare una singola impostazione:
defaults delete com.apple.finder ShowPathbar
```

## 📚 Risorse

- [Dotbot Documentation](https://github.com/anishathalye/dotbot)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)
- [macOS defaults](https://macos-defaults.com/)
