--[[ Agenda: 解析 iCalendar（ICS）订阅源，按"今天起 RangeDays 天"排成可滚动列表。

     数据通路：每路订阅一个 WebParser（整页捕获）-> GetStringValue()
     -> 本脚本合并去重、按时间排序、按日期分组，并驱动行表。

     场景：只支持公开 ICS 订阅（webcal:// 会转成 https://）。
     iCloud 私密 CalDAV 端点需要 PROPFIND，Rainmeter 的 WebParser 只能 GET，做不了。
]]

local DAYNAMES = { 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' }

local feeds, VIS, headerH, eventH, viewH, listTop, rowW, padX, style, tc, rangeDays, hasData
local lastOff, lastMove

local function num(v, d)
  local n = tonumber(v)
  if n == nil then return d end
  return n
end

local function unescape(s)
  if not s then return '' end
  s = s:gsub('\\n', ' '):gsub('\\N', ' ')
  s = s:gsub('\\,', ','):gsub('\\;', ';'):gsub('\\\\', '\\')
  return s:gsub('^%s+', ''):gsub('%s+$', '')
end

local function parseDT(v)
  if not v then return nil end
  v = v:gsub('^[^:]*:', ''):gsub('Z$', '')
  local y, m, d, H, M = v:match('^(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)')
  if y then return { y = num(y), m = num(m), d = num(d), H = num(H), M = num(M) } end
  local y2, m2, d2 = v:match('^(%d%d%d%d)(%d%d)(%d%d)')
  if y2 then return { y = num(y2), m = num(m2), d = num(d2) } end
  return nil
end

local function dayKey(t) return t.y * 10000 + t.m * 100 + t.d end
local function sortKey(t) return dayKey(t) * 10000 + num(t.H, 0) * 100 + num(t.M, 0) end
local function hhmm(t) return string.format('%02d:%02d', num(t.H, 0), num(t.M, 0)) end
local function prop(blk, name) return blk:match('\n' .. name .. '[^:\r\n]*:([^\r\n]*)') end

local function parseICS(raw)
  local out = {}
  raw = raw:gsub('\r\n[ \t]', ''):gsub('\n[ \t]', '')
  for blk in raw:gmatch('BEGIN:VEVENT(.-)END:VEVENT') do
    local s = parseDT(prop(blk, 'DTSTART'))
    if s then
      local e = parseDT(prop(blk, 'DTEND'))
      local title = unescape(prop(blk, 'SUMMARY'))
      if title == '' then title = '(untitled)' end
      out[#out + 1] = { s = s, e = e, title = title, key = sortKey(s) }
    end
  end
  table.sort(out, function(a, b) return a.key < b.key end)
  return out
end

local function buildRows(events)
  local rows, curDay = {}, nil
  for _, ev in ipairs(events) do
    local k = dayKey(ev.s)
    local wt = os.date('*t', os.time({ year = ev.s.y, month = ev.s.m, day = ev.s.d, hour = 12 }))
    local dayText = string.format('%s %d', DAYNAMES[wt.wday], ev.s.d)

    local r = { kind = 'ev', h = eventH, title = ev.title }
    if ev.e and (ev.e.H or ev.e.M) then
      r.time = hhmm(ev.s) .. '-' .. hhmm(ev.e)
    elseif ev.s.H then
      r.time = hhmm(ev.s)
    else
      r.time = 'all day'
    end

    if k ~= curDay then
      curDay = k
      rows[#rows + 1] = { kind = 'day', h = headerH, text = dayText }
    end
    rows[#rows + 1] = r
  end
  return rows
end

local function totalHeight(rows)
  local t = 0
  for _, r in ipairs(rows) do t = t + r.h end
  return t
end

local function hideAll()
  for i = 1, VIS do
    SKIN:Bang('!SetOption Row' .. i .. ' Hidden 1')
    SKIN:Bang('!SetOption Bar' .. i .. ' Hidden 1')
    SKIN:Bang('!SetOption Time' .. i .. ' Hidden 1')
  end
end

local function set(meter, opt, val)
  SKIN:Bang('!SetOption ' .. meter .. ' ' .. opt .. ' "' .. val .. '"')
end

local function render(slot, r, y)
  -- 左留白随面板宽度走（窄档位若沿用固定 30px，右侧只剩 10px，视觉重心会偏右）
  local x = '(' .. padX .. ')*#ScaleDpi#'
  -- 文字必须让开竖条：原先两者同 X，文字直接压在竖条上
  local textX = '(' .. (padX + 10) .. ')*#ScaleDpi#'
  local w = '(' .. rowW .. ')*#ScaleDpi#'

  if r.kind == 'day' then
    set('Row' .. slot, 'Text', r.text)
    set('Row' .. slot, 'FontColor', tc .. ',235')
    set('Row' .. slot, 'FontSize', '(#Height#/13)*#ScaleDpi#')
    set('Row' .. slot, 'StringAlign', 'LeftTop')
    set('Row' .. slot, 'X', x)
    set('Row' .. slot, 'W', w)
    set('Row' .. slot, 'Y', y + math.floor(headerH * 0.24))
    set('Row' .. slot, 'Hidden', 0)
    return
  end

  local inner = math.floor(eventH * 0.06)
  local lineGap = math.floor(eventH * 0.48)

  if style == 3 then
    set('Row' .. slot, 'Text', r.title)
    set('Row' .. slot, 'FontColor', tc .. ',255')
    set('Row' .. slot, 'FontSize', '(#Height#/14)*#ScaleDpi#')
    set('Row' .. slot, 'StringAlign', 'LeftTop')
    set('Row' .. slot, 'X', x)
    set('Row' .. slot, 'W', '(' .. math.floor(rowW * 0.62) .. ')*#ScaleDpi#')
    set('Row' .. slot, 'Y', y + lineGap - math.floor(eventH * 0.24))
    set('Row' .. slot, 'Hidden', 0)
    set('Time' .. slot, 'Text', r.time)
    set('Time' .. slot, 'FontColor', tc .. ',125')
    set('Time' .. slot, 'FontSize', '(#Height#/17)*#ScaleDpi#')
    set('Time' .. slot, 'StringAlign', 'RightTop')
    set('Time' .. slot, 'X', '(' .. (rowW + padX) .. ')*#ScaleDpi#')
    set('Time' .. slot, 'W', '(' .. math.floor(rowW * 0.38) .. ')*#ScaleDpi#')
    set('Time' .. slot, 'Y', y + lineGap - math.floor(eventH * 0.20))
    set('Time' .. slot, 'Hidden', 0)

  elseif style == 4 then
    set('Bar' .. slot, 'SolidColor', tc .. ',18')
    set('Bar' .. slot, 'X', x)
    set('Bar' .. slot, 'Y', y + inner)
    set('Bar' .. slot, 'W', w)
    set('Bar' .. slot, 'H', '(' .. (eventH - 2 * inner) .. ')*#ScaleDpi#')
    set('Bar' .. slot, 'Hidden', 0)
    set('Row' .. slot, 'Text', r.title)
    set('Row' .. slot, 'FontColor', tc .. ',255')
    set('Row' .. slot, 'FontSize', '(#Height#/15)*#ScaleDpi#')
    set('Row' .. slot, 'StringAlign', 'LeftTop')
    set('Row' .. slot, 'X', x)
    set('Row' .. slot, 'W', w)
    set('Row' .. slot, 'Y', y + inner + 3)
    set('Row' .. slot, 'Hidden', 0)
    set('Time' .. slot, 'Text', r.time)
    set('Time' .. slot, 'FontColor', tc .. ',125')
    set('Time' .. slot, 'FontSize', '(#Height#/20)*#ScaleDpi#')
    set('Time' .. slot, 'StringAlign', 'LeftTop')
    set('Time' .. slot, 'X', x)
    set('Time' .. slot, 'W', w)
    set('Time' .. slot, 'Y', y + inner + 3 + lineGap - 2)
    set('Time' .. slot, 'Hidden', 0)

  else
    set('Bar' .. slot, 'SolidColor', tc .. ',90')
    set('Bar' .. slot, 'X', x)
    set('Bar' .. slot, 'Y', y + inner)
    set('Bar' .. slot, 'W', '(#Height#/70)*#ScaleDpi#')
    set('Bar' .. slot, 'H', '(' .. (eventH - 2 * inner) .. ')*#ScaleDpi#')
    set('Bar' .. slot, 'Hidden', 0)
    set('Row' .. slot, 'Text', r.title)
    set('Row' .. slot, 'FontColor', tc .. ',255')
    set('Row' .. slot, 'FontSize', '(#Height#/14)*#ScaleDpi#')
    set('Row' .. slot, 'StringAlign', 'LeftTop')
    set('Row' .. slot, 'X', textX)
    set('Row' .. slot, 'W', w)
    set('Row' .. slot, 'Y', y + inner + 1)
    set('Row' .. slot, 'Hidden', 0)
    set('Time' .. slot, 'Text', r.time)
    set('Time' .. slot, 'FontColor', tc .. ',125')
    set('Time' .. slot, 'FontSize', '(#Height#/17)*#ScaleDpi#')
    set('Time' .. slot, 'StringAlign', 'LeftTop')
    set('Time' .. slot, 'X', textX)
    set('Time' .. slot, 'W', w)
    set('Time' .. slot, 'Y', y + inner + 1 + lineGap)
    set('Time' .. slot, 'Hidden', 0)
  end
end

local function layout(rows, off)
  hideAll()
  local slot, top = 0, 0
  for _, r in ipairs(rows) do
    if top + r.h > off then
      if slot >= VIS then break end
      if top - off < viewH then
        slot = slot + 1
        render(slot, r, listTop + (top - off))
      end
    end
    top = top + r.h
  end
  SKIN:Bang('!UpdateMeterGroup Rows')
  SKIN:Bang('!Redraw')
end

function Initialize()
  feeds = {}
  local n = num(SKIN:GetVariable('FeedCount'), 1)
  for i = 1, n do
    local url = SKIN:GetVariable('Feed' .. i, '')
    if url ~= '' then
      -- iCloud 给出的是 webcal:// 形式，WebParser 只认 http(s)
      local https = url:gsub('^webcal://', 'https://')
      if https ~= url then
        set('MeasureICS' .. i, 'Url', https)
      end
      -- 测量默认禁用，地址就位后再启用：避免加载瞬间用 webcal:// 去抓而报 12006
      SKIN:Bang('!EnableMeasure MeasureICS' .. i)
      SKIN:Bang('!UpdateMeasure MeasureICS' .. i)
      local ok, m = pcall(function() return SKIN:GetMeasure('MeasureICS' .. i) end)
      if ok and m then feeds[#feeds + 1] = m end
    end
  end
  VIS = num(SKIN:GetVariable('VisibleRows'), 6)
  headerH = num(SKIN:GetVariable('HeaderH'), 24)
  eventH = num(SKIN:GetVariable('EventH'), 40)
  viewH = num(SKIN:GetVariable('ViewH'), 260)
  listTop = num(SKIN:GetVariable('ListTop'), 22)
  rowW = num(SKIN:GetVariable('RowW'), 250)
  padX = num(SKIN:GetVariable('PadX'), 30)
  style = num(SKIN:GetVariable('AgendaStyle'), 1)
  tc = SKIN:GetVariable('textcolor2', '255,255,255')
  rangeDays = num(SKIN:GetVariable('RangeDays'), 6)
  lastOff, lastMove = 0, os.time()
end

function Update()
  local events, seen, fetched = {}, {}, false
  for _, m in ipairs(feeds) do
    local raw = m:GetStringValue()
    if raw and #raw > 40 then
      fetched = true
      for _, ev in ipairs(parseICS(raw)) do
        local sig = dayKey(ev.s) .. '|' .. num(ev.s.H, 0) .. ':' .. num(ev.s.M, 0) .. '|' .. ev.title
        if not seen[sig] then
          seen[sig] = true
          events[#events + 1] = ev
        end
      end
    end
  end
  -- 每个订阅内部 parseICS 已排好，但跨源合并后仍是"一路接一路"，必须重排
  table.sort(events, function(a, b)
    if a.key ~= b.key then return a.key < b.key end
    return a.title < b.title
  end)

  if not fetched then
    -- 仅在从未取到过数据时提示：某轮刷新期间源暂时为空，不该把已显示的内容顶上这行字
    if not hasData then
      set('Msg', 'Text', 'loading feed...')
      set('Msg', 'Hidden', 0)
      SKIN:Bang('!UpdateMeter Msg')
    end
    return 'loading'
  end

  local today = os.date('*t')
  local t0 = os.time({ year = today.year, month = today.month, day = today.day, hour = 0 })
  local lo = os.date('*t', t0)
  local hi = os.date('*t', t0 + rangeDays * 86400)
  local loK = lo.year * 10000 + lo.month * 100 + lo.day
  local hiK = hi.year * 10000 + hi.month * 100 + hi.day

  local inRange = {}
  for _, ev in ipairs(events) do
    local k = dayKey(ev.s)
    if k >= loK and k <= hiK then inRange[#inRange + 1] = ev end
  end

  local rows = buildRows(inRange)
  if #rows > 0 then hasData = true end
  local mx = math.max(0, totalHeight(rows) - viewH)

  local off = num(SKIN:GetVariable('Offset'), 0)
  if off ~= lastOff then lastOff, lastMove = off, os.time() end
  if off > 0 and os.time() - lastMove > 6 then off = 0 end
  if off < 0 then off = 0 end
  if off > mx then off = mx end
  if off ~= num(SKIN:GetVariable('Offset'), 0) then
    SKIN:Bang('!SetVariable Offset ' .. off)
  end
  SKIN:Bang('!SetVariable MaxOffset ' .. mx)

  if #rows == 0 then
    set('Msg', 'Text', 'no events in the next 7 days')
    set('Msg', 'Hidden', 0)
  else
    set('Msg', 'Hidden', 1)
  end
  SKIN:Bang('!UpdateMeter Msg')

  layout(rows, off)
  return tostring(#inRange)
end
