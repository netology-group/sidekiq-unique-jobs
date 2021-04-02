-------- BEGIN keys ---------
local digest    = KEYS[1]
local queued    = KEYS[2]
local primed    = KEYS[3]
local locked    = KEYS[4]
local info      = KEYS[5]
local changelog = KEYS[6]
local digests   = KEYS[7]
-------- END keys ---------

-------- BEGIN lock arguments ---------
local job_id    = ARGV[1]      -- The job_id that was previously primed
local pttl      = tonumber(ARGV[2])
local lock_type = ARGV[3]
local limit     = tonumber(ARGV[4])
-------- END lock arguments -----------

--------  BEGIN injected arguments --------
local current_time = tonumber(ARGV[2])
local debug_lua    = ARGV[3] == "true"
local max_history  = tonumber(ARGV[4])
local script_name  = tostring(ARGV[5]) .. ".lua"
---------  END injected arguments ---------

--------  BEGIN Variables --------
local queued_count = redis.call("LLEN", queued)
local locked_count = redis.call("HLEN", locked)
local within_limit = limit > locked_count
local limit_exceeded = not within_limit
--------   END Variables  --------

--------  BEGIN local functions --------
<%= include_partial "shared/_common.lua" %>
---------  END local functions ---------


--------  BEGIN locked.lua --------
return limit_exceeded
---------  END locked.lua ---------
