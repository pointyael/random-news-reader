let Parser = require('rss-parser');
let parser = new Parser();
let itemsModel = require('../models/itemModel');

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
            datePub: item.datePub,
            link: item.link,
            language: item.language,
            category: item.category
          }
          itemArray.push(itemSchema);
    });
    return itemArray;
}

async function getItemsFromLink(link) {
    parsedFeed = await retrieveItemsFromLink(link);
    return await feedToArray(parsedFeed);
}

async function getFeedInfosFromLink(link) {
    parsedFeed = await retrieveItemsFromLink(link);
    return await getFeedInfo(parsedFeed);
}

module.exports = {
    retrieveItemsFromLink,
    feedToArray,
    getFeedInfo,
    getItemsFromLink,
    getFeedInfosFromLink
}

itemsModel.insertItems();
