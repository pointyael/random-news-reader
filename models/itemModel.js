var db = require("../database/dbFactory").db;
var ItemsRetrieved = require("../retrieveFromWeb/retrieveData.js");
var FeedModel = require("./feedModel");

let name;
let description;
let type;
let dateInsert;
let language;
let theme;

<<<<<<< HEAD
/* Query items from data base */
const getAllItems = (request, response) => {
    db.any("SELECT * FROM item")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
=======
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
  .catch(function (error) { console.log(error);});
>>>>>>> e4319148861426ca222a8745716a605f20013703
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
const insertItems = (request, response) => {

    deleteOldItems();

    db
    .any("SELECT * FROM source")
    .then(
      function (data)
      {
        data.forEach(
          source =>
          {
            ItemsRetrieved
            .getItems(source.sou_link)
            .then
            (
              function(res){
                feedInfo =
                {
                  id: source.sou_id,
                  title: source.sou_name,
                  link: source.sou_link
                }
                feedInfoStringified = "'" + JSON.stringify(feedInfo).replace( /'/, "''") + "'::json";

                itemsJsonString = (JSON.stringify(res));

                db
                .any("CALL \"insertNewItems\"("+feedInfoStringified+", '"+itemsJsonString+"')")
                .catch(function(err) {console.log(err)});
              }
            )
            .catch( function (err) {console.log(err);});
          }
        );

      }
    )
    .catch();

}

const deleteOldItems =
() =>
{
  db
  .any('CALL "deleteOldItemsProc"()')
  .catch(function(err) {console.log(err);});
}

module.exports = {
    getAllItems,
    getRandomItems
}