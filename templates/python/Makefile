#### Python Environment ####
.PHONY: install
install: 
	pip install -r ./requirements-build.txt
	pip install -r ./requirements.txt
	pip install -r ./requirements-dev.txt

.PHONY: uninstall
uninstall:
	@bash -c "pip uninstall -y -r <(pip freeze)"

#### Testing ####
TEST_COMMANDS = \
	--cov=dockmaster \
	--cov-config=setup.cfg \
	--cov-report html \
	--cov-report term

.PHONY: test
test: test.clean test.unit 
	rm -rf htmlcov/
	rm -f .coverage

.PHONY: test.clean
test.clean:
	rm -rf htmlcov/
	rm -f .coverage

.PHONY: test.unit
test.unit: 
	pytest -rfEP $(TEST_COMMANDS) tests

#### Code Style ####
FORMAT_DIRS = src/ test/
LINT_DIRS = src/ test/

.PHONY: pre-commit
pre-commit: format lint test

.PHONY: lint
lint:
	ruff check $(LINT_DIRS)

.PHONY: format
format:
	ruff format $(FORMAT_DIRS)


#### Build ####
VERSION=`grep version setup.cfg | awk '{print $$3}'`
TAGNAME=v$(VERSION)

.PHONY: publish.tag
publish.tag:
	@echo "---Tagging commit hash $(TAGNAME) "
	git tag -a $(TAGNAME) -m"Release $(TAGNAME)"
	git push origin $(TAGNAME)
	@echo "---Pushed tag as version=$(VERSION)"


#### Development ####
.PHONY: jupyter
jupyter: 
	@jupyter lab --autoreload --no-browser

.PHONY: fastapi.dev
fastapi.dev:
	@echo "Starting FastAPI server for development..."
	@fastapi dev src/dockmaster/main.py --reload