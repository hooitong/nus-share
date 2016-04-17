'use strict';
const bcrypt = require('bcrypt');
const uuid = require('node-uuid');

const mutedAttributes = ['id', 'name', 'email', 'contact'];

module.exports = function (sequelize, DataTypes) {
  return sequelize.define('user', {
    id: {
      type: DataTypes.STRING,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    contact: DataTypes.STRING,
    password: {
      type: DataTypes.STRING,
      allowNull: false
    }
  }, {
    underscored: true,
    classMethods: {
      createUser(userInfo) {
        userInfo.id = uuid.v4();
        return this.create(userInfo);
      },
      getUserById(userId) {
        return this.find({
          where: { id: userId },
          include: [this.associations.listings],
          attributes: mutedAttributes
        });
      },
      getUserByEmail(email) {
        return this.find({ where: { email } });
      },
      updateUser(userId, userContent) {
        return this.find({
          where: { id: userId },
          attributes: mutedAttributes
        }).then((user) => {
          return user.update(userContent);
        });
      }
    },
    instanceMethods: {
      validatePassword(password) {
        return bcrypt.compareSync(password, this.password);
      }
    },
    hooks: {
      beforeCreate(user) {
        user.password = bcrypt.hashSync(user.password, 10);
      },
      beforeUpdate(user) {
        if (user.changed('password')) user.password = bcrypt.hashSync(user.password, 10);
      }
    }
  });
};
