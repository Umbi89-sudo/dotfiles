#!/usr/bin/env zsh

# ==========================
# 🍎 MACOS SETUP SCRIPT
# ==========================
# Configurazioni macOS ottimizzate per produttività

echo "\n<<< Starting macOS Setup >>>\n"

# Chiudi System Preferences per evitare conflitti
osascript -e 'tell application "System Preferences" to quit'

# ==========================
# 🗂️ FINDER
# ==========================
echo "Configuring Finder..."

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder > Preferences > General > New Finder windows show:
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Mostra tutte le estensioni dei file
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Mostra file nascosti
defaults write com.apple.finder AppleShowAllFiles -bool true

# Usa vista lista come default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# ==========================
# 🖱️ TRACKPAD
# ==========================
echo "Configuring Trackpad..."

# System Preferences > Accessibility > Pointer Control > Mouse & Trackpad > Trackpad Options
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Abilita tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ==========================
# ⌨️ TASTIERA E TESTO
# ==========================
echo "Configuring Keyboard and Text..."

# Disabilita correzione automatica
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disabilita capitalizzazione automatica
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disabilita smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disabilita sostituzione automatica del punto
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disabilita smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Velocità ripetizione tasti più veloce
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# ==========================
# 🖥️ DOCK
# ==========================
echo "Configuring Dock..."

# Rimuovi il delay per mostrare il Dock
defaults write com.apple.dock autohide-delay -float 0

# Velocizza l'animazione del Dock
defaults write com.apple.dock autohide-time-modifier -float 0.5

# ==========================
# 🔒 SICUREZZA E PRIVACY
# ==========================
echo "Configuring Security..."

# Richiedi password immediatamente dopo sleep o screen saver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ==========================
# 📱 ALTRI MIGLIORAMENTI
# ==========================
echo "Configuring Miscellaneous..."

# Disabilita il suono di avvio
sudo nvram SystemAudioVolume=" "

# Abilita sviluppatore nel menu contestuale di Safari
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Mostra URL completo in Safari
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# ==========================
# 🔄 RESTART SERVICES
# ==========================
echo "Restarting affected applications..."

# Restart Finder
killall Finder

# Restart Dock
killall Dock

# Restart SystemUIServer
killall SystemUIServer

echo "\n<<< macOS Setup Complete. >>>"
echo "    A logout or restart might be necessary for all changes to take effect. >>>\n"
