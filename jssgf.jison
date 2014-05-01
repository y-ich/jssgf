/* description: Parses SGF string and generates corresponding object. */

%{
/* prologue */

function addGameTrees(s, gts){
	var n = s;
	while (n._children.length == 1)
		n = n._children[0];
	n._children = gts;
	return n;
}
%}

/* lexical grammar */
%lex

%%
\s*\(                 return '(';
")"                   return ')';
\s*\;                 return ';';
"["                   return '[';
\]\s*                 return ']';
":"                   return ':';
\\[\r\n]+             return 'SOFT_LINEBREAK';
\\.                   return 'ESCAPECHAR';
[^();\[\]]            return 'CHAR';
<<EOF>>               return 'EOF';

/lex

%% /* language grammar */

output
	: collection EOF
        { return $1; }
	;

collection
	: gametree
		{ $$ = [$1]; }
	| gametree collection
		{ $2.unshift($1); $$ = $2; }
    ;

gametree
    : '(' sequence ')'
		{ $$ = $2; }
	| WHITESPACE '(' sequence ')'
		{ $$ = $3; }
    | '(' sequence gametrees ')'
        { $$ = addGameTrees($2, $3); }
    | WHITESPACE '(' sequence gametrees ')'
        { $$ = addGameTrees($3, $4); }
    ;

gametrees
	: gametree
		{ $$ = [$1]; }
	| gametree gametrees
		{ $2.unshift($1); $$ = $2; }
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
	| node propident propvalues
		{ $1[$2] = $3; $$ = $1; }
	;

propident
	: text
		{ $$ = $1; }
	;

propvalues
	: propvalue
		{ $$ = $1; }
	| propvalues propvalue
		{ var a; if ($1 instanceof Array) a = $1; else a = [$1]; $$ = a.concat($2); }
	;

propvalue
	: '[' ']'
		{ $$ = ''; }
	| '[' cvaluetype ']'
		{ $$ = $2; }
	;

cvaluetype
	: text
		{ $$ = $1; }
	| compose
		{ $$ = $1; }
	;

compose
	: text ':' text
		{ var o = {}; o[$1] = $2; $$ = o; }
	;

text
	: CHAR
		{ $$ = $1; }
	| '\]'
		{ $$ = ']'; }
	| text CHAR
		{ $$ = $1 + $2; }
	| text SOFT_LINEBREAK
		{ $$ = $1; }
	| text ESCAPECHAR
		{ $$ = $1 + $2.slice(1); }
	;
