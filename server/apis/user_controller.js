'use strict';
const _ = require('lodash');
const bcrypt = require('bcrypt');

const User = require('../models/user');

function addUser(req, res) {
  const name = req.body.name;
  const email = req.body.email;
  const contact = req.body.contact;
  const password = bcrypt.hashSync(req.body.password, 10);
  new User({ name, email, contact, password }).saveAll()
    .then((result) => {
      res.json({ success: true, userId: result.id });
    })
    .catch((error) => {
      res.json(error, 400);
    });
}

function getUser(req, res) {
  const userId = req.params.name;
  User.get(userId).getJoin().run().then((result) => {
    res.json(_.omit(result, ['password']));
  });
}

function updateUser(req, res) {
  const userId = req.params.userId;
  const name = req.body.name;
  const email = req.body.email;
  const contact = req.body.contact;
  const password = bcrypt.hashSync(req.body.password, 10);
  const payload = { name, email, contact, password };
  User.get(userId).run().then((user) => {
    user.merge(payload).save().then((result) => {
      res.json({ success: true, userID: result.id })
    });
  });
}

const userCtrl = { addUser, getUser, updateUser };
export default userCtrl;
