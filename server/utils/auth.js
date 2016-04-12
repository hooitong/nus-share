const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;
const User = require('./../models/user');
const config = require('config');

export default (passport) => {
  const opts = {};
  opts.jwtFromRequest = ExtractJwt.fromAuthHeader();
  opts.secretOrKey = config.secret;
  passport.use(new JwtStrategy(opts, (payload, done) => {
    return User.get({ id: payload.id }).then((user) => {
      return user ? done(null, user) : done(null, false);
    });
  }));
};
