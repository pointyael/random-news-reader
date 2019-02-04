var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/about', function(req, res, next) {
  //res.render('about', { title: 'À propos' });
  res.send('Hello World!');
});

module.exports = router;