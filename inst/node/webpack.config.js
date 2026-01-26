const { join } = require('path');

const appDir = join(__dirname, '..', 'inst');

module.exports = {
  mode: 'production',
  entry: join(appDir, 'js', 'index.js'),
  output: {
    library: 'App',
    path: join(appDir, 'app', 'www', 'js'),
    filename: 'app.min.js',
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        use: 'babel-loader',
      },
    ],
  },
  resolve: {
    extensions: ['.js', '.jsx'],
  },
};
