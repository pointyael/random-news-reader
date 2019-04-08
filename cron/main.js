/* Script appelé par cron */

rURL = require('../retrieveFromWeb/retrieveURL');
rFL = require('../retrieveFromWeb/retrieveFeedLinks');
rData = require('../retrieveFromWeb/retrieveData');
feedModel = require('../models/feedModel');
itemModel = require('../models/itemModel');

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
        if (feedURL && feedURL[0]) {
            console.log('FLUX TROUVE : ', feedURL);
            feedURL.forEach(element => {
                feedModel.insertFeed(element).then(()=>{
                    itemModel.insertItems(element)
                }).catch(err => {
                    console.log(err);
                });
            });
        } else {
            console.log('PAS DE FLUX');
        }
    })
    .catch(err => {
        console.log(err);
    });

