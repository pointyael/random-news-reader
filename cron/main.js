/* Script appelé par cron */

rURL = require('../retrieveFromWeb/retrieveURL');
rFL = require('../retrieveFromWeb/retrieveFeedLinks');
feedModel = require('../models/feedModel');

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
        if (feedURL != '' && typeof feedURL != undefined) {
            console.log('FLUX TROUVE : ', feedURL);
            feedModel.insertFeed(feedURL);
        } else {
            console.log('PAS DE FLUX');
        }
    })
    .catch(err => {
        console.log(err);
    });

