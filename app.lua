local lapis = require("lapis")
local app = lapis.Application()

local cqueues = require "cqueues"

local db = require "lapis.db"

app:get("/", function(self)
  -- local res = db.query("select pg_sleep(2), * from pg_stat_activity")
  return self:html(function()
    h1 "Concurrent request test"

    div({
      style = "display: flex; gap: 20px; flex-wrap: wrap;"
    }, function()
      for i=1,20 do
        iframe{
          width = 200,
          height = 200,
          src = self:url_for("sub_request", nil, {
            request_number = i
          })
        }
      end
    end)
  end)
end)

app:get("sub_request", "/sub-req", function(self)
  local start_time = cqueues.monotime()
  local delay = math.random()*2 + 0.01
  local res = nil
  -- cqueues.sleep(delay)
  local res = db.query("select pg_sleep(?), ? as request_number; select * from pg_stat_activity", delay, self.params.request_number)
  return self:html(function()
    div(function()
      strong("Request ".. self.params.request_number)
      text(" Got back " .. res[1][1].request_number)
    end)
    div("Elapsed: " .. ("%0.3f"):format(cqueues.monotime() - start_time))
    div("Delay: " .. ("%0.3f"):format(delay))
    pre(require("moon").dump(res))
  end)
end)

app:get("/favicon.ico", function(self)
  return { status = 404 }
end)

return app
