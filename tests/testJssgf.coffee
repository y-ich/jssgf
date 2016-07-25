###
description: test jssgf.js
author: ICHIKAWA, Yuji
copyright: 2014 (C) ICHIKAWA, Yuji (New 3 Rs)
###

assert = require 'assert'
parser = require('./jssgf').parser

describe 'parser', ->
    describe 'bug of regular expression in V8', ->
        it 'bracket with linebreak', ->
            bracket = '[\n]'
            match = bracket.match /\[[^\]]*\]/
            assert.equal match[0], bracket
        it 'brackets with linebreak', ->
            a = '[][][][][][][][][][][][][][][][][][][][][][][][][][][][][\n])'.match /(\[[^\]]*\])+\)$/
            assert.equal typeof a, 'object'
    describe 'collection', ->
        it 'should return the smallest collection', ->
            assert.deepEqual parser.fastParse('(;)'), [_children: []]
        it 'should includes plural game tree', ->
            assert.deepEqual parser.fastParse('(;)(;)'), [{_children: []}, {_children: []}]
        it 'should includes plural game tree', ->
            assert.deepEqual parser.fastParse('(;)\n(;)'), [{_children: []}, {_children: []}]
    describe 'game tree', ->
        it 'should includes a normal game tree', ->
            assert.deepEqual parser.fastParse('(;FF[4])'), [_children: [], FF: '4']
        it 'should includes a normal game tree', ->
            assert.deepEqual parser.fastParse('(;FF[4]GM[1])'), [_children: [], FF: '4', GM: '1']
        it 'should includes a normal game tree', ->
            assert.deepEqual parser.fastParse('(;FF[4]GM[1]EV[])'), [_children: [], FF: '4', GM: '1', EV: '']
        it 'should includes a normal game tree', ->
            assert.deepEqual parser.fastParse('(;FF[4]GM[1]EV[ ])'), [_children: [], FF: '4', GM: '1', EV: ' ']
        it 'should treats a soft line break', ->
            assert.deepEqual parser.fastParse('(;FF[4]GM[1]EV[a\\\nb])'), [_children: [], FF: '4', GM: '1', EV: 'ab']
        it 'should treats an escaped ]', ->
            assert.deepEqual parser.fastParse('(;FF[4]GM[1]EV[\\]])'), [_children: [], FF: '4', GM: '1', EV: ']']
        it 'should treats an escaped ]', ->
            assert.deepEqual parser.fastParse('(;FF[4]GM[1]EV[()])'), [_children: [], FF: '4', GM: '1', EV: '()']
        it 'should  an escaped ]', ->
            assert.deepEqual parser.fastParse('(;DT[2015-09-03];B[pd](;W[nq])(;W[aa]))'), [_children: [
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
        it 'long sequence with linebreak', ->
            a = parser.fastParse '(;A[][][][][][][][][][][][][][][][][][][][][][][][][][][][][\n])'
            assert.equal typeof a, 'object'
        it 'wrong sequence with linebreak', ->
            a = try
                parser.fastParse '(;A[][][][][][][][][][][][][][][][][][][][][][][][][][][][][\n]'
            catch e
                null
            assert.equal a, null
    describe 'stringify', ->
        it 'should return string', ->
            sgf = '(;FF[4])'
            assert.equal parser.stringify(parser.fastParse sgf), sgf
        it 'should make FF prior', ->
            sgf = '(;GM[1]FF[4])'
            assert.equal parser.stringify(parser.fastParse sgf), '(;FF[4]GM[1])'
    describe 'isSgf', ->
        it 'should return true', ->
            sgf = '(;FF[4])'
            assert.equal parser.isSgf(sgf), true
    describe 'nthMoveNode', ->
        it 'should return root', ->
            [root] = parser.fastParse '(;FF[4]SZ[19];B[aa])'
            assert.equal parser.nthMoveNode(root, 0), root
        it 'should return first move node', ->
            [root] = parser.fastParse '(;FF[4]SZ[19];B[aa])'
            assert.equal parser.nthMoveNode(root, 1), root._children[0]
        it 'should return first move node', ->
            [root] = parser.fastParse '(;FF[4]SZ[19];B[aa];W[bb];B[cc];W[dd])'
            assert.equal parser.nthMoveNode(root, Infinity).W, 'dd'
