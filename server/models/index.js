'use strict';

const Sequelize = require('sequelize');
const config = require('config');

// Setup Sequelize and Connection with Database
// ======================================================
const dbName = config.get('db.name');
const dbUsername = config.get('db.username');
const dbPassword = config.get('db.password');
const dbConfig = config.get('db.config');

const sequelize = new Sequelize(
  dbName,
  dbUsername,
  dbPassword,
  dbConfig
);
const modelFiles = ['listing', 'user'];

modelFiles.forEach(model => {
  module.exports[model] = sequelize.import(`${__dirname}/${model}`);
});

(m => {
  m.listing.belongsTo(m.user, { as: 'creator' });
  m.listing.belongsToMany(m.user, { through: 'user_listing' });
  m.user.belongsToMany(m.listing, { through: 'user_listing' });
})(module.exports);

// Synchronize all the defined model into the actual mySQL database
// ========================================================================
sequelize.sync().then(() => {
}, error => console.error(error));

module.exports.sequelize = sequelize;
