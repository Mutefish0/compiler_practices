assert = require 'assert'

describe 'DFA', ->
    DFA = require '../src/common/DFA'


    test = (dfa, testCases) ->
         for testCase in testCases
            do (testCase) ->
                it "should#{if testCase.fit then ' ' else ' not '}fit in case `#{testCase.input}`",  ->
                    assert.equal  testCase.fit, dfa.accepte testCase.input


    describe 'Accepte all strings that contain even `a` and odd `b`', ->
        dfa = new DFA [
            { key: '0', start: true, route: 'a': '3', 'b': '1' }
            { key: '1', accepted: true, route: 'a': '2', 'b': '0' }
            { key: '2', route: 'a': '1', 'b': '3' }
            { key: '3', route: 'a': '0', 'b': '2' }
        ]
        testCases = [
            { input: 'b', fit: true }
            { input: 'bb', fit: false }
            { input: 'aab', fit: true }
            { input: 'aba', fit: true }
            { input: 'ababab', fit: false }
            { input: 'baabababb', fit: true }
            { input: 'baabaababb', fit: false }
            { input: 'aabababbb', fit: true }
        ]
        test dfa, testCases
 

    describe 'Accepte all strings of `a`s and `b`s that d\'nt contain substring `abb`', ->
        dfa = new DFA [
            { key: '0', start: true, accepted: true, route: 'a': '1', 'b': '0', '': '0'}
            { key: '1', accepted: true, route: 'a': '1', 'b': '2' }
            { key: '2', accepted: true, route: 'a': '1', 'b': '3' }
            { key: '3', dead: true }
        ]
        
        testCases = [
            { input: '', fit: true }
        ]
        Randexp = require 'randexp'
        randexp = new Randexp /b*(a+b?)*/
        randexp.max = 8
        # generate 10 random positive testCases
        for i in [0..9]
            testCases.push input: randexp.gen(), fit: true
        randexp = new Randexp /[ab]*abb[ab]*/
        randexp.max = 8
        # generate 10 random negtive testCases
        for i in [0..9]
            testCases.push input: randexp.gen(), fit: false

        test dfa, testCases


module.exports = ''