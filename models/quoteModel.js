var db = require("../database/dbFactory").db;

/* Query button quote from data base */
const getButtonQuote = (request, response) => {
    db.any("SELECT * FROM buttonquote ORDER BY RANDOM() LIMIT 1")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

/* Query quote from data base */
const getQuote = (request, response) => {
    db.any("SELECT * FROM sidebarquote ORDER BY RANDOM() LIMIT 1")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}
module.exports = {
    getButtonQuote,
    getQuote
}
