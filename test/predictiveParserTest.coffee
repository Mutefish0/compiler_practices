assert = require 'assert'

describe 'Predictive Parser', () ->
    PredictiveParser = require '../src/PredictiveParser'
    pprs = new PredictiveParser()
    
    it 'should work in case with +, -', () ->
        assert.equal '13+2-', pprs.parse '1+3-2'

    it 'should work in case with *, /', () ->
        assert.equal '12*4/', pprs.parse '1*2/4'

    it 'should ignore blanks, tabs, etc.', () ->
        assert.equal '12+4-', pprs.parse '1  +   2 - 4'

    it 'should work mixing with +, - and *, /', () ->
        assert.equal '123*+', pprs.parse '1 + 2 * 3' 
    
    it 'should work in normal case', () ->
        assert.equal '32/42*3/-4+', pprs.parse '3 / 2 - 4 * 2 / 3 + 4'
    
    it 'should work in normal case', () ->
        assert.equal '632/-42*3/-4+', pprs.parse '6 - 3 / 2 - 4 * 2 / 3 + 4'

    it 'should throw syntaxt error with multiple digitals', () ->
        assert.throws () ->
            pprs.parse '21 + 2'
        , /SyntaxtError/

    it 'should throw syntaxt error with unknown terminal', () ->
        assert.throws () ->
            pprs.parse '(1 + 2) * 4'
        , /SyntaxtError/

    it 'should throw syntaxt error end with operator', () ->
        assert.throws () ->
            pprs.parse '1 + 2 -'
        , /SyntaxtError/

    it 'should throw syntaxt error end with operator', () ->
        assert.throws () ->
            pprs.parse '1 + 2 *'
        , /SyntaxtError/

    it 'should throw syntaxt error start with operator', () ->
        assert.throws () ->
            pprs.parse '* 1 + 2'
        , /SyntaxtError/

    it 'should throw syntaxt error with adjoining operators', () ->
        assert.throws () ->
            pprs.parse '1 + + 2'
        , /SyntaxtError/


module.exports = ''