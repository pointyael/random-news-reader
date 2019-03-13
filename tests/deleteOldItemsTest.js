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
        before( function()
        {
          Item.deleteOldItems();
          itemsData = Item.getAllItems();
        });
        it
        (
          'should be items with ite_pubdate > now() - 2 days',
          async function () {
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
    );
  }
);
