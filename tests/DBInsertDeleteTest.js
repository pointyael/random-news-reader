const expect = require('chai').expect;
let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../app');
const Item = require('../models/itemModel.js');
const moment = require('moment');

require('it-each')({ testPerIteration: true });
chai.use(chaiHttp);


describe('"deleteOldItems"', () => {
    var itemsData;
    before(async function() {
      await Item.deleteOldItems();
    });

    it ('After delete, all items should have ite_pubdate > now() - 2 days',
      (done) => {
        Item
        .getAllItems()
        .then((reponse) => {
          itemsData = reponse;
          let dateMinusTwoDays = moment().add(-2, 'days').format("YYYY-MM-DD HH:mm:ss");

          itemsData.forEach( (item) => {

            expect(item).to.have.property("ite_pubdate");
            expect
            (
              moment(item.ite_pubdate).format("YYYY-MM-DD HH:mm:ss")
              > dateMinusTwoDays
            ).to.be.true;
          });
          done();
        })
        .catch((err) => { done(err); })
    });
});

describe( '"insertNewItems"', () => {
  var itemsData;
  before(async function() {
    Item.insertItems('https://mixmag.net/rss.xml')
    .then(function(status) {})
    .catch(function(error) { console.log(error);});
  });

  it( 'after insert, all items must be inserted into the database and must be younger than two days',
    function(done) {
      Item
      .getAllItems()
      .then((reponse) => {
        itemsData = reponse;
        let dateMinusTwoDays = moment().add(-2, 'days');
        itemsData.forEach( item => {

            expect(item).to.have.property("ite_pubdate");
            expect
            (
              moment(item.ite_pubdate) > dateMinusTwoDays
            ).to.be.true;
        });
        done();
      })
      .catch((err) => done(err))
  });
});
