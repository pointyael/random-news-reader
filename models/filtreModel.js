var db = require("../database/dbFactory").db;

const getFilters = (request, reponse) => {
    db
    .any("SELECT * FROM (select DISTINCT * from filtrelocalise WHERE fll_language=16 and fll_filtre < 6) filtre ORDER BY RANDOM() LIMIT 5")
    .then((data) => {
      reponse.status(200).json(data)
    })
    .catch((err) => { console.log(err); })
}

const getRandomFilters = (request, reponse) => {
  db
  .any('SELECT "getRandomFilterWords"()')
  .then((data) => {
    reponse.status(200).json(data[0].getRandomFilterWords);
  })
  .catch((err) => { console.log(err); });
}

module.exports = {
  getFilters,
  getRandomFilters
}
