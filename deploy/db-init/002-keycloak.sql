-- Initialize Keycloak role and database (runs only on first DB container init)
-- Use idempotent approach to avoid errors if role/database already exists

DO $$
BEGIN
  -- Create keycloak role if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'keycloak') THEN
    CREATE ROLE keycloak WITH LOGIN PASSWORD 'keycloak';
    RAISE NOTICE 'Created role: keycloak';
  ELSE
    -- Update password if role exists
    ALTER ROLE keycloak WITH LOGIN PASSWORD 'keycloak';
    RAISE NOTICE 'Updated password for existing role: keycloak';
  END IF;
END$$;

-- Create database (separate transaction to avoid issues)
SELECT 'CREATE DATABASE keycloak OWNER keycloak'
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'keycloak')\gexec
