N2O = require("../")

assert = require("assert")
express = require("express")
fs = require("fs")
path = require("path")

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

    app.configure(() ->
      app.set("root", "/tmp/")
    )

    app.listen(3000, () ->
      app.close()
      done()
    )
  )

  it("should run w/ nitrous", (done) ->
    app = express.createServer()

    app.configure(() ->
      app.set("root", "/tmp/")
    )
    nitrous = new N2O(app)

    app.listen(3000, () ->
      app.close()
      done()
    )
  )
)