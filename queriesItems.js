var pgp = require("pg-promise")();
var db = pgp("postgres://postgres:md5244af1e2823d5eaeeffc42c5096d8260@localhost:5432/randomizer");

/* Query items from data base */
const getAllItems = (request, response) => {
    db.any("SELECT * FROM item")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

/* Query 12 random items from data base */
const getRandomItems = (request, response) => {
    db.any("SELECT * FROM item ORDER BY RANDOM() LIMIT 12")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

module.exports = {
    getAllItems,
    getRandomItems
}
