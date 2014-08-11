###
SGF libarary
(C) 2013-2014 ICHIKAWA, Yuji (New 3 Rs)
###

# use jssgf.parse to parse SGF string

stringify = (c) ->
    c.map(gameTree2string).join ''

gameTree2string = (gameTree) ->
    result = '('
    n = gameTree
    loop
        result += node2string n
        if n._children.length == 0
            break
        else if n._children.length == 1
            n = n._children[0]
        else
            result += (gameTree2string e for e in n._children).join ''
            break
    result += ')'

node2string = (node) ->
    ';' + (k + propvalues2string v for k, v of node when not /^_/.test k).join ''

propvalues2string = (propvalues) ->
    propvalues = [propvalues] unless propvalues instanceof Array
    ("[#{escapePropvalue e}]" for e in propvalues).join ''

escapePropvalue = (propvalue) ->
    # propvalue.replace /([\]\\:])/g, '\\$1'
    propvalue.replace /([\]\\])/g, '\\$1' # do not escape : because it is not interpreted yet.
