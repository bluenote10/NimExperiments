console.log("test")
console.log("test3")

import S from 's-js';
import * as Surplus from 'surplus';
import SArray from 's-array';
import data from 'surplus-mixin-data';

const
    Todo = t => ({               // our Todo constructor
       title: S.data(t.title),   // properties are S data signals
       done: S.data(t.done)
    }),
    todos = SArray([]),          // our todos, using SArray
    newTitle = S.data(""),       // title for new todos
    addTodo = () => {            // push new title onto list
       todos.push(Todo({ title: newTitle(), done: false }));
       newTitle("");             // clear new title
    };

const view =                     // declarative main view
    <div>
        <h2>Minimalist ToDos in Surplus</h2>
        <input type="text" fn={data(newTitle)}/>
        <a onClick={addTodo}> + </a>
        {todos.map(todo =>       // insert todo views
            <div>
                <input type="checkbox" fn={data(todo.done)}/>
                <input type="text" fn={data(todo.title)}/>
                <a onClick={() => todos.remove(todo)}>&times;</a>
            </div>
        )}
    </div>;

document.body.appendChild(view); // add view to document


//import { compiler } from 'surplus/compiler';
var compiler = require('surplus/compiler')
console.log(compiler);

let jsx = `
 <div>
        <h2>Minimalist ToDos in Surplus</h2>
        <input type="text" fn={data(newTitle)}/>
        <a onClick={addTodo}> + </a>
        {todos.map(todo =>       // insert todo views
            <div>
                <input type="checkbox" fn={data(todo.done)}/>
                <input type="text" fn={data(todo.title)}/>
                <a onClick={() => todos.remove(todo)}>&times;</a>
            </div>
        )}
    </div>`;

// simple string -> string translation, no sourcemap
const out = compiler.compile(jsx);

// w/ appended sourcemap
//const out = compiler.compile(jsx, { sourcemap: 'append' });

// w/ extracted sourcemap
// note that output is different, to return map and src
//const { out, map } = compiler.compile(in, { sourcemap: 'extract' });

console.log(out)