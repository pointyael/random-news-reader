/*
ite_id integer NOT NULL,
    ite_title character varying(250),
    ite_description character varying(400),
    ite_type integer,
    ite_link character varying(250),
    ite_dateinsert date,
    ite_language integer,
    ite_theme integer,
ite_source integer
*/
const mongoose = require('mongoose');

let Schema = mongoose.Schema;

const itemStruct = new Schema({
  ItemSchema: {
      type: mongoose.Schema.Types.Mixed,
    },
    title: {
      type: String,
    },
    description: {
      type: String,
    },
    type: {
      type: String,
    },
    datePub: {
      type: String,
    },
    link: {
      type: String,
    },
    language: {
      type: String,
    },
    category: {
      type: String,
    },
  });

const ItemSchema = mongoose.model('ItemSchema', itemStruct);

module.exports = ItemSchema;