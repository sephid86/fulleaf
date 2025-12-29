#!/usr/bin/lua

local cmd = arg[1]
if not cmd then return end

local actions = {
    volume_up   = { exec = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",   cat = "Audio" },
    volume_down = { exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",   cat = "Audio" },
    volume_mute = { exec = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", cat = "Audio" },
}

local target = actions[cmd]
if not target then return end

os.execute(target.exec)

local val, icon, msg = 0, "audio-volume-high", ""
local app_name = "OSD" .. target.cat  -- 카테고리에 따라 OSD-Audio 등으로 자동 설정

if target.cat == "Audio" then
    local h = io.popen("wpctl get-volume @DEFAULT_AUDIO_SINK@")
    local res = h:read("*a")
    h:close()

    local vol = tonumber(res:match("(%d+%.%d+)")) or 0
    local mute = res:match("MUTED")
    val = math.floor(vol * 100)
    icon = mute and "audio-volume-muted" or "audio-volume-high"
    msg = mute and "Muted" or string.format("Volume: %d%%", val)
end

-- 알림 전송 (앱 이름을 -a OSD-Audio 형식으로 전달)
local notify_cmd = string.format(
    'notify-send -a "OSDAudio" -e -t 1500 -r 999 -h int:value:%d -h string:x-swaync-display-settings-no-history:true -h string:category:OSDAudio -i "%s" "%s" "%s"',
    val, icon, target.cat, msg
)
os.execute(notify_cmd)
