/*
    description: Parses SGF string and generates corresponding object.
    author: ICHIKAWA, Yuji
    copyright: 2014 (C) ICHIKAWA, Yuji (New 3 Rs)
    note1: This parser doesn't interpret PropValue, returns all as text.
*/

%{
/* prologue */
var strict = false; // if true, throw exception when overlapping a property in a node.
function addGameTrees(s, gts){
	var n = s;
	while (n._children.length == 1)
		n = n._children[0];
	n._children = gts;
	return s;
}

function decodeValue(str) {
  var decoded, e, ss;
  ss = str.split('\\\\');
  decoded = (function() {
    var i, len, results;
    results = [];
    for (i = 0, len = ss.length; i < len; i++) {
      e = ss[i];
      results.push(e.replace(/\\(\r\n|\n\r|\r|\n)/g, '').replace(/\\(\S)/g, '$1').replace(/(?!\r\n|\n\r|\r|\n)\s/g, ' '));
    }
    return results;
  })();
  return decoded.join('\\');
};
%}

/* lexical grammar */
%lex

%x CVALUETYPE

%%
\s+                         /* skip whitespace */
"("                         return '(';
")"                         return ')';
";"                         return ';';
[A-Z]+                      return 'PROPIDENT';
"["                         this.begin('CVALUETYPE');
<CVALUETYPE>"]"             this.popState();
<CVALUETYPE>(\\\]|[^\]])*   return 'CVALUETYPE';
<<EOF>>                     return 'EOF';

/lex

%% /* language grammar */

output
	: collection EOF
        { return $1; }
	;

collection
	: gametree
		{ $$ = [$1]; }
	| collection gametree
		{ $1.push($2); $$ = $1; }
    ;

gametree
    : '(' sequence ')'
		{ $$ = $2; }
    | '(' sequence gametrees ')'
        { $$ = addGameTrees($2, $3); }
    ;

gametrees
	: gametree
		{ $$ = [$1]; }
	| gametrees gametree
		{ $1.push($2); $$ = $1; }
	;

sequence
	: node
		{ $$ = $1; }
	| node sequence
		{ $1._children.push($2); $$ = $1; }
	;

node
	: ';'
		{ $$ = {_children: []}; }
	| node property
		{
            if (typeof $1[$2[0]] !== 'undefined') {
                if (strict) {
                    throw new Error('double properties');
                }
            } else {
                $1[$2[0]] = $2[1];
                $$ = $1;
            }
        }
	;

property
    : PROPIDENT propvalues
        { $$ = [$1, $2]; }
    ;

propvalues
    : propvalue
		{ $$ = $1; }
	| propvalues propvalue
		{ var a; if ($1 instanceof Array) a = $1; else a = [$1]; $$ = a.concat($2); }
	;

propvalue
    :  /* empty */
        { $$ = ''; }
	| CVALUETYPE
		{ $$ = decodeValue($1); }
	;

%%
