/*
Switch .babelrc to the following for testing against ES6

{
  "presets": [[
    "@babel/preset-env",
    {
      "targets_": {"node": "7"}
    }
  ]]
}
*/

var warmup = true;

class HelloWorld {
  constructor() {
    this.data = 0
  }
  inc() {
    this.data += 1
  }
}

class HelloWorldNoMethods {
  constructor() {
    this.data = 0
  }
}
function incHelloWorld(o) {
  o.data += 1;
}

function HelloWorldClosure() {
  var self = {data: 0};

  return {
    inc: function() {
      self.data += 1;
    },
    data: function() {
      return self.data;
    }
  }
}

// warmup
if (warmup) {
  (function() {
    let o = new HelloWorld();
    console.time("Warmup");
    for (var i=0; i<1000000; i++) {
      o.inc()
    }
    console.timeEnd("Warmup");
  })();
}

let N = 100000000;

(function() {
  let o = new HelloWorld();
  console.time("Inc (class)");
  for (var i=0; i<N; i++) {
    o.inc()
  }
  console.timeEnd("Inc (class)");
  console.assert(o.data == N);
})();

(function() {
  let o = new HelloWorldNoMethods();
  console.time("Inc (func)");
  for (var i=0; i<N; i++) {
    incHelloWorld(o);
  }
  console.timeEnd("Inc (func)");
  console.assert(o.data == N);
})();

(function() {
  let o = new HelloWorldClosure();
  console.time("Inc (closure)");
  for (var i=0; i<N; i++) {
    o.inc();
  }
  console.timeEnd("Inc (closure)");
  console.assert(o.data() == N);
})();

