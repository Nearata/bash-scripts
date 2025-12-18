#!/bin/bash

# Script per download torrent ottimizzato con aria2c
# Supporta file .torrent e magnet link
# Usage: ./torrent_download.sh [TORRENT_FILE/MAGNET] [OUTPUT_DIR]

# ========================================
# CONFIGURAZIONE OTTIMIZZATA
# ========================================

# BitTorrent Settings
BT_MAX_PEERS=100                    # Numero massimo di peer
BT_MIN_PEER_SPEED="100K"            # Velocità minima peer (scarta peer lenti)
BT_REQUEST_PEER_SPEED="100K"        # Richiedi peer veloci
SEED_RATIO=0.0                      # Ratio di seed (0.0=non fare seed, 1.0=seed 1:1)
SEED_TIME=0                         # Tempo di seed in minuti (0=disabilitato)

# Download Settings
MAX_CONCURRENT=3                    # Download paralleli (torrent multipli)
MAX_CONNECTION_PER_SERVER=16        # Connessioni per server
SPLIT=16                            # Parti in cui dividere il file
MIN_SPLIT_SIZE="10M"                # Dimensione minima parti

# Bandwidth Settings (opzionale - commenta per nessun limite)
#MAX_DOWNLOAD_LIMIT="10M"           # Limite download (es: 10M = 10MB/s)
#MAX_UPLOAD_LIMIT="100K"            # Limite upload (100K = 100KB/s)

# Advanced Settings
LISTEN_PORT="6881-6999"             # Range porte per connessioni
FILE_ALLOCATION="falloc"            # Allocazione file (falloc/trunc/none)
DISK_CACHE="64M"                    # Cache disco
BT_TRACKER_TIMEOUT=10               # Timeout tracker
MAX_TRIES=5                         # Tentativi massimi
RETRY_WAIT=3                        # Secondi tra tentativi

# ========================================
# SCRIPT
# ========================================

OUTPUT_DIR="${2:-./downloads}"
TORRENT_INPUT="$1"

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verifica input
if [ -z "$TORRENT_INPUT" ]; then
    echo -e "${RED}Errore: Specificare file torrent o magnet link${NC}"
    echo ""
    echo "Uso: $0 [TORRENT_FILE/MAGNET] [OUTPUT_DIR]"
    echo ""
    echo "Esempi:"
    echo "  $0 file.torrent"
    echo "  $0 file.torrent /path/to/downloads"
    echo "  $0 'magnet:?xt=urn:btih:...'"
    exit 1
fi

# Crea cartella output
mkdir -p "$OUTPUT_DIR"

# Prepara parametri aria2c
ARIA2C_PARAMS=(
    # BitTorrent Protocol
    "--enable-dht=true"
    "--enable-peer-exchange=true"
    "--bt-enable-lpd=true"
    "--bt-max-peers=$BT_MAX_PEERS"
    "--bt-request-peer-speed-limit=$BT_REQUEST_PEER_SPEED"
    "--bt-min-crypto-level=plain"
    "--bt-require-crypto=false"
    "--bt-max-open-files=100"
    
    # Seeding
    "--seed-ratio=$SEED_RATIO"
    "--seed-time=$SEED_TIME"
    
    # Download Settings
    "--max-concurrent-downloads=$MAX_CONCURRENT"
    "--max-connection-per-server=$MAX_CONNECTION_PER_SERVER"
    "--split=$SPLIT"
    "--min-split-size=$MIN_SPLIT_SIZE"
    
    # Network
    "--listen-port=$LISTEN_PORT"
    
    # Performance
    "--file-allocation=$FILE_ALLOCATION"
    "--disk-cache=$DISK_CACHE"
    "--continue=true"
    "--max-tries=$MAX_TRIES"
    "--retry-wait=$RETRY_WAIT"
    
    # Tracker
    "--bt-tracker-connect-timeout=$BT_TRACKER_TIMEOUT"
    "--bt-tracker-timeout=$BT_TRACKER_TIMEOUT"
    
    # Metadata
    "--bt-save-metadata=true"
    "--bt-load-saved-metadata=true"
    "--bt-metadata-only=false"
    "--bt-force-encryption=false"
    
    # Output
    "-d" "$OUTPUT_DIR"
    "--summary-interval=10"
    "--console-log-level=notice"
)

# Aggiungi limiti bandwidth se specificati
if [ ! -z "$MAX_DOWNLOAD_LIMIT" ]; then
    ARIA2C_PARAMS+=("--max-overall-download-limit=$MAX_DOWNLOAD_LIMIT")
fi
if [ ! -z "$MAX_UPLOAD_LIMIT" ]; then
    ARIA2C_PARAMS+=("--max-overall-upload-limit=$MAX_UPLOAD_LIMIT")
fi

# Determina tipo di input
if [[ "$TORRENT_INPUT" == magnet:* ]]; then
    INPUT_TYPE="Magnet Link"
elif [[ "$TORRENT_INPUT" == *.torrent ]]; then
    INPUT_TYPE="File Torrent"
    if [ ! -f "$TORRENT_INPUT" ]; then
        echo -e "${RED}Errore: File '$TORRENT_INPUT' non trovato${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Avviso: Input non riconosciuto, provo comunque...${NC}"
    INPUT_TYPE="Sconosciuto"
fi

# Avvia download
aria2c "${ARIA2C_PARAMS[@]}" "$TORRENT_INPUT"
