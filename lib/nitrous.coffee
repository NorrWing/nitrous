express = require("express")
path = require("path")

RequestHandler = require("./request")

class Nitrous
  constructor: (@app) ->
    @app.config = require(path.join(app.settings.root, "./config/index")) # TODO: option to change path
    # @app.redisStore = require("connect-redis")(express)
    process.port = @app.config.port
  
  init: (req, res, next) ->
    package = require("../package.json")

    return (req, res, next) ->
      req.socket.remoteAddress = req.headers["x-forwarded-for"] || req.socket.remoteAddress
      origwriteHead = res.writeHead
      res.writeHead = (status, headers) ->
        headers = headers || {}
        headers["X-Powered-By"] = "Nitrous #{package.version}"
        # headers["Strict-Transport-Security"] = "max-age=16070400;"
        origwriteHead.call(res, status, headers)
      next()
  
  router: () ->
    return express.router(require(path.join(app.settings.root, "./routes")(@app))
  
  controllers: () -> 
    Request = new RequestHandler(@app.settings.root)
    @app.Controllers = Request.Controllers
    @app.Models = Request.Models

    return (req, res, next) ->
      req.Models = @app.Models = Request.Models

      res.psend = (data, pure = false) ->
        output = JSON.stringify(data, null, 2)
        output = "<pre>" + output + "</pre>" if !pure
        res.send(output)
      
      res.error = (err) ->
        res.returned = true # TODO: evaluate this line's questionable value
        res.psend({status: 500, data: err})
      
      next()

exports = module.exports = Nitrous