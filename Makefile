all: test

build:
	coffee --output build --compile lib/booster.coffee

test:
	./node_modules/mocha/bin/mocha --reporter spec test/booster.spec.coffee --compilers coffee:coffee-script

.PHONY: test build
