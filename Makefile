.PHONY: docs-live docs-static

test:
	bundle exec rspec

docs-live:
	rm -rf docs/build && cd docs && bundle exec guard --no-interactions

docs-static:
	rm -rf docs/build && cd docs && bundle exec parklife build
