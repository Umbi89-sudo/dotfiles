#!/usr/bin/env bash

# ==========================
# 🛡️ CLAMAV MANAGER
# ==========================
# Script per gestire ClamAV su macOS in modo efficiente

set -euo pipefail

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funzione per stampare messaggi colorati
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Funzione per verificare se ClamAV è installato
check_clamav_installed() {
    if ! command -v clamscan &> /dev/null; then
        print_message "$RED" "❌ ClamAV non è installato!"
        print_message "$YELLOW" "Installalo con: brew install clamav"
        exit 1
    fi
}

# Funzione per aggiornare le definizioni virus
update_definitions() {
    print_message "$BLUE" "🔄 Aggiornamento definizioni virus..."

    # Verifica se freshclam è configurato
    if [[ ! -f /opt/homebrew/etc/clamav/freshclam.conf ]]; then
        print_message "$YELLOW" "⚠️  Configurazione freshclam mancante. Creazione in corso..."
        sudo cp /opt/homebrew/etc/clamav/freshclam.conf.sample /opt/homebrew/etc/clamav/freshclam.conf
        sudo sed -i '' 's/^Example/#Example/' /opt/homebrew/etc/clamav/freshclam.conf
    fi

    # Aggiorna definizioni
    if freshclam; then
        print_message "$GREEN" "✅ Definizioni virus aggiornate!"
    else
        print_message "$RED" "❌ Errore nell'aggiornamento delle definizioni"
        exit 1
    fi
}

# Funzione per scansione rapida
quick_scan() {
    local target="${1:-$HOME}"
    print_message "$BLUE" "🔍 Scansione rapida di: $target"
    print_message "$YELLOW" "   (solo file eseguibili e archivi)"

    clamscan -r --bell -i \
        --include='\.exe$' \
        --include='\.dll$' \
        --include='\.app$' \
        --include='\.dmg$' \
        --include='\.pkg$' \
        --include='\.zip$' \
        --include='\.rar$' \
        --include='\.7z$' \
        --include='\.tar$' \
        --include='\.gz$' \
        "$target"
}

# Funzione per scansione completa
full_scan() {
    local target="${1:-$HOME}"
    print_message "$BLUE" "🔍 Scansione completa di: $target"
    print_message "$YELLOW" "   (questo potrebbe richiedere molto tempo)"

    clamscan -r --bell -i \
        --exclude-dir="^/System" \
        --exclude-dir="^/private/var/db" \
        --exclude-dir="^/private/var/folders" \
        --exclude-dir="\.Trash" \
        --exclude-dir="Library/Caches" \
        --exclude-dir="node_modules" \
        --exclude-dir="\.git" \
        "$target"
}

# Funzione per scansione download
scan_downloads() {
    print_message "$BLUE" "🔍 Scansione cartella Downloads..."
    clamscan -r --bell -i "$HOME/Downloads"
}

# Funzione per mostrare l'help
show_help() {
    cat << EOF
🛡️  ClamAV Manager - Gestione semplificata di ClamAV

Uso: clamav [comando] [opzioni]

Comandi:
    update          Aggiorna le definizioni virus
    quick [path]    Scansione rapida (solo file a rischio)
    full [path]     Scansione completa
    downloads       Scansiona la cartella Downloads
    help            Mostra questo messaggio

Esempi:
    clamav update              # Aggiorna definizioni
    clamav quick               # Scansione rapida della home
    clamav quick /Applications # Scansione rapida di Applications
    clamav full ~/Documents    # Scansione completa di Documents
    clamav downloads           # Scansiona Downloads

Note:
    - Le scansioni mostrano solo i file infetti (-i flag)
    - Un campanello suona quando trova virus (--bell flag)
    - La scansione completa esclude cartelle di sistema e cache

EOF
}

# Main
check_clamav_installed

case "${1:-help}" in
    update)
        update_definitions
        ;;
    quick)
        quick_scan "${2:-$HOME}"
        ;;
    full)
        full_scan "${2:-$HOME}"
        ;;
    downloads)
        scan_downloads
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_message "$RED" "❌ Comando non riconosciuto: $1"
        show_help
        exit 1
        ;;
esac
