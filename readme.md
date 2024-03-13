# Eating Introduction
```javascript
  // basic useage
  // one
  var obj1, opr1, opr2, output1, output2, output3, pipeLib;
  pipeLib = require("icat_pipelib")
  pipeLib.start(() => {
    return [1, 2, 3, 4, 5];
  })().to((data) => {
    data = data();
    data.push("hello");
    return data;
  })().to((data) => {
    data = data();
    data.shift();
    return data;
  })().to(pipeLib.print)().to(pipeLib.end)();

  //two
  obj1 = pipeLib.start({
    a: 12,
    b: 5
  })();

  opr1 = obj1.to((ref) => {
    var data;
    data = ref(); //ref() -> object {a:12,b5} is reference
    data.c = 20;
    return data;
  })();

  opr2 = obj1.to((ref) => {
    var data;
    data = ref();
    data.d = "hello";
    return data;
  })();

  output1 = opr1.to(pipeLib.print)().to(0)();

  output2 = opr2.to(pipeLib.print)().to(pipeLib.end)();

  output3 = obj1.to(pipeLib.print)().to(0)();

  console.log(output1 === output3); //true

  (async function() {  
    //async useage
    await pipeLib.start({
      data: null
    })().to(async(ref) => {
      var data;
      data = ref();
      data.data = (await new Promise((res) => {
        return setTimeout(() => {
          return res("async data");
        }, 1000);
      }));
      return data;
    })().to(async(ref) => {
      var data;
      data = (await ref());
      console.log(data);
      return data;
    })().to(0)();
    return console.log(222);
  })();
```