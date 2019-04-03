const fs = require('fs');
const se_scraper = require('se-scraper');
var pgp = require("pg-promise")();
var db = pgp("postgres://postgres:md5244af1e2823d5eaeeffc42c5096d8260@localhost:5432/randomizer");
var request = require('request');

var searchEngines = ['google', 'bing', 'baidu', 'webcrawler'];

function getRandomWord(callback) {
    db.one('SELECT * FROM  (SELECT DISTINCT 1 + trunc(random() * 31434241)::integer AS mot_id FROM generate_series(1,1) g) r JOIN   mot USING (mot_id) LIMIT  1;').then(function (word) {
        callback(word);
    }).catch(function (error) {
        console.log("ERROR:", error);
    });
}

function getSearchResult(word, callback){
    let label = word.mot_lib;
        let config = {
            //search_engine: 'baidu',
            search_engine: searchEngines[Math.floor(Math.random() * searchEngines.length)],
            debug: false,
            verbose: false,
            keywords: [label],
            num_pages: 20,
        };

        console.log(config.search_engine)
        se_scraper.scrape(config, function(err, response) {
            if (err) {
                console.error(err)
            }
            let searchResult = response.results
            console.log(searchResult);
            callback(label, searchResult, config.search_engine);
        });
}

function processSearchResults(label, searchResult, search_engine, callback) {

    console.log("---- process -----");
    console.log(searchResult);

    let randomURL;
    let code;

    let randomNumber = Math.floor(Math.random() * Object.keys(searchResult[label]).length + 1);
    let randomString = String(randomNumber);
    let randomSearchResult = searchResult[label][randomString];
    randomNumber = Math.floor(Math.random() * Object.keys(searchResult[label]).length + 1);

    console.log("--------------")
    console.log(randomSearchResult.results[1]);

    if(!(typeof randomSearchResult.results[randomString] == 'undefined')) {
        randomURL = randomSearchResult.results[randomString].link;
        console.log(1);
    } else if(!(typeof randomSearchResult.results[randomNumber] == 'undefined')) {
        randomURL = randomSearchResult.results[randomNumber].link;
        console.log(2);
    } else {
        console.log('Pas de résultat');
        callback(false);
    }

    if (search_engine == 'baidu') {
        redirectedURL = request.get(randomURL, function (err, res, body) {
            console.log(this.uri.href);
            callback(redirectedURL);
        });
    } else {
        callback(randomURL);
    }
}

module.exports = {
    getSearchResult,
    processSearchResults,
    getRandomWord
}