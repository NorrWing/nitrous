_ = require("underscore")
async = require("async")
# everyauth = require("everyauth")
# mongoose = require("mongoose")
# ObjectId = mongoose.Types.ObjectId

# console.log(mongoose.Types.ObjectId.fromString.toString())
# Traversal = require("../lib/traversal")
Traversal = require("./traversal")

# TODO: move this elsewhere
Errors = {
  NOT_OMNISCIENT: "You must be all powerful to access this page.",
  NOT_EMPLOYEE: "You must be an employee to access this page.",
  NOT_ADMIN: "You do not have permission to access this page.",
  LOGGED_OUT: "You must be logged in to access this page.",
}

HTTP404Error = (req, res) ->
  res.send("404: Page not found") # TODO: create this

class RequestHandler
  constructor: (dir, @Controllers = {}, @Models = {}) ->
    # Autoloaders
    c = new Traversal(dir + "/controllers", "js", {
      functions: {
        pre: () =>
        post: (startPath, currentFile, selected) =>
          selected.push(selected_path = currentFile.replace(startPath + "/", ""))
          [folder, filename] = currentFile.split("/")[-2..-1]
          @Controllers[folder] ?= {}
          try
            @Controllers[folder][filename.split(".")[0]] = require(currentFile)
          catch error
            throw error
          
      }
    }).traverse()
    models = new Traversal(dir + "/models", "js", {
      functions: {
        pre: () =>
        post: (startPath, currentFile, selected) =>
          selected.push(selected_path = currentFile.replace(startPath + "/", ""))
          [folder, filename] = currentFile.split("/")[-2..-1]
          @Models[folder] ?= {}
          try
            @Models[folder][filename.split(".")[0]] = require(currentFile)
          catch error
            throw error
      }
    }).traverse()

  request: (controller_fn = HTTP404Error) ->
    return controller_fn

  is_anony: (controller_fn = HTTP404Error) =>
    return @request(controller_fn)
    
  
    
  

module.exports = RequestHandler