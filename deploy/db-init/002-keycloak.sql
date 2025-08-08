-- Initialize Keycloak role and database (runs only on first DB container init)
CREATE ROLE keycloak WITH LOGIN PASSWORD 'keycloak';
CREATE DATABASE keycloak OWNER keycloak;
