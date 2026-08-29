# 直接将 pipeLib 声明为主力组装函数
pipeLib = (fn, prevTask = (->), layerIndex = 1) ->
  if fn is 0
    return (runArgs...) -> prevTask(runArgs...)

  if fn?.endSign is 1
    return fn(@, prevTask, layerIndex)

  return (buildArgs...) ->
    currentTask = (runArgs...) ->
      ref = -> prevTask(runArgs...)
      try
        # 核心：透传三元组参数
        return fn(ref, buildArgs, runArgs)
      catch err
        if not err.pipeLayer?
          fnName = fn.name or "Anonymous Function"
          err.pipeLayer = layerIndex
          err.message = "[Pipeline Layer #{layerIndex} <#{fnName}> Error] -> " + err.message
        throw err

    return {
      # 递归调用 pipeLib 本身
      to: (nextFn) -> pipeLib(nextFn, currentTask, layerIndex + 1)
      _:  (nextFn) -> pipeLib(nextFn, currentTask, layerIndex + 1)
    }



pipeLib.use = (ref, buildArgs, runArgs) =>
  [subPipelineExecutor] = buildArgs
  upperData = ref()
  if upperData? and typeof upperData.then is 'function'
    return upperData.then (resolvedData) => subPipelineExecutor(resolvedData)
  return subPipelineExecutor(upperData)

pipeLib.print = (ref, buildArgs, runArgs) =>
  result = ref() # 严格单次决议
  prefix = buildArgs[0]

  if result? and typeof result.then is 'function'
    return result.then (resolvedData) =>
      if prefix then console.log(prefix, resolvedData) else console.log(resolvedData)
      return resolvedData

  if prefix then console.log(prefix, result) else console.log(result)
  return result

pipeLib.end = (ctx, prevTask, layerIndex) =>
  return (runArgs...) => prevTask(runArgs...)
pipeLib.end.endSign = 1

# 辅助算子：用于直接注入一个静态数据作为管道源头
pipeLib.value = (ref, buildArgs, runArgs) => buildArgs[0]










module.exports = pipeLib



