require('coffee-coverage').register({
  path: 'abbr',
  basePath: __dirname + '/../src',
  exclude: ['/test', '/node_modules', '/.git', '/lib'],
  initAll: true,
  streamlinejs: false
});
