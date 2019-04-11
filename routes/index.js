var express = require('express');
const itemDB = require('../models/itemModel');
const quoteDB = require('../models/quoteModel');
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
router.get('/random-items', function(req, res, next) {
  itemDB.getRandomItems()
  .then(function(data){
    res.status(200).json(data);
  })
  .catch(function(err){
    console.log(err);
  });
});

/* GET API random items. */
router.get('/random-items/:notLike', function(req, res, next) {
  itemDB.getRandomItemsNotLike(req)
  .then(function(data){
    res.status(200).json(data);
  })
  .catch(function(err){
    console.log(err);
  });
});

/* GET API insertItems method. */
router.get('/insertItems', itemDB.insertItems);

/* GET API button quote. */
router.get('/random-btnQuote', function(req, res, next){
  quoteDB.getButtonQuote()
  .then(function(data) {
    res.status(200).json(data);
  })
  .catch(function(err) {
    console.log(err);
  })
});

/* GET API quote. */
router.get('/random-quote', function(req, res, next) {
  quoteDB.getQuote()
  .then(function(data) {
    res.status(200).json(data);
  })
  .catch(function(err) {
    console.log(err);
  })
});

module.exports = router;
