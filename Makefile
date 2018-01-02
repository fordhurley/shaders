all: build/.touch

package-lock.json: package.json
	npm install

gallery/shaders.js: gallery/generate-shaders.js
	node gallery/generate-shaders.js > gallery/shaders.js

build/.touch: $(wildcard gallery/* lib/* shaders/* textures/*) gallery/shaders.js webpack.config.js package-lock.json
	./node_modules/.bin/webpack --config webpack.config.js
	touch $@ # so that make can tell when this is needed

serve:
	./node_modules/.bin/webpack-dev-server --config webpack.config.js --open

clean:
	rm -rvf build

.PHONY: all serve clean
