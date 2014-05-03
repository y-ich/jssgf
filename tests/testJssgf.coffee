assert = require 'assert'
parser = require('../jssgf').parser

describe 'parser', ->
    it 'should return smallest collection', ->
        assert.deepEqual parser.parse('(;)'), [_children: []]
    it 'should return a collection', ->
        assert.deepEqual parser.parse('(;FF[4])'), [_children: [], FF: '4']