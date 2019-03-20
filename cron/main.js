/* Script appelé par cron */

rURL = require('../retrieveFromWeb/retrieveURL');
rFL = require('../retrieveFromWeb/retrieveFeedLinks');
rURL.getRandomWord(function(word){
    rURL.getRandomURL(word, function(randomURL){
        rFL.getFeedLinks(randomURL, function(feed) {
            console.log(feed);
        })
    });
})