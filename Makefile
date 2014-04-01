all: prepare test

prepare:
	npm install

test:
	PATH="$(PATH):./node_modules/.bin/" mocha --compilers coffee:coffee-script/register

develop: prepare
	fswatch "./src/:./test/" "make test"

.PHONY: all prepare test develop
