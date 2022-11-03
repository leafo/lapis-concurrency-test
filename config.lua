
require "lapis.config" ("cqueues", {
  server = "cqueues",
  port = 8181,
  code_cache = true,
  measure_performance = true,
  postgres = {
    database = "postgres",
    socket_type = "cqueues",
  }
})


require "lapis.config" ("nginx", {
  server = "nginx",
  port = 8181,
  code_cache = "on",
  measure_performance = true,
  postgres = {
    database = "postgres",
    socket_type = "nginx",
  }
})
