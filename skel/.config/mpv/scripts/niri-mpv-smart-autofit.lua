-- ############################################################
-- #  Niri Anti-Overfit for MPV (v2.0 Revision)
-- #  Co-authored by Google AI Assistant and debugged by sephid86
-- #  Logic: Absolute 'current-window-scale' Shield
-- #  License: MIT (Free to use, modify, and distribute)
-- ############################################################
-- [Niri Configuration / Niri 설정 가이드]
-- This script works regardless of 'default-column-width {}' setting.
-- 이 스크립트는 'default-column-width {}' 설정 여부와 상관없이 완벽하게 동작합니다.
-- window-rule {
--   match app-id="mpv"
--   // open-floating true  <-- Also works perfectly in floating mode!
-- }
-- ############################################################
-- [Release Note / 릴리즈 노트]
-- 1. Niri Exclusive: Optimized specifically for Niri IPC & Tiling.
--    Niri 전용: Niri IPC 및 타일링 환경에 최적화된 전용 로직.
-- 2. Current-Scale Lock: Fixed initial scale 1.0 drift and overfit.
--    물리 배율 잠금: 초기 1.0 배율 가출 및 모든 오버핏 현상 완벽 해결.
-- 3. Zero-Conflict: No more infinite loops or focus-return resizing issues.
--    충돌 제로: 무한 루프 및 포커스 복귀 시 발생하는 리사이징 문제 해결.
-- 4. Need jq. jq 설치 되어 있어야 합니다.
-- ############################################################

-- [Gatekeeper / 입구 컷] niri IPC 응답 확인 (Niri 환경이 아니면 즉시 종료)
-- Exit immediately if Niri IPC is not responding (Windows/Other WMs)
local handle = io.popen("niri msg windows 2>/dev/null")
local output = handle and handle:read("*a") or ""
if handle then handle:close() end
if output == "" then return end

-- 메인 보정 함수: Niri Anti-Overfit
-- Main Correction Function: Niri Anti-Overfit
local function niri_anti_overfit()
  -- 전체화면 중일 때는 보정 로직을 정지합니다.
  -- Disable logic during fullscreen to prevent malfunctions.
  if mp.get_property_native("fullscreen") then return end

  -- niri가 수치를 확정할 최소한의 시간(0.05초)을 벌어주는 안정화 장치입니다.
  -- Safe timeout (0.05s) for Niri to finalize dimensions.
  mp.add_timeout(0.05, function()
    if mp.get_property_native("fullscreen") then return end

    -- 1. 시스템 수치 및 물리적 배율 확보
    -- Get system resolution and real physical scale
    local screen_w = mp.get_property_number("display-width")
    local screen_h = mp.get_property_number("display-height")
    local dwidth = mp.get_property_number("dwidth")
    local dheight = mp.get_property_number("dheight")
    local current_scale = mp.get_property_number("current-window-scale")

    if not screen_w or not dwidth or not current_scale then return end

    -- 2. Niri 좌표 데이터 확보 시도
    -- Fetch verified window coordinates from Niri IPC
    local h = io.popen("niri msg windows 2>/dev/null")
    local full_output = h:read("*a")
    h:close()

    local x_str, y_str = full_output:match('App ID: "mpv".-Workspace%-view position:%s*([%d%.%-]+),%s*([%d%.%-]+)')
    local real_x = tonumber(x_str) or 0
    local real_y = tonumber(y_str) or 0

    -- 3. 가용 공간 및 최대 허용 배율 계산 (45px 여백 포함)
    -- Calculate usable space and max allowable scale (includes 45px margin)
    local usable_w = screen_w - real_x
    local usable_h = (screen_h - 45) - real_y
    local max_scale = math.min(usable_w / dwidth, usable_h / dheight)

    -- 4. 보정 실행: 현재 배율이 한계를 넘으면 즉시 잠금
    -- Execute: Lock immediately if current physical scale exceeds limit
    if current_scale > max_scale + 0.001 then
      mp.set_property_number("window-scale", max_scale)
      mp.osd_message(string.format("ANTI-OVERFIT: %.2f", max_scale), 2)
    end

    local cmd = [[niri msg -j windows | jq -r '.[] | select(.app_id == "mpv") | .id' 2>/dev/null]]
    local h = io.popen(cmd)
    local mpv_id = h and h:read("*a"):gsub("%s+", "") or ""
    if h then h:close() end

    local actual_width = math.floor(dwidth * mp.get_property_number("current-window-scale"))
    if actual_width > 0 then
      local cmd = string.format("niri msg action set-window-width --id %s %d", mpv_id, actual_width)
      os.execute(cmd)
    end
  end)
end

-- [트리거 설정 / Trigger System]
-- 1. 물리적 배율 변화 감시 (Real-time physical scale monitoring)
mp.observe_property("current-window-scale", "number", niri_anti_overfit)
-- 2. 영상 소스 변경 감시 (Video source changes)
mp.observe_property("video-out-params", "native", niri_anti_overfit)

-- [초기화] 실행 즉시 초기 오버핏 차단
-- [Init] Run immediately to prevent initial overfit on launch.
niri_anti_overfit()
