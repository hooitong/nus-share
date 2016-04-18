'use strict';
const _ = require('lodash');
const moment = require('moment');

const Listing = require('../models').listing;

function getListings(req, res) {
  return Listing.getValidListings(moment().format())
    .then(listings => {
      res.json(listings);
    });
}

function addListing(req, res) {
  const listingInfo = req.body.listing;
  const creator = req.body.userId;
  return Listing.createListing(listingInfo, creator)
    .then(listing => {
      res.json(listing);
    });
}

function updateListing(req, res) {
  const listingId = req.params.listingId;
  const listingInfo = req.body.listing;
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

const userCtrl = {
  getListings, addListing, updateListing,
  registerUser, closeListing, getListing
};
export default userCtrl;
