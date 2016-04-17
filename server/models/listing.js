'use strict';
const _ = require('lodash');
const uuid = require('node-uuid');

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('listing', {
    id: {
      type: DataTypes.STRING,
      primaryKey: true
    },
    title: DataTypes.STRING,
    type: DataTypes.STRING,
    content: DataTypes.STRING,
    venue: DataTypes.STRING,
    startDate: DataTypes.DATE,
    endDate: DataTypes.DATE,
    limit: DataTypes.INTEGER,
    closed: DataTypes.BOOLEAN,
    tags: DataTypes.ARRAY(DataTypes.STRING)
  }, {
    underscored: true,
    classMethods: {
      createListing(listingInfo, creator) {
        listingInfo.id = uuid.v4();
        return this.create(listingInfo)
          .then(listing => {
            return listing.setCreator(creator);
          });
      },
      getListingById(listingId) {
        return this.findById(listingId);
      },
      updateListing(listingId, updateContent) {
        return this.findById(listingId)
          .then((listing) => {
            return listing.update(updateContent);
          });
      },
      getListings() {
        return this.findAll();
      },
      getValidListings(currentDate) {
        return this.findAll({ where: { endDate: { $gt: currentDate }, closed: false } })
          .then(pendingListings => {
            return _.filter(pendingListings, listing => {
              return listing.getUsers()
                .then(participants => (participants.count || 0) < listing.limit);
            });
          });
      },
      registerUser(userId, listingId) {
        return this.findById(listingId)
          .then(listing => {
            return listing.addUser(userId);
          });
      },
      closeListing(listingId) {
        return this.findById(listingId)
          .then(listing => {
            return listing.update({ closed: true });
          });
      }
    }
  });
};
