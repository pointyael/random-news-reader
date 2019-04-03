<<<<<<< HEAD
//Require the dev-dependencies
let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../app');
let should = chai.should();


chai.use(chaiHttp);
/*
  * Test the /GET route
  */

describe('/GET random-items', () => {
    it('it should GET an array of items', (done) => {
    chai.request(server)
        .get('/random-items')
        .end((err, res) => {
                res.should.have.status(200);
                res.body.should.be.a('array');
                items = res.body;
                items.forEach(item => {
                    console.log(item);
                    item.ite_title.should.be.a('string').not.empty;
                });
            done();
        });
    });
});
=======
//Require the dev-dependencies
let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../app');
let moment = require('moment');
let expect = chai.expect;
let should = chai.should();


chai.use(chaiHttp);
/*
  * Test the /GET route
  */

describe('/GET random-items', () => {
    var status;
    var items;
    before(
      async function(){
        await chai.request(server)
        .get('/random-items')
        .then(
          (res) => {
            items = res.body;
            status = res.status;
          }
        )
        .catch();
      }
    );

    it('it expect GET an array of 12 items', (done) => {

      items.should.be.a('array');
      items.forEach(item => {
        expect(item.ite_title).be.a('string').not.empty;
      });
      expect(items.length == 12).to.be.true;

      done();
    });

    it('it GET items published less than 2 days', (done) => {
      let dateMinusTwoDays = moment().add(-2, 'days').format("YYYY-MM-DD HH:mm:ss");
      items.forEach(item => {
        expect(item).to.have.property("ite_pubdate");
        expect
        (
          moment(item.ite_pubdate).format("YYYY-MM-DD HH:mm:ss")
            > dateMinusTwoDays
        ).to.be.true;
      });

      done();
    });
});
>>>>>>> master
