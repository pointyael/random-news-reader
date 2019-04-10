/* Script appelé par cron */

rURL = require('../retrieveFromWeb/retrieveURL');
rFL = require('../retrieveFromWeb/retrieveFeedLinks');
feedModel = require('../models/feedModel');
itemModel = require('../models/itemModel');

/* rURL.getRandomWord()
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
            for (let i = 0; i < feedURL.length; i++) {
                feedModel.insertFeed(feedURL[i]).then(function() {
                    itemModel.insertItems(feedURL[i]);
                });
            }
        } else {
            console.log('PAS DE FLUX');
        }
    })
    .catch(err => {
        console.log(err);
    }); */

itemModel.insertItems('https://syndication.lesechos.fr/rss/rss_idee.xml');

