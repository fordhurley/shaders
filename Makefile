all: build/.touch

package-lock.json: package.json
	npm install

build/.touch: $(wildcard gallery/* lib/* shaders/* textures/*) webpack.config.js package-lock.json
	./node_modules/.bin/webpack --config webpack.config.js
	touch $@ # so that make can tell when this is needed

serve:
	DEBUG=true ./node_modules/.bin/webpack-dev-server --config webpack.config.js --open

clean:
	rm -rvf build

.PHONY: all serve clean
