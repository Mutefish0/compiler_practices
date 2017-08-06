assert = require 'assert'

describe 'DFA', ->
    DFA = require '../src/common/DFA'
    describe 'All strings that contain even `a` and odd `b`', ->
        dfa = new DFA [
            { key: '0', state: DFA.start, route: 'a': '3', 'b': '1' }
            { key: '1', state: DFA.accepted, route: 'a': '2', 'b': '0' }
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

        for testCase in testCases
            it "case `#{testCase.input}` should#{if testCase.fit then ' ' else ' not '}fit", ((testCase) ->
                assert.equal  testCase.fit, dfa.test testCase.input 
            ).bind {}, testCase   

module.exports = ''