/* Script appelé par cron */

rURL = require('../retrieveFromWeb/retrieveURL');
rFL = require('../retrieveFromWeb/retrieveFeedLinks');
rURL.getRandomWord(function(word){
    rURL.getSearchResult(word, function(label, searchResult, search_engine){
        rURL.processSearchResults(label, searchResult, search_engine, function(URL){
            if(URL) {
                rFL.getFeedLinks(URL, function(feed) {
                    console.log(feed);
                });
            }
        });
    });
})


