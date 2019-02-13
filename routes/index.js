var express = require('express');
const db = require('../models/itemModel');
const phraseDB = require('../models/phraseModel');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index.html', { title: 'Express' });
});

/* GET about page. */
router.get('/about', function(req, res, next) {
  res.render('about', { title: 'À propos' });
});

/* GET API all items. */
router.get('/all-items', db.getAllItems);

/* GET API random items. */
router.get('/random-items', db.getRandomItems);

/* GET API button phrase. */
router.get('/random-phrase', phraseDB.getButtonPhrase);

module.exports = router;
