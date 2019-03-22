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
router.get('/random-items',
  async function(req, res, next)
  {
    Item.getRandomItems(req, res);
  }
);

/* GET API random Items not like parameter. */
router.get('/random-items/:notLike', Item.getRandomItemsNotLike);

/* GET API all items ==> ONLY FOR TEST */
router.get('/random', Item.getAllItems);

/* GET API random items. */
router.get('/insert',
  async function(req, res, next)
  {
    await Item.deleteOldItems();
    await Item.insertItems(req, res);
    res.end();
  }
);

/* GET API button quote. */
router.get('/random-btnQuote', Quote.getButtonQuote);

/* GET API quote. */
router.get('/random-quote', Quote.getQuote);

module.exports = router;
