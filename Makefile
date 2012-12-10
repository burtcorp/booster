all: test

test:
	./node_modules/mocha/bin/mocha test/booster.spec.coffee --compilers coffee:coffee-script

.PHONY: test
