# JSSGF
JSSGF is a parser for Smart Game Format(SGF) in JavaScript generated by Jison with faster regular expression parser in simple cases.

##Usage
###on browsers
```html
<script src="jssgf.js"></script>
<script type="text/javascript">
console.log(jssgf.fastParse('(;C[example])'));
</script>
```
###on Node.js
```sh
npm install jssgf
```

```javascript
var jssgf = require('jssgf');
console.log(jssgf.fastParse('(;C[example])'));
```

##Note
### ValueType
No support of various ValueTypes and Compose. All PropValues are as Text.

### Compilation
When you compile jssgf.jison, you will encounter the message
```
Conflict in grammar: multiple actions possible when lookahead token is [ in state 16
- reduce by rule: propvalues ->
- shift token (then go to state 23)
Conflict in grammar: multiple actions possible when lookahead token is WHITE_SPACE in state 17
- reduce by rule: propident -> MAYBE_PROPIDENT
- shift token (then go to state 24)
...
```
But jssgf.js should have been generated. Jison resolves the conflicts with higher priority to a shift.

##License
MIT
