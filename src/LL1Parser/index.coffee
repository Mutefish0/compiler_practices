###
internal terminals:

EOF = {
    tag: '$'  //eof
    pattern: '$'
}

EPSILON = {
    tag: ''  //epsilon
    pattern: ''
}

{
    terminals: [
        {
            tag: 'ID',
            pattern: '[a-zA-Z_$][\w_$]*'
        },
        {
            tag: 'NUMBER',
            pattern: '\d*'
        },
        {
            tag: 'LPAREN',
            pattern: '('
        },
        {
            tag: 'RPAREN',
            pattern: ')'
        }
    ],
    nonterminals: [
        {
            tag: 'S',
            start: true,
            productions: [
                ['LPAREN', 'A', 'ID'],
                ['NUMBER'],
            ]
        },
        {
            tag: 'T',
            productions: [
                ['NUMBER'],
                ['']
            ]
        }
    ]
}

###


class LL1Parser
    constructor: (@_nonterms) ->
        @_firstDepMap = null
        @_firstSetMap = null
        @_followSetMap = null
        @_prodsMap = new Map()
        @_tags = []
        @_startTag = null
        @_table = null

        for nonterm in @_nonterms
            if nonterm.start
                @_startTag = nonterm.tag

        @_resolveLeftRecusive()

        for nonterm in @_nonterms
            @_prodsMap.set nonterm.tag, nonterm.productions
            @_tags.push nonterm.tag

        @_resolveDependence()
        @_resolveFirstSets()
        @_resolveFollowSets()
        @_constructParseTable()

    @printProduction: (nonterminal) ->
        span = "\n#{nonterminal.tag.replace(/./g, ' ')}  | "
        prods = for prod in nonterminal.productions
            _prod = (sym || 'ε' for sym in prod)
            _prod.join ' '
        "#{nonterminal.tag} -> #{prods.join span}"

    @printProductions: (nonterminals) ->
        (@printProduction nonterm for nonterm in nonterminals).join '\n\n'

    # 消除立即左递归
    #   input: A -> Aa | Ab | Ac | d | e 
    #   output:
    #       A -> dA' | eA' 
    #       A' -> aA' | bA' | cA' | ε
    @_immedianteLeftRecusive: (nonterm) ->
        { tag, productions } = nonterm
        alphas = []
        betas = [] 
        for prod in productions
            if prod[0] is tag 
                alphas.push prod[1..]
            else 
                betas.push prod
        if !alphas.length 
            return [nonterm]
        tagRest = "##{tag}#"
        [
            {
                tag: tag
                productions: [...beta, tagRest] for beta in betas
            }
            {
                tag: tagRest 
                productions: ([...alpha, tagRest] for alpha in alphas).concat [['']]
            }
        ]

    # 消除左递归
    @_leftRecusive:(nonterms) ->
        resolvedNonterms = []
        extraNonterms = []

        newNonterm = nonterms[0]
        newNonterm = LL1Parser._immedianteLeftRecusive newNonterm
        resolvedNonterms.push newNonterm[0]
        extraNonterms.push newNonterm[1]

        for nti, i in nonterms[1..]
            newNonterm = tag: nti.tag, productions: []
            for prod in nti.productions
                replaced = false
                for ntj in resolvedNonterms
                    if prod[0] is ntj.tag
                        replaced = true
                        newNonterm.productions.push (
                            [...prodj].concat prod[1..] for prodj in ntj.productions
                        )
                if not replaced
                    newNonterm.productions.push [...prod]

            newNonterm = LL1Parser._immedianteLeftRecusive newNonterm
            resolvedNonterms.push newNonterm[0]
            newNonterm[1] && extraNonterms.push newNonterm[1]

        resolvedNonterms.concat extraNonterms


    _resolveLeftRecusive: ->
        @_nonterms = LL1Parser._leftRecusive @_nonterms 

    # 解析计算FIRST集所需的依赖
    _resolveDependence:  ->
        @_firstDepMap = new Map()
        for nonterm in @_nonterms
            set = new Set()
            for prod in nonterm.productions
                for sym in prod
                    if @_prodsMap.has sym
                        set.add sym
                    else 
                        break
            @_firstDepMap.set nonterm.tag, set

    # 寻找FIRST集, 必须先消除左递归，不然会产生无限循环
    _resolveFirstSets: ->
        queue = [...@_tags]
        resolveMap = new Map()

        depOk = (tag) => 
            for dep from @_firstDepMap.get tag
                if not resolveMap.has dep  
                    return false
            true

        resolve = (tag) =>
            set = new Set()
            for prod in @_prodsMap.get tag 
                for sym in [...prod, '$'] # 加入哨兵标记
                    # 如果是终结符，加入first集，遍历下一个产生式
                    if not @_prodsMap.has sym
                        set.add sym
                        break
                    # 非终结符的first集直接加入(非ε)
                    fset = resolveMap.get sym
                    for term from fset when term isnt ''
                        set.add term
                    # 如果first集无ε，终止循环
                    if '' not in fset
                        break
            if set.has '$'
                set.delete '$'
                set.add ''
            set
                    
            
        while queue.length
            tag = queue.pop()
            if resolveMap.has tag
                continue
            if not depOk tag
                queue.shift tag
            else
                resolveMap.set tag, resolve tag
        
        @_firstSetMap = resolveMap

    _getFirstSet: (sym) ->
        @_firstSetMap.get(sym) || new Set([sym])

    _getFollowSet: (tag) ->
        @_followSetMap.get tag

    # 获取一个符号序列的FIRST集
    _getFirstSetBySeq: (seq) ->
        set = new Set()
        for sym in [...seq, '$']
            first = @_getFirstSet sym
            for f from first when f isnt ''
                set.add f
            if not first.has ''
                break
        if set.has '$'
            set.delete '$'
            set.add ''
        set
    
    # 寻找FOLLOW集
    _resolveFollowSets: ->
        followDepMap = new Map() # => Set
        partialMap = new Map() # => Set
        resolveMap = new Map() # => Set

        reduceFirstSet = new Set()
        firstSet = null
        
        for tag in @_tags
            followDepMap.set tag, new Set()
            partialMap.set tag, new Set()

        partialMap.get(@_startTag).add '$'

        for tag in @_tags
            for prod in @_prodsMap.get tag
                reduceFirstSet.clear()
                reduceFirstSet.add ''
                for sym in prod by -1
                    firstSet = @_getFirstSet sym 
                    partial = partialMap.get sym
                    # 如果是非终结符
                    if @_prodsMap.has sym

                        for rf from reduceFirstSet when rf isnt ''
                            partial.add rf
                        
                        if reduceFirstSet.has ''
                            followDepMap.get(sym).add tag
                    
                    if not firstSet.has ''
                        reduceFirstSet.clear()

                    for f from firstSet
                        reduceFirstSet.add f 
        # 去掉对自己的依赖
        for dep from followDepMap
            followDepMap.get(dep[0]).delete dep[0]

        queue = [...@_tags]
        while queue.length
            tag = queue.pop()
            if resolveMap.has tag 
                continue
            
            partial = partialMap.get tag
            deps = followDepMap.get tag

            for dep from deps
                if resolveMap.has dep 
                    for rd from resolveMap.get dep
                        partial.add rd
                    deps.delete dep 

            if deps.size is 0
                resolveMap.set tag, partial
            else
                queue.unshift tag 

        @_followSetMap = resolveMap

    # 构造预测分析表
    _constructParseTable: ->
        table = {}
        for tag in @_tags
            table[tag] = {}
            for prod in @_prodsMap.get tag
                first = @_getFirstSetBySeq prod
                for f from first when f isnt ''
                    # 存在重复的条目
                    if table[tag][f] 
                        throw Error 'SyntaxtError: incorrect LL(1) gramer'
                    else 
                        table[tag][f] = tag: tag, production: prod
                if first.has ''
                    follow = @_getFollowSet tag
                    for f from follow
                        if table[tag][f]
                            throw Error 'SyntaxtError: incorrect LL(1) gramer'
                        else    
                            table[tag][f] = tag: tag, production: prod
        @_table = table

    # 给定一个lexer，执行解析过程
    parse: (lexer) ->
        stack = ['$', @_startTag]
        token = lexer.nextToken()
        parseStack = [[token]]
        
        while stack.length
            head = stack.pop()

            if head is '$$'
                p = parseStack.pop()
                parseStack[parseStack.length - 1].push p
                continue

            if head is '' # just ignore ε
                continue
            # 终结符
            if not @_prodsMap.has head
                token = lexer.nextToken head

                if token.tag isnt '$'
                    parseStack[parseStack.length - 1].push token

            else 
                prod = @_table[head][token.tag]
                if not prod
                    throw Error 'SyntaxtError: parse error'
                stack.push '$$'
                parseStack.push []
                for sym in prod.production by -1 
                    stack.push sym

        parseStack[0]
    

module.exports = LL1Parser
