# Script de Backup de Base de Datos

Este script en Bash permite automatizar la generación, visualización, limpieza y consulta de respaldos (.sql.gz) de una base de datos MariaDB.
Funcionalidades
- Generar backups comprimidos de una base de datos.
- Listar los respaldos existentes.
- Mostrar el contenido del respaldo más reciente.
- Eliminar respaldos antiguos (más de 7 días).
- Mostrar un mensaje de ayuda con las opciones disponibles.


## Uso
- Implementar la variable que almacena la contraseña de la base de datos, ingresando en la terminal: `export DB_PASSWORD="passwd"`
- Dar permisos de ejecución `sudo chmod +x ./db_backup.sh`
- Recomiendo implementar un alias para el uso de este script, ingresando a ~/.bashrc :
`sudo nano ~/.bashrc`
- Al final del archivo ingresar:
`alias nombre_alias = 'ruta/al/programa/db_backup.sh'`
- Luego implementar los cambios ejecutando:
`source  ~/.bashrc`

Para ejecutar el script:
`./db_backup.sh [opciones]`

## Opciones disponibles:
- Realiza un backup de la base de datos usando la contraseña proporcionada.
    - `-b` o `--backup <contraseña>`
- Lista los backups existentes.
    - `-l` o `--list`
- Elimina los respaldos con más de 7 días de antigüedad.
    - `-c` o `--clear`
- Muestra el contenido SQL del último respaldo disponible.
    - `-s` o `--show`
- Muestra este mensaje de ayuda.
    - `-h` o `--help`: 


## Consideraciones
- Los backups se nombran automáticamente con fecha y hora para facilitar su organización.
- Los respaldos con más de 7 días son eliminados automáticamente al usar la opción --clear.
- El programa puede ser sincronizado utilizando crontab.

## Requisitos
- Bash
- mariadb-dump
- Herramientas estándar de Unix como gzip, zless, awk, find, etc.
- crontab
