.PHONY: all install deps setup-db start clean

# Default target
all: install deps setup-db

# Install system dependencies
install:
	@echo "Installing system dependencies..."
	sudo apt-get update
	sudo apt-get install -y curl git postgresql postgresql-contrib
	# Install Node.js 22.x
	curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
	sudo apt-get install -y nodejs
	# Install pnpm
	sudo npm install -g pnpm
	# Install build essentials
	sudo apt-get install -y build-essential python3

# Install project dependencies
deps:
	@echo "Installing project dependencies..."
	pnpm install
	pnpm run bootstrap

# Setup PostgreSQL database
setup-db:
	@echo "Setting up PostgreSQL database..."
	sudo -u postgres psql -c "CREATE DATABASE nocodb;"
	sudo -u postgres psql -c "CREATE USER nocodb WITH ENCRYPTED PASSWORD 'nocodb';"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE nocodb TO nocodb;"

# Start the application
start:
	@echo "Starting NocoDB..."
	# Start backend in background
	pnpm run start:backend & \
	# Start frontend
	pnpm run start:frontend

# Clean installation
clean:
	@echo "Cleaning up..."
	rm -rf node_modules
	rm -rf packages/*/node_modules
	sudo -u postgres psql -c "DROP DATABASE IF EXISTS nocodb;"
	sudo -u postgres psql -c "DROP USER IF EXISTS nocodb;"

# Help target
help:
	@echo "Available targets:"
	@echo "  make          : Install everything and setup the database"
	@echo "  make install  : Install system dependencies"
	@echo "  make deps     : Install project dependencies"
	@echo "  make setup-db : Setup PostgreSQL database"
	@echo "  make start    : Start the application"
	@echo "  make clean    : Clean up installation"
	@echo "  make help     : Show this help message"

# Environment variables
export NODE_ENV=development
export NC_DB=pg://nocodb:nocodb@localhost:5432/nocodb
export NC_DISABLE_TELE=true 