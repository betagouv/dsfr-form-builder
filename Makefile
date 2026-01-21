.PHONY: docs-live docs-static

docs-live:
	cd docs && bundle exec guard --no-interactions

docs-static:
	cd docs && bundle exec parklife build
