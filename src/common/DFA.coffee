###
node {
    key: 's1',
    route: {
        'a': 's2',
        'b': 's3',
        '': 's4'   # optional, go default
    },
    accepted:  # accepted state,  optional, true | false, default false 
    dead:  # dead state, optional, true | false, default false
    start: # start state, optional, true | false, default false
}
###

class DFA
    constructor: (@nodes) ->
        @_nodeMap = new Map()
        for node in @nodes
            @_nodeMap.set node.key, node
            if node.start
                @_startNode = node

    accepte: (str) ->
        head = @_startNode
        for p in [0..str.length - 1]
            if head.dead
                return false
            head = @_nodeMap.get head.route[str[p]] || head.route['']
        !!head.accepted

module.exports = DFA