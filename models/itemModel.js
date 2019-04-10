var db = require("../database/dbFactory").db;
var ItemsRetrieved = require("../retrieveFromWeb/retrieveData.js");
var FeedModel = require("./feedModel");

let name;
let description;
let type;
let dateInsert;
let language;
let theme;

/* Query all items from db => only for test */
const getAllItems = () =>
{
  return new Promise(function(resolve, reject){
    db
    .any("SELECT * from item")
    .then(
      function(data) { resolve(data); }
    )
    .catch(function (error) { reject(error) });
  });
}

/* Query 12 random items from data base */
const getRandomItems = (request, response) => {
    db.any('SELECT "getRandomItems"()')
    .then(function (data) {
      response.status(200).json(data[0].getRandomItems);
    })
    .catch(function (error) {
        console.log("ERROR:", error);
    });
}

/* Query 12 random items from data base */
const getRandomItemsNotLike = (request, response) => {
  var notLike = "";
  request.params.notLike
  .split("+")
  .forEach(
    param =>
    {
      if(param.length > 1)
      notLike += "'" + param + "',"
    }
  );
  notLike = notLike.substring(0, notLike.length - 1);

  db.any(
      'SELECT "getRandomItemsNotLike"( ARRAY['
      + notLike
      +'])'
  )
  .then(function (data) {
      response.status(200).json(data[0].getRandomItemsNotLike);
  })
  .catch(function (error) {
      console.log("ERROR:", error);
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
      await ItemsRetrieved.getItems(source.sou_link)
      .then( function(res) {
        feedInfo = {
            id: source.sou_id,
            link: source.sou_link
        }

        feedInfoStringified = "'" + JSON.stringify(feedInfo).replace( /'/, "''") + "'::json";

        itemsJsonString = (JSON.stringify(res));

        db.any("CALL \"insertNewItems\"("+feedInfoStringified+", '"+itemsJsonString+"')")
        .then(function(status) {
          resolve(status);
        })
        .catch(function(err) {
            reject(err)
        });
     })
     .catch(function(err) {
        reject(err);
     });
    }).catch(function(err2) {
        reject(err2);
    });
  })
}

const deleteOldItems = function() {
    db
    .any('CALL "deleteOldItemsProc"()')
    .then( function() {})
    .catch(function(err) {console.log(err);} );
  }

module.exports = {
    getAllItems,
    getRandomItems,
    getRandomItemsNotLike,
    insertItems,
    deleteOldItems
}
