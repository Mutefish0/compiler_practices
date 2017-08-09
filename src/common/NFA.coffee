DFA = require './DFA'

###
state {
    key: 's1',
    route: {
        'a': ['s2', 's5'],
        'b': ['s3'],
        '': ['s2'],  # ε move
    },
    accepted:  # accepted state,  optional, true | false, default false 
    start: # start state, optional, true | false, default false
}
###




class NFA
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
        # 获取字母表
        alphabets = new Set()
        for state in @states
            for alpha of state.route
                alphabets.add alpha
        alphabets.delete ''
        @alphabets = Array.from alphabets


    accepte: (str) ->
        head = new Set @_startState.key
        for char in str
            head = @_move @_closure(head), char
        @_accepte head 


    # extend a set using it's ε-closure
    _closure: (set) ->
        nextSet = new Set()
        set.forEach (key) =>
            state = @_stateMap.get key
            route = state.route[''] || []
            for key in route
                nextSet.add key
        set.forEach (key) ->
            nextSet.add key
        nextSet


    # move a set
    _move: (set, char) ->
        nextSet = new Set()
        set.forEach (key) =>
            state = @_stateMap.get key
            route = state.route[char] || []
            for key in route
                nextSet.add key
        nextSet
    
    # the set is accepted when there is at least one state of it is accepted
    _accepte: (set) ->
        result = false
        set.forEach (key) =>
            if @_stateMap.get(key).accepted
                result = true
        result
    

    # hash a set of strings
    _hash: (set) ->
        keys = Array.from(set).sort()
        for key, idx in keys
            keys[idx] = key.replace('@', '@@').replace('#', '@#')
        keys.join '#'

    # compile to a corresponding DFA, exponential growth time cost
    compile: ->
        resolvedMap = new Map()
        startSet = @_closure new Set @_startState.key
    
        queue = [{ 
            key: @_hash startSet
            start: true
            accepted: @_accepte startSet
            route: {}
            subset: startSet
        }]

        while queue.length
            node = queue.shift()
            if !node.key
                resolvedMap.set '', key: '', dead: true
                continue
            if resolvedMap.has node.key
                continue 

            for alpha in @alphabets
                next = @_closure @_move(node.subset, alpha)
                hashNext = @_hash next

                queue.push {
                    key: hashNext
                    accepted: @_accepte next
                    route: {}
                    subset: next
                }
                node.route[alpha] = hashNext 

            resolvedMap.set node.key, key: node.key, start: !!node.start, accepted: node.accepted, route: node.route

        new DFA Array.from resolvedMap.values()

    toString: ->
        @states


module.exports = NFA