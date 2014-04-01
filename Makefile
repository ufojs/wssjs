all: prepare test compile

prepare:
	npm install

test:
	PATH="$(PATH):./node_modules/.bin/" mocha --compilers coffee:coffee-script/register

compile:
	mkdir -p lib
	PATH="$(PATH):./node_modules/.bin/" browserify -t coffeeify --extension=".coffee" src/wss.coffee > lib/wss.bundle.js
	PATH="$(PATH):./node_modules/.bin/" uglifyjs lib/wss.bundle.js -o lib/wss.bundle.min.js

develop: prepare
	fswatch "./src/:./test/" "make test"

clean:
	rm -rf node_modules lib

.PHONY: all prepare test compile develop clean
