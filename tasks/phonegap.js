(function() {
  module.exports = function(grunt) {
    var Build, Run, async, defaults, _;
    Build = require('./build').Build;
    Run = require('./run').Run;
    _ = grunt.util._;
    async = grunt.util.async;
    async.eachSeries = require('async').eachSeries;
    defaults = {
      root: 'www',
      root2: '',
      root3: '',
      config: 'www/config.xml',
      path: 'build',
      cordova: '.cordova',
      releases: 'releases',
      plugins: [],
      platforms: [],
      verbose: false
    };
    grunt.registerTask('phonegap:build', 'Build as a Phonegap application', function() {
      var build, config, done;
      config = _.defaults(grunt.config.get('phonegap.config'), defaults);
      done = this.async();
      build = new Build(grunt, config).clean().buildTree();
      return async.series([build.cloneRoot, build.cloneSrc1, build.cloneSrc2, build.cloneCordova, build.copyConfig], function() {
        return async.eachSeries(config.plugins, build.addPlugin, function(err) {
          return async.eachSeries(config.platforms, build.buildPlatform, function(err) {
            return done();
          });
        });
      });
    });
    return grunt.registerTask('phonegap:run', 'Run a Phonegap application', function() {
      var build, config, device, done, platform;
      config = _.defaults(grunt.config.get('phonegap.config'), defaults);
      platform = this.args[0] || _.first(config.platforms);
      device = this.args[1] || '';
      done = this.async();
      return build = new Run(grunt, config).run(platform, device, function() {
        return done();
      });
    });
  };

}).call(this);
