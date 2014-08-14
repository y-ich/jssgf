.SUFFIXES:	.coffee .js

jssgf.js: jssgf.jison stringify.js
	cat jssgf.jison stringify.js > /tmp/foo.jison
	jison /tmp/foo.jison -o $@

test: jssgf.js tests/testJssgf.js
	mocha tests

clean:
	rm jssgf.js stringify.js tests/testJssgf.js

.coffee.js:
	coffee -bc $<