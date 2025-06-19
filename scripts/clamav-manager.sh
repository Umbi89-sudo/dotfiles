#!/usr/bin/env bash

# ==========================
# 🛡️ CLAMAV MANAGER ENHANCED
# ==========================
# Script avanzato per gestire ClamAV su macOS

set -euo pipefail

# Configurazione
QUARANTINE_DIR="$HOME/.clamav/quarantine"
LOG_DIR="$HOME/.clamav/logs"
SCAN_LOG="$LOG_DIR/scan_$(date +%Y%m%d_%H%M%S).log"

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Crea directory necessarie
mkdir -p "$QUARANTINE_DIR" "$LOG_DIR"

# Funzione per stampare messaggi colorati
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$SCAN_LOG"
}

# Funzione per notifiche macOS
notify() {
    local title=$1
    local message=$2
    local sound=${3:-"Glass"}

    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
    fi
}

# Funzione per verificare se ClamAV è installato
check_clamav_installed() {
    if ! command -v clamscan &> /dev/null; then
        print_message "$RED" "❌ ClamAV non è installato!"
        print_message "$YELLOW" "Installalo con: brew install clamav"
        notify "ClamAV Manager" "ClamAV non è installato!" "Basso"
        exit 1
    fi
}

# Funzione per verificare lo stato del database
check_database_status() {
    local db_dir="/opt/homebrew/var/lib/clamav"
    local main_cvd="$db_dir/main.cvd"
    local daily_cld="$db_dir/daily.cld"

    if [[ ! -f "$main_cvd" ]] || [[ ! -f "$daily_cld" ]]; then
        print_message "$YELLOW" "⚠️  Database antivirus mancante. Aggiornamento necessario."
        update_definitions
    else
        # Controlla l'età del database
        local daily_age=$(( ($(date +%s) - $(stat -f %m "$daily_cld")) / 86400 ))
        if [[ $daily_age -gt 7 ]]; then
            print_message "$YELLOW" "⚠️  Database antivirus vecchio di $daily_age giorni."
            print_message "$YELLOW" "   Si consiglia di aggiornare con: $0 update"
        fi
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
    if sudo freshclam; then
        print_message "$GREEN" "✅ Definizioni virus aggiornate!"
        notify "ClamAV Manager" "Definizioni virus aggiornate con successo" "Glass"
    else
        print_message "$RED" "❌ Errore nell'aggiornamento delle definizioni"
        notify "ClamAV Manager" "Errore aggiornamento definizioni" "Basso"
        exit 1
    fi
}

# Funzione per gestire file infetti
handle_infected_file() {
    local infected_file=$1
    local virus_name=$2

    print_message "$RED" "🦠 VIRUS TROVATO: $virus_name"
    print_message "$RED" "📁 File: $infected_file"

    # Notifica macOS
    notify "⚠️ Virus Rilevato!" "$virus_name trovato in: $(basename "$infected_file")" "Sosumi"

    # Chiedi all'utente cosa fare
    echo -e "${YELLOW}Cosa vuoi fare?${NC}"
    echo "1) Metti in quarantena"
    echo "2) Elimina il file"
    echo "3) Ignora (non consigliato)"
    echo -n "Scelta (1-3): "
    read -r choice

    case $choice in
        1)
            # Quarantena
            local quarantine_path="$QUARANTINE_DIR/$(date +%Y%m%d_%H%M%S)_$(basename "$infected_file")"
            if mv "$infected_file" "$quarantine_path" 2>/dev/null; then
                print_message "$GREEN" "✅ File messo in quarantena: $quarantine_path"
                # Aggiungi attributo di quarantena macOS
                xattr -w com.apple.quarantine "0081;$(printf %x $(date +%s));ClamAV;|" "$quarantine_path" 2>/dev/null || true
            else
                print_message "$RED" "❌ Impossibile spostare il file. Potrebbe essere necessario sudo."
            fi
            ;;
        2)
            # Elimina
            if rm -f "$infected_file" 2>/dev/null; then
                print_message "$GREEN" "✅ File eliminato"
            else
                print_message "$RED" "❌ Impossibile eliminare il file. Potrebbe essere necessario sudo."
            fi
            ;;
        3)
            print_message "$YELLOW" "⚠️  File ignorato (a tuo rischio)"
            ;;
        *)
            print_message "$RED" "❌ Scelta non valida. File ignorato."
            ;;
    esac
}

# Funzione per scansione con gestione risultati
scan_with_handler() {
    local scan_cmd=$1
    local temp_output="/tmp/clamscan_output_$$"

    # Esegui scansione e cattura output
    $scan_cmd | tee "$temp_output"

    # Analizza risultati per file infetti
    if grep -q "FOUND$" "$temp_output"; then
        print_message "$RED" "⚠️  ATTENZIONE: Trovati file infetti!"

        # Processa ogni file infetto
        grep "FOUND$" "$temp_output" | while IFS=: read -r file virus; do
            virus=$(echo "$virus" | sed 's/FOUND$//' | xargs)
            handle_infected_file "$file" "$virus"
        done
    else
        print_message "$GREEN" "✅ Nessuna minaccia rilevata"
    fi

    # Salva report
    echo -e "\n=== SCAN REPORT ===" >> "$SCAN_LOG"
    cat "$temp_output" >> "$SCAN_LOG"

    # Cleanup
    rm -f "$temp_output"
}

# Funzione per scansione rapida
quick_scan() {
    local target="${1:-$HOME}"
    print_message "$BLUE" "🔍 Scansione rapida di: $target"
    print_message "$YELLOW" "   (solo file a rischio)"

    check_database_status

    local scan_cmd="clamscan -r --bell -i \
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
        --include='\.iso$' \
        --include='\.jar$' \
        --include='\.apk$' \
        --include='\.deb$' \
        --include='\.rpm$' \
        \"$target\""

    scan_with_handler "$scan_cmd"
}

# Funzione per scansione completa
full_scan() {
    local target="${1:-$HOME}"
    print_message "$BLUE" "🔍 Scansione completa di: $target"
    print_message "$YELLOW" "   (questo potrebbe richiedere molto tempo)"

    check_database_status

    local scan_cmd="clamscan -r --bell -i \
        --exclude-dir='^/System' \
        --exclude-dir='^/private/var/db' \
        --exclude-dir='^/private/var/folders' \
        --exclude-dir='\.Trash' \
        --exclude-dir='Library/Caches' \
        --exclude-dir='node_modules' \
        --exclude-dir='\.git' \
        --exclude-dir='\.npm' \
        --exclude-dir='\.cargo' \
        --exclude-dir='\.rustup' \
        \"$target\""

    scan_with_handler "$scan_cmd"
}

# Funzione per scansione download
scan_downloads() {
    print_message "$BLUE" "🔍 Scansione cartella Downloads..."
    check_database_status

    local scan_cmd="clamscan -r --bell -i \"$HOME/Downloads\""
    scan_with_handler "$scan_cmd"
}

# Funzione per scansione file singolo
scan_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        print_message "$RED" "❌ File non trovato: $file"
        exit 1
    fi

    print_message "$BLUE" "🔍 Scansione file: $file"
    check_database_status

    local scan_cmd="clamscan --bell -i \"$file\""
    scan_with_handler "$scan_cmd"
}

# Funzione per mostrare statistiche
show_stats() {
    print_message "$CYAN" "📊 Statistiche ClamAV"

    # Database info
    local db_dir="/opt/homebrew/var/lib/clamav"
    if [[ -f "$db_dir/daily.cld" ]]; then
        local daily_age=$(( ($(date +%s) - $(stat -f %m "$db_dir/daily.cld")) / 86400 ))
        print_message "$BLUE" "   Database aggiornato: $daily_age giorni fa"
    fi

    # Quarantine info
    local quarantine_count=$(find "$QUARANTINE_DIR" -type f 2>/dev/null | wc -l | xargs)
    print_message "$YELLOW" "   File in quarantena: $quarantine_count"

    # Recent scans
    local recent_scans=$(find "$LOG_DIR" -name "scan_*.log" -mtime -7 2>/dev/null | wc -l | xargs)
    print_message "$GREEN" "   Scansioni ultima settimana: $recent_scans"

    # Show quarantine contents if any
    if [[ $quarantine_count -gt 0 ]]; then
        print_message "$PURPLE" "\n📦 File in quarantena:"
        ls -la "$QUARANTINE_DIR" | tail -n +2
    fi
}

# Funzione per pulire quarantena
clean_quarantine() {
    local days=${1:-30}
    print_message "$YELLOW" "🧹 Pulizia file in quarantena più vecchi di $days giorni..."

    local count=$(find "$QUARANTINE_DIR" -type f -mtime +$days 2>/dev/null | wc -l | xargs)

    if [[ $count -gt 0 ]]; then
        find "$QUARANTINE_DIR" -type f -mtime +$days -delete
        print_message "$GREEN" "✅ Eliminati $count file dalla quarantena"
    else
        print_message "$BLUE" "ℹ️  Nessun file da eliminare"
    fi
}

# Funzione per mostrare l'help
show_help() {
    cat << EOF
🛡️  ClamAV Manager Enhanced - Gestione avanzata di ClamAV per macOS

Uso: $(basename "$0") [comando] [opzioni]

Comandi Base:
    update              Aggiorna le definizioni virus
    quick [path]        Scansione rapida (solo file a rischio)
    full [path]         Scansione completa
    downloads           Scansiona la cartella Downloads
    file <path>         Scansiona un file specifico

Comandi Avanzati:
    stats               Mostra statistiche e stato
    quarantine [days]   Pulisci quarantena (default: 30 giorni)
    help                Mostra questo messaggio

Esempi:
    $(basename "$0") update                    # Aggiorna definizioni
    $(basename "$0") quick                     # Scansione rapida della home
    $(basename "$0") quick /Applications       # Scansione rapida di Applications
    $(basename "$0") full ~/Documents          # Scansione completa di Documents
    $(basename "$0") file ~/Downloads/app.dmg  # Scansiona file specifico
    $(basename "$0") stats                     # Mostra statistiche
    $(basename "$0") quarantine 7              # Elimina quarantena > 7 giorni

Caratteristiche:
    ✅ Gestione automatica file infetti (quarantena/eliminazione)
    ✅ Notifiche macOS per virus trovati
    ✅ Log dettagliati di tutte le scansioni
    ✅ Controllo automatico età database
    ✅ Statistiche e report

File e Directory:
    Quarantena: $QUARANTINE_DIR
    Logs:       $LOG_DIR

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
    file)
        if [[ -z "${2:-}" ]]; then
            print_message "$RED" "❌ Specifica il file da scansionare"
            exit 1
        fi
        scan_file "$2"
        ;;
    stats)
        show_stats
        ;;
    quarantine|clean)
        clean_quarantine "${2:-30}"
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

# Mostra percorso log alla fine
print_message "$CYAN" "\n📄 Log salvato in: $SCAN_LOG"
