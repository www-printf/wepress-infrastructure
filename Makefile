.PHONY: setup deploy backup logs restart

setup:
	@echo "Setting up infrastructure..."
	bash scripts/setup/setup-vm.sh

deploy:
	@echo "Deploying services..."
	docker-compose up -d

backup:
	@echo "Creating backup..."
	bash scripts/backup/backup-databases.sh

logs:
	docker-compose logs -f

restart:
	docker-compose restart

clean:
	docker-compose down -v