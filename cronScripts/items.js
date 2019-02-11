let Parser = require('rss-parser');
let parser = new Parser();

async function retrieveItemsFromLink(link) {
    let parsedFeed = parser.parseURL(link);
    return parsedFeed;
}

async function getFeedInfo(feed){
    let feedSchema = Object();
    feedSchema = {
        title: feed.title,
        link: feed.link
    }
    return feedSchema;
}

async function feedToArray(feed){
    let itemArray = [];
    let itemSchema = Object();
    feed.items.forEach(item => {
        itemSchema = {
            title: item.title,
            description: item.description,
            type: item.type,
            datePub: item.datePub,
            link: item.link,
            language: item.language,
            category: item.category
          }
          itemArray.push(itemSchema);
    });
    return itemArray;
}

async function getItemFromLink(link) {
    parsedFeed = retrieveItemsFromLink(link);
    return feedToArray(parsedFeed);
}

async function getFeedInfosFromLink(link) {
    parsedFeed = retrieveItemsFromLink(link);
    return getFeedInfo(parsedFeed);
}

module.exports = {
    retrieveItemsFromLink,
    feedToArray,
    getFeedInfo,
    getItemFromLink,
    getFeedInfosFromLink
}