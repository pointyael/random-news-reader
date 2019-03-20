const fs = require('fs');
const se_scraper = require('se-scraper');
var pgp = require("pg-promise")();
var db = pgp("postgres://postgres:md5244af1e2823d5eaeeffc42c5096d8260@localhost:5432/randomizer");

var searchEngines = ['google', 'bing', 'baidu', 'webcrawler'];

function getRandomWord(callback) {
    db.one('SELECT * FROM  (SELECT DISTINCT 1 + trunc(random() * 31434241)::integer AS mot_id FROM generate_series(1,1) g) r JOIN   mot USING (mot_id) LIMIT  1;').then(function (word) {
        callback(word);
    }).catch(function (error) {
        console.log("ERROR:", error);
    });
}

function getRandomURL(word, callback) {
        let label = word.mot_lib;
        let config = {
            search_engine: searchEngines[Math.floor(Math.random() * searchEngines.length)],
            debug: false,
            verbose: false,
            keywords: [label],
            num_pages: 20,
            output_file: 'data.json',
        };
        
        console.log(config.search_engine)
        se_scraper.scrape(config, function(err, response) {
            if (err) {
                console.error(err)
            }
            //console.dir(response, {depth: null, colors: true});
            fs.readFile('data.json', function(err, data) {
                let searchResult = JSON.parse(data);
                console.log(searchResult);
                if (searchResult[label]['1'].results.length != 0) {
                    let randomNumber = Math.floor(Math.random() * Object.keys(searchResult[label]).length + 1);
                    let randomString = String(randomNumber);
                    let randomSearchResult = searchResult[label][randomString];
                    randomNumber = Math.floor(Math.random() * Object.keys(searchResult[label]).length + 1);
                    console.log(randomSearchResult.results);
                    let randomURL;
                    if(typeof randomSearchResult.results[randomString] == 'undefined') {
                        randomURL = randomSearchResult.results[randomNumber].link
                    } else if(typeof randomSearchResult.results[randomNumber] == 'undefined') {
                        randomURL = randomSearchResult[randomNumber].link;
                    } else {
                        randomURL = randomSearchResult.results[randomString].link
                    }
                    callback(randomURL);
                } else {
                    getRandomURL();
                }
            });
        });
}

module.exports = {
    getRandomURL,
    getRandomWord
}