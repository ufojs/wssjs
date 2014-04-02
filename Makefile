UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	CHROME := /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome
endif

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
	PATH="$(PATH):./node_modules/.bin/" browserify -t coffeeify --extension=".coffee" -s ufo src/wss.coffee -o lib/wss.bundle.js
	PATH="$(PATH):./node_modules/.bin/" uglifyjs lib/wss.bundle.js -o lib/wss.bundle.min.js

develop: prepare
	fswatch "./src/:./test/" "make test"

run-chrome: prepare test compile integration-test
	$(CHROME) --load-and-launch-app=integration-test/chrome-app --user-data-dir=/tmp/testufo

clean:
	rm -rf node_modules lib

.PHONY: all prepare test compile develop clean integration-test
