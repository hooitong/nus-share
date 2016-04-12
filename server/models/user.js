const thinky = require('../utils/thinky');
const type = thinky.type;

const User = thinky.createModel('User', {
  id: type.string().uuid(4),
  name: type.string(),
  email: type.string(),
  contact: type.number(),
  password: type.string()
});

module.exports = User;

const Listing = require(`${__dirname}/models/listing`);
User.hasAndBelongsToMany(Listing, 'offeredListings', 'id', 'id');
