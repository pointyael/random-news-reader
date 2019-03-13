var express = require('express');
const Item = require('../models/itemModel.js');
const Quote = require('../models/quoteModel');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index.html', { title: 'Express' });
});

/* GET about page. */
router.get('/about', function(req, res, next) {
  res.render('about', { title: 'À propos' });
});

/* GET API random Items. */
router.get('/random-items', Item.getRandomItems);

/* GET API random Items not like parameter. */
router.get('/random-items/:notLike', Item.getRandomItemsNotLike);

/* GET API all items ==> ONLY FOR TEST */
router.get('/random', Item.getAllItems);

/* GET API random items. */
router.get('/insert', Item.insertItems);

/* GET API button quote. */
router.get('/random-btnQuote', Quote.getButtonQuote);

/* GET API quote. */
router.get('/random-quote', Quote.getQuote);

module.exports = router;
