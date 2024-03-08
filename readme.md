# Basic Useage

```
let pipeLib = require("icat_pipeLib")
let push = pipeLib.mid(Array.prototype.push)
let output = pipeLib.start([])(push)(3)(push)(4)(pipeLib.end)
console.log(output)
```

you can create middleware by yourself like:

```
let pop = function(){
  this.pop()
  return this
}

pipeLib.start([])(push)(3)(push)(4,5,6)(pop)()(pipeLib.end)

```