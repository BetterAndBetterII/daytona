-- Optional Postgres initialization script
-- This file is executed automatically on first container startup
-- Place your schema/bootstrap SQL here. Safe to leave empty.

-- Example: create extension and an app-specific schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.schemata WHERE schema_name = 'daytona'
  ) THEN
    EXECUTE 'CREATE SCHEMA daytona AUTHORIZATION ' || current_user || ';';
  END IF;
END$$;

-- Example table (commented)
-- CREATE TABLE IF NOT EXISTS daytona.example(
--   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--   created_at TIMESTAMPTZ NOT NULL DEFAULT now()
-- );
