const express = require('express');
const path = require('path');
const fs = require('fs');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.urlencoded({extended: false}));
app.use(bodyParser.json());

app.use(cors({
  'origin': '*',
  'allowedHeaders': ['Content-Type', 'Accept'],
  'methods': ['GET, POST']
}));

const PORT = 3000;
const FILE = path.join(__dirname, './todos.json');
const TIMEOUT = 200;

const readTodos = () => {
  return new Promise((resolve, reject) => {
    fs.readFile(FILE, 'utf8', (err, todos) => {
      if (err) {
        reject(err);
      }
      else {
        resolve(JSON.parse(todos));
      }
    });
  });
};

const writeTodos = (todos) => {
  return new Promise((resolve, reject) => {
    fs.writeFile(FILE, JSON.stringify(todos), err => {
      if (err) {
        reject(err);
      }
      else {
        resolve(todos);
      }
    });
  });
};

const getTodos = async (req, res, next) => {
  try {
    const todos = await readTodos();
    setTimeout(() => res.json(todos), TIMEOUT);
  }
  catch (err) {
    next(err);
  }
};

const addTodo = async (req, res, next) => {
  const { text } = req.body;
  try {
    if (!text) {
      throw Error('No text provided!');
    }
    let todos = await readTodos();
    let todo = todos.find(todo => todo.text === text);
    if (todo) {
      throw Error('Todo already exists!');
    }
    else {
      todo = { text, id: Date.now(), isDone: false };
      todos.push(todo);
      await writeTodos(todos);
      setTimeout(() => res.json(todo), TIMEOUT);
    }
  }
  catch (err) {
    next(err);
  }
};

const deleteTodo = async (req, res, next) => {
  const { id } = req.body;
  try {
    let todos = await readTodos();
    let todo = todos.find(todo => todo.id === id);
    if (todo) {
      todos = todos.filter(todo => todo.id !== id);
      await writeTodos(todos);
      setTimeout(() => res.json(todo), TIMEOUT);
    }
    else {
      throw Error('Todo not found!');
    }
  }
  catch (err) {
    next(err);
  }
};

const toggleTodo = async (req, res, next) => {
  const { id, isDone } = req.body;
  try {
    let todos = await readTodos();
    let todo = todos.find(todo => todo.id === id);
    if (todo) {
      todo.isDone = isDone;
      await writeTodos(todos);
      setTimeout(() => res.json(todo), TIMEOUT);
    }
    else {
      throw Error('Todo not found!');
    }
  }
  catch (err) {
    next(err);
  }
};

const handleError = (err, req, res, next) => {
  // console.error(err);
  res.status(500).json({ error: err.message });
};

app.get('/', getTodos);
app.post('/add', addTodo);
app.post('/delete', deleteTodo);
app.post('/toggle', toggleTodo);
app.use(handleError);

app.listen(PORT, () => console.log(`App listening on port ${PORT}!`));
