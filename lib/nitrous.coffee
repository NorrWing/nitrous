express = require("express")
fs = require("fs")
path = require("path")

RequestHandler = require("./request")

load = (pathstr) ->
  try
    package = require(pathstr)  
  catch error
    try
      if pathstr[0] == "/"
        fullpath = pathstr
      else
        fullpath = path.join(__dirname, pathstr)
      package = JSON.parse(fs.readFileSync(fullpath).toString())
    catch error
      throw error
  return package

class Nitrous
  constructor: (@app, root, config_path = "./config/index") ->
    @app.settings.root = root
    @app.config = require(path.join(@app.settings.root, config_path)) # TODO: option to change path
    @app.redisStore = require("connect-redis")(express)
    # @app.config.port = process.env.PORT || @app.config.port # override with
  
  init: (req, res, next) ->
    package = load("../package")
    
    onExit = path.join(@app.settings.root, "./config/on_exit")
    if path.existsSync(onExit)
      require(onExit)

    return (req, res, next) ->
      req.socket.remoteAddress = req.headers["x-forwarded-for"] || req.socket.remoteAddress
      origwriteHead = res.writeHead
      res.writeHead = (status, headers) ->
        headers = headers || {}
        headers["X-Powered-By"] = "Nitrous #{package.version}"
        # headers["Strict-Transport-Security"] = "max-age=16070400;"
        origwriteHead.call(res, status, headers)
      next()
  
  # router: () ->
  #   r = require(path.join(@app.settings.root, "./routes"))
  #   return express.router(r(@app))
  
  routes: () ->
    r = require(path.join(@app.settings.root, "./routes"))(@app)
    return r
  
  mvc: () -> 
    Request = new RequestHandler(@app.settings.root)
    @app.Controllers = Request.Controllers
    
    self = this

    return (req, res, next) ->
      req.Models = self.app.Models = Request.Models

      res.psend = (data, pure = false) ->
        output = JSON.stringify(data, null, 2)
        output = "<pre>" + output + "</pre>" if !pure
        res.send(output)
      
      res.error = (err) ->
        res.returned = true # TODO: evaluate this line's questionable value
        res.psend({status: 500, data: err})
      
      next()

exports = module.exports = Nitrous