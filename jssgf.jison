/*
    description: Parses SGF string and generates corresponding object.
    author: ICHIKAWA, Yuji
    copyright: 2014 (C) ICHIKAWA, Yuji (New 3 Rs)
    note1: This parser doesn't interpret PropValue, returns all as text.
*/

%{
/* prologue */
var strict = false; // if true, throw exception when overlapping a property in a node.
var debug = false;
function addGameTrees(s, gts){
	var n = s;
	while (n._children.length == 1)
		n = n._children[0];
	n._children = gts;
	return s;
}
%}

/* lexical grammar */
%lex

%%
\s*"("\s*       return '(';
\s*")"\s*       return ')';
\s*";"\s*       return ';';
\s*"["          return '[';
"]"\s*          return ']';
\s+             return 'WHITE_SPACE';
\\[\r\n]+       return 'SOFT_LINEBREAK';
\\.             return 'ESCAPE_CHAR';
[A-Z]+          return 'MAYBE_PROPIDENT';
.               return 'OTHER_CHAR';
<<EOF>>         return 'EOF';

/lex

%% /* language grammar */

output
	: collection EOF
        {
            if (debug) {
                console.log($1);
                /*
                var n = $1[0];
                while (n._children.length > 0) {
                    console.log(n);
                    n = n._children[0];
                }
                */
            }
            return $1;
        }
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
	| node WHITE_SPACE property
		{
            if (typeof $1[$3[0]] !== 'undefined') {
                if (strict) {
                    throw new Error('double properties');
                }
            } else {
                $1[$3[0]] = $3[1];
                $$ = $1;
            }
        }
	;

property
    : propident propvalues
        { $$ = [$1, $2]; }
    ;

propident
    : MAYBE_PROPIDENT
        { $$ = $1; }
    | MAYBE_PROPIDENT  WHITE_SPACE
        { $$ = $1; }
    ;

propvalues
    : propvalue
		{ $$ = $1; }
	| propvalues propvalue
		{ var a; if ($1 instanceof Array) a = $1; else a = [$1]; $$ = a.concat($2); }
	;

propvalue
	: '[' cvaluetype ']'
		{ $$ = $2; }
	;

cvaluetype
	: text
		{ $$ = $1; }
	;

text
    : /* empty */
        { $$ = '' }
    | text '('
        { $$ = $1 + yytext }
    | text ')'
        { $$ = $1 + yytext }
    | text ';'
        { $$ = $1 + yytext }
    | text '['
        { $$ = $1 + yytext }
    | text WHITE_SPACE
		{ $$ = $1 + $2; }
    | text MAYBE_PROPIDENT
		{ $$ = $1 + $2; }
	| text OTHER_CHAR
		{ $$ = $1 + $2; }
	| text SOFT_LINEBREAK
		{ $$ = $1; }
	| text ESCAPE_CHAR
		{ $$ = $1 + $2.slice(1); }
	;

%%
