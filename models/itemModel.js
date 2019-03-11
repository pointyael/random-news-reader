var db = require("../database/dbFactory").db;
var Items = require("../retrieveFromWeb/retrieveData.js");
var FeedModel = require("./feedModel");

let name;
let description;
let type;
let dateInsert;
let language;
let theme;

/* Query all items from db => only for test */
const getAllItems = (request, response) =>
{
  db
  .any("SELECT * from item")
  .then
  (
    function(data)
    {
      response.status(200).json(data);
    }
  )
  .catch(function (error)
  { });
}

/* Query 12 random items from data base */
const getRandomItems = (request, response) => {
    db.any('SELECT "getRandomItems"()')
      .then(function (data) {
          response.status(200).json(data);
      })
      .catch(function (error) {
          console.log("ERROR:", error);
      });
}

/* Query 12 random items from data base */
const getRandomItemsNotLike = (request, response) => {
    db.any(
        'SELECT "getRandomItemsNotLike"(\''
        + request.params.notLike
        +'\')'
      )
      .then(function (data) {
          response.status(200).json(data);
      })
      .catch(function (error) {
          console.log("ERROR:", error);
      });
}

/* Insert items in data base */
const insertItems = (request, response) => {

    db
    .any("SELECT * FROM source WHERE source.sou_id=2")
    .then(
      function (data)
      {
          data = data[0];
          feedInfo =
          {
              id: data.sou_id,
              title: data.sou_title,
              link: data.sou_link
          }

          feedInfoStringified = "'" + JSON.stringify(feedInfo).replace( /'/, "''") + "'::json";

          Items
          .getItems(data.sou_link)
          .then
          (
              function(res){
                  itemsJsonString = (JSON.stringify(res));
                  //console.log(res);
                  db
                  .any("CALL \"insertNewItems\"("+feedInfoStringified+", '"+itemsJsonString+"')")
                  .then( () => response.status(200) )
                  .catch();
              }
          )
          .catch()

      }
    )
    .catch();

}

const deleteOldItems =
() =>
{
  db
  .any('CALL "deleteOldItemsProc"()')
  .then()
  .catch();
}

module.exports = {
    getAllItems,
    getRandomItems,
    getRandomItemsNotLike,
    insertItems,
    deleteOldItems
}
