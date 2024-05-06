vendor/autoload.php: composer.lock Makefile
	composer install --optimize-autoloader
	@touch $@

composer.lock: composer.json
	composer update
