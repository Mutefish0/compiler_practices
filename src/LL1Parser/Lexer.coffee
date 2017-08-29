###
Token
    tag 
    lexme
    attr 


Terminals

    internal terminals:

    EOF = {
        tag: '$'  //eof
        pattern: '$'
    }

    customer terminals:

    ID = {
        tag: 'id'
        pattern: '[a-zA-Z_]\w*'
    }

    ADD = {
        tag: '+'
        pattern: '\\+' 
    }

    MUL = {
        tag: '*'
        pattern: '\\*' 
    }

    LPAREN = {
        tag: '('
        pattern: '\\(' 
    }

    RPAREN = {
        tag: ')'
        pattern: '\\)' 
    }

###
class Lexer
    @EOF = tag: '$', pattern: '$'

    constructor: (terminals, options = ignoreBlank: true) ->
        @_input = ''
        @_regexMap = new Map()
        @_tags = []

        @_ignoreBlank = options.ignoreBlank

        for term in [...terminals, Lexer.EOF]
            @_tags.push term.tag
            @_regexMap.set term.tag, new RegExp '^' + term.pattern

    build: (str) ->
        @_input = str
        this

    nextToken: (tag) ->
        if @_ignoreBlank # 忽略空白
             @_input = @_input.replace /^\s*/, ''
        tags = if tag then [tag] else @_tags 
        for tag in @_tags
            match = @_input.match @_regexMap.get tag
            if match
                lexme = match[0]
                @_input = @_input[lexme.length..]
                return tag: tag, lexme: lexme

        throw 'Syntax Error: parse error'

module.exports = Lexer