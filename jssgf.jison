/*
    description: Parses SGF string and generates corresponding object.
    note1: This parser doesn't interpret PropValue, returns all as text.
    note2: Yout need at least one PropValues in each Property as I didn't understand elist of PropValue in the SGF specification.
*/

%{
/* prologue */
var strict = false; // if true, throw exception when overapping a property in a node.
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
\s*"("                return '(';
")"\s*                return ')';
\s*";"\s*             return ';';
"["                   return '[';
"]"\s*                return ']';
":"                   return ':';
\\[\r\n]+            return 'SOFT_LINEBREAK';
\\.                  return 'ESCAPE_CHAR';
[A-Z]                 return 'UC_LETTER';
[^();\[\]]            return 'OTHER_CHAR';
<<EOF>>               return 'EOF';

/lex

%% /* language grammar */

output
	: collection EOF
        {
        /*
            console.log($1);
            var n = $1[0];
            while (n._children.length > 0) {
            console.log(n);
            n = n._children[0];
            }
        */
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
	| node propident propvalues
		{
            if (strict == true && typeof $1[$2] !== 'undefined') {
                throw new Error('double properties');
            } else {
                $1[$2] = $3;
                $$ = $1;
            }
        }
	;

propident
	: UC_LETTER
		{ $$ = $1; }
    | propident UC_LETTER
        { $$ = $1 + $2; }
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
    : UC_LETTER
        { $$ = $1; }
	| OTHER_CHAR
		{ $$ = $1; }
    | text UC_LETTER
		{ $$ = $1 + $2; }
	| text OTHER_CHAR
		{ $$ = $1 + $2; }
	| text SOFT_LINEBREAK
		{ $$ = $1; }
	| text ESCAPE_CHAR
		{ $$ = $1 + $2.slice(1); }
	;
