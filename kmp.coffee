findSkip = (str) ->
    len = str.length
    if len < 2
        return 1
    for x in [len - 2..0]
        y = len - 1 - x
        for i in [0..x]
            if str[i] isnt str[y + i]
                break
        if i > x
            return y
    1

generateSkipTable = (pattern)  ->
    if pattern.length < 2
        return [] 
    findSkip pattern[0..i] for i in [0..pattern.length - 2]


indexOf = (target, pattern) -> 
    

exports.findSkip = findSkip
exports.generateSkipTable = generateSkipTable