const passport = require('passport');

module.exports = function (app, express) {
  const usersRouter = express.Router();
  const listingsRouter = express.Router();

  // Configure app to load all the routers
  app.use('/api/users', usersRouter);
  app.use('/api/listings', listingsRouter);
};
