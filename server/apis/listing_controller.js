'use strict';
const _ = require('lodash');
const chrono = require('chrono-node');
const moment = require('moment');
const Promise = require('bluebird');

const Listing = require('../models').listing;
const User = require('../models').user;

function getListings(req, res) {
  return Listing.getValidListings(moment().format())
    .then(listings => {
      res.json(listings);
    });
}

function addListing(req, res) {
  const listingInfo = req.body;
  listingInfo.startDate = moment(Date.parse(chrono.parseDate(listingInfo.startDate))).format();
  listingInfo.endDate = moment(Date.parse(chrono.parseDate(listingInfo.endDate))).format();
  const creator = listingInfo.creatorId;
  delete listingInfo.creatorId;

  return Listing.createListing(listingInfo, creator)
    .then(listing => {
      return listing.getCreator()
        .then(user => {
          listing = listing.toJSON();
          user = user.toJSON();
          listing.creator = user;
          listing.users = [];
          res.json(listing);
        });
    });
}

function updateListing(req, res) {
  const listingId = req.params.listingId;
  const listingInfo = req.body;
  return Listing.updateListing(listingId, listingInfo)
    .then(listing => {
      res.json(listing);
    });
}

function registerUser(req, res) {
  const userId = req.params.userId;
  const listingId = req.params.listingId;

  return Listing.registerUser(userId, listingId)
    .then(listing => {
      res.json(listing);
    });
}

function closeListing(req, res) {
  const listingId = req.params.listingId;
  return Listing.closeListing(listingId)
    .then(listing => {
      res.json(listing);
    });
}

function getListing(req, res) {
  const listingId = req.params.listingId;
  return Listing.getListingById(listingId)
    .then(listing => {
      res.json(listing);
    });
}

function getCreatorListings(req, res) {
  const userId = req.params.userId;
  return Listing.getCreatorListings(userId)
    .then(listings => {
      res.json(listings);
    });
}

function getParticipatedListings(req, res) {
  const userId = req.params.userId;
  return User.getUserById(userId)
    .then(Listing.getParticipatedListings)
    .then(listings => {
      const promiseArray = [];
      listings.forEach(listing => {
        promiseArray.push(Listing.getListingById(listing.id));
      });
      return Promise.all(promiseArray);
    })
    .then(listings => {
      res.json(_.orderBy(listings, ['startDate', 'endDate', 'title'], ['desc', 'desc', 'asc']));
    });
}

const userCtrl = {
  getListings, addListing, updateListing,
  registerUser, closeListing, getListing,
  getCreatorListings, getParticipatedListings
};
export default userCtrl;
