var db = require("../database/dbFactory").db;

const getFilters = (request, reponse) => {
  return new Promise( (resolve, reject) => {
    db
    .any("SELECT * FROM (select DISTINCT * from filtrelocalise WHERE fll_language=16 and fll_filtre < 6) filtre ORDER BY RANDOM() LIMIT 5")
    .then((data) => {
      resolve(data);
    })
    .catch((err) => { reject(err); })
  });
}

const getRandomFilters = (request, reponse) => {
  return new Promise( (resolve, reject) => {
    db
    .any('SELECT "getRandomFilterWords"()')
    .then((data) => {
      resolve(data[0].getRandomFilterWords);
    })
    .catch((err) => { reject(err); });
  });
}

module.exports = {
  getFilters,
  getRandomFilters
}
