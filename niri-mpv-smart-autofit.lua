-- ############################################################
-- #  Niri Smart Autofit for MPV (v2025.12.23)
-- #  Co-authored by Google AI Assistant and debugged by sephid86
-- #  Logic: Real-time Screen Position calculation & Smart Autofitting
-- #  License: MIT (Free to use, modify, and distribute)
-- ############################################################

local function smart_autofit_logic()
    -- 고해상도 및 다중 모니터 환경에서 niri가 좌표를 확정할 시간을 줍니다.
    -- Safe Timeout for High-res & Multi-monitor stability
    mp.add_timeout(0.05, function()
        -- 1. mpv 속성 및 화면 해상도 정보 확보
        -- Get MPV properties and screen resolution
        local screen_w = mp.get_property_number("display-width")
        local screen_h = mp.get_property_number("display-height")
        local win_w = mp.get_property_number("osd-width")
        local win_h = mp.get_property_number("osd-height")
        local current_scale = mp.get_property_number("window-scale")

        -- 데이터가 아직 준비되지 않았다면 다음 신호를 기다립니다.
        -- If data is not ready, skip this cycle
        if not screen_w or not win_w or not current_scale then return end

        -- 2. niri로부터 검증된 실제 화면 좌표(real_x, real_y) 가져오기
        -- Fetch Verified Real Screen Position from niri
        local handle = io.popen("niri msg windows")
        if not handle then return end
        local full_output = handle:read("*a")
        handle:close()

        -- 포커스된 mpv 창의 블록에서 정확한 좌표만 파싱합니다.
        -- Targeted parsing for focused MPV window
        local x_str, y_str = full_output:match('App ID: "mpv".-Workspace%-view position:%s*([%d%.%-]+),%s*([%d%.%-]+)')
        local real_x = tonumber(x_str)
        local real_y = tonumber(y_str)

        if real_x and real_y then
            -- 3. 질문자님이 설계하신 '끝점 계산 공식' 적용
            -- Calculate Boundary Constraints based on sephid86's formula
            local max_w = screen_w - real_x
            local max_h = screen_h - real_y
            
            -- 창 끝부분이 화면 경계를 벗어나는지 판정합니다.
            -- If window exceeds edges, calculate safe scale ratio
            if (real_x + win_w > screen_w) or (real_y + win_h > screen_h) then
                local ratio_w = max_w / win_w
                local ratio_h = max_h / win_h
                
                -- 가로와 세로 중 더 많이 침범한 쪽을 기준으로 축소 비율을 결정합니다.
                -- Fit to the most constrained edge to keep aspect ratio
                local shrink_ratio = math.min(ratio_w, ratio_h)
                local new_scale = current_scale * shrink_ratio

                -- 4. mpv가 스스로 배율을 조정하여 화면 안으로 안착합니다.
                -- Apply Instant Self-Correction via MPV internal scale
                mp.set_property_number("window-scale", new_scale)
                mp.osd_message(string.format("SMART AUTOFIT: %.2f", new_scale), 2)
            end
        end
    end)
end

-- [검증된 트리거] 사용자가 배율을 바꾸거나 영상 소스가 변경될 때 실행합니다.
-- [Verified Triggers] Monitor scale changes and video source changes
mp.observe_property("window-scale", "number", smart_autofit_logic)
mp.observe_property("video-out-params", "native", smart_autofit_logic)
