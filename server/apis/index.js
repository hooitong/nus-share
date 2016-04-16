const passport = require('passport');
const listingCtrl = require('./listing_controller');
const userCtrl = require('./user_controller');

module.exports = function (app, express) {
  const usersRouter = express.Router();
  const listingsRouter = express.Router();

  /* User-Related Endpoints */
  usersRouter.post('/', userCtrl.addUser);
  usersRouter.get('/:userId', userCtrl.getUser);
  usersRouter.put('/:userId', userCtrl.updateUser);

  /* Listings-Related Endpoints */
  listingsRouter.get('/', listingCtrl.getListings);
  listingsRouter.post('/', listingCtrl.addListing);
  listingsRouter.put('/:listingId', listingCtrl.updateListing);
  listingsRouter.delete('/:listingId', listingCtrl.removeListing);
  listingsRouter.get('/:listingId', listingCtrl.getListing);

  // Configure app to load all the routers
  app.use('/api/users', usersRouter);
  app.use('/api/listings', listingsRouter);
};
