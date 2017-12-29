all: build/.touch

package-lock.json: package.json
	npm install

build/.touch: $(wildcard gallery/*) $(wildcard lib/*) $(wildcard shaders/*) $(wildcard textures/*) webpack.config.js package-lock.json
	./node_modules/.bin/webpack --config webpack.config.js
	touch $@ # so that make can tell when this is needed

serve:
	./node_modules/.bin/webpack-dev-server --config webpack.config.js --open

clean:
	rm -rvf build

.PHONY: all serve clean
