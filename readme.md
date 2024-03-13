# Eating Introduction
这是一个能够帮助我们链式处理数据的工具，我们可以创建一个数据集，然后链式的处理它，每次处理都会返回一个函数用于下一次的处理，直到遇到了结束函数pipeLib.end或者传入0,最终会返回处理的数据集
你可以手动存储链式步骤，用于在不同的地方执行。
每次传入的链式函数的第一个参数ref或data是一个函数，运行这个函数可以获取到链式调用的数据
每个函数返回的结果会被下一个函数的第一个参数的函数运行后取得
你可以自己决定需要传递的值是对对象的引用，还是对对象拷贝的副本，来满足函数式编程的需要、
你可以使用async函数处理异步数据，如果使用了async函数，那么每一次取得的ref或data函数都需要await来取值，最终的结果也需要await来取值，这是需要注意的地方

推荐您将每次处理的中间函数单独封装成一个工具集，以便每次都可以使用函数名来使用它，这样可以使得链式处理的流程变得清晰易读，我们通过阅读函数名就很容易得知我们的代码正在做什么
这个库本身不提供工具集，我认为元编程是有趣的，因为每一个小工具的实现都很简单，你应该在每个项目使用的时候直接编写它，而不是把进行封装。因为封装有记忆成本
实际上，有一个理念是，只需要记忆最原始的js本身的知识，而忘记任何工具复杂冗长的使用方式，因为你可以每次手动编写和组合每一个“元组件”，包括这个工具本身的实现也并不复杂，现场手写也是一件容易得事情

his is a tool that helps us chain process data. We can create a dataset and then process it in a chained manner, with each step returning a function for the next processing stage until we encounter the end function pipeLib.end or input 0. Ultimately, it will return the processed dataset.

You can manually store the steps in the chain to execute them in different places. In each chained function call, the first argument, either ref or data, is a function. Running this function allows you to access the data being passed through the chain.

The result returned by each function will be obtained by running the function of the first argument in the subsequent function. You have the flexibility to decide whether to pass a reference to the object or a copied version of the object to meet the needs of functional programming.

You can use async functions to handle asynchronous data. If async functions are used, both the ref/data function at each step and the final result must be awaited for their values. This is an important point to note.

It's recommended to encapsulate each intermediate processing function into a separate toolkit so that they can be conveniently invoked by their function names, making the chaining process clear and readable. By reading the function names, we can easily understand what our code is doing.

This library itself does not provide such toolkits. I find metaprogramming interesting because each small tool's implementation is quite simple. Instead of pre-packaging them, you should write them directly for each project, as there's a memory cost associated with pre-packaged tools.

In fact, there's a philosophy that suggests remembering only the fundamental knowledge of raw JavaScript itself and forgetting about any complex or lengthy usage patterns of tools. The reason being that you can manually write and combine every "meta-component" on the spot. Even the implementation of this tool itself isn't complicated, so writing it out manually is also an easy task.
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