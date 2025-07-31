#!/bin/bash

OPTS=$(getopt -o hlcb:s --long help,list,clear,backup:,show -n 'test.sh' -- "$@")

PASSWD=""
TIMESTAMP_DATE=$(date +"%d-%m-%Y")
TIMESTAMP_HOUR=$(date +"%H-%M-%S")
FULLDIR="/home/lab/Scripts/database/testBackup"
FILENAME="backup_"${TIMESTAMP_HOUR}_${TIMESTAMP_DATE}".sql"
RETENTION_DAYS=7

if [ $? -ne 0 ]; then
  echo "Failed to parse options" >&2
  exit 1
fi

eval set -- "$OPTS"

HELP=false
LIST=false
CLEAR=false
BACKUP=false
SHOW=false

help(){
        echo "Como usar este Script"
        echo
        echo    "Este script está pensado para automatizar la generación y mantención de copias de seguridad de la base de datos"
        echo    "También es útil para consultar una lista de Backups existentes en el sistema"
        echo
        echo "  Comando                         Función"
        echo
        echo "  -b, --backup                    Ejecuta la función backup Database"
        echo "  -r, --restore                   Ejecuta la función restore Database"
        echo "  -l, --list                      Lista  los backups existentes"
        echo "  -c, --clear                     Limpia los backups antiguos"
        echo "  -s,--show                       Muestra el codigo SQL del último backup"
        echo "  -h, help                        Muestra este mensaje de ayuda :)"
        echo
}

fullBackup() {
local PSW="$1"

if [ -z "$PSW" ]; then
        echo "[ERROR] No se proporcionó contraseña para el backup."
        exit 1
fi

mariadb-dump --user=username --password="$PSW" --lock-tables --extended-insert --databases database_name > $FULLDIR/$FILENAME

if [ $? -eq 0 ]; then
        echo "[OK] - ["${TIMESTAMP_HOUR}" - "${TIMESTAMP_DATE}"] Backup generado"
        gzip  $FULLDIR/$FILENAME
        echo  "Comprimido y guardado en: "${FULLDIR}"/"${FILENAME}".gz"
else
        echo "[ERROR] - ["${TIMESTAMP_HOUR}" - "${TIMESTAMP_DATE}"] Fallo al realizar Backup"
        rm $FULLDIR/$FILENAME
        exit 1

fi
}

list(){
        echo
        echo "Listado de Backups de los últimos 7 días"
        echo
        echo "FECHA             NOMBRE                                          TAMAÑO"
        ls -lh "$FULLDIR" | grep -v '^total' | awk '{print $7,$6,$8,"   ", $9," ", $5}'
        echo
}

clearBackups(){
    echo "[INFO] Eliminando respaldos con más de $RETENTION_DAYS días en $FULLDIR..."
    find "$FULLDIR" -maxdepth 1 -type f -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;
    echo "[OK] Limpieza completada."
}
showLast(){
        local last_file
        last_file=$(ls -t "$FULLDIR"/*.gz 2>/dev/null | head -n 1)

        if [ -n "$last_file" ]; then
                zless "$last_file"
        else
                echo "No hay archivos en $FULLDIR"
        fi
}
while true; do
        case "$1" in
        -h | --help)
                HELP=true
                shift
                ;;
        -l | --list)
                LIST=true
                shift
                ;;
        -c | --clear)
                CLEAR=true
                shift
                ;;
        -b | --backup)
                BACKUP=true
                PASSWD="$2"
                shift 2
                ;;
        -s | --show)
                SHOW=true
                shift
                ;;
        --)
                shift
                break
                ;;
        *)
                echo "Error Interno!"
                exit 1
                ;;
        esac
done

if [ "$HELP" = true ]; then
        help
        exit 0
fi

if [ "$LIST" = true ]; then
        list
        exit 0
fi

if [ "$CLEAR" = true ]; then
        clearBackups
        exit 0
fi

if [ "$BACKUP" = true ]; then
        fullBackup "$PASSWD"
        exit 0
fi

if [ "$SHOW" = true ]; then
        showLast
        exit 0
fi
