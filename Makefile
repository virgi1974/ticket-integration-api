.PHONY: build run stop restart logs test setup clean install-gems

# Default target
all: build run

# Build the Docker images
build:
	docker-compose build

# Start the application
run:
	docker-compose up -d
	@echo "Application is running at http://localhost:3000"
	@echo "API endpoint: http://localhost:3000/api/v1/events?starts_at=YYYY-MM-DDT00:00:00Z&ends_at=YYYY-MM-DDT23:59:59Z"

# Stop the application
stop:
	docker-compose down

# Restart the application
restart: stop run

# View logs
logs:
	docker-compose logs -f

# Install gems
install-gems:
	docker-compose run --rm app bundle install

# Run tests
test:
	docker-compose run --rm app bundle exec rspec

# Setup the database
setup:
	docker-compose run --rm app bundle install
	docker-compose run --rm app rails db:create db:migrate db:seed

# Clean up volumes and unused images
clean:
	docker-compose down -v
	# docker system prune -f

# Help command
help:
	@echo "Available commands:"
	@echo "  make build    - Build Docker images"
	@echo "  make run      - Start the application"
	@echo "  make stop     - Stop the application"
	@echo "  make restart  - Restart the application"
	@echo "  make logs     - View application logs"
	@echo "  make install-gems - Install gems"
	@echo "  make test     - Run tests"
	@echo "  make setup    - Set up the database"
	@echo "  make clean    - Clean up Docker resources"
