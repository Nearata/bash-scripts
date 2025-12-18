#!/bin/bash

# Script per generare link sostituendo il wildcard * con numeri sequenziali
# Usage: ./script.sh "URL_CON_*" MAX [PADDING]

# Verifica argomenti
if [ $# -lt 2 ]; then
    echo "Uso: $0 \"URL_CON_*\" MAX [PADDING]"
    echo ""
    echo "Parametri:"
    echo "  URL_CON_*  : URL con asterisco (*) da sostituire"
    echo "  MAX        : Numero massimo della sequenza"
    echo "  PADDING    : (Opzionale) Numero di zeri per il padding (es: 2 per 01, 3 per 001)"
    echo ""
    echo "Esempi:"
    echo "  $0 \"https://example.com/file_*.mp4\" 25 2"
    echo "  $0 \"https://example.com/file_*.mp4\" 100 3"
    echo "  $0 \"https://example.com/file_*.mp4\" 10"
    exit 1
fi

URL_TEMPLATE="$1"
MAX="$2"
PADDING="${3:-0}"  # Default: nessun padding
OUTPUT_FILE="links.txt"

# Verifica che l'URL contenga un asterisco
if [[ ! "$URL_TEMPLATE" == *"*"* ]]; then
    echo "Errore: L'URL deve contenere un asterisco (*)"
    exit 1
fi

# Verifica che MAX sia un numero
if ! [[ "$MAX" =~ ^[0-9]+$ ]]; then
    echo "Errore: MAX deve essere un numero intero"
    exit 1
fi

# Pulisci il file di output se esiste
> "$OUTPUT_FILE"

echo "Generazione link da 1 a $MAX..."
if [ "$PADDING" -gt 0 ]; then
    echo "Padding: $PADDING cifre"
fi

# Genera i link
for ((i=1; i<=MAX; i++)); do
    if [ "$PADDING" -gt 0 ]; then
        # Con padding (es: 01, 001)
        NUM=$(printf "%0${PADDING}d" $i)
    else
        # Senza padding (es: 1, 2, 3)
        NUM=$i
    fi
    
    # Sostituisci * con il numero
    LINK="${URL_TEMPLATE//\*/$NUM}"
    echo "$LINK" >> "$OUTPUT_FILE"
done

echo "Completato! $MAX link generati in '$OUTPUT_FILE'"
