# Basic Useage

```javascript
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

```javascript
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

# magic useage
index.html
```html
<html>
  <body>
    <div id="main"></div>
    <button id="btn1">click me</button>
    <button id="btn2">click me</button>
    <button id="btn3">click me</button>
    <script src="./run.js">
  </body>
</html>
```
run.js
```javascript
lib = pipeLib //use webpack or vite import pipeLib
Count = { //a data sets tools
  init(){return {count:0}}
  add(num){
    this.count += num
    return this
  }
  render(){
    document.querySelector("#main").innerHTML = this.count
    return this
  }
}
count = lib.start(Count.init)()

document.querySelector("#btn1").onclick = ()=>{
  count(Count.add)(1)(Count.render)()
}
document.querySelector("#btn2").onclick = ()=>{
  count(Count.add)(2)(Count.render)()
}
document.querySelector("#btn3").onclick = ()=>{
  console.log(count(lib.end))
}

```