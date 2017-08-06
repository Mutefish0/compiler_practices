###
功能
    采用预测分析法 （适用于同一个非终结符的各个产生式的First集合不相交） 
    将包含`+`, `-`, `*`, `/`空格和单个数字的表达式翻译为后缀表达式 eg:
    2 + 5 - 7 -> 25+7-


产生式                       语义规则
    expr -> expr1 + factor   expr.t = expr1.t + factor.t + '+'
          | expr1 - factor   expr.t = expr1.t + factor.t + '-'          
          | factor           expr.t = factor.t

    
 factor  -> factor * term
          | factor / term
          | term

    term -> 0               term.t = '0'         
          | 1               term.t = '1'
          ...
          | 9               term.t = '9'


消除左递归
    令 
    α = + factor              α.t = factor.t + '+'
    β = - factor              β.t = factor.t + '-'   
    γ = factor 
    得
    expr -> factor rest       expr.t = factor.t + rest.t     

    rest -> + factor rest1    rest.t = α.t + rest1.t = factor.t + '+' + rest1.t
          | - factor rest1    rest.t = β.t + rest1.t = factor.t + '-' + rest1.t
          | ε                 rest.t = ''

    同理得
  factor -> term trest      factor.t = term.t + trest.t

   trest -> * term trest1   trest.t = term.t + '*' + trest1.t
          | / term trest1   trest.t = term.t + '/' + trest1.t
          | ε

###

PredictiveParser = () -> 
    @lookahead
    @seq
    @matched

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
    
    @eof = () ->
        if @seq[@lookahead] is undefined
            ''
        else 
            throw new Error "SyntaxtError"

    @sourceSeq = () ->
        @expr() + @eof()

    @expr = () -> 
        @factor() + @rest()
        
    @rest = () ->
        if @match '+'
            @factor() + '+' + @rest()
        else if @match '-'
            @factor() + '-' + @rest()
        else 
            ''
    
    @factor = () ->
        @term() + @trest()

    @trest = () ->
        if @match '*'
            @term() + '*' + @trest()
        else if @match '/'
            @term() + '/' + @trest()
        else 
            ''

    @term = () ->
        if @match /[0-9]/
            @matched
        else 
            throw new Error "SyntaxtError"

    @parse = (@seq) ->
        @lookahead = 0
        @sourceSeq()

    'Parser'

module.exports = PredictiveParser
