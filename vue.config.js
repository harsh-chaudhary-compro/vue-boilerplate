const path = require('path');
const Webpack = require("webpack");
module.exports = {
  //extra path over base path default deployment
  publicPath: '/',

  //output directory for the deployment/compressed project
  // outputDir: './public/site/dist',

  //directory(relative to outputDir)to nest generated static assets(js, css, img, fonts)under.
  // assetsDir: './public/site/assets',

  //Specify the output path for the generated index.html
  //indexPath: './public/site/templates/base-vue.html'

  //default:true, generated static assets contains hashes in their filenames for better caching control
  //filenameHashing: true

  //pages
  pages: {
    index: {
      // entry for the page
      entry: path.join(__dirname, './src/main.js'),

      // the source template
      // template: './public/index.html',

      // output as dist/index.html
      // filename: 'index.html',
      
      // when using title option,
      // template title tag needs to be <title><%= htmlWebpackPlugin.options.title %></title>
      // title: 'Index Page',

      // chunks to include on this page, by default includes
      // extracted common chunks and vendor chunks.
      // chunks: ['chunk-vendors', 'chunk-common', 'index']
    },
    /* when using the entry-only string format,
     template is inferred to be `public/subpage.html`
     and falls back to `public/index.html` if not found.
     Output filename is inferred to be `subpage.html`.
     when first fallback failed
     subpage: 'src/subpage/main.js'*/
  },

  //'default'/'error'-warning overlay on window
  //true/'warning'-only on terminal not on overlay
   lintOnSave: 'warning',//boolean | 'warning' | 'default' | 'error',
  /*  or
    devServer: {
      overlay: {
        warnings: true,
        errors: true
      }
    }*/

  //if true, you can use the template option in Vue components, but will incur around an extra 10kb payload for your app.
  // runtimeCompiler: false,

  //for babel-loader: ignores all files inside node_modules list incase..kind of a translator
  transpileDependencies:[],

  // false can speed up production builds if you don't need source maps for production
  productionSourceMap: process.env.NODE_ENV != 'production',
  
  // not imp-crossorigin,integrity(for cdn),pluginOptions

  //it will be merged into the final config using webpack-merge, if function resolved value, incase we need many webpack files
  configureWebpack: {},

  //a place to define any rule regarding any file ext
  chainWebpack: config => {
    config.module
      .rule('i18n')
      .resourceQuery(/blockType=i18n/)
      .use('i18n')
        .loader('@kazupon/vue-i18n-loader')
        .end()
      .use('yaml-loader')
        .loader('yaml-loader')
        .end();
  },
  devServer: {
    port: 7000,
    host: "localhost",
    historyApiFallback: true, // true for index.html upon 404, object for multiple paths
    hot: true,
    // for api server
    // proxy: "http://localhost:4000"
  },
  //to modify css options
  // css: {
  //   //requireModuleExtension: true if false allow allow *.(css|scss|sass|less|styl(us)?) files as module
  //   loaderOptions: {
  //     sass: {
  //       sassOptions: {
  //     //     incase we want to include node_module css
  //     //     includePaths: [
  //     //       path.resolve(__dirname, 'node_modules')
  //     //     ]
  //     // prependData: [
  //     //   `@import "@/assets/default.scss";`
  //     // ]//some default css
  //       }
  //     },
  //   }
  // },
  // plugins: [],

  //prodution:-pwa, parallel(when the system has more than 1 CPU cores),
  // module: {
  //   rules: [
  //     {
  //       test: /\.ya?ml$/,
  //       use: 'yaml-loader'
  //     }
  //   ]
  // }
};