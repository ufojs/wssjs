all: prepare test compile integration-test

prepare:
	npm install

test:
	PATH="$(PATH):./node_modules/.bin/" mocha --compilers coffee:coffee-script/register

integration-test:
	cp lib/wss.bundle.js integration-test/chrome-app/
	PATH="$(PATH):node_modules/karma/bin/" karma start integration-test/karma.conf.js

compile:
	mkdir -p lib
	PATH="$(PATH):./node_modules/.bin/" browserify -t coffeeify --extension=".coffee" src/wss.coffee > lib/wss.bundle.js
	PATH="$(PATH):./node_modules/.bin/" uglifyjs lib/wss.bundle.js -o lib/wss.bundle.min.js

develop: prepare
	fswatch "./src/:./test/" "make test"

clean:
	rm -rf node_modules lib

.PHONY: all prepare test compile develop clean integration-test
