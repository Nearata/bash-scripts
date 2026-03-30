#!/bin/bash

# Script per generare link sostituendo il wildcard * con numeri sequenziali
# Usage: ./script.sh "URL_CON_*" START END [PADDING]

# Verifica argomenti
if [ $# -lt 3 ]; then
    echo "Uso: $0 \"URL_CON_*\" START END [PADDING]"
    echo ""
    echo "Parametri:"
    echo "  URL_CON_* : URL con asterisco (*) da sostituire"
    echo "  START      : Numero iniziale della sequenza"
    echo "  END        : Numero finale della sequenza"
    echo "  PADDING    : (Opzionale) Numero di zeri per il padding (es: 2 per 01, 3 per 001)"
    echo ""
    echo "Esempi:"
    echo "  $0 \"https://example.com/file_*.mp4\" 4 8 2"
    echo "  $0 \"https://example.com/file_*.mp4\" 1 100 3"
    echo "  $0 \"https://example.com/file_*.mp4\" 10 20"
    exit 1
fi

URL_TEMPLATE="$1"
START="$2"
END="$3"
PADDING="${4:-0}"  # Default: nessun padding
OUTPUT_FILE="links.txt"

# Verifica che l'URL contenga un asterisco
if [[ ! "$URL_TEMPLATE" == *"*"* ]]; then
    echo "Errore: L'URL deve contenere un asterisco (*)"
    exit 1
fi

# Verifica che START e END siano numeri
if ! [[ "$START" =~ ^[0-9]+$ ]] || ! [[ "$END" =~ ^[0-9]+$ ]]; then
    echo "Errore: START e END devono essere numeri interi"
    exit 1
fi

# Pulisci il file di output se esiste
> "$OUTPUT_FILE"

echo "Generazione link da $START a $END..."
if [ "$PADDING" -gt 0 ]; then
    echo "Padding: $PADDING cifre"
fi

# Genera i link
for ((i=START; i<=END; i++)); do
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

echo "Completato! $((END - START + 1)) link generati in '$OUTPUT_FILE'"