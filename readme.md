# Eating Introduction


```coffeescript


#【基本使用】

arrLib =
  new: (ref, buildArgs, runArgs) =>
    new Array(buildArgs...)
  push: (ref, buildArgs, runArgs) =>
    tmp = ref()
    tmp.push(buildArgs...)
    return tmp
  shift: (ref, buildArgs, runArgs) =>
    tmp = ref()
    tmp.shift()
    return tmp
  toString: (ref, buildArgs, runArgs) =>
    tmp = ref()
    return String(tmp)

strLib =
  toArray: (ref, buildArgs, runArgs) =>
    tmp = ref()
    sign = buildArgs[0] or ","
    return tmp.split(sign)


pipeLib(arrLib.new)(1, 2, 3)
  .to(arrLib.push)(4, 5, 6)
  .to(arrLib.shift)()
  .to(arrLib.toString)()
  .to(pipeLib.print)("array is")       # array is [ '2', '3', '4', '5', '6' ]
  .to(strLib.toArray)()
  .to(pipeLib.print)("become array") # become array [ '2', '3', '4', '5', '6' ]
  .to(pipeLib.end)()                 # 触发执行


#【分支】
obj1 = pipeLib(pipeLib.value)({ a: 12, b: 5 })

# 分支 1：修改 c
opr1 = obj1.to((ref, buildArgs, runArgs) =>
  data = ref() # 拿到的是对象引用
  data.c = 20
  return data
)()

# 分支 2：修改 d
opr2 = obj1.to((ref, buildArgs, runArgs) =>
  data = ref()
  data.d = "hello"
  return data
)()

# 验证引用污染现象（同源管道的副作用）
output1 = opr1.to(pipeLib.print)("output1").to(0)()         # { a: 12, b: 5, c: 20, d: 'hello' }
output2 = opr2.to(pipeLib.print)("output2").to(pipeLib.end)() # { a: 12, b: 5, c: 20, d: 'hello' }
output3 = obj1.to(pipeLib.print)("output3").to(0)()         # { a: 12, b: 5, c: 20, d: 'hello' }

console.log(output1 is output3) # true，因为它们操作的是内存中的同一个引用对象



#【异步使用】
do ->
  await pipeLib(pipeLib.value)({ data: null })
    # 模拟异步赋值算子
    .to( (ref, buildArgs, runArgs) =>
      data = ref()
      data.data = await new Promise (res) =>
        setTimeout =>
          res("async data resolved")
        , 1000
      return data
    )()
    # 模拟普通异步拦截算子
    .to( (ref, buildArgs, runArgs) =>
      # 因为上游算子是 async 的，所以这里的 ref() 返回的是 Promise
      # 手写算子需要显式 await 
      data = await ref()
      console.log "Async Data Caught: ", data
      return data
    )()
    # 也可以直接用整合后的 print（它内部会自动嗅探 Promise，无需外部 await）
    .to(pipeLib.print)("Final Output")
    .to(0)() 
    
  console.log(222)


 #【管道衔接】

# 增加一个用于修改对象属性的测试工具库
objLib = 
  set: (ref, buildArgs, runArgs) =>
    data = ref()
    [key, val] = buildArgs
    data[key] = val
    return data

# ================= 宏算子复用测试 (pipeLib.use) =================

# 1. 组装并封存一个【通用数据加工】的子管道
# 起手式的源头算子：直接透传外部（主管道）传入的参数 runArgs[0]
processPipe = pipeLib( (ref, buildArgs, runArgs) => runArgs[0] )()
  .to(objLib.set)("status", "processed")
  .to(objLib.set)("timestamp", 1724900000000) # 模拟注入时间戳
  .to(pipeLib.end) # 必须封存，产出高阶执行器


# 2. 在主管道中通过 use 算子无缝接入
mainPipe = pipeLib(pipeLib.value)({ user: "lamuda", action: "login" })
  .to(objLib.set)("role", "admin")
  .to(pipeLib.use)(processPipe) # 把上方封存的子管道像普通插件一样插进来
  .to(pipeLib.print)("use result") 
  .to(0) # 主管道封存

# 运行主管道
mainPipe() 
# 预期输出: 
# use result { user: 'lamuda', action: 'login', role: 'admin', status: 'processed', timestamp: 1724900000000 }



```



This is a tool that helps us chain process data. We can create a dataset and then process it in a chained manner, with each step returning a function for the next processing stage until we encounter the end function pipeLib.end or input 0. Ultimately, it will return the processed dataset.

You can manually store the steps in the chain to execute them in different places. In each chained function call, the first argument, either ref or data, is a function. Running this function allows you to access the data being passed through the chain.

The result returned by each function will be obtained by running the function of the first argument in the subsequent function. You have the flexibility to decide whether to pass a reference to the object or a copied version of the object to meet the needs of functional programming.

You can use async functions to handle asynchronous data. If async functions are used, both the ref/data function at each step and the final result must be awaited for their values. This is an important point to note.

It's recommended to encapsulate each intermediate processing function into a separate toolkit so that they can be conveniently invoked by their function names, making the chaining process clear and readable. By reading the function names, we can easily understand what our code is doing.

This library itself does not provide such toolkits. I find metaprogramming interesting because each small tool's implementation is quite simple. Instead of pre-packaging them, you should write them directly for each project, as there's a memory cost associated with pre-packaged tools.

In fact, there's a philosophy that suggests remembering only the fundamental knowledge of raw JavaScript itself and forgetting about any complex or lengthy usage patterns of tools. The reason being that you can manually write and combine every "meta-component" on the spot. Even the implementation of this tool itself isn't complicated, so writing it out manually is also an easy task.


这是一个能够帮助我们链式处理数据的工具，我们可以创建一个数据集，然后链式的处理它，每次处理都会返回一个函数用于下一次的处理，直到遇到了结束函数pipeLib.end或者传入0,最终会返回处理的数据集
你可以手动存储链式步骤，用于在不同的地方执行。
每次传入的链式函数的第一个参数ref或data是一个函数，运行这个函数可以获取到链式调用的数据
每个函数返回的结果会被下一个函数的第一个参数的函数运行后取得
你可以自己决定需要传递的值是对对象的引用，还是对对象拷贝的副本，来满足函数式编程的需要、
你可以使用async函数处理异步数据，如果使用了async函数，那么每一次取得的ref或data函数都需要await来取值，最终的结果也需要await来取值，这是需要注意的地方

推荐您将每次处理的中间函数单独封装成一个工具集，以便每次都可以使用函数名来使用它，这样可以使得链式处理的流程变得清晰易读，我们通过阅读函数名就很容易得知我们的代码正在做什么
这个库本身不提供工具集，我认为元编程是有趣的，因为每一个小工具的实现都很简单，你应该在每个项目使用的时候直接编写它，而不是把进行封装。因为封装有记忆成本
实际上，有一个理念是，只需要记忆最原始的js本身的知识，而忘记任何工具复杂冗长的使用方式，因为你可以每次手动编写和组合每一个“元组件”，包括这个工具本身的实现也并不复杂，现场手写也是一件容易得事情