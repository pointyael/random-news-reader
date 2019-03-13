const expect = require('chai').expect;
const Item = require('../models/itemModel.js');
const moment = require('moment');

require('it-each')({ testPerIteration: true });

describe(
  "Delete items older than 48 hours",
  () =>
  {
    describe(
      '"deleteOldItems"',
      () =>
      {
        var itemsData;
        before(async function()
        {
          await Item.deleteOldItems();
          itemsData = await Item.getAllItems();
        });
        it
        (
          'should be items with ite_pubdate > now() - 2 days',
          function () {
            let dateMinusTwoDays = moment().add(-2, 'days').format("YYYY-MM-DD HH:mm:ss");

            for(var index in itemsData)
            itemsData.forEach
            (
              item =>
              {
                expect(item).to.have.property("ite_pubdate");
                expect
                (
                  moment(item.ite_pubdate).format("YYYY-MM-DD HH:mm:ss") > dateMinusTwoDays
                ).to.be.true;
              }
            );
          }
        );
      }
    );

    describe(
      '"insertNewItems"',
      () =>
      {
        var itemsData;
        before(async function()
        {
          await Item.insertItems();
          itemsData = await Item.getAllItems();
        });

        it(
          'items must be inserted into the database and must be younger than two days',
          function()
          {
            let dateMinusTwoDays = moment().add(-2, 'days');

            for(var index in itemsData)
            itemsData.forEach
            (
              item =>
              {

                expect(item).to.have.property("ite_pubdate");
                expect
                (
                  moment(item.ite_pubdate) > dateMinusTwoDays
                ).to.be.true;
              }
            );
          }
        );
      }
    )
  }
);
