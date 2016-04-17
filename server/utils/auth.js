const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;
const User = require('./../models').user;
const config = require('config');

module.exports = (passport) => {
  const opts = {};
  opts.jwtFromRequest = ExtractJwt.fromAuthHeader();
  opts.secretOrKey = config.secret;
  passport.use(new JwtStrategy(opts, (payload, done) => {
    return User.getUserById(payload.id).then((user) => {
      return user ? done(null, user) : done(null, false);
    });
  }));
};
