//Require the dev-dependencies
let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../server');
let should = chai.should();


chai.use(chaiHttp);
//Our parent block
describe('Books', () => {
    beforeEach((done) => { //Before each test we empty the database
        Book.remove({}, (err) => { 
           done();           
        });        
    });
/*
  * Test the /GET route
  */
  describe('/GET all-items', () => {
      it('it should GET all the items', (done) => {
        chai.request(server)
            .get('/all-items')
            .end((err, res) => {
                  res.should.have.status(200);
                  res.body.should.be.a('array');
              done();
            });
      });
  });

});