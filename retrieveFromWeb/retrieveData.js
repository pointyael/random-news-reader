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
  return new Promise( async (resolve, reject) => {
    let parsedFeed = await RSSParser.parseURL(link);
    if(parsedFeed)
      resolve(parsedFeed);
    reject();
  })
}

function _processFeedInfo(parsedFeed){
    let feedSchema = Object();
    parsedFeed.title = parsedFeed.title.replace(/'/g, "''");
    feedSchema = {
        //id: parsedFeed.id,
        title: parsedFeed.title,
        link: parsedFeed.link
    };
    return feedSchema;
}


function _processItems(parsedFeed){
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
  return new Promise( async (resolve, reject) => {
    if( (parsedFeed = await _retrieveFeedData(link)) )
      if( (parsedItems = _processItems(parsedFeed)) )
        resolve(parsedItems);

    reject();
  });
}

async function getFeedData(link) {
  return new Promise( async (resolve, reject) => {
    if( parsedFeed = await _retrieveFeedData(link) )
      if( (processedInfo = await _processFeedInfo(parsedFeed)) )
        resolve(processedInfo);

    reject();
  });
}

module.exports = {
    getItems,
    getFeedData,
    parseItem
}
