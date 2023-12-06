#!/bin/bash

# Verificación de las variables de entorno
if [ -f .envlocal ]; then
    source .envlocal
else
    echo "Error: Don't found .env file or not exists." >&2
    exit 1
fi

DATE_FORMAT=$(date +"%Y%m%d_%H%M%S")

# Obtén las credenciales de KMS
DB_USER=$(aws kms decrypt --key-id $KMS_KEY_ID --ciphertext-blob fileb://<(echo "$ACALSA_ENC_DB_USER" | base64 -d) --output text --query Plaintext | base64 -d)
DB_PASSWORD=$(aws kms decrypt --key-id $KMS_KEY_ID --ciphertext-blob fileb://<(echo "$ACALSA_ENC_DB_PASSWORD" | base64 -d) --output text --query Plaintext | base64 -d)
DB_INSTANCE=$(aws kms decrypt --key-id $KMS_KEY_ID --ciphertext-blob fileb://<(echo "$ACALSA_ENC_DB_INSTANCE" | base64 -d) --output text --query Plaintext | base64 -d)
DB_INSTANCE_IDENTIFIER="instance-$DATE_FORMAT"

# Error codes
ERROR_BACKUP=1
ERROR_EMPTY_BACKUP=2
ERROR_CREATE_TEST_DB=3
ERROR_RESTORE_BACKUP=4
ERROR_DB_COMPARISON=5
SUCCESSFULL_CLONE=200

# Verificación de las variables de entorno para las credenciales
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: Las variables de entorno DB_USER y DB_PASSWORD deben estar configuradas." >&2
    exit 1
fi

BACKUP_FILE="$(pwd)/$ACALSA_BACKUP_DIRECTORY/$ACALSA_DB_NAME-$DATE_FORMAT.sql"
TEST_DB_NAME="test_acalsa_db"
TEST_BACKUP_FILE="$(pwd)/$ACALSA_BACKUP_DIRECTORY/$TEST_DB_NAME-$DATE_FORMAT.sql"

# Función para mostrar mensajes de error y salir con un código de error
error_exit() {
    echo "Error: $1" >&2
    exit $2
}

# Comando mysqldump para respaldo
mysqldump --no-tablespaces -u $DB_USER -p$DB_PASSWORD -h $DB_INSTANCE $ACALSA_DB_NAME | gzip > "$BACKUP_FILE.gz" || error_exit $ERROR_BACKUP

# Verificación del éxito del comando mysqldump
if [ $? -eq 0 ]; then
    # Verificar que el archivo de respaldo no esté vacío
    if [ -s "$BACKUP_FILE.gz" ]; then

        # 🐰 Decompress the backup file and change its name
        gunzip -c "$BACKUP_FILE.gz" > "$TEST_BACKUP_FILE"

        if [ $? -eq 0 ]; then
            mysql -u dev -pdev $TEST_DB_NAME
            # 🐿️ Restore the database
            mysql -u dev -pdev $TEST_DB_NAME < $TEST_BACKUP_FILE

            if [ $? -eq 0 ]; then
                echo $SUCCESSFULL_CLONE
            fi
        fi

    else
        error_exit $ERROR_EMPTY_BACKUP
    fi
else
    error_exit $ERROR_BACKUP
fi
