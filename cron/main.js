/* Script appelé par cron */

rURL = require('../retrieveFromWeb/retrieveURL');
rFL = require('../retrieveFromWeb/retrieveFeedLinks');
rURL.getRandomWord(function(word){
    rURL.getSearchResult(word, function(searchResult){
        rURL.processSearchResults(searchResult, function(URL){
            if(URL) {
                rFL.getFeedLinks(URL, function(feed) {
                    console.log(feed);
                });
            }
        });
    });
})


