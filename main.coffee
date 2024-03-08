pipeLib = {}
pipeLib.start = (data)->
  (fn)->
    if fn.keyName is "end"
      fn.call @
    else
      (args...)-> pipeLib.start fn.call @,args...
      .bind @
  .bind data
pipeLib.end = -> @
pipeLib.end.keyName = "end"
pipeLib.mid = (fn)->
  (args...)->
    fn.call(@,args...)
    @
pipeLib.print = ()->
  console.log @
  @
pipeLib.error = ->
  console.error @
  @

pipeLib.开始 = pipeLib.start
pipeLib.结束 = pipeLib.end
pipeLib.转换 = pipeLib.mid
pipeLib.输出 = pipeLib.print
pipeLib.错误 = pipeLib.error

module.exports = pipeLib
### example
lib = pipeLib
push = lib.mid(Array.prototype.push)
lib.start([])(push)(3)(push)(4)(lib.error)()
###