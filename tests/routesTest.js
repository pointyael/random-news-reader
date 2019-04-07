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
    before(
      async function(){
        await chai.request(server)
        .get('/random-items')
        .then( (res) =>  items = res.body )
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

describe('/GET random-items/:notLike', () =>{
  var items;

  it('itemsNoLibe must not contain \'Liberation\' in the title, (if exists) description and link fields, match case ',
    (done) => {
      chai.request(server)
      .get('/random-items/liberation')
      .then((res) => {
        items = res.body
        items.forEach(item => {
          expect(!(item.ite_title.match(/liberation/i))).to.be.true;
          expect(!(item.ite_link.match(/liberation/i))).to.be.true;
          if(item.ite_description)
          expect(!(item.ite_description.match(/liberation/i))).to.be.true;
        });
        done();
      })
      .catch((err) => {});
    }
  );

  it('itemsNoEcho must not contain \'echos\' in the title, (if exists) description and link fields, match case ',
    (done) => {
      chai.request(server)
      .get('/random-items/echos')
      .then((res) => {
        items = res.body
        items.forEach(item => {
          expect(!(item.ite_title.match(/echos/i))).to.be.true;
          expect(!(item.ite_link.match(/echos/i))).to.be.true;
          if(item.ite_description)
            expect(!(item.ite_description.match(/echos/i))).to.be.true;
        });
        done();
      })
      .catch((err) => {});
    }
  );
  it('itemsNoLibeAndEcho must not contain \'Liberation\' and \'echos\' in the title, (if exists) description and link fields, match case ',
    (done) => {
      chai.request(server).get('/random-items/liberation+echos')
      .then((res) => {
          items = res.body;
          items.forEach(item => {
            expect(!(item.ite_title.match(/liberation/i))).to.be.true;
            expect(!(item.ite_link.match(/liberation/i))).to.be.true;
            expect(!(item.ite_title.match(/echos/i))).to.be.true;
            expect(!(item.ite_link.match(/echos/i))).to.be.true;
            if(item.ite_description){
              expect(!(item.ite_description.match(/liberation/i))).to.be.true;
              expect(!(item.ite_description.match(/echos/i))).to.be.true;
            }
          });
          done();
      })
      .catch((err) => {});
    }
  );
});
