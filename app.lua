local lapis = require("lapis")
local app = lapis.Application()

local cqueues = require "cqueues"

local function sleep(delay)
  if ngx then
    return ngx.sleep(delay)
  else
    return cqueues.sleep(delay)
  end
end

local db = require "lapis.db"

app:get("/", function(self)
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
            request_number = i,
            delay_type = "sleep",
          })
        }
      end
    end)
  end)
end)

app:get("sub_request", "/sub-req", function(self)
  local start_time = cqueues.monotime()
  local delay = math.random()*2 + 0.01
  local res
  local sleep_type = self.params.delay_type or "query"

  if sleep_type == "sleep" then
    res = sleep(delay)
  elseif sleep_type == "query" then
    res = db.query("select pg_sleep(?), ? as request_number; select * from pg_stat_activity", delay, self.params.request_number)
  end


  return self:html(function()
    div(function()
      strong("Request ".. self.params.request_number)
      if res and res[1] and res[1][1] then
        text(" Got back " .. res[1][1].request_number)
      end
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
