.SUFFIXES:	.coffee .js
jssgf.js: jssgf.jison
	jison $<

test: jssgf.js tests/testJssgf.js
	mocha tests

.coffee.js:
	coffee -c $<