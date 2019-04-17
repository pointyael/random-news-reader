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
    RSSParser.parseURL(link)
    .then((feed) => {
      parsedFeed = feed;
      resolve(parsedFeed);
    })
    .catch((err) => reject(err));
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
          itemSchema.pubDate != "Invalid date" &&
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
    _retrieveFeedData(link)
    .then((res) => {
      if( (parsedItems = _processItems(parsedFeed)) )
        resolve(parsedItems);
    })
    .catch((err) => { reject(err); });
  });
}

async function getFeedData(link) {
  return new Promise( async (resolve, reject) => {
    _retrieveFeedData(link)
    .then((res) => {
      if( (processedInfo = _processFeedInfo(parsedFeed)) )
        resolve(processedInfo);
    })
    .catch((err) => reject(err));
  });
}

module.exports = {
    getItems,
    getFeedData,
    parseItem
}
