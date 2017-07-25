assert = require 'assert'

{ findSkip, generateSkipTable } = require './kmp'

describe 'KMP Skip Function', () ->
    it 'Should return 1 when no match', () -> 
        assert.equal 1, findSkip 'acdw'

    it 'Should return 1 when empty', () ->
        assert.equal 1, findSkip ''

    it 'Should return 1 when length is 1', () ->
        assert.equal 1, findSkip 'a'

    it 'Should return 3 when match 2 with length 5', () ->
        assert.equal 3, findSkip 'abcab'

    it 'Should return 2 when match 3 with length 5', () -> 
        assert.equal 2, findSkip 'ababa'
    it 'Should return 1 when match 4 with length 5', () ->
        assert.equal 1, findSkip 'aaaaa'

        
describe 'KMP Generate Skip Table', () ->
    testCases = [
        { input: 'abcabcad', expect: [1, 1, 1, 3, 3, 3, 3] }
        { input: 'def', expect: [1, 1] }
    ]

    for testCase in testCases
        it "Correct with input: #{testCase.input}", () ->
            assert.deepEqual testCase.expect, generateSkipTable testCase.input

describe 'KMP '


    

    
        