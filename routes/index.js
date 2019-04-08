var express = require('express');
const itemDB = require('../models/itemModel');
const quoteDB = require('../models/quoteModel');
const filtreDB = require('../models/filtreModel');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index.html', { title: 'Express' });
});

/* GET about page. */
router.get('/about', function(req, res, next) {
  res.render('about', { title: 'À propos' });
});

/* GET API random items. */
router.get('/random-items', itemDB.getRandomItems);

/* GET API random Items not like parameter. */
router.get('/random-items/:notLike', itemDB.getRandomItemsNotLike);

/* GET API insertItems method. */
router.get('/insertItems', itemDB.insertItems);

/* GET API button quote. */
router.get('/random-btnQuote', quoteDB.getButtonQuote);

/* GET API quote. */
router.get('/random-quote', quoteDB.getQuote);

/* GET API quote. */
router.get('/random-defaultfilter', filtreDB.getFilters);

/* GET API quote. */
router.get('/random-filter', filtreDB.getRandomFilters);


module.exports = router;
