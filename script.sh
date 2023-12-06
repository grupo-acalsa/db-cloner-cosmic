#!/bin/bash

# Verificación de las variables de entorno
if [ -f .envlocal ]; then
    source .envlocal
else
    echo "Error: Don't found .env file or not exists." >&2
    exit 1
fi

# Obtén las credenciales de KMS
DB_USER=$(aws kms decrypt --key-id $KMS_KEY_ID --ciphertext-blob fileb://<(echo "$ENCRYPTED_DB_USER" | base64 -d) --output text --query Plaintext | base64 -d)
DB_PASSWORD=$(aws kms decrypt --key-id $KMS_KEY_ID --ciphertext-blob fileb://<(echo "$ENCRYPTED_DB_PASSWORD" | base64 -d) --output text --query Plaintext | base64 -d)
DB_INSTANCE=$("$ACALSA_DB_INSTANCE" | base64 -d)
DB_NAME=$("$ACALSA_DB_NAME" | base64 -d)
BACKUP_DIR=$("$BACKUP_DIRECTORY" | base64 -d)

# Verificación de las variables de entorno para las credenciales
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: Las variables de entorno DB_USER y DB_PASSWORD deben estar configuradas." >&2
    exit 1
fi

DATE_FORMAT=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$DATE_FORMAT.sql"
TEST_DB_NAME="test_$DB_NAME"

# Códigos de error
ERROR_BACKUP=1
ERROR_EMPTY_BACKUP=2
ERROR_CREATE_TEST_DB=3
ERROR_RESTORE_BACKUP=4
ERROR_DB_COMPARISON=5

# Función para mostrar mensajes de error y salir con un código de error
error_exit() {
    echo "Error: $1" >&2
    exit $2
}

# Comando mysqldump para respaldo
mysqldump -h RDS_ENDPOINT -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE || error_exit $ERROR_BACKUP

# Verificación del éxito del comando mysqldump
if [ $? -eq 0 ]; then
    # Verificar que el archivo de respaldo no esté vacío
    if [ -s "$BACKUP_FILE" ]; then
        # Crear una base de datos de prueba y restaurar el respaldo
        mysql -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $TEST_DB_NAME" || error_exit $ERROR_CREATE_TEST_DB
        mysql -u $DB_USER -p$DB_PASSWORD $TEST_DB_NAME < $BACKUP_FILE || error_exit $ERROR_RESTORE_BACKUP

        # Comparar las bases de datos original y restaurada
        mysqldump -h RDS_ENDPOINT -u $DB_USER -p$DB_PASSWORD $DB_NAME > /tmp/original_db.sql  
        mysqldump -u $DB_USER -p$DB_PASSWORD $TEST_DB_NAME > /tmp/restored_db.sql

        # Comparar archivos
        if diff /tmp/original_db.sql /tmp/restored_db.sql >/dev/null; then
            echo "Las bases de datos son idénticas. Prueba unitaria exitosa."
        else
            error_exit $ERROR_DB_COMPARISON
        fi
    else
        error_exit $ERROR_EMPTY_BACKUP
    fi
else
    error_exit $ERROR_BACKUP
fi
