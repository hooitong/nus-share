'use strict';
const _ = require('lodash');
const moment = require('moment');

const User = require('../models/user');
const Listing = require('../models/listing');

function getListings(req, res) {
  Listing.filter((listing) => {
    return moment(listing('endDate')).isSameOrBefore(moment());
  }).getJoin({
    participants: {
      _apply: (user) => {
        return user.pluck('id', 'name', 'email', 'contact');
      }
    }
  }).run().then((listings) => {
    res.json(listings);
  });
}

function addListing(req, res) {

}

function updateListing(req, res) {

}

function removeListing(req, res) {

}

function getListing(req, res) {

}

const userCtrl = { getListings, addListing, updateListing, removeListing, getListing };
export default userCtrl;
