# 🚀 Grupo Acalsa - DB Cloner Cosmic.

## 🪐 Overview 

This project launches a cosmic worker using Bash and the Bats-Core framework to generate a clone of an AWS RDS MySQL database. AWS Key Management Service (KMS) acts as the alien technology for securely managing database credentials. Data from branches across the cosmos is stored in an AWS RDS database. Docker serves as the spacecraft for containerized management, launching containers every 5 minutes. Grafana acts as the observatory for monitoring the cosmic workers, providing insights into their performance.

## 🛰️ Components 

### 🦇 Bats-Core { Framework }

[Bats-Core](https://github.com/bats-core/bats-core) is a Bash Automated Testing System used to write and execute unit tests for Bash scripts. These tests ensure the reliability and correctness of the Bash scripts, including the worker responsible for cloning the AWS RDS MySQL database.

### 🌌 Bash 

The Bash scripting language is utilized to create a worker that generates clones of AWS RDS MySQL databases. The worker script leverages the AWS KMS service to securely read and manage the credentials required for accessing the databases.

### ☁️ AWS RDS Mysql

[Amazon RDS](https://aws.amazon.com/rds/) is employed as the relational database service to store data from various branches. It provides a scalable, secure, and fully managed database solution.

### 🔐 AWS KMS 

[Amazon Key Management Service (KMS)](https://aws.amazon.com/kms/) is used for secure key management, enabling the secure reading of database credentials in the worker script.

### 🚢 Docker 

[Docker](https://www.docker.com/) is used to containerize the worker script. Containers are launched every 5 minutes to perform the database cloning operation, providing an isolated and reproducible environment.

### 📡 Grafana 

[Grafana](https://grafana.com/) is employed for observability and monitoring of the worker instances. It provides a visual representation of the worker's performance and allows for easy identification of any issues or bottlenecks.

## 🚀 Usage 

To run the worker and execute the database cloning operation, follow these steps:

1. Configure AWS credentials: Ensure that AWS credentials are set up with the necessary permissions, and the AWS CLI is properly configured.

2. Configure AWS KMS: Set up AWS KMS and obtain the Key ID for secure management of database credentials.

3. Set environment variables: Create a `.env` file with the required environment variables, including AWS credentials, KMS Key ID, and any other necessary configurations.

   ```bash
   # .env

   export AWS_ACCESS_KEY_ID="your_access_key_id"
   export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
   export AWS_DEFAULT_REGION="your_region"
   export KMS_KEY_ID="your_kms_key_id"
   ```

4. Build and run Docker container: Execute the Docker commands to build the container and run the worker script.

   ```bash
   docker build -t database-worker .
   docker run --rm -d --name database-worker database-worker
   ```

5. Access Grafana dashboard: Open Grafana to observe and monitor the worker instances. The Grafana dashboard provides insights into the worker's performance.

## 🛸 Error Codes

REF_BC_001
   ERROR_BACKUP
   Error al realizar el respaldo.
   Error en el respaldo. Verifica las credenciales y la base de datos.
REF_BC_002
   ERROR_EMPTY_BACKUP
   ¡Error! El archivo de respaldo está vacío. Prueba unitaria fallida.
REF_BC_003
   ERROR_CREATE_TEST_DB
   Error al crear la base de datos de prueba.
REF_BC_004
   ERROR_RESTORE_BACKUP
   Error al restaurar el respaldo en la base de datos de prueba.
REF_BC_005
   ERROR_DB_COMPARISON
   ¡Error! Las bases de datos son diferentes. Prueba unitaria fallida.

## 🌌 Contributions 

Contributions to this cosmic project are welcome. If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## 🚀 License 

This cosmic project is licensed under the [MIT License](LICENSE). 
