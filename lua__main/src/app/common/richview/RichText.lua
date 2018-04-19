local RichText = class("RichText", function ()
    return ccui.RichText:create()
end)

local NORMAL_TEXT = 0

-- 目前支持的标签定义, 从1开始且连续
local FONT_COMPONENT = 1     -- 不同颜色
local IMG_COMPONENT = 2 -- 图片
local NEW_LINE_COMPONENT = 3 -- 换行<br>


local DEFAULT_FONT = "微软雅黑"
--
-- ******** color要定义在font.lua里 *************
-- 示例： <font color = DARK_GOLDEN size = 28>金色的字体</font>
--
local COMPONENT_CONFIG = {
    [FONT_COMPONENT] = {
        ["all"] = "<%s-font.->.-</%s-font%s->",
        ["color"] = "color%s-=%s-([%w_]+)%s-",
        ["size"] = "size%s-=%s-(%d+)%s-",
        ["content"] = "<%s-font.->(.*)</%s-font%s->",
    },

      -- <img src = "base_icon.png" width=10 height=10 />
     [IMG_COMPONENT] = {
         ["all"] = "<%s-img%s-src%s-=.-/%s->",
         ["src"] = "src%s-=%s-[\"'](.-)[\"']%s-",
         ["width"] = "width%s-=%s-[\"']*(%d+)[\"']*%s-",
         ["height"] = "height%s-=%s-[\"']*(%d+)[\"']*%s-",
     },

    -- [NEW_LINE_COMPONENT] = {
    --     ["all"] = "<%s-[bB][rR]%s->",
    -- },
}

--------------------------------------------------------------------------------------------
-- BEGIN
--------------------------------------------------------------------------------------------
function RichText:ctor( params )
        params = params or {}
        self.m_components = {}
        self.m_color      = params.color or _cc.pwhite
        self.m_size       = params.size or 20
end

function RichText:setText( _content )
    self.m_content    = _content

    self:update()
end

function RichText:update( ... )
    local PATTERN_CONFIG = COMPONENT_CONFIG
    self.m_components = {}
    
    local totalLen = string.len( self.m_content )
    local st = 0
    local en = 0

    -- 根据配置，在原串中找出所有标记的文本
    for i = 1, #PATTERN_CONFIG, 1 do
        st = 0
        en = 0

        while true do
            st, en = string.find( self.m_content, PATTERN_CONFIG[i]["all"], st + 1 )
            if not st then
                break
            end
            local comp = {}
            comp.sIdx = st
            comp.eIdx = en
            comp.type = i
            comp.text = string.sub( self.m_content, comp.sIdx, comp.eIdx )

            table.insert( self.m_components, comp )
            st = en
        end
    end

    local function sortFunc( a, b )
        return a.sIdx < b.sIdx
    end
    table.sort( self.m_components, sortFunc )

    if #self.m_components <= 0 then
        -- 全部都是普通文本
        local comp = {}
        comp.sIdx = 1
        comp.eidx = totalLen
        comp.type = NORMAL_TEXT
        comp.text = self.m_content
        table.insert( self.m_components, comp )
    else
        local offset = 1
        local newComponents = {}

        for i = 1, #self.m_components, 1 do
            local comp = self.m_components[ i ]
            table.insert( newComponents, comp )

            if comp.sIdx > offset then
                local newComp = {}
                newComp.sIdx = offset
                newComp.eIdx = comp.sIdx - 1
                newComp.type = NORMAL_TEXT
                newComp.text = string.sub( self.m_content, newComp.sIdx, newComp.eIdx )

                table.insert( newComponents, newComp )
            end

            offset = comp.eIdx + 1
        end

        if offset < totalLen then
            local newComp = {}
            newComp.sIdx = offset
            newComp.eIdx = totalLen
            newComp.type = NORMAL_TEXT
            newComp.text = string.sub( self.m_content, newComp.sIdx, newComp.eIdx )

            table.insert( newComponents, newComp )
        end

        self.m_components = newComponents
    end

    table.sort( self.m_components, sortFunc )

    self:render()

    self:formatText()
end

function RichText:render( ... )
    
    for i = 1, #self.m_components, 1 do
        local comp = self.m_components[i]
        local text = comp.text

        if comp.type == NORMAL_TEXT then
            self:handleNormalTextRender( text )
        elseif comp.type == FONT_COMPONENT then
            self:handleFontTextRender( text )
        elseif comp.type == NEW_LINE_COMPONENT then--暂不支持
            self:handleNormalTextRender( text )
        elseif comp.type == IMG_COMPONENT then
            self:handleImgRender( text )
        end
    end
end

function RichText:handleNormalTextRender( _text )
    if not _text then
        return
    end
    local color = self.m_color
    local element = ccui.RichElementText:create(1, getC3B(color), 255, _text or "", DEFAULT_FONT, self.m_size)
    self:pushBackElement( element )
end

function RichText:handleFontTextRender( _text )
    if not _text then
        return
    end
    local content = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["content"] ) or ""
    local color = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["color"] ) or self.m_color
    local size  = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["size"] ) or self.m_size

    local element = ccui.RichElementText:create(1, getC3B(color), 255, content or "", DEFAULT_FONT, size)
    self:pushBackElement( element )
end

function RichText:handleNewLineRender( ... )
    local element = ccui.RichElementNewLine:create(1, self.m_color, 255)
    self:pushBackElement( element )
end

function RichText:handleImgRender( _text )
  local src = string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "src" ] )
  local width = string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "width" ] )
  local height = string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "height" ] )

  -- print( ">>>> handleImgRender: " .. src .. ", w: " .. (width or "") .. ", h: " .. (height or "") )

  if src and width and height then
      local node = display.newNode()
      local pImg = display.newSprite(src)
          :setAnchorPoint(cc.p(0.5,0.5))
          :pos(width/2, height/2)
      node:addChild(pImg)
      node:setContentSize( cc.size(width, height) )
      local pSize = pImg:getContentSize()
      pImg:setScale(width/pSize.width)

      local element = ccui.RichElementCustomNode:create( 1, getC3B(self.m_color), 255, node )
      self:pushBackElement( element )
  end
end

--兼容当前项目
function RichText:setString( tStr )
    if not tStr then
        return
    end

    if type(tStr) == "string" then
        self:setText(tStr)
    elseif type(tStr) == "table" then
        local sStr = ""
        for i=1,#tStr do
            local tData = tStr[i]
            if tData.text then
                sStr = sStr .. string.format("<font color = %s size = %s>%s</font>", tData.color or _cc.pwhite, tData.size or 20, tData.text)
            elseif tData.img then --文字
                sStr = sStr .. string.format("<img src = \"%s\" width = %s height = %s />", tData.img, tData.width or 60, tData.height or 55)
            end
        end
        self:setText(sStr)
    end
end

--统一图标缩放
function RichText:setImgScale( )
end

return RichText