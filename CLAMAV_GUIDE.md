# 🛡️ Guida Completa ClamAV per macOS

## 📋 Indice

- [Installazione](#installazione)
- [Configurazione Iniziale](#configurazione-iniziale)
- [Utilizzo dello Script](#utilizzo-dello-script)
- [Manutenzione](#manutenzione)
- [Troubleshooting](#troubleshooting)
- [Implementazioni Future](#implementazioni-future)
- [Best Practices](#best-practices)

---

## 🚀 Installazione

### 1. Installare ClamAV

```bash
brew install clamav
```

### 2. Configurazione automatica

Lo script di installazione dei dotfiles configura automaticamente:

- File di configurazione ottimizzati
- Aggiornamenti automatici del database
- Script di gestione avanzato

### 3. Primo aggiornamento

```bash
sudo freshclam
```

---

## 🔧 Configurazione Iniziale

### File di configurazione

- **clamd.conf**: `/opt/homebrew/etc/clamav/clamd.conf`
- **freshclam.conf**: `/opt/homebrew/etc/clamav/freshclam.conf`

### Directory importanti

- **Database**: `/opt/homebrew/var/lib/clamav/`
- **Quarantena**: `~/.clamav/quarantine/`
- **Log**: `~/.clamav/logs/`

---

## 📖 Utilizzo dello Script

### Comandi Base

#### Aggiornare le definizioni virus

```bash
./scripts/clamav-manager.sh update
```

⚠️ Richiede sudo per accedere alle directory di sistema

#### Scansione rapida (solo file a rischio)

```bash
# Scansione rapida della home
./scripts/clamav-manager.sh quick

# Scansione rapida di una directory specifica
./scripts/clamav-manager.sh quick /Applications
```

#### Scansione completa

```bash
# Scansione completa della home
./scripts/clamav-manager.sh full

# Scansione completa di una directory
./scripts/clamav-manager.sh full ~/Documents
```

#### Scansione Downloads

```bash
./scripts/clamav-manager.sh downloads
```

#### Scansione file singolo

```bash
./scripts/clamav-manager.sh file ~/Downloads/suspicious-file.zip
```

### Comandi Avanzati

#### Visualizzare statistiche

```bash
./scripts/clamav-manager.sh stats
```

Mostra:

- Età del database antivirus
- Numero di file in quarantena
- Scansioni recenti

#### Pulire la quarantena

```bash
# Elimina file in quarantena più vecchi di 30 giorni (default)
./scripts/clamav-manager.sh quarantine

# Elimina file più vecchi di 7 giorni
./scripts/clamav-manager.sh quarantine 7
```

### Gestione File Infetti

Quando viene trovato un virus, lo script offre 3 opzioni:

1. **Quarantena**: Sposta il file in `~/.clamav/quarantine/`
2. **Elimina**: Rimuove permanentemente il file
3. **Ignora**: Lascia il file (non consigliato)

---

## 🔧 Manutenzione

### Manutenzione Giornaliera

```bash
# Aggiornare il database (automatico con launchd)
sudo freshclam
```

### Manutenzione Settimanale

```bash
# Scansione rapida della home
./scripts/clamav-manager.sh quick

# Controllare statistiche
./scripts/clamav-manager.sh stats
```

### Manutenzione Mensile

```bash
# Scansione completa
./scripts/clamav-manager.sh full ~/

# Pulire quarantena vecchia
./scripts/clamav-manager.sh quarantine 30

# Verificare log per pattern sospetti
ls -la ~/.clamav/logs/
```

### Aggiornamenti Automatici

Il LaunchAgent configurato aggiorna automaticamente il database ogni 4 ore:

```bash
# Verificare stato
launchctl list | grep freshclam

# Riavviare se necessario
launchctl unload ~/Library/LaunchAgents/com.clamav.freshclam.plist
launchctl load ~/Library/LaunchAgents/com.clamav.freshclam.plist
```

---

## 🔍 Troubleshooting

### Problema: "Database antivirus vecchio"

```bash
# Soluzione: Aggiornare manualmente
sudo freshclam
```

### Problema: "Permission denied"

```bash
# Soluzione: Usare sudo per operazioni di sistema
sudo ./scripts/clamav-manager.sh update
```

### Problema: "Can't create temporary directory"

```bash
# Soluzione: Correggere i permessi
sudo chown -R _clamav:_clamav /opt/homebrew/var/lib/clamav
sudo chmod 755 /opt/homebrew/var/lib/clamav
```

### Problema: "Failed to open log file"

```bash
# Soluzione: Correggere proprietario log
sudo chown _clamav:_clamav /opt/homebrew/var/log/clamav/freshclam.log
```

### Verificare configurazione

```bash
# Test configurazione freshclam
freshclam --config-test

# Verificare database
clamscan --debug 2>&1 | grep "loaded"
```

---

## 🚀 Implementazioni Future

### 1. **Integrazione con FSEvents**

Monitorare in tempo reale modifiche ai file:

```bash
# Concept per monitoring real-time
fswatch -o ~/Downloads | xargs -n1 -I{} ./scripts/clamav-manager.sh file {}
```

### 2. **Dashboard Web**

- Statistiche in tempo reale
- Gestione quarantena via web
- Grafici delle minacce nel tempo

### 3. **Integrazione con Mail**

```bash
# Scansione automatica allegati email
# Integrazione con Mail.app
```

### 4. **API REST**

```bash
# Endpoint per scansioni remote
# Webhook per notifiche
```

### 5. **Machine Learning**

- Analisi comportamentale
- Rilevamento anomalie
- Pattern recognition personalizzato

### 6. **Backup Automatico**

```bash
# Prima della quarantena/eliminazione
# Integrazione con Time Machine
```

### 7. **Report Avanzati**

- Report PDF mensili
- Analisi trend minacce
- Statistiche dettagliate

### 8. **Integrazione CI/CD**

```bash
# Scansione automatica nei pipeline
# GitHub Actions integration
```

---

## 📚 Best Practices

### 1. **Scansioni Programmate**

```bash
# Crontab per scansione notturna
0 3 * * * /Users/$USER/dotfiles/scripts/clamav-manager.sh quick >> /Users/$USER/.clamav/logs/cron.log 2>&1
```

### 2. **Esclusioni Intelligenti**

Aggiungere al file di configurazione:

- Directory di sviluppo (node_modules, .git)
- File di sistema macOS
- Cache applicazioni

### 3. **Monitoraggio Performance**

```bash
# Verificare impatto CPU durante scansioni
top -pid $(pgrep clamscan)
```

### 4. **Backup Prima di Eliminare**

Sempre verificare il contenuto della quarantena prima di eliminarla:

```bash
ls -la ~/.clamav/quarantine/
```

### 5. **Log Rotation**

```bash
# Pulire log vecchi mensilmente
find ~/.clamav/logs -name "*.log" -mtime +30 -delete
```

### 6. **Notifiche Personalizzate**

Modificare lo script per integrare con:

- Slack/Discord per team
- Email per report
- Push notification per mobile

### 7. **Whitelist Personalizzata**

Creare file di esclusioni per software fidato:

```bash
# ~/.clamav/whitelist.txt
/Applications/MyTrustedApp.app
~/Development/my-project
```

---

## 🔐 Sicurezza Aggiuntiva

### Combinare con altri strumenti

1. **XProtect** (built-in macOS)
2. **Gatekeeper** (verifica app)
3. **FileVault** (crittografia disco)
4. **Little Snitch** (firewall)

### Verifiche periodiche

```bash
# Verificare integrità sistema
sudo sip status
csrutil status

# Controllare processi sospetti
ps aux | grep -v grep | grep -i suspicious
```

---

## 📞 Supporto

### Risorse Ufficiali

- [ClamAV Documentation](https://docs.clamav.net/)
- [ClamAV GitHub](https://github.com/Cisco-Talos/clamav)
- [Homebrew Formula](https://formulae.brew.sh/formula/clamav)

### Community

- IRC: #clamav on irc.freenode.net
- Mailing List: <clamav-users@lists.clamav.net>

---

## 📝 Note Finali

Questo sistema di protezione è progettato per essere:

- **Non invasivo**: Scansioni su richiesta, non in background
- **Efficiente**: Ottimizzato per macOS e SSD
- **Flessibile**: Facilmente estendibile e personalizzabile
- **Sicuro**: Quarantena automatica con backup

Ricorda: ClamAV è uno strumento aggiuntivo di sicurezza. Mantieni sempre:

- macOS aggiornato
- Backup regolari con Time Machine
- Buone pratiche di sicurezza online

---

_Ultimo aggiornamento: Giugno 2025_
