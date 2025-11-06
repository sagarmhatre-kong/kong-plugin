-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------



local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}



-- do initialization here, any module level code runs in the 'init_by_lua_block',
-- before worker processes are forked. So anything you add here will run once,
-- but be available in all workers.

-- SAGAR_NOTES
-- useful for:
--   * Loading shared libraries or modules that all workers will need
--   * Setting up global configuration that doesn't change
--   * Initializing connection pools or shared resources
--   * Performing expensive setup operations once instead of in each worker


-- handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker()

  -- your custom code here
  kong.log.debug("[[init_worker]] handler (handles more initialization, but AFTER the worker process has been forked/created) ")

end --]]


---[[ Executed every time a plugin config changes.
-- This can run in the `init_worker` or `timer` phase.
-- @param configs table|nil A table with all the plugin configs of this plugin type.
function plugin:configure(configs)
  kong.log.notice("[[configure]] plugin config changed, got ", (configs and #configs or 0)," configs")

  if configs == nil then
    return -- no configs, nothing to do
  end

  -- your custom code here

end --]]


--[[ runs in the 'ssl_certificate_by_lua_block'
-- IMPORTANT: during the `certificate` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:certificate(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'certificate' handler")

end --]]



--[[ runs in the 'rewrite_by_lua_block'
-- IMPORTANT: during the `rewrite` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:rewrite(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'rewrite' handler")

end --]]



-- runs in the 'access_by_lua_block'
-- The access phase is place to modify what gets sent to the upstream.

function plugin:access(plugin_conf)

  -- your custom code here

  kong.log.notice("[[access]] plugin config pretty print: ")
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!

  -- we are adding a header to the request being sent to the upstream here
  kong.service.request.set_header(plugin_conf.request_header, "this is on a request")


  -- we are adding the api_key to the request being sent to the upstream here
  local api_key = plugin_conf.api_key
  local api_key_value = kong.vault.get(api_key)
  kong.service.request.set_header("x-api-key", api_key_value)

  local request_body = kong.request.get_raw_body()
  if request_body then
    kong.log.debug(request_body)
  end

end --]]


-- runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)

  -- your custom code here, for example;
  kong.response.set_header(plugin_conf.response_header, "this is on the response")

end --]]


-- runs in the 'body_filter_by_lua_block'
function plugin:body_filter(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'body_filter' handler")

  local body = kong.response.get_raw_body()

  if body then
    kong.log.debug(body)
  end


end --


-- runs in the 'log_by_lua_block'
function plugin:log(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'log' handler")

 

end --


-- return our plugin object
return plugin
