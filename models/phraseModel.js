var pgp = require("pg-promise")();
var db = pgp("postgres://postgres:md5244af1e2823d5eaeeffc42c5096d8260@localhost:5432/randomizer");

/* Query button phrase from data base */
const getButtonPhrase = (request, response) => {
    db.any("SELECT * FROM button ORDER BY RANDOM() LIMIT 1")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

module.exports = {
    getButtonPhrase
}