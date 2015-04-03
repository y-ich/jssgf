.SUFFIXES:	.coffee .js

jssgf.js: jssgf.jison extension.js
	cat jssgf.jison extension.js > /tmp/foo.jison
	jison /tmp/foo.jison -m js -o $@

tests/jssgf.js: jssgf.jison extension.js
	cat jssgf.jison extension.js > /tmp/foo.jison
	jison /tmp/foo.jison -o $@

test: tests/jssgf.js tests/testJssgf.js
	mocha tests

clean:
	rm jssgf.js extension.js tests/jssgf.js tests/testJssgf.js

.coffee.js:
	coffee -bc $<

meteor-package/jssgf.js: jssgf.js
	sed -e 's/var jssgf/jssgf/' $< > $@
