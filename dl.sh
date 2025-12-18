#!/bin/bash

# Script per download multipli con aria2c ottimizzato
# Usage: ./download.sh [FILE_LINKS] [OUTPUT_DIR]

# Configurazione parametri aria2c
CONNECTIONS=10          # Connessioni per file (-x)
MIN_SPLIT_SIZE="1M"     # Dimensione minima split (-k)
PARALLEL_DOWNLOADS=10   # Download paralleli (-j)
SPLITS=10               # Numero di split (-s)
MAX_TRIES=5             # Tentativi massimi
RETRY_WAIT=3            # Secondi tra i tentativi

# Parametri script
INPUT_FILE="${1:-links.txt}"
OUTPUT_DIR="${2:-./downloads}"

# Verifica che aria2c sia installato
if ! command -v aria2c &> /dev/null; then
    echo "Errore: aria2c non è installato"
    echo "Installa con: sudo apt install aria2  (Ubuntu/Debian)"
    echo "           o: brew install aria2      (macOS)"
    exit 1
fi

# Verifica che il file di input esista
if [ ! -f "$INPUT_FILE" ]; then
    echo "Errore: File '$INPUT_FILE' non trovato"
    echo ""
    echo "Uso: $0 [FILE_LINKS] [OUTPUT_DIR]"
    echo ""
    echo "Parametri:"
    echo "  FILE_LINKS : File con i link (default: links.txt)"
    echo "  OUTPUT_DIR : Cartella di destinazione (default: ./downloads)"
    echo ""
    echo "Esempio:"
    echo "  $0 links.txt ./downloads"
    exit 1
fi

# Crea la cartella di output se non esiste
mkdir -p "$OUTPUT_DIR"

# Conta i link
NUM_LINKS=$(wc -l < "$INPUT_FILE")

# Esegui aria2c con i parametri ottimizzati
aria2c \
    -x${CONNECTIONS} \
    -k${MIN_SPLIT_SIZE} \
    -j${PARALLEL_DOWNLOADS} \
    -s${SPLITS} \
    --max-tries=${MAX_TRIES} \
    --retry-wait=${RETRY_WAIT} \
    --connect-timeout=10 \
    --summary-interval=0 \
    --console-log-level=notice \
    -d "${OUTPUT_DIR}" \
    -i "${INPUT_FILE}"
