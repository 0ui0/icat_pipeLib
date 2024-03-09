pipeLib = ->

pipeLib.start = (fn)->
  if fn.endSign
    fn.call @
  else
    (args...)-> pipeLib.start.bind fn.call @,args...
      .bind @
pipeLib.开始 = pipeLib.start

pipeLib.print = ()->
  console.log @
  @
pipeLib.输出 = pipeLib.print

pipeLib.end = ()-> @
pipeLib.end.endSign = 1
pipeLib.结束 = pipeLib.end

module.exports = pipeLib

###
newArr = -> []
push = (args...)->
  this.push args...
  @

console.log  pipeLib.start(newArr)()(push)(3)(push)(4)(pipeLib.end)
###
