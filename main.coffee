pipeLib = ->
checkType = require "icat_checktype"

pipeLib.start = (fn)->
  checkType arguments,[["function","asyncfunction","number","object"]],"pipeLib.start()"
  data = null
  if Object::toString.call(fn) is "[object Object]"
    data = {fn...}
    fn = ()=> data
  if fn.endSign is 1
    return fn(@)
  if fn is 0
    return @
  return (args...)=>
    to:pipeLib.start.bind => fn(@,args...)
    给:pipeLib.start.bind => fn(@,args...)
  
  
pipeLib.开始 = pipeLib.start


pipeLib.print = (data)->
  console.log data()
  data()
pipeLib.输出 = pipeLib.print

pipeLib.printx = (data)->
  console.log await data()
  await data()
pipeLib.异步输出 = pipeLib.printx

pipeLib.end = (data)=>
  data
pipeLib.end.endSign = 1
pipeLib.结束 = pipeLib.end

###
# basic useage
pipeLib.start(()=>[1,2,3,4,5])()
  .to((data)=>
    data = data()
    data.push "hello"
    return data
  )()
  .to((data)=>
    data = data()
    data.shift()
    return data
  )()
  .to(pipeLib.print)()
  .to(pipeLib.end)()


obj1 = pipeLib.start({a:12,b:5})()
opr1 = obj1.to((ref)=>
    data = ref() #ref() -> object {a:12,b5} is reference
    data.c = 20
    data
  )()
opr2 = obj1.to((ref)=>
  data = ref()
  data.d = "hello"
  data
)()

output1 = opr1.to(pipeLib.print)().to(0)()
output2 = opr2.to(pipeLib.print)().to(pipeLib.end)()
output3 = obj1.to(pipeLib.print)().to(0)()
console.log(output1 is output3) #true

#async useage
do->
  await pipeLib.start({data:null})()
    .to((ref)=>
      data = ref()
      data.data = await new Promise (res)=>
        setTimeout =>
          res("async data")
        ,1000
      data
    )()
    .to((ref)=>
      data = await ref()
      console.log data
      data
    )()
    .to(0)()
  console.log(222)
###

module.exports = pipeLib

