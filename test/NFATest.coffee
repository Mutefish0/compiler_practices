assert = require 'assert'

describe 'NFA', ->
    NFA = require '../src/common/NFA'
    
    test = (executor, testCases) -> 
        for testCase in testCases
            do (testCase) ->
                it "should#{if testCase.fit then ' ' else ' not '}fit in case `#{testCase.input}`",  ->
                    assert.equal  testCase.fit, executor.accepte testCase.input    

    describe 'Accepte all strings of `a`s and `b`s that d\'nt contain substring `abb`', ->
        nfa = new NFA [
            { key: '0', start: true, accepted: true, route: 'b': ['0'], '': ['1']}
            { key: '1', route: 'a': ['1', '2', '3'],}
            { key: '2', route: 'b': ['3'] }
            { key: '3', accepted: true, route: '': ['1'] }
        ]
        testCases = [
            { input: '', fit: true }
            { input: 'aba', fit: true }
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
        
        describe 'Using plain NFA executor', ->
            test nfa, testCases

        dfa = nfa.compile()
        describe 'Using compiled DFA executor', ->
            test dfa, testCases