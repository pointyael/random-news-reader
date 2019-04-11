var db = require("../database/dbFactory").db;

/* Query button quote from data base */
const getButtonQuote = (request, response) => {
  return new Promise( (resolve, reject) => {
    db.any("SELECT * FROM buttonquote ORDER BY RANDOM() LIMIT 1")
    .then(function (data) { resolve(data[0]); })
    .catch(function (error) { reject(error); });
  });
}

/* Query quote from data base */
const getQuote = (request, response) => {
  return new Promise( (resolve, reject) => {
    db.any("SELECT * FROM sidebarquote ORDER BY RANDOM() LIMIT 1")
    .then(function (data) { resolve(data[0]); })
    .catch(function (error) { reject(error); });
  })
}
module.exports = {
    getButtonQuote,
    getQuote
}
