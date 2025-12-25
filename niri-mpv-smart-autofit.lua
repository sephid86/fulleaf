-- ############################################################
-- #  Universal Smart Autofit for MPV (v2025.12.23)
-- #  Co-authored by Google AI Assistant and debugged by sephid86
-- #  Logic: Cross-Platform Boundary Check (Windows/Mac/Linux)
-- #  License: MIT
-- ############################################################

local function smart_autofit_logic()
    mp.add_timeout(0.05, function()
        -- 1. 공통 수치 확보
        local screen_w = mp.get_property_number("display-width")
        local screen_h = mp.get_property_number("display-height")
        local win_w = mp.get_property_number("osd-width")
        local win_h = mp.get_property_number("osd-height")
        local current_scale = mp.get_property_number("window-scale")

        if not screen_w or not win_w or not current_scale then return end
        -- 패널 여백 보정 (범용성을 위해 45px 적용)
        local usable_h = screen_h - 45 

        -- 2. 운영체제 확인 (범용성 핵심)
        -- Windows는 패키지 경로에 백슬래시(\)가 포함되는 특성을 이용합니다.
        local is_windows = package.config:sub(1,1) == "\\"
        
        -- 3. Niri 좌표 데이터 확보 시도 (Niri 환경에서만 동작)
        local real_x, real_y = nil, nil
        if not is_windows then
            -- Linux/macOS에서만 niri 명령 실행 시도
            local handle = io.popen("niri msg windows 2>/dev/null")
            if handle then
                local full_output = handle:read("*a")
                handle:close()
                if full_output and full_output ~= "" then
                    local x_str, y_str = full_output:match('App ID: "mpv".-Workspace%-view position:%s*([%d%.%-]+),%s*([%d%.%-]+)')
                    real_x = tonumber(x_str)
                    real_y = tonumber(y_str)
                end
            end
        end

        local needs_fix = false
        local shrink_ratio = 1.0

        -- 4. 통합 보정 로직 (좌표 유무에 따른 하이브리드 판정)
        if real_x and real_y then
            -- [Niri 전용] 좌표 기반 정밀 판정
            if (real_x + win_w > screen_w) or (real_y + win_h > usable_h) then
                shrink_ratio = math.min((screen_w - real_x) / win_w, (usable_h - real_y) / win_h)
                needs_fix = true
            end
        else
            -- [범용/Windows/Tiling] 사이즈 기반 판정
            if (win_w > screen_w) or (win_h > usable_h) then
                shrink_ratio = math.min(screen_w / win_w, usable_h / win_h)
                needs_fix = true
            end
        end

        -- 5. 보정 실행 (Pure MPV Internal)
        if needs_fix then
            local new_scale = current_scale * shrink_ratio
            mp.set_property_number("window-scale", new_scale)
            mp.osd_message(string.format("SMART FIT: %.2f", new_scale), 2)
        end
    end)
end

-- 트리거 설정
mp.observe_property("window-scale", "number", smart_autofit_logic)
mp.observe_property("video-out-params", "native", smart_autofit_logic)
