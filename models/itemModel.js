var db = require("../database/dbFactory").db;
var ItemsRetrieved = require("../retrieveFromWeb/retrieveData.js");
var FeedModel = require("./feedModel");

/* Query all items from db => only for test */
const getAllItems = () =>
{
  return new Promise(function(resolve, reject){
    db
    .any("SELECT * from item")
    .then( function(data) { resolve(data); })
    .catch(function (error) { reject(error) });
  });
}

/* Query 12 random items from data base */
const getRandomItems = (lang) => {
  return new Promise((resolve, reject) => {
    db.any('SELECT "getRandomItems"(' + lang + ')')
    .then(function (data) { resolve(data[0].getRandomItems); })
    .catch(function (error) { reject(error); });
  });
}

/* Query 12 random items from data base */
const getRandomItemsNotLike = (notLike, lang) => {
  return new Promise( (resolve, reject) => {
    db.any(
      'SELECT "getRandomItemsNotLike"( ARRAY['
      + splitRequestParamters(notLike)
      +'], '
      + lang
      +')'
    )
    .then(function (data) { resolve(data[0].getRandomItemsNotLike); })
    .catch(function (error) { reject (error); });
  });
}

/* Insert items in data base */
const insertItems = (feed) => {
  return new Promise(function(resolve, reject) {
    deleteOldItems();

    db
    .any("SELECT * FROM source WHERE sou_link = '" + feed + "' LIMIT 1")
    .then(async function(source) {
      source = source[0];
      var res = await ItemsRetrieved.getItems(source.sou_link),
      [feedString, itemsString] = parseAsParameters(source, res);
      await db.any("CALL \"insertNewItems\"("+ feedString +", '"+ itemsString +"')");
      resolve();

    }).catch(function(error) { reject(error); });
  })
}

/* Insert items in data base */
const insertItemsAllSources  = (feed) => {
  return new Promise(function(resolve, reject) {
    deleteOldItems();

    db
    .any("SELECT * FROM source")
    .then(async function(source) {
      source.forEach(async (s) => {
        ItemsRetrieved.getItems(s .sou_link)
        .then(async (items) => {
          [feedString, itemsString] = parseAsParameters(s , items);
          await db.any("CALL \"insertNewItems\"("+ feedString +", '"+ itemsString +"')");
        })
        .catch((err) => {});
      });
      resolve();

    }).catch(function(error) { reject(error); });
  })
}

const deleteOldItems = function() {
  return new Promise((resolve, reject) => {
    db
    .any('CALL "deleteOldItemsProc"()')
    .then( function() { resolve(); })
    .catch(function(err) {console.log(err); reject(err); } );
  });
}

const splitRequestParamters = (params) => {
  var notLike = "";
  params
  .split("+")
  .forEach( (param) => {
      if(param.length > 1)
      notLike += "'" + param + "',"
  });

  notLike = notLike.substring(0, notLike.length - 1);

  return notLike;
}

const parseAsParameters = (source, items) => {
  feedInfo = {
      id: source.sou_id,
      link: source.sou_link
  }

  feedInfoStringified = "'" + JSON.stringify(feedInfo).replace( /'/, "''") + "'::json";
  itemsStringified = (JSON.stringify(items));

  return [feedInfoStringified, itemsStringified];
}

module.exports = {
    getAllItems,
    getRandomItems,
    getRandomItemsNotLike,
    insertItems,
    insertItemsAllSources,
    deleteOldItems
}
