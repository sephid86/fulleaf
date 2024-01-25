local filepath = mp.command_native({"expand-path", "~/.mpv_volume"})

local loadfile = io.open(filepath, "r")

if loadfile then
	set_volume = string.sub(loadfile:read(), 8)
	loadfile:close()
	mp.set_property_number("volume", set_volume)
end

mp.register_event("shutdown", 
	function()
		local savefile  = io.open(filepath, "w+")
		savefile:write("volume=" .. mp.get_property("volume"), "\n")    
		savefile:close()
	end
)
