# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

# Flight Reservation Ruby on Rails

## Executing SQL Files

To execute SQL files for schema creation and data insertion, use the following commands from inside the app container:

1. Execute the schema SQL file:
   ```bash
   docker-compose exec app sh -c "mysql -h db -u root -p reservation < /app/db/1-schema.sql"
   ```

2. Execute the data SQL file:
   ```bash
   docker-compose exec app sh -c "mysql -h db -u root -p reservation < /app/db/2-data.sql"
   ```

Replace `/app/db/1-schema.sql` and `/app/db/2-data.sql` with the paths to your SQL files if they are located elsewhere.

## Building the Docker Image

To build the Docker image securely using secrets, use the following command:

```bash
docker build \
  --secret id=database_username,src=.secrets/database_username \
  --secret id=database_password,src=.secrets/database_password \
  --secret id=database_host,src=.secrets/database_host \
  -t flightreservation_ruby_on_rails .
```

This command ensures that sensitive information like database credentials is securely passed during the build process without being exposed in the final image.

## Populating Secret Files

Before building the Docker image, you need to create and populate the secret files for database credentials. These files should be stored in the `.secrets` directory.

1. Create the `.secrets` directory:
   ```bash
   mkdir .secrets
   ```

2. Populate the secret files with the required values:
   ```bash
   echo "root" > .secrets/database_username
   echo "1234" > .secrets/database_password
   echo "db" > .secrets/database_host
   ```

3. Ensure the `.secrets` directory is ignored by Git:
   - The `.secrets/` directory is already included in the `.gitignore` file to prevent it from being committed to version control.

## Handling Secrets in Production

In production environments, move sensitive secrets to AWS Secrets Manager for enhanced security.

### Steps:
1. **Store Secrets in AWS Secrets Manager**:
   - Navigate to AWS Secrets Manager in the AWS Management Console.
   - Create a new secret and add the following key-value pairs:
     ```
     database_username: root
     database_password: 1234
     ```
   - Save the secret with a name like `flightreservation/secrets`.

2. **Grant IAM Permissions**:
   - Ensure the IAM role or user associated with your application has the following permissions:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "secretsmanager:GetSecretValue"
           ],
           "Resource": "arn:aws:secretsmanager:<region>:<account-id>:secret:flightreservation/secrets"
         }
       ]
     }
     ```

3. **Set Environment Variables**:
   - In your production environment, set the following environment variables:
     - `AWS_REGION`: The AWS region where your secret is stored (e.g., `us-east-1`).
     - `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`: Credentials for accessing AWS Secrets Manager.

4. **Keep Non-Sensitive Variables in `.env`**:
   - Variables like `DATABASE_HOST` (e.g., `localhost` or `db`) can remain in `.env` or as environment variables.

5. **Fetch Secrets in the Application**:
   - The application will automatically fetch secrets from AWS Secrets Manager during runtime using the `aws_secrets.rb` initializer.

6. **Remove Local Secrets**:
   - Ensure that local secret files (e.g., `.secrets`) are not used in production to avoid redundancy and potential security risks.

In production environments, secrets should not be stored in plain text files. Instead, use a secret management tool such as:
- **AWS Secrets Manager**
- **HashiCorp Vault**
- **Azure Key Vault**
- **Google Secret Manager**

These tools provide secure storage and access to sensitive information. Update your deployment pipeline to fetch secrets dynamically from the chosen secret management tool.

## Managing Environment Variables and Secrets

### Environment Variables
- Non-sensitive environment variables (e.g., `BASE_URL`, `DATABASE_HOST`) are defined in the `.env` file.
- The `.env` file is loaded into the runtime environment in Dockerized environments using the `env_file` directive in `docker-compose.yml`.
- For non-Dockerized environments, the `.env` file can be loaded into the shell using:
  ```bash
  export $(cat .env | xargs)
  ```

### Secrets Management
Sensitive environment variables (e.g., `DATABASE_USERNAME`, `DATABASE_PASSWORD`) are managed securely. They can be stored in **either** `.secrets` for local development or AWS Secrets Manager for production, but not both.

#### Local Development
- Use the `.secrets` directory to store sensitive information.
- Example:
  ```bash
  mkdir .secrets
  echo "root" > .secrets/database_username
  echo "1234" > .secrets/database_password
  echo "db" > .secrets/database_host
  ```
- The `.secrets/` directory is ignored by Git to prevent sensitive information from being committed.

#### Production
- Use AWS Secrets Manager to securely store and manage secrets.
- Example:
  - Store secrets in AWS Secrets Manager with key-value pairs:
    ```
    database_username: prod_user
    database_password: prod_password
    ```
  - Fetch secrets dynamically in the application using the `aws-sdk-secretsmanager` gem.

### Dockerized Environment
- During the build process, `DATABASE_HOST` is overridden by `DOCKER_DATABASE_HOST` using the `args` section in `docker-compose.yml`.
- At runtime, `DATABASE_HOST` is explicitly set to `DOCKER_DATABASE_HOST` using the `environment` section in `docker-compose.yml`.

### Non-Dockerized Environment
- The `.env` file is used to define all environment variables.
- Secrets are either loaded from `.secrets` or passed directly to the container using the `-e` flag:
  ```bash
  docker run -e DATABASE_HOST=localhost -e DATABASE_USERNAME=root -e DATABASE_PASSWORD=1234 flightreservation_ruby_on_rails
  ```

### Summary
- **Non-sensitive variables**: Defined in `.env`.
- **Sensitive secrets**: Stored in `.secrets` for local development or AWS Secrets Manager for production.
- **Dockerized environments**: Use `DOCKER_DATABASE_HOST` to override `DATABASE_HOST` for consistency between build and runtime.
- **Non-Dockerized environments**: Use `.env` and `-e` flags to manage environment variables.

## Development Environment

For development, keep all environment variables in `.env` for simplicity.

Example `.env`:
```properties
DATABASE_USERNAME=root
DATABASE_PASSWORD=1234
DATABASE_HOST=localhost
BASE_URL=flightreservation-ruby-on-rails
```

This approach simplifies the setup and makes it easy to manage configurations locally. Sensitive information should only be moved to AWS Secrets Manager in production environments.
