###
功能
    采用预测分析法 （适用于同一个非终结符的各个产生式的First集合不相交） 
    将包含`+`, `-`, 空格和单个数字的表达式翻译为后缀表达式 eg:
    2 + 5 - 7 -> 25+7-


产生式                     语义规则
    expr -> expr1 + term    expr.t = expr1.t + term.t + '+'
          | expr1 - term    expr.t = expr1.t + term.t + '-'          
          | term            expr.t = term.t

    term -> 0               term.t = '0'         
          | 1               term.t = '1'
          ...
          | 9               term.t = '9'



消除左递归
    令 
    α = + term              α.t = term.t + '+'
    β = - term              β.t = term.t + '-'   
    γ = term 
    得
    expr -> term rest       expr.t = term.t + rest.t     

    rest -> + term rest1    rest.t = term.t + '+' + rest1.t
          | - term rest1    rest.t = term.t + '-' + rest1.t
          | ε               rest.t = ''
###

predictiveParser = () -> 
    @lookahead
    @seq
    @matched

    @eof = () ->
        @seq[@lookahead] is undefined
    
    @blank = () ->
        /\s/.test @seq[@lookahead]

    @match = (regT) ->
        @lookahead++ while @blank()
        t = @seq[@lookahead]

        if regT instanceof RegExp and regT.test(t) or regT is t 
            @lookahead += 1
            @matched = t
            true
        else
            false

    @expr = () -> 
        @term() + @rest()
        
    @rest = () ->
        if @match '+'
            @term() + '+' + @rest()
        else if @match '-'
            @term() + '-' + @rest()
        else  if @eof()
            ''
        else
            throw new Error "SyntaxtError"
    
    @term = () ->
        if @match /[0-9]/
            @matched
        else 
            throw new Error "SyntaxtError"

    @parse = (@seq) ->
        @lookahead = 0
        @expr()

    'Parser'

module.exports = predictiveParser
