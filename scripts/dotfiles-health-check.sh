#!/usr/bin/env bash

# ==========================
# 🏥 DOTFILES HEALTH CHECK
# ==========================
# Script per verificare lo stato delle configurazioni dotfiles

set -euo pipefail

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contatori per il report finale
declare -i CHECKS_PASSED=0
declare -i CHECKS_FAILED=0
declare -i CHECKS_WARNING=0

# Funzione per stampare messaggi colorati
print_status() {
    local status=$1
    local message=$2

    case $status in
        "pass")
            echo -e "${GREEN}✓${NC} $message"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
            ;;
        "fail")
            echo -e "${RED}✗${NC} $message"
            CHECKS_FAILED=$((CHECKS_FAILED + 1))
            ;;
        "warn")
            echo -e "${YELLOW}⚠${NC} $message"
            CHECKS_WARNING=$((CHECKS_WARNING + 1))
            ;;
        "info")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
    esac
}

# Header
echo -e "\n${BLUE}===========================${NC}"
echo -e "${BLUE}🏥 DOTFILES HEALTH CHECK${NC}"
echo -e "${BLUE}===========================${NC}\n"

# ==========================
# 1. Verifica link simbolici
# ==========================
echo -e "${BLUE}📎 Verificando link simbolici...${NC}"

check_symlink() {
    local link=$1
    local target=$2
    local description=$3

    if [[ -L "$link" ]]; then
        if [[ -e "$link" ]]; then
            print_status "pass" "$description"
        else
            print_status "fail" "$description (link rotto)"
        fi
    else
        print_status "warn" "$description (non è un link simbolico)"
    fi
}

# Controlla i link principali
check_symlink "$HOME/.zshrc" "$HOME/dotfiles/zshrc" "Zsh config"
check_symlink "$HOME/.gitconfig" "$HOME/dotfiles/gitconfig" "Git config"
check_symlink "$HOME/.config/starship" "$HOME/dotfiles/starship" "Starship config"

echo ""

# ==========================
# 2. Verifica permessi file sensibili
# ==========================
echo -e "${BLUE}🔒 Verificando permessi file sensibili...${NC}"

check_permissions() {
    local file=$1
    local expected_perms=$2
    local description=$3

    if [[ -e "$file" ]]; then
        # Se è un link simbolico, controlla i permessi del file target
        if [[ -L "$file" ]]; then
            target=$(readlink "$file")
            # Se il target è un percorso relativo, rendilo assoluto
            if [[ ! "$target" = /* ]]; then
                target=$(dirname "$file")/"$target"
            fi
            actual_perms=$(stat -f "%OLp" "$target" 2>/dev/null || stat -c "%a" "$target" 2>/dev/null)
        else
            actual_perms=$(stat -f "%OLp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
        fi

        if [[ "$actual_perms" == "$expected_perms" ]]; then
            print_status "pass" "$description (permessi: $actual_perms)"
        else
            print_status "fail" "$description (permessi: $actual_perms, attesi: $expected_perms)"
        fi
    else
        print_status "warn" "$description (file non trovato)"
    fi
}

check_permissions "$HOME/.ssh" "700" "Directory SSH"
check_permissions "$HOME/.ssh/config" "600" "SSH config"
check_permissions "$HOME/.config/op/config" "600" "1Password config"

echo ""

# ==========================
# 3. Verifica strumenti installati
# ==========================
echo -e "${BLUE}🛠️  Verificando strumenti installati...${NC}"

check_command() {
    local cmd=$1
    local description=$2

    if command -v "$cmd" &> /dev/null; then
        print_status "pass" "$description"
    else
        print_status "fail" "$description (non installato)"
    fi
}

# Strumenti essenziali
check_command "brew" "Homebrew"
check_command "git" "Git"
check_command "zsh" "Zsh"
check_command "starship" "Starship prompt"

# Strumenti CLI moderni
check_command "bat" "Bat (cat migliorato)"
check_command "eza" "Eza (ls moderno)"
check_command "rg" "Ripgrep"
check_command "fd" "Fd (find moderno)"
check_command "fzf" "FZF"
check_command "zoxide" "Zoxide"

echo ""

# ==========================
# 4. Verifica configurazioni Git
# ==========================
echo -e "${BLUE}🔧 Verificando configurazioni Git...${NC}"

git_user=$(git config --global user.name 2>/dev/null)
git_email=$(git config --global user.email 2>/dev/null)

if [[ -n "$git_user" ]]; then
    print_status "pass" "Git user.name: $git_user"
else
    print_status "fail" "Git user.name non configurato"
fi

if [[ -n "$git_email" ]]; then
    print_status "pass" "Git user.email: $git_email"
else
    print_status "fail" "Git user.email non configurato"
fi

echo ""

# ==========================
# 5. Verifica shell predefinita
# ==========================
echo -e "${BLUE}🐚 Verificando shell predefinita...${NC}"

current_shell=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
if [[ "$current_shell" == "/bin/zsh" ]] || [[ "$current_shell" == "/opt/homebrew/bin/zsh" ]]; then
    print_status "pass" "Shell predefinita: $current_shell"
else
    print_status "warn" "Shell predefinita: $current_shell (non è zsh)"
fi

echo ""

# ==========================
# 6. Verifica Homebrew
# ==========================
echo -e "${BLUE}🍺 Verificando Homebrew...${NC}"

if command -v brew &> /dev/null; then
    outdated_count=$(brew outdated | wc -l | tr -d ' ')
    if [[ "$outdated_count" -eq 0 ]]; then
        print_status "pass" "Tutti i pacchetti Homebrew sono aggiornati"
    else
        print_status "warn" "$outdated_count pacchetti Homebrew da aggiornare"
    fi

    # Controlla problemi con brew doctor
    brew_doctor_output=$(brew doctor 2>&1 || true)
    if [[ "$brew_doctor_output" == *"Your system is ready to brew"* ]]; then
        print_status "pass" "Homebrew è in buono stato"
    elif [[ -z "$brew_doctor_output" ]]; then
        print_status "pass" "Homebrew è in buono stato"
    else
        print_status "warn" "Homebrew ha alcuni avvisi (esegui 'brew doctor' per dettagli)"
    fi
fi

echo ""

# ==========================
# 7. Verifica directory di lavoro
# ==========================
echo -e "${BLUE}📁 Verificando directory di lavoro...${NC}"

check_directory() {
    local dir=$1
    local description=$2

    if [[ -d "$dir" ]]; then
        print_status "pass" "$description"
    else
        print_status "warn" "$description (non esiste)"
    fi
}

check_directory "$HOME/work" "Directory work"
check_directory "$HOME/.config" "Directory .config"
check_directory "$HOME/.nano/backups" "Directory backup nano"

echo ""

# ==========================
# 8. Report finale
# ==========================
echo -e "${BLUE}===========================${NC}"
echo -e "${BLUE}📊 REPORT FINALE${NC}"
echo -e "${BLUE}===========================${NC}"

total_checks=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))

echo -e "${GREEN}✓ Passati:${NC} $CHECKS_PASSED"
echo -e "${YELLOW}⚠ Warning:${NC} $CHECKS_WARNING"
echo -e "${RED}✗ Falliti:${NC} $CHECKS_FAILED"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Totale:${NC} $total_checks controlli"

echo ""

# Suggerimenti basati sui risultati
if [[ $CHECKS_FAILED -gt 0 ]]; then
    echo -e "${RED}⚠️  Alcuni controlli sono falliti!${NC}"
    echo -e "${YELLOW}Suggerimenti:${NC}"
    echo "  • Esegui './install' per sistemare i link simbolici"
    echo "  • Controlla i permessi dei file sensibili"
    echo "  • Installa i tool mancanti con 'brew bundle'"
elif [[ $CHECKS_WARNING -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Alcuni controlli hanno generato warning.${NC}"
    echo -e "${YELLOW}Controlla i dettagli sopra per migliorare la configurazione.${NC}"
else
    echo -e "${GREEN}✅ Tutto sembra essere configurato correttamente!${NC}"
fi

echo ""

# Exit code basato sui fallimenti
exit $CHECKS_FAILED
