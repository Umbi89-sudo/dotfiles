# 📋 Piano di Espansione Dotfiles

## 🔍 Configurazioni Esistenti Trovate

### ✅ Già gestite con dotbot

- `~/.zshrc` → `zshrc`
- `~/.zshenv` → `zshenv`
- `~/.gitconfig` → `gitconfig`
- `~/.config/starship/` → `starship/`

### 📁 Configurazioni trovate non ancora nei dotfiles

#### 1. **SSH Config**

- **File**: `~/.ssh/config`
- **Contenuto attuale**: Configurazione per GitHub con chiave SSH
- **Suggerimento**: Aggiungere ai dotfiles con permessi 600

#### 2. **Helix Editor**

- **File**: `~/.config/helix/config.toml`
- **Contenuto**: Tema onedark, keybindings personalizzati, LSP settings
- **Suggerimento**: Ottimo candidato per dotfiles

#### 3. **htop**

- **File**: `~/.config/htop/htoprc`
- **Suggerimento**: Utile per mantenere le preferenze di visualizzazione

#### 4. **nnn File Manager**

- **Directory**: `~/.config/nnn/`
- **Contenuto**: bookmarks, plugins, sessions
- **Suggerimento**: Considera di includere almeno bookmarks e plugins

### 🛠️ Altri tool installati (potenziali configurazioni future)

- cleanmac
- mpv (media player)
- raycast
- waveterm
- op (1Password CLI)

## 📝 Install.conf.yaml Suggerito

```yaml
- defaults:
    link:
      relink: true
      create: true

- clean: ['~']

- link:
    # Shell
    ~/.zshrc: zshrc
    ~/.zshenv: zshenv

    # Git
    ~/.gitconfig: gitconfig

    # Editor
    ~/.config/helix/config.toml: helix/config.toml

    # Terminal & Prompt
    ~/.config/starship:
      path: starship/
      create: true

    # SSH
    ~/.ssh/config:
      path: ssh/config
      create: true
      permissions: '600'

    # System Tools
    ~/.config/htop/htoprc: htop/htoprc

    # File Manager
    ~/.config/nnn/bookmarks: nnn/bookmarks
    ~/.config/nnn/plugins:
      path: nnn/plugins/
      create: true

- create:
    - ~/work
    - ~/.config
    - ~/.ssh

- shell:
    - [chmod 700 ~/.ssh, Securing SSH directory]
```

## 🚀 Prossimi Passi

1. **Creare le directory nel repository dotfiles**:

   ```
   dotfiles/
   ├── helix/
   │   └── config.toml
   ├── ssh/
   │   └── config
   ├── htop/
   │   └── htoprc
   └── nnn/
       ├── bookmarks
       └── plugins/
   ```

2. **Copiare i file esistenti nel repository**

3. **Aggiornare install.conf.yaml**

4. **Testare l'installazione**:

   ```bash
   cd ~/dotfiles
   ./install
   ```

## 💡 Configurazioni Future da Considerare

Quando installerai questi tool, potrai aggiungere:

- `~/.config/bat/config` - Configurazione bat (cat con syntax highlighting)
- `~/.tmux.conf` - Se userai tmux
- `~/.config/mpv/mpv.conf` - Configurazione media player
- `~/.npmrc` - Configurazione npm globale
- `~/.cargo/config.toml` - Se usi Rust
