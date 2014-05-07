###
description: test jssgf.js
author: ICHIKAWA, Yuji
copyright: 2014 (C) ICHIKAWA, Yuji (New 3 Rs)
###

assert = require 'assert'
parser = require('../jssgf').parser

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
