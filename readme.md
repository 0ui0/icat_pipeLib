# Basic Useage

```
let pipeLib = require("icat_pipelib")

let newArr = function() {
  return [];
};

let push = function(...args) {
  this.push(...args);
  return this;
};

console.log(pipeLib.start(newArr)()(push)(3)(pipeLib.print)()(push)(4)(pipeLib.end));
//[3]
//[3,4]
```

you can create middleware by yourself like:

```
let output = pipeLib.start(function(){return new Object()})()
  (function(){
    this.a = 12
    return this
  })()
  (function(){
    this.b = 15
    return this
  })()
  (function(){
    return this.a + this.b
  })()
  (pipeLib.end)
console.log(output) //27
```