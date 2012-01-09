_ = require("underscore")
async = require("async")
path = require("path")
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
  Models: {}
  Controllers: {}
  constructor: (dir, controllers_path = "/controllers", models_path = "/models") ->
    # Autoloaders
    c = new Traversal(path.join(dir, controllers_path), "js", {
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
    models = new Traversal(path.join(dir, models_path), "js", {
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