import listingCtrl from './listing_controller';
import userCtrl from './user_controller';

module.exports = function (app, express) {
  const usersRouter = express.Router();
  const listingsRouter = express.Router();

  /* User-Related Endpoints */
  usersRouter.post('/', userCtrl.addUser);
  usersRouter.get('/:userId', userCtrl.getUser);
  usersRouter.put('/:userId', userCtrl.updateUser);
  usersRouter.post('/authenticate', userCtrl.authenticate);

  /* Listings-Related Endpoints */
  listingsRouter.get('/', listingCtrl.getListings);
  listingsRouter.post('/', listingCtrl.addListing);
  listingsRouter.get('/created/:userId', listingCtrl.getCreatorListings);
  listingsRouter.get('/participated/:userId', listingCtrl.getParticipatedListings)
  listingsRouter.put('/:listingId', listingCtrl.updateListing);
  listingsRouter.put('/:listingId/:userId', listingCtrl.registerUser);
  listingsRouter.delete('/:listingId', listingCtrl.closeListing);
  listingsRouter.get('/:listingId', listingCtrl.getListing);

  // Configure app to load all the routers
  app.use('/api/users', usersRouter);
  app.use('/api/listings', listingsRouter);
};
