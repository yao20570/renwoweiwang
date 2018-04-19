-- 拆分出单个字符
local function stringToChars(str)
    -- 主要用了Unicode(UTF-8)编码的原理分隔字符串
    -- 简单来说就是每个字符的第一位定义了该字符占据了多少字节
    -- UTF-8的编码：它是一种变长的编码方式
    -- 对于单字节的符号，字节的第一位设为0，后面7位为这个符号的unicode码。因此对于英语字母，UTF-8编码和ASCII码是相同的。
    -- 对于n字节的符号（n>1），第一个字节的前n位都设为1，第n+1位设为0，后面字节的前两位一律设为10。
    -- 剩下的没有提及的二进制位，全部为这个符号的unicode码。
    local list = {}
    local shiftList = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
        table.insert(shiftList, shift)
    end
    return list, shiftList
end

--富文本扩展，效率不是很高，实现了居中或左对齐，\n换行，下划线（兼容老版本，具体看最下面的示例）
local RichTextEx = class("RichTextEx", function ()
    return display.newLayer()
    -- local pLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- pLayer:ignoreAnchorPointForPosition(false)
    -- return pLayer
end)

local NORMAL_TEXT = 0

-- 目前支持的标签定义, 从1开始且连续
local FONT_COMPONENT = 1     -- 不同颜色
local IMG_COMPONENT = 2 -- 图片
local DEFAULT_FONT = "微软雅黑"
local NEW_LINE_CHAT = "\\n"--换行

local COMPONENT_CONFIG = {
    [FONT_COMPONENT] = {
        ["all"] = "<%s-font.->.-</%s-font%s->",
        ["color"] = "color%s-=%s-'-#-([%w_]+)'-%s-",--兼容旧版本
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
}

--全局Chat记录表,只记录不同非中文尺寸的字符
RICHTEXT_CHAT_CONFIG = {
    tCn = {},
    tEn = {},
} --

--------------------------------------------------------------------------------------------
-- BEGIN
--------------------------------------------------------------------------------------------
function RichTextEx:ctor( params )
    params = params or {}
    self.m_components = {}
    self.m_color      = params.color or "c6c7da" --默认文本颜色
    self.m_size       = params.size or 20 --默认文本尺寸
    self.m_width      = params.width or display.width --最大宽度，超过则自动换行
    self.m_autowidth  = params.autow -- 是否自动宽度,取最长的行作为宽度
    self.m_lineoffset = params.lineoffset or 0  --默认行距
    self.m_align      = params.align or 0 --默认,0:左对齐，1，居中
    self.m_maxlinecount = params.maxlinecount or 99999999 --默认99999999, 显示的最大行数,超过了则不渲染了
end

function RichTextEx:setText( _content )
    self.m_content    = _content
    self:clearPrevData()
    self:update()
    self:setLayout()
end

function RichTextEx:update(  )
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
    --排序
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
end


--Fix:下划线跨颜色时,补全<u>或</u>
local bIsUnline = false
function RichTextEx:render(  )
    
    bIsUnline = false

    for i = 1, #self.m_components, 1 do
        local comp = self.m_components[i]
        local text = comp.text
        if comp.type == NORMAL_TEXT then
            self:handleNormalTextRender( text )
        elseif comp.type == FONT_COMPONENT then
            self:handleFontTextRender( text )
        elseif comp.type == IMG_COMPONENT then
            self:handleImgRender( text )
        elseif comp.type == UNDER_LINE then

        end
    end
end



--清空上一次数据
function RichTextEx:clearPrevData(  )
    self:removeAllChildren()--移除之前的所有精灵
    self.pTextGetChat = nil
    self.tLineList = {}--清空所有数据
    self.nLineIndex = 0
end

--获取当前行
function RichTextEx:getCurrLine(  )
    return self.tLineList[self.nLineIndex]
end

--获取当前行的剩余长度
function RichTextEx:getLineRemainW( tLine )
    if tLine then
        return tLine.nRemainW
    end
end

--更新当前行的剩余长度
function RichTextEx:subLineRemainW( tLine, nSubW )
    if tLine then
        tLine.nRemainW = tLine.nRemainW - nSubW
    end
end

--插入新的空行
function RichTextEx:addNewLine(  )
    if self.m_maxlinecount <= self.nLineIndex then
        return false
    end

    self.nLineIndex = self.nLineIndex + 1
    self.tLineList[self.nLineIndex] = {
        tObjList = {},
        nObjIndex = 0,
        nRemainW = self.m_width,
    }
    return true
end

--插入Obj
function RichTextEx:addObj( tLine, tObj )
    table.insert(tLine.tObjList, tObj)
    tLine.nObjIndex = tLine.nObjIndex + 1
end

--获取最后插入的Obj
function RichTextEx:getPrevObj( tLine )
    return tLine.tObjList[tLine.nObjIndex]
end

--插入文本数据
function RichTextEx:addOneChat( sChat, sColor, nFontSize, bUnderLine, nChatWidth)
    local tLine = self:getCurrLine()
    if not tLine then
        local ret = self:addNewLine()
        if ret == false then
            return
        end
        tLine = self:getCurrLine()
    end
    --剩余长度
    local nRemainW = self:getLineRemainW(tLine)
    --当前剩余长度可以容纳
    if nRemainW >= nChatWidth then
        local tObj = self:getPrevObj(tLine)
        if tObj and tObj.sStr and
            tObj.sColor == sColor and
            tObj.nFontSize == nFontSize and
            tObj.bUnderLine == bUnderLine then
            tObj.sStr = tObj.sStr .. sChat
        else
            local tObj = {
                sStr = sChat,
                sColor = sColor,
                nFontSize = nFontSize,
                bUnderLine = bUnderLine,
            }
            self:addObj(tLine, tObj)
        end
    else --创建新行
        local ret = self:addNewLine()
        if ret == false then
            return
        end
        tLine = self:getCurrLine()
        local tObj = {
            sStr = sChat,
            sColor = sColor,
            nFontSize = nFontSize,
            bUnderLine = bUnderLine,
        }
        self:addObj(tLine, tObj)
    end
    --更新剩余长度
    self:subLineRemainW(tLine, nChatWidth)
end

--插入图片数据
function RichTextEx:addImage( pImg, nWidth, nHeight)
    local tLine = self:getCurrLine()
    if not tLine then
        local ret = self:addNewLine()
        if ret == false then
            return
        end
        tLine = self:getCurrLine()
    end
    --剩余长度
    local nRemainW = self:getLineRemainW(tLine)
    --创建新行
    if nRemainW < nWidth then
        local ret = self:addNewLine()
        if ret == false then
            return
        end
        tLine = self:getCurrLine()
    end
    local tObj = {
        pImg = pImg,
        nWidth = nWidth,
        nHeight = nHeight,
    }
    self:addObj(tLine, tObj)
    --更新剩余长度
    self:subLineRemainW(tLine, nWidth)
end

-- 解析16进制颜色rgb值
function RichTextEx:convertColor( xstr )
    if not xstr then return 
    end
    local toTen = function (v)
        return tonumber("0x" .. v)
    end

    local b = string.sub(xstr, -2, -1) 
    local g = string.sub(xstr, -4, -3) 
    local r = string.sub(xstr, -6, -5)

    local red = toTen(r)
    local green = toTen(g)
    local blue = toTen(b)
    if red and green and blue then 
        return cc.c4b(red, green, blue, 255)
    end
end

--下划线分割文本
function RichTextEx:splitByUnderLineChat( _text )
    local st = 0
    local en = 0
    local tTextList = {}
    while true do
        local nStartIndex = st + 1
        local nS1, nE1 = string.find(_text, "<u>", nStartIndex)
        if nS1 then
            bIsUnline = true
            local nS2, nE2 = string.find(_text, "</u>", nE1 + 1)
            if nS2 then
                --前部分
                if nS1 > nStartIndex then
                    local sStr = string.sub(_text, nStartIndex, nS1 - 1)
                    if sStr ~= "" then
                        table.insert(tTextList, {text = sStr})
                    end
                end
                --后部分
                local sStr = string.sub(_text, nE1 + 1, nS2 - 1)
                if sStr ~= "" then
                    table.insert(tTextList, {text = sStr, bUnderLine = true})
                end

                -- 下划线结束
                bIsUnline = false
                -- 下一循环
                st = nE2

            else
                --下划线还没结束
                local sStr = string.sub(_text, nE1 + 1, string.len(_text))
                if sStr ~= "" then
                    table.insert(tTextList, {text = sStr, bUnderLine = true})
                end
                
                break
            end
        else 
            
            if bIsUnline == true then
                --上一段文字延续下来的下划线
                local nS2, nE2 = string.find(_text, "</u>", nStartIndex)
                if nS2 then                    
                    local sStr = string.sub(_text, nStartIndex, nS2 - 1)
                    if sStr ~= "" then
                        table.insert(tTextList, {text = sStr, bUnderLine = true})
                    end

                    -- 下划线结束
                    bIsUnline = false
                    -- 下一循环
                    st = nE2
                else
                    --下划线还没结束
                    local sStr = string.sub(_text, nStartIndex, string.len(_text))
                    if sStr ~= "" then
                        table.insert(tTextList, {text = sStr, bUnderLine = true})
                    end
                    break
                end
            else
                -- 没有下划线
                local sStr = string.sub(_text, nStartIndex, string.len(_text))
                if sStr ~= "" then
                    table.insert(tTextList, {text = sStr})
                end
                break
            end
            
        end
    end
    -- dump(tTextList, "tTextList=", 100)
    return tTextList
end

--换行分割文本
function RichTextEx:splitByChangeLine( _text )
    local st = 0
    local en = 0
    local tTextList = {}
    while true do
        local nStartIndex = st + 1
        local nS1, nE1 = string.find(_text, NEW_LINE_CHAT, nStartIndex, true)
        if nS1 then
            --前部分
            if nS1 > nStartIndex then
                local sStr = string.sub(_text, nStartIndex, nS1 - 1)
                if sStr ~= "" then
                    table.insert(tTextList, {text = sStr})
                end
            end
            table.insert(tTextList, {text = NEW_LINE_CHAT})
            st = nE1
        else --不满足条件，直接所有
            local sStr = string.sub(_text, nStartIndex, string.len(_text))
            if sStr ~= "" then
                table.insert(tTextList, {text = sStr})
            end
            break
        end
    end
    return tTextList
end

--设置格局
function RichTextEx:setLayout(  )
    local nWidthMax = self.m_width
    local nHeightMax = 0
    --dump(self.tLineList, "self.tLineList", 100)
    for i=1,#self.tLineList do
        
        local tLine = self.tLineList[i]
        local nLineHeight = 0
        local nLineWidth = 0
        for j=1,#tLine.tObjList do
            local tObj = tLine.tObjList[j]
            if tObj.pImg then
                self:addChild(tObj.pImg)
                --更新行高和宽
                nLineHeight = math.max(nLineHeight, tObj.nHeight)
                nLineWidth = nLineWidth + tObj.nWidth
            elseif tObj.sStr then
                --初始化文本
                local pColor = self:convertColor(tObj.sColor)
                tObj.pTxt = display.newTTFLabel({
                    text = tObj.sStr,
                    font = DEFAULT_FONT, --不经常变所以用默认
                    size = tObj.nFontSize,
                    color = pColor,
                })
                tObj.pTxt:setAnchorPoint(0, 0)
                if self.pTextC4b and self.pTextOutLine then
                    tObj.pTxt:enableOutline(self.pTextC4b, self.pTextOutLine)
                end
                self:addChild(tObj.pTxt)

                --记录真正的宽度和高度
                local pSize = tObj.pTxt:getContentSize()
                tObj.nWidth = pSize.width
                tObj.nHeight = pSize.height
                --更新行高和宽
                nLineHeight = math.max(nLineHeight, tObj.nHeight)
                nLineWidth = nLineWidth + tObj.nWidth

                --下划线
                if tObj.bUnderLine then
                    local pUnderLine = cc.DrawNode:create() 
                    pUnderLine:setAnchorPoint(0, 0) 
                    self:addChild(pUnderLine)  
                    pUnderLine:drawSolidRect(cc.p(0, 0), cc.p(tObj.nWidth,1), cc.c4f(pColor.r/255,pColor.g/255,pColor.b/255,1))
                    tObj.pUnderLine = pUnderLine
                end
            end
        end
        if nLineHeight == 0 then--空行时处理
            tLine.nLineWidth = self.m_width
            tLine.nLineHeight = self.m_size
        else --普通处理
            tLine.nLineWidth = nLineWidth
            tLine.nLineHeight = nLineHeight
        end
        --整体高
        if i > 1 then --行间隔
            nHeightMax = nHeightMax + tLine.nLineHeight + self.m_lineoffset
        else
            nHeightMax = nHeightMax + tLine.nLineHeight
        end
    end

    if self.m_autowidth then   
        nWidthMax = 0     
        for k, v in pairs(self.tLineList) do
            nWidthMax = math.max(self.tLineList[k].nLineWidth, nWidthMax)
        end
    end
    --设置整体大小
    self:setContentSize(nWidthMax, nHeightMax)

    -- dump(self.tLineList, "self.tLineList=", 100)
    --排列位置
    local nY = nHeightMax
    for i=1,#self.tLineList do
        local tLine = self.tLineList[i]
        local nX = 0
        if self.m_align == 1 then --居中
            nX = math.max((nWidthMax - tLine.nLineWidth)/2, 0)
        end
        nY = nY - tLine.nLineHeight
        for j=1,#tLine.tObjList do
            local tObj = tLine.tObjList[j]
            if tObj.pImg then
                tObj.pImg:setPosition(nX, nY)
                nX = nX + tObj.nWidth
            elseif tObj.pTxt then
                tObj.pTxt:setPosition(nX, nY)
                if tObj.pUnderLine then
                    tObj.pUnderLine:setPosition(nX, nY)
                end
                nX = nX + tObj.nWidth
            end
        end
        nY = nY - self.m_lineoffset--行间隔
    end
end

--处理不带任何标识的文本
function RichTextEx:handleNormalTextRender( _text )
    if not _text or _text == ""  then
        return
    end
   
    local tTextList = {}
     --分割下划线符
    local tTextList1 = self:splitByUnderLineChat(_text)
    for i=1,#tTextList1 do
        local bUnderLine = tTextList1[i].bUnderLine
        --换行分割文本
        local tTextList2 = self:splitByChangeLine(tTextList1[i].text)
        for j=1,#tTextList2 do
            table.insert(tTextList, {text = tTextList2[j].text, bUnderLine = bUnderLine})
        end
    end

    for i=1,#tTextList do
        local sText = tTextList[i].text
        if sText == NEW_LINE_CHAT then
            local ret = self:addNewLine()
            if ret == false then
                return
            end
        else
            local bUnderLine = tTextList[i].bUnderLine
            --插入单个字符
            local tChar, tShift = stringToChars(sText)
            for j=1,#tChar do
                local sChar = tChar[j]
                local nChatWidth = self:getOneChatWidth(sChar, self.m_size, tShift[j] == 1)
                self:addOneChat(sChar, self.m_color, self.m_size, bUnderLine, nChatWidth)
            end
        end
    end
end

function RichTextEx:handleFontTextRender( _text )
    if not _text or _text == ""  then
        return
    end
    local content = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["content"] ) or ""
    if content == "" then
        return
    end
    local color = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["color"] ) or self.m_color
    local size  = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["size"] ) or self.m_size
    local nFontSize = tonumber(size)
    if nFontSize then
       size = nFontSize
    end
    
    local tTextList = {}
     --分割下划线符
    local tTextList1 = self:splitByUnderLineChat(content)
    for i=1,#tTextList1 do
        local bUnderLine = tTextList1[i].bUnderLine
        --换行分割文本
        local tTextList2 = self:splitByChangeLine(tTextList1[i].text)
        for j=1,#tTextList2 do
            table.insert(tTextList, {text = tTextList2[j].text, bUnderLine = bUnderLine})
        end
    end
    
    for i=1,#tTextList do
        local sText = tTextList[i].text
        if sText == NEW_LINE_CHAT then
            local ret = self:addNewLine()
            if ret == false then
                return
            end
        else
            local bUnderLine = tTextList[i].bUnderLine
            --插入单个字符
            local tChar, tShift = stringToChars(sText)
            for j=1,#tChar do
                local sChar = tChar[j]
                local nChatWidth = self:getOneChatWidth(sChar, size, tShift[j] == 1)
                self:addOneChat(sChar, color, size, bUnderLine, nChatWidth)
            end
        end
    end
end

function RichTextEx:handleImgRender( _text )
  local src = string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "src" ] )
  local width = tonumber(string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "width" ] ))
  local height = tonumber(string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "height" ] ))

  -- print( ">>>> handleImgRender: " .. src .. ", w: " .. (width or "") .. ", h: " .. (height or "") )

  if src then
    local pImg = display.newSprite(src)
    local pSize = pImg:getContentSize()
    if width and height then
        pImg:setScaleX(width/pSize.width)
        pImg:setScaleY(height/pSize.height)
    else
        width = pSize.width
        height = pSize.height
    end
    pImg:setAnchorPoint(0, 0)
    self:addImage(pImg, width, height)
  end
end

function RichTextEx:setOutline( c4b, size)
    self.pTextC4b = c4b
    self.pTextOutLine = size
end

--兼容当前项目
function RichTextEx:setString( tStr )
    if not tStr then
        return
    end

    if type(tStr) == "string" then
        self:setText(tStr)
    elseif type(tStr) == "table" then
        local sStr = ""
        for i=1,#tStr do
            local tData = tStr[i]
            if tData.text then --文字
                sStr = sStr .. string.format("<font color = %s size = %s>%s</font>", tData.color or self.m_color, tData.size or self.m_size, tData.text)
            elseif tData.img then --图片
                if tData.width and tData.height then
                    sStr = sStr .. string.format("<img src = \"%s\" width = %s height = %s />", tData.img, tData.width, tData.height)
                else
                    sStr = sStr .. string.format("<img src = \"%s\" />", tData.img)
                end
            end
        end
        self:setText(sStr)
    end
end

--添加字符长度
--sChat，文本
--nFontSize，字体大小
--bIsEn, 是否为英文
function RichTextEx:getOneChatWidth( sChat, nFontSize, bIsEn)
    if bIsEn then
        local tChatList = RICHTEXT_CHAT_CONFIG.tEn[nFontSize]
        if tChatList then
            local nWidth = tChatList[sChat]
            if nWidth then
                return nWidth
            end
        end
    else
        local nWidth = RICHTEXT_CHAT_CONFIG.tCn[nFontSize]
        if nWidth then
            return nWidth
        end
    end
    return self:createOneChatWidth(sChat, nFontSize, bIsEn)
end

--sChat，文本
--nFontSize，字体大小
--bIsEn, 是否为英文
function RichTextEx:createOneChatWidth( sChat, nFontSize, bIsEn )
    if self.pTextGetChat then
        self.pTextGetChat:setString(sChat)
        self.pTextGetChat:setSystemFontSize(nFontSize)
    else
        self.pTextGetChat = display.newTTFLabel({
                    text = sChat,
                    font = DEFAULT_FONT, --不经常变所以用默认
                    size = nFontSize,
                })
        self.pTextGetChat:setVisible(false)
        self:addChild(self.pTextGetChat)
    end
    local nWidth = self.pTextGetChat:getContentSize().width
    if bIsEn then
        if not RICHTEXT_CHAT_CONFIG.tEn[nFontSize] then
            RICHTEXT_CHAT_CONFIG.tEn[nFontSize] = {}
        end
        RICHTEXT_CHAT_CONFIG.tEn[nFontSize][sChat] = nWidth
    else
        RICHTEXT_CHAT_CONFIG.tCn[nFontSize] = nWidth
    end
    return nWidth
end

return RichTextEx

--[[-------------------示例
function MainScene:richTextTest(  )
    local sHtml = "<font color=848484>主公</font><font color=77d4fd><u>45级</u></font><img src=\"#emo_1.png\"/><font color=848484>可以对所在区域的系统城池发起国战</font>"
    local RichTextEx = require("app.scenes.RichTextEx")
    local pRichText = RichTextEx.new({width = 200, lineoffset = 10, align = 0})
    pRichText:setPosition(cc.p(display.cx,display.cy))
    pRichText:setString(sHtml)
    pRichText:setAnchorPoint(0.5, 0.5)
    self:addChild(pRichText)
end

function MainScene:richTextTest2(  )
    local sHtml = "1.<font color='#f5d93d'>击败乱军</font>可获得各种<font color='#f5d93d'>纣王召唤券</font>，用于召唤纣王\n2.击败纣王可获得丰厚奖励及信物，<font color='#f5d93d'>信物</font>可用于兑换各种奖励"
    local RichTextEx = require("app.scenes.RichTextEx")
    local pRichText = RichTextEx.new({width = 200, lineoffset = 10, align = 0})
    pRichText:setPosition(cc.p(display.cx,display.cy))
    pRichText:setString(sHtml)
    pRichText:setAnchorPoint(0.5, 0.5)
    self:addChild(pRichText)
end

function MainScene:richTextTest3(  )
    local sHtml = "城防武将:ffffff;满耐力:f5d93d;<u>才可参与防守</u>:ffffff;\n每分钟消耗:ffffff;600粮草补充600耐力:f5d93d;\n更换新武将耐力需要:ffffff;重新补充:f5d93d"
    local RichTextEx = require("app.scenes.RichTextEx")
    local pRichText = RichTextEx.new({width = 200, lineoffset = 10, align = 0})
    pRichText:setPosition(cc.p(display.cx,display.cy))
    pRichText:setString(self:getTextColorByConfigure(sHtml))
    pRichText:setAnchorPoint(0.5, 0.5)
    self:addChild(pRichText)
end

function MainScene:richTextTest4(  )
    local sHtml = "<font color='#31d840'>占领殿、宫</font>全国可获得<font color='#31d840'>国家百姓加成</font>\n本国殿范围内进行<font color='#31d840'>采集</font>、<font color='#31d840'>击杀乱军</font>能为殿提供经"
    local RichTextEx = require("app.scenes.RichTextEx")
    local pRichText = RichTextEx.new({width = 200, lineoffset = 10, align = 0})
    pRichText:setPosition(cc.p(display.cx,display.cy))
    pRichText:setString(sHtml)
    pRichText:setAnchorPoint(0.5, 0.5)
    self:addChild(pRichText)
end

function MainScene:richTextTest4(  )
    local sHtml = "<font color='#31d840'>占领殿、宫</font>全国可获得<font color='#31d840'>国家百姓加成</font>\n本国殿范围内进行<font color='#31d840'>采集</font>、<font color='#31d840'>击杀乱军</font>能为殿提供经"
    local RichTextEx = require("app.scenes.RichTextEx")
    local pRichText = RichTextEx.new({width = 200, lineoffset = 10, align = 0})
    pRichText:setPosition(cc.p(display.cx,display.cy))
    pRichText:setString(sHtml)
    pRichText:setAnchorPoint(0.5, 0.5)
    self:addChild(pRichText)
end
--]]