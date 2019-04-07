/* Script appelé par cron */

rURL = require('../retrieveFromWeb/retrieveURL');
rFL = require('../retrieveFromWeb/retrieveFeedLinks');

rURL.getRandomWord()
    .then(word => {
        return rURL.getSearchResult(word);
    })
    .then(searchResult => {
        return rURL.processSearchResults(searchResult);
    })
    .then(URL => {
        if(URL) {
            return rFL.getFeedLinks(URL);
        }
    })
    .then(feedURL => {
        console.log(feedURL)
    })
    .catch(err => {
        console.log(err);
    });

