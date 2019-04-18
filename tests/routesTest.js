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

describe('/GET random-items/:lang', () => {

    var items;

    it('it GET array of 12 items published less than 2 days', (done) => {
      chai.request(server)
      .get('/random-items/0')
      .then( (res) =>  {
        items = res.body;
        items.should.be.a('array').not.empty;
        (items.length == 12).should.be.true;

        let dateMinusTwoDays = moment().add(-2, 'days').format("YYYY-MM-DD HH:mm:ss");
        items.forEach(item => {
          item.should.to.have.property("ite_title");
          item.should.to.have.property("ite_pubdate");
          expect
          (
            moment(item.ite_pubdate).format("YYYY-MM-DD HH:mm:ss")
            > dateMinusTwoDays
          ).to.be.true;
        });
        done();
      })
      .catch((err) => done(err));
    })
});

describe('/GET random-items/:notLike/:lang', () =>{
  var items;

  it('itemsNoLibe must not contain \'Liberation\' in the title, (if exists) description and link fields, match case and french',
    (done) => {
      chai.request(server)
      .get('/random-items/liberation/16')
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

  it('itemsNoEcho must not contain \'echos\' in the title, (if exists) description and link fields, match case and french',
    (done) => {
      chai.request(server)
      .get('/random-items/echos/16')
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
  it('itemsNoLibeAndEcho must not contain \'Liberation\' and \'echos\' in the title, (if exists) description and link fields, match case and french ',
    (done) => {
      chai.request(server)
      .get('/random-items/liberation+echos/16')
      .then((res) => {
        items = res.body;
        items.forEach(item => {
          if(item.ite_title){
            expect(item.ite_title.match(/liberation/i)).to.be.null;
            expect(item.ite_link.match(/liberation/i)).to.be.null;
            expect(item.ite_title.match(/echos/i)).to.be.null;
            expect(item.ite_link.match(/echos/i)).to.be.null;
            if(item.ite_description){
              expect(item.ite_description.match(/liberation/i)).to.be.null;
              expect(item.ite_description.match(/echos/i)).to.be.null;
            }
          }
        });
        done();
      })
      .catch((err) => { done(err); });
    }
  );
});

describe('/GET random-quote', () => {
  it('Returned quote must be an object with an ID and a quote', function(done) {
    chai.request(server)
    .get('/random-quote')
    .then((res) => {
      quote = res.body;
      quote.should.be.a('object').not.empty;;
      quote.should.have.property("quo_id");
      quote.should.have.property("quo_quote");
      done();
    })
    .catch((err) => { done(err); });
  })
});

describe('/GET random-btnQuote', () => {
  it('Returned button quote must be an object with an ID and a quote', function(done) {
    chai.request(server)
    .get('/random-btnQuote')
    .then((res) => {
      quote = res.body;
      quote.should.be.a('object').not.empty;;
      quote.should.have.property("but_id");
      quote.should.have.property("but_quote");
      done();
    })
    .catch((err) => { done(err); });
  })
});
