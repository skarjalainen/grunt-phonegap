class module.exports.Build
  copy: require 'directory-copy'
  cp: require 'cp'
  path: require 'path'
  exec: require('child_process').exec

  constructor: (@grunt, @config) ->
    @file = @grunt.file
    @log = @grunt.log
    @warn = @grunt.warn
    @fatal = @grunt.fatal

  clean: (path = @config.path) ->
    if @file.exists(path) then @file.delete(path)
    @

  buildTree: ->
    path = @config.path
    @file.mkdir @path.join(path, 'plugins')
    @file.mkdir @path.join(path, 'platforms')
    @file.mkdir @path.join(path, 'merges', 'android')
    @file.mkdir @path.join(path, 'www')
    @file.mkdir @path.join(path, '.cordova')
    @

  cloneCordova: (fn) =>
    @copy src: @config.cordova, dest: @path.join(@config.path, '.cordova'), (err) =>
      @warn(err) if err
      fn(err) if fn

  cloneRoot: (fn) =>
    @copy src: @config.root, dest: @path.join(@config.path, 'www'), (err) =>
      @warn(err) if err
      fn(err) if fn

  cloneRoot2: (fn) =>
    if @config.root2
      @copy src: @config.root2, dest: @path.join(@config.path, 'www'), excludes: @config.excludes2, (err) =>
        @warn(err) if err
        fn(err) if fn
    else
      true

  cloneRoot3: (fn) =>
    if @config.root3
      @copy src: @config.root3, dest: @path.join(@config.path, 'www'), (err) =>
        @warn(err) if err
        fn(err) if fn
    else
      true

  copyConfig: (fn) =>
    @cp @config.config, @path.join(@config.path, 'www', 'config.xml'), -> fn()

  addPlugin: (plugin, fn) =>
    cmd = "phonegap local plugin add #{plugin} #{@_setVerbosity()}"
    proc = @exec cmd, cwd: @config.path, (err, stdout, stderr) =>
      @fatal err if err
      fn(err) if fn

    proc.stdout.on 'data', (out) => @log.write(out)
    proc.stderr.on 'data', (err) => @fatal(err)

  buildPlatform: (platform, fn) =>
    cmd = "phonegap local build #{platform} #{@_setVerbosity()}"
    childProcess = @exec cmd, cwd: @config.path, (err, stdout, stderr) =>
      @fatal err if err
      fn(err) if fn

    childProcess.stdout.on 'data', (out) => @log.write(out)
    childProcess.stderr.on 'data', (err) => @fatal(err)

  _setVerbosity: ->
    if @config.verbose then '-V' else ''
