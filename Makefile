.PHONY: all install deps setup-db start clean

# Default target
all: install deps setup-db

# Install system dependencies
install:
	@echo "Installing system dependencies..."
	sudo apt-get update
	sudo apt-get install -y curl build-essential python3 mysql-server
	# Install Node.js 20.x
	curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
	sudo apt-get install -y nodejs
	# Install pnpm
	sudo npm install -g pnpm cross-env
	# Start MySQL service
	sudo systemctl start mysql

# Install project dependencies
deps:
	@echo "Installing project dependencies..."
	pnpm install
	pnpm run bootstrap

# Setup MySQL database
setup-db:
	@echo "Setting up MySQL database..."
	sudo mysql -e "CREATE DATABASE IF NOT EXISTS nocodb;"
	sudo mysql -e "CREATE USER IF NOT EXISTS 'nocodb'@'localhost' IDENTIFIED BY 'nocodb';"
	sudo mysql -e "GRANT ALL PRIVILEGES ON nocodb.* TO 'nocodb'@'localhost';"
	sudo mysql -e "FLUSH PRIVILEGES;"

# Start the application
start:
	@echo "Starting NocoDB..."
	# Start backend in background
	NODE_ENV=development NC_DISABLE_TELE=true NC_DB=mysql2://nocodb:nocodb@localhost:3306/nocodb pnpm run start:backend & \
	# Wait for backend to start
	sleep 10 && \
	# Start frontend and automatically answer no to telemetry
	echo "no" | pnpm run start:frontend

# Clean installation
clean:
	@echo "Cleaning up..."
	rm -rf node_modules
	rm -rf packages/*/node_modules
	sudo mysql -e "DROP DATABASE IF EXISTS nocodb;"
	sudo mysql -e "DROP USER IF EXISTS 'nocodb'@'localhost';"

# Help target
help:
	@echo "Available targets:"
	@echo "  make          : Install everything and setup the database"
	@echo "  make install  : Install system dependencies"
	@echo "  make deps     : Install project dependencies"
	@echo "  make setup-db : Setup MySQL database"
	@echo "  make start    : Start the application"
	@echo "  make clean    : Clean up installation"
	@echo "  make help     : Show this help message"

# Environment variables
export NODE_ENV=development
export NC_DB=mysql2://nocodb:nocodb@localhost:3306/nocodb
export NC_DISABLE_TELE=true 