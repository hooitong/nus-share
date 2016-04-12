const thinky = require('../utils/thinky');
const type = thinky.type;

const Listing = thinky.createModel('Listing', {
  id: type.string().uuid(4),
  title: type.string(),
  type: type.string(),
  content: type.string(),
  venue: type.string(),
  startDate: type.date(),
  endDate: type.date(),
  limit: type.number(),
  tags: type.array(),
  creatorId: type.string()
});

module.exports = Listing;

const User = require(`${__dirname}/models/user`);
Listing.hasOne(User, 'creator', 'creatorId', 'id');
Listing.hasAndBelongsToMany(User, 'participants', 'id', 'id');
