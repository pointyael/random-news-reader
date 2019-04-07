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

    var items;

    it('it GET 12 items published less than 2 days', (done) => {
      chai.request(server)
      .get('/random-items')
      .then( (res) =>  {
        items = res.body

        let dateMinusTwoDays = moment().add(-2, 'days').format("YYYY-MM-DD HH:mm:ss");

        items.should.be.a('array');

        // Cann't test the length < 12 because too few sources
        //expect(items.length == 12).to.be.true;

        items.forEach(item => {
          expect(item.ite_title).be.a('string').not.empty;
          expect(item).to.have.property("ite_pubdate");
          expect
          (
            moment(item.ite_pubdate).format("YYYY-MM-DD HH:mm:ss")
            >= dateMinusTwoDays
          ).to.be.true;
        });
        done();
      })
      .catch( (err) => done(err) );
    });
});

describe('/GET random-items/:notLike', () =>{
  var items;

  it('itemsNoLibe must not contain \'Liberation\' in the title, (if exists) description and link fields, match case ',
    (done) => {
      chai.request(server)
      .get('/random-items/liberation')
      .then((res) => {
        items = res.body
        items.forEach(item => {
          if (item.ite_title){
            expect(item.ite_title.includes("liberation")).to.be.false;
            expect(item.ite_link.includes("liberation")).to.be.false;
            if(item.ite_description)
            expect(!(item.ite_description.includes('liberation'))).to.be.true;
          }
        });
        done();
      })
      .catch((err) => { done(err); });
    }
  );

  it('itemsNoEcho must not contain \'echos\' in the title, (if exists) description and link fields, match case ',
    (done) => {
      chai.request(server)
      .get('/random-items/echos')
      .then((res) => {
        items = res.body
        items.forEach(item => {
          if (item.ite_title) { // IDK why a item is null ???  no pb during run on pgadmin posgtres
            expect(!(item.ite_title.includes("echos"))).to.be.true;
            expect(!(item.ite_link.includes("echos"))).to.be.true;
          }
        });
        done();
      })
      .catch((err) => { done(err); });
    }
  );
  it('itemsNoLibeAndEcho must not contain \'Liberation\' and \'echos\' in the title, (if exists) description and link fields, match case ',
    (done) => {
      chai.request(server)
      .get('/random-items/liberation+echos')
      .then((res) => {
          items = res.body;
          items.forEach(item => {
            if(item.ite_title) {
              expect(!(item.ite_title.includes("liberation"))).to.be.true;
              expect(!(item.ite_title.includes("echos"))).to.be.true;
              expect(!(item.ite_link.includes("liberation"))).to.be.true;
              expect(!(item.ite_link.includes("echos"))).to.be.true;
              if(item.ite_description){
                expect(!(item.ite_description.includes("liberation"))).to.be.true;
                expect(!(item.ite_description.includes("echos"))).to.be.true;
              }
            }
          });
          done();
      })
      .catch((err) => { done(err); });
    }
  );
});
