.PHONY: docs-live docs-static

docs-live:
	rm -rf docs/build && cd docs && bundle exec guard --no-interactions

docs-static:
	rm -rf docs/build && cd docs && bundle exec parklife build
