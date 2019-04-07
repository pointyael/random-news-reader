const Parser = require('rss-parser');
const RSSParser = new Parser({
  customFields: {
    item: [
      ['image', 'image'],
      ['media:content', 'media:content']
    ]
  }
});

const moment = require('moment');
const itemParser = require('./itemParser.js');

/* use an URL to return parsed object containing feed infos and items */
async function _retrieveFeedData(link) {
    let parsedFeed = await RSSParser.parseURL(link);
    return parsedFeed;
}

async function _processFeedInfo(parsedFeed){
    let feedSchema = Object();
    parsedFeed.title = parsedFeed.title.replace(/'/g, "''");
    feedSchema = {
        //id: parsedFeed.id,
        title: parsedFeed.title,
        link: parsedFeed.link
    };
    return feedSchema;
}


async function _processItems(parsedFeed){
    let itemArray = [];
    let itemSchema = Object();
    let dateMinusTwoDays = moment().add(-2, 'days').format("YYYY-MM-DD HH:mm:ss");

    parsedFeed.items.forEach(item => {

        itemSchema = parseItem(item);

        if (
          moment(itemSchema.pubDate).format("YYYY-MM-DD HH:mm:ss")
          > dateMinusTwoDays
        )
          itemArray.push(itemSchema);
    });

    return itemArray;
}

function parseItem(item) {
  return itemParser.aItem(item);
}

async function getItems(link) {
    parsedFeed = await _retrieveFeedData(link);
    return await _processItems(parsedFeed);
}

async function getFeedData(link) {
    parsedFeed = await _retrieveFeedData(link);
    processedInfo = await _processFeedInfo(parsedFeed);
    return processedInfo;
}

module.exports = {
    getItems,
    getFeedData,
    parseItem
}
