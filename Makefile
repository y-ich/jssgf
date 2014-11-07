.SUFFIXES:	.coffee .js

jssgf.js: jssgf.jison extension.js
	cat jssgf.jison extension.js > /tmp/foo.jison
	jison /tmp/foo.jison -o $@

test: jssgf.js tests/testJssgf.js
	mocha tests

clean:
	rm jssgf.js extension.js tests/testJssgf.js

.coffee.js:
	coffee -bc $<