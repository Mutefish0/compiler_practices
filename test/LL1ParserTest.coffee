assert = require 'assert'
LL1Parser = require '../src/LL1Parser'
Lexer = require '../src/LL1Parser/Lexer'
treeify = require 'treeify'

describe 'LL(1) Gramar Parser', ->
    nonterminals = [
        {
            start: true
            tag: 'E'
            productions: [
                ['E', '+', 'T']
                ['T']
            ]
        }
        {
            tag: 'T'
            productions: [
                ['T', '*', 'F']
                ['F']
            ]
        }
        {
            tag: 'F'
            productions: [
                ['(', 'E', ')']
                ['id']
            ]
        }
    ]

    parser = new LL1Parser nonterminals


    terminals = [
        {
            tag: 'id'
            pattern: '[a-zA-Z_]\\w*'
        }

        {
            tag: '+'
            pattern: '\\+'
        }

        {
            tag: '*'
            pattern: '\\*'
        }

        {
            tag: '('
            pattern: '\\('
        }

        {
            tag: ')'
            pattern: '\\)'
        }
    ]

    lexer = new Lexer terminals
    lexer.build '( x + y ) * z'

    parseTree =  parser.parse lexer




module.exports = ''
