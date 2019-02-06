var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var cons = require('consolidate');

var indexRouter = require('./routes/index');
var app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

// View engine setup (HTML)
app.engine('html', cons.swig)
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'html');

app.use('/', indexRouter);

/* API for JSON results from queries */
const db = require('./queriesItems');
app.get('/all-items', db.getAllItems);
app.get('/random-items', db.getRandomItems);

module.exports = app;
