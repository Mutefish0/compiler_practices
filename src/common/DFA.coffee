###
node {
    key: 's1',
    state: DFA.start  #  start | final | accepted | undefined,
    route: {
        'a': 's2',
        'b': 's3'
    }
    default: 's4'
}
###

class DFA
    nodes: []
    _nodeMap: new Map()
    _startNode: null

    @start: 0
    @accepted: 1
    @final: 2

    constructor: (@nodes) ->
        for node in @nodes
            @_nodeMap.set node.key, node
            if node.state is DFA.start
                @_startNode = node

    test: (str) ->
        head = @_startNode
        for p in [0..str.length - 1]
            if head.state is DFA.final
                return false
            head = @_nodeMap.get head.route[str[p]] || head.default
        head.state is DFA.accepted

module.exports = DFA