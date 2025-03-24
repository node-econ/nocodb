.PHONY: all install deps start clean

# Default target
all: install deps

# Install system dependencies
install:
	@echo "Installing system dependencies..."
	sudo apt-get update
	sudo apt-get install -y curl build-essential python3
	# Install Node.js 20.x
	curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
	sudo apt-get install -y nodejs
	# Install pnpm
	sudo npm install -g pnpm cross-env

# Install project dependencies
deps:
	@echo "Installing project dependencies..."
	pnpm install
	pnpm run bootstrap

# Start the application
start:
	@echo "Starting NocoDB..."
	# Start backend in background
	NODE_ENV=development NC_DISABLE_TELE=true NC_DB=sqlite://nocodb.db pnpm run start:backend & \
	# Wait for backend to start
	sleep 10 && \
	# Start frontend and automatically answer no to telemetry
	echo "no" | pnpm run start:frontend

# Clean installation
clean:
	@echo "Cleaning up..."
	rm -rf node_modules
	rm -rf packages/*/node_modules
	rm -f nocodb.db

# Help target
help:
	@echo "Available targets:"
	@echo "  make          : Install everything"
	@echo "  make install  : Install system dependencies"
	@echo "  make deps     : Install project dependencies"
	@echo "  make start    : Start the application"
	@echo "  make clean    : Clean up installation"
	@echo "  make help     : Show this help message"

# Environment variables
export NODE_ENV=development
export NC_DB=sqlite://nocodb.db
export NC_DISABLE_TELE=true 