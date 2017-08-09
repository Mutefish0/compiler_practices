###
state {
    key: 's1',
    route: {
        'a': 's2',
        'b': 's3',
    },
    accepted:  # accepted state,  optional, true | false, default false 
    dead:  # dead state, optional, true | false, default false
    start: # start state, optional, true | false, default false
}
###

class DFA
    constructor: (@states) ->
        if !@states.length 
            throw Error 'No state found'
        @_stateMap = new Map()
        for state in @states
            @_stateMap.set state.key, state
            if state.start
                @_startState = state
        if !@_startState 
            throw Error 'No starting state found'

    accepte: (str) ->
        head = @_startState
        for char in str
            if head.dead
                return false
            head = @_stateMap.get head.route[char]
        !!head.accepted

    toString: ->
        @states

module.exports = DFA