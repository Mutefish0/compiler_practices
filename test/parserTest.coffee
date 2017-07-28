assert = require 'assert'

describe 'Predictive Parser', () ->
    predictiveParser = require '../src/predictiveParser'
    pprs = new predictiveParser()
    
    it 'should work fine in normal case.', () ->
        assert.equal '13+2-', pprs.parse '1+3-2'

    it 'should ignore blanks, tabs, etc.', () ->
        assert.equal '12+4-', pprs.parse '1  +  2 - 4'

    it 'should throw syntaxt error with multiple digitals.', () ->
        assert.throws () ->
            pprs.parse '11 + 2'
        , /SyntaxtError/

    it 'should throw syntaxt error with unknown terminal.', () ->
        assert.throws () ->
            pprs.parse '1 + 2 * 4'
        , /SyntaxtError/