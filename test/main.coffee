N2O = require("../")

assert = require("assert")
express = require("express")
fs = require("fs")
path = require("path")

# describe("nitrous", () ->
#   it("should be require-able", (done) ->
#     n2o = require("../")
#   )
# )

describe("express", () ->
  beforeEach((done) ->
    files = ["/tmp/config/index"]
    for file in files
      dir = path.dirname(file)
      fs.unlinkSync(file) if path.existsSync(file)
      fs.mkdirSync(dir) if !path.existsSync(dir)
      fs.writeFileSync(file, "")
    
    done()
  )

  it("should run w/o nitrous", (done) ->
    app = express.createServer()
    app.listen(3000, () ->
      app.close()
      done()
    )
  )

  it("should run w/ nitrous", (done) ->
    app = express.createServer()
    nitrous = new N2O(app, "/tmp/")

    app.listen(3000, () ->
      app.close()
      done()
    )
  )

  it("should run w/ nitrous.init()", (done) ->
    app = express.createServer()
    nitrous = new N2O(app, "/tmp/")

    app.configure(() ->
      app.use(nitrous.init())
    )

    app.listen(3000, () ->
      app.close()
      done()
    )
  )

  it("should run w/ nitrous.mvc()", (done) ->
    app = express.createServer()
    nitrous = new N2O(app, "/tmp/")

    app.configure(() ->
      app.use(nitrous.init())
      app.use(nitrous.mvc())
    )

    app.listen(3000, () ->
      app.close()
      done()
    )
  )
)





