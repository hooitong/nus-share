const bodyParser = require('body-parser');
const config = require('config');
const morgan = require('morgan');
const passport = require('passport');
const express = require('express');
const app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(morgan('dev'));

app.use(passport.initialize());
require('./server/utils/auth')(passport);

app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST');
  res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type, \Authorization');
  next();
});

app.use('/', express.static('./elm'));

require('./server/apis')(app, express);

app.listen(config.express.port);
console.log(`Server Port opened at ${config.express.port}`);
