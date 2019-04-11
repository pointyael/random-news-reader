const fs = require('fs');
const se_scraper = require('se-scraper'); 
const wordModel = require('../models/wordModel');
var request = require('request');

var searchEngines = ['google', 'bing', 'baidu'];

function getSearchResult(word){
    return new Promise(function(resolve, reject){
        let label = word.mot_lib;
            let config = {
                search_engine: searchEngines[Math.floor(Math.random() * searchEngines.length)],
                debug: false,
                verbose: false,
                keywords: [label],
                num_pages: 20,
            };

            console.log('--------- RECHERCHE -----------');
            console.log('Mot : ', label);

            console.log(config.search_engine)
            se_scraper.scrape(config, function(err, response) {
                if (err) {
                    reject(err);
                }
                let searchResult = response.results
                resolve(searchResult, config.search_engine);
            });
        });
}

function processSearchResults(searchResult) {

    return new Promise(function(resolve, reject){

        console.log("---- process -----");
        searchResult = searchResult[Object.keys(searchResult)[0]] // Get first property

        console.log(searchResult);

        let randomURL;
        let randomPageNumber = Math.floor(Math.random() * Object.keys(searchResult).length);
        var randomResultNumber;
        let randomSearchPage = searchResult[Object.keys(searchResult)[randomPageNumber]];
        let randomSearchResult;

        console.log('Numéro de page : ' + randomPageNumber);
        console.log('Page selectionnée : ');
        console.log(randomSearchPage);
        if(typeof randomSearchPage.results != 'undefined' && randomSearchPage.results.length > 0) {
            randomResultNumber = Math.floor(Math.random() * Object.keys(randomSearchPage.results).length);
            randomSearchResult = randomSearchPage.results[Object.keys(randomSearchPage.results)[randomResultNumber]];
            console.log('Résultat selectionné : ');
            console.log(randomSearchResult);

            randomURL = randomSearchResult.link;
            console.log('Lien selectionné : ' + randomURL);
            console.log("------ REDIRECTION --------");

            redirectedURL = request.get(randomURL, function (err, res, body) {
                console.log('Lien final: ' +this.uri.href);
                resolve(this.uri.href);
            });
        } else {
            console.log('Pas de résultat');
            resolve(false);
        }
    });
}

module.exports = {
    getSearchResult,
    processSearchResults
}
