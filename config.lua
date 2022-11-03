require "lapis.config" ("development", {
  server = "cqueues",
  port = 8181,
  code_cache = true,
  measure_performance = true,
  postgres = {
    database = "postgres",
    socket_type = "cqueues",
  }
})
