###
description: test jssgf.js
author: ICHIKAWA, Yuji
copyright: 2014 (C) ICHIKAWA, Yuji (New 3 Rs)
###

assert = require 'assert'
parser = require('./jssgf').parser

describe 'parser', ->
    describe 'collection', ->
        it 'should return the smallest collection', ->
            assert.deepEqual parser.parse('(;)'), [_children: []]
        it 'should includes plural game tree', ->
            assert.deepEqual parser.parse('(;)(;)'), [{_children: []}, {_children: []}]
        it 'should includes plural game tree', ->
            assert.deepEqual parser.parse('(;)\n(;)'), [{_children: []}, {_children: []}]
    describe 'game tree', ->
        it 'should includes empty value of property ', ->
            assert.deepEqual parser.parse('(;TB)'), [_children: [], TB: null]
        it 'should includes empty value of property ', ->
            assert.deepEqual parser.parse('(;TB FF[4])'), [_children: [], TB: null, FF: '4']
        it 'should includes a normal game tree', ->
            assert.deepEqual parser.parse('(;FF[4])'), [_children: [], FF: '4']
        it 'should includes a normal game tree', ->
            assert.deepEqual parser.parse('(;FF[4]GM[1])'), [_children: [], FF: '4', GM: '1']
        it 'should includes a normal game tree', ->
            assert.deepEqual parser.parse('(;FF[4]GM[1]EV[])'), [_children: [], FF: '4', GM: '1', EV: '']
        it 'should includes a normal game tree', ->
            assert.deepEqual parser.parse('(;FF[4]GM[1]EV[ ])'), [_children: [], FF: '4', GM: '1', EV: ' ']
        it 'should treats a soft line break', ->
            assert.deepEqual parser.parse('(;FF[4]GM[1]EV[a\\\nb])'), [_children: [], FF: '4', GM: '1', EV: 'ab']
        it 'should treats an escaped ]', ->
            assert.deepEqual parser.parse('(;FF[4]GM[1]EV[\\]])'), [_children: [], FF: '4', GM: '1', EV: ']']
        it 'should treats an escaped ]', ->
            assert.deepEqual parser.parse('(;FF[4]GM[1]EV[()])'), [_children: [], FF: '4', GM: '1', EV: '()']
        it 'should  an escaped ]', ->
            assert.deepEqual parser.parse('(;DT[2015-09-03];B[pd](;W[nq])(;W[aa]))'), [_children: [
                    _children: [
                            _children: []
                            W: 'nq'
                        ,
                            _children: []
                            W: 'aa'
                    ]
                    B: 'pd'
                ,
            ], DT: '2015-09-03']

    describe 'stringify', ->
        it 'should return string', ->
            sgf = '(;FF[4])'
            assert.equal parser.stringify(parser.parse sgf), sgf
    describe 'isSgf', ->
        it 'should return true', ->
            sgf = '(;FF[4])'
            assert.equal parser.isSgf(sgf), true
    describe 'nthMoveNode', ->
        it 'should return root', ->
            [root] = parser.parse '(;FF[4]SZ[19];B[aa])'
            assert.equal parser.nthMoveNode(root, 0), root
        it 'should return first move node', ->
            [root] = parser.parse '(;FF[4]SZ[19];B[aa])'
            assert.equal parser.nthMoveNode(root, 1), root._children[0]
        it 'should return first move node', ->
            [root] = parser.parse '(;FF[4]SZ[19];B[aa];W[bb];B[cc];W[dd])'
            assert.equal parser.nthMoveNode(root, Infinity).W, 'dd'
