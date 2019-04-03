const fs = require('fs');
const se_scraper = require('se-scraper');
var pgp = require("pg-promise")();
var db = pgp("postgres://postgres:md5244af1e2823d5eaeeffc42c5096d8260@localhost:5432/randomizer");

var searchEngines = ['google', 'bing', 'baidu', 'webcrawler'];

getRandomURL();

function getRandomURL() {
    db.one("SELECT mot_lib FROM mot ORDER BY RANDOM() LIMIT 1").then(function (word) {
        console.log(word.mot_lib);
        let label = word.mot_lib;
        let config = {
            search_engine: searchEngines[Math.floor(Math.random() * searchEngines.length) - 1],
            debug: false,
            verbose: false,
            keywords: [label],
            num_pages: 20,
            output_file: 'data.json',
        };
    
        se_scraper.scrape(config, function callback(err, response) {
            if (err) {
                console.error(err)
            }
            console.dir(response, {depth: null, colors: true});
            fs.readFile('data.json', function(err, data) {
                let searchResult = JSON.parse(data);
                console.log(searchResult);
                if (config.search_engine == 'google' || config.search_engine == 'bing') {
                    let randomNumber = Math.floor(Math.random() * Object.keys(searchResult.label).length + 1);
                    let randomString = String(randomNumber);
                    let randomSearchResult = searchResult.label[randomString];
                    randomNumber = Math.floor(Math.random() * Object.keys(searchResult.label).length + 1);
                    randomString = String(randomNumber);
                    let randomURL = randomSearchResult.results[randomString].link;
                    return randomURL;
                }
            });
        });
    }).catch(function (error) {
        console.log("ERROR:", error);
    });
}

module.exports = {
    getRandomURL
}