class module.exports.Run
  exec: require('child_process').exec

  constructor: (@grunt, @config) ->

  run: (platform, device, fn) =>
    cmd = "phonegap local install #{platform} #{@_setVerbosity()}"
    cmd += " --device #{device}" if device
    childProcess = @exec cmd, cwd: @config.path, (err, stdout, stderr) =>
      @grunt.fatal err if err
      fn(err) if fn

    childProcess.stdout.on 'data', (out) => @grunt.log.write(out)
    childProcess.stderr.on 'data', (err) => @grunt.fatal(err)

  _setVerbosity: ->
    if @config.verbose then '-V' else ''
