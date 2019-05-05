const path = require('path');

module.exports = {
  entry: './src/main.js',
  devtool : 'source-map',
  mode: 'development',
  output: {
    filename: 'main.js',
    path: path.resolve(__dirname, 'dist')
  },
  module: {
    rules: [
      // if just using javascript
      //{ test: /\.jsx$/, loader: 'surplus-loader' },
    ]
  },
	optimization: {
		// We no not want to minimize our code.
		minimize: false
	},
};