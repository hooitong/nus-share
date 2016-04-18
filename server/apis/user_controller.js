'use strict';
const _ = require('lodash');
const config = require('config');
const jwt = require('jsonwebtoken');

const User = require('../models').user;

function addUser(req, res) {
  const name = req.body.name;
  const email = req.body.email;
  const contact = req.body.contact;
  const password = req.body.password;
  const userInfo = { name, email, contact, password };
  return User.createUser(userInfo)
    .then(user => {
      res.json(user);
    });
}

function getUser(req, res) {
  const userId = req.params.userId;
  return User.getUserById(userId)
    .then(user => {
      res.json(user);
    });
}

function updateUser(req, res) {
  const userId = req.params.userId;
  const payload = req.body.payload;
  return User.updateUser(userId, payload)
    .then(user => {
      res.json(user);
    });
}

const AUTH_ERROR = 'Wrong Credentials. Check your username or password again.';
function authenticate(req, res) {
  const email = req.body.email;
  const password = req.body.password;

  User.getUserByEmail(email)
    .then(user => {
      if (!user) res.json({ success: false, message: AUTH_ERROR }, 400);
      else if (user.validatePassword(password)) {
        const token = jwt.sign(user.toJSON(), config.secret);
        res.json({ success: true, authToken: token });
      } else res.json({ success: false, message: AUTH_ERROR }, 400);
    });
}

const userCtrl = { addUser, getUser, updateUser, authenticate };
export default userCtrl;
