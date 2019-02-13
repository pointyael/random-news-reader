var express = require('express');
const db = require('../models/itemModel');
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
router.get('/random-items', db.getRandomItems);

/* GET API random items. */
router.get('/insert', db.insertItems);

module.exports = router;
