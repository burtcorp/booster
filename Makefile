all: test

test:
	./node_modules/mocha/bin/mocha --reporter spec test/booster.spec.coffee --compilers coffee:coffee-script

.PHONY: test
