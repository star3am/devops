SHELL := /bin/bash
TIMESTAMP := $(shell date +%Y-%m-%d_%H-%M-%S)

bootstrap:
	echo "Running bootstrap.."
	echo "Riaan Nolan - https://www.linkedin.com/in/riaannolan/"

clear-cache:
	clear-cache-file
	php artisan cache:clear

clear-cache-file:
	php artisan cache:clear file

clear-view:
	php artisan view:clear

clear-compiled:
	php artisan clear-compiled

clear-config:
	php artisan config:clear

clear-route:
	php artisan route:clear

composer:
	composer install --prefer-dist --no-interaction --no-progress --no-suggest
	make composer-dump-autoload
	rm -rf ./bootstrap/cache/*.php
