'use strict';
const _ = require('lodash');
const moment = require('moment');

const Listing = require('../models').listing;

function getListings(req, res) {
  return Listing.getValidListings(moment().format())
    .then(listings => {
      res.json({ success: true, listings });
    });
}

function addListing(req, res) {
  const listingInfo = req.body.listing;
  const creator = req.body.userId;
  return Listing.createListing(listingInfo, creator)
    .then(listing => {
      res.json({ success: true, listing });
    });
}

function updateListing(req, res) {
  const listingId = req.body.listingId;
  const listingInfo = req.body.listing;
  return Listing.updateListing(listingId, listingInfo)
    .then(listing => {
      res.json({ success: true, listing });
    });
}

function registerUser(req, res) {
  const userId = req.body.userId;
  const listingId = req.body.listingId;

  return Listing.registerUser(userId, listingId)
    .then(listing => {
      res.json({ success: true, listing });
    });
}

function closeListing(req, res) {
  const listingId = req.body.listingId;
  return Listing.closeListing(listingId)
    .then(listing => {
      res.json({ success: true, listing });
    });
}

function getListing(req, res) {
  const listingId = req.body.listingId;
  return Listing.getListingById(listingId)
    .then(listing => {
      res.json({ success: true, listing });
    });
}

const userCtrl = {
  getListings, addListing, updateListing,
  registerUser, closeListing, getListing
};
export default userCtrl;
