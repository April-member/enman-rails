gen:
	bash script/openapi-generator-cli.sh

code-gen:
	docker compose run --rm app bundle exec rake openapi:generate_code

gen-all: gen code-gen

setup-docker: gen
	@echo "==> Running gen and setting up app (docker)"
	docker compose run --rm app bash -lc 'bundle install --gemfile /rails/Gemfile && bin/rails db:create db:migrate'

setup: setup-docker
	@echo "Setup complete (docker)"

db-create:
	docker compose run --rm app bin/rails db:create

db-migrate:
	docker compose run --rm app bin/rails db:migrate

db-setup: db-create db-migrate