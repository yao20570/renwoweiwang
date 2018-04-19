-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-17 10:41:57 星期一
-- Description: 富文本控件
-----------------------------------------------------

-------------------------------------------------------------------------------------------
--   例子如下：
	-- local MRichLabel = require("app.common.richview.MRichLabel")
	-- local str = json.encode({{color="a2abcc",text="主公，是否花费金币购买"},{color="41b3e2",text="100"},{color="a2abcc",text="体力？"},{image = "#v1_btn_red1.png"}})
	-- --[[
	-- str:字符串 fontSize:字体大小  rowWidth:行宽 rowSpace:行间距
	-- --]]
 --    local ricLab = MRichLabel.new({str=str, fontSize=24, rowWidth=280})
 --    ricLab:setPosition(cc.p(display.width / 2, display.height/ 2))
 --    self:addView(ricLab,20000)
 --    -- 添加事件监听函数
 --    local function listener(pView, number)
 --        if number == 998 then
 --            print("预约事件")
 --        end
 --    end
 --    ricLab:setClickEventListener(listener)
-------------------------------------------------------------------------------------------

local json = require("framework.json")
local MCommonView = require("app.common.MCommonView")

local ChineseSize = 3 -- 修正宽度缺陷(范围:3~4)
local MRichLabel = class("MRichLabel", function()
    return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--[[
--需要传入一个tab
--坐标最好传固定数值
-- param = {str, font, fontSize, rowWidth, rowSpace}
--]]
function MRichLabel:ctor(param, auto)
	self:myInit()
	if not param.str then
		print("传入的字符串为nil")
	end
	if not param.font then
		param.font = MUI.DEFAULT_FONT
	end
	param.fontSize = param.fontSize or 22       --字体大小
	param.rowWidth = param.rowWidth or 280      --内容宽度
	param.rowSpace = param.rowSpace or 4 		--行间隔
	-- 字体赋值
	self.font = param.font
	self.fontsize = param.fontSize
	-- 隐藏的文本控件（用来计算大小来的）
	self.pLabelHide = MUI.MLabel.new({
	    text = "test",
	    size = param.fontSize,
	    font = self.font,
	})
	self.pLabelHide:setPosition(self:getWidth() / 2, self:getHeight() / 2)
	self.pLabelHide:setVisible(false)
	self:addView(self.pLabelHide)

	-- 初始化数据
	local tTextTab = self:initData(param.str, param.font, param.fontSize, param.rowWidth)
	-- 纯字符表,渲染表
	self.ptab, self.copyVar = self:automaticNewline(tTextTab) 
	-- 设置富文本控件大小
	local nH = table.nums(self.ptab) * (self.fontsize + param.rowSpace)
	self:setContentSize(cc.size(param.rowWidth, nH))
	-- self:setBackgroundImage("#v3_bg1.png")

	local ocWidth = 0   -- 当前占宽
	local ocRow   = 1   -- 当前行
	local ocHeight = 0  -- 当前高度
	local nMaxWidth = 0 --最大宽度
	local view,useWidth,useHeight = 0,0,0
	for k,v in pairs(self.copyVar) do
		local params = {}
		self:tab_addDataTo(params, v)
		-- 计算实际渲染宽度
		if params.row == ocRow then
			ocWidth = ocWidth + useWidth
		else
			ocRow = params.row
			ocWidth = 0
			-- 计算实际渲染高度
			ocHeight = ocHeight + useHeight + param.rowSpace --修正高度间距
		end
		local maxsize = params.size 
		local byteSize = math.floor((maxsize + 2) / ChineseSize)
		params.width  = byteSize*params.breadth     -- 控件宽度
		params.height = maxsize                     -- 控件高度
		params.x = ocWidth       					-- 控件x坐标
		params.y = nH-(ocHeight)                    -- 控件y坐标
		params.scene = self
		view,useWidth,useHeight = self:creatViewObj(params)

		if nMaxWidth < ocWidth + useWidth then
			nMaxWidth = ocWidth + useWidth
		end
	end
	ocWidth = ocWidth + useWidth
	--重置宽度
	if nMaxWidth < param.rowWidth then
		self:setLayoutSize(nMaxWidth, nH)
	end
end

--初始化成员变量
function MRichLabel:myInit(  )
	-- body
	self.font 		= nil  --字体
	self.fontsize 	= nil  --字体大小
end

-- 初始化数据(解析为规定的格式)
-- _str：内容
-- _font: 字体
-- _fontSize：字体大小
-- _rowWidth：每一行宽度
function MRichLabel:initData(_str, _font, _fontSize, _rowWidth)
	_str = json.encode(_str) --设置成josn格式
    local tTab = self:parseString(_str, {font = _font, size = _fontSize})
    local var = {}
    var.tab = tTab          -- 文本字符
    var.width = _rowWidth   -- 指定宽度
    return var
end

--根据初始化后获得渲染表
--var：初始化并格式化的数据table
function MRichLabel:automaticNewline( var )
	-- 根据限定的宽度, 再切割。确定行数
	local allTab = {}   -- 总的字符数组
	local copyVar = {}  -- 准备渲染的数组
	local useLen = 0    -- 记录该行使用长度信息
	local str = ""		-- 储存该行字符
	local current = 1 	-- 记录最大行数
	for ktb, tab in ipairs(var.tab) do
		-- 切割字符串数组,字符数
		local txtTab = self:comminuteText(tab.text)   
		-- 每一行最多能完整放下几个字符
		local num = math.floor((var.width) / math.ceil((tab.size) / ChineseSize))
		-- 最后一行被占用却未占满先填满
		if useLen > 0 then
			local remain = num - useLen
			local txtLen = self:accountTextLen(tab.text, tab.size)
			if txtLen <= remain then -- 新的文本块长度小于剩余长度则直接拼接 
				allTab[current] = allTab[current] .. tab.text
				self:addDataToRenderTab(copyVar, tab, tab.text, (useLen + 1), current, txtLen)
				useLen = useLen + txtLen
				txtTab = {}
			else -- 填满最后一行
				local cTag = 0
				local mstr = ""
				local sIndex = useLen+1
				local s_Len = 0
				for k,element in pairs(txtTab) do
					local sLen = self:accountTextLen(element, tab.size)
					if (useLen + sLen) <= num then
						useLen = useLen + sLen
						s_Len = s_Len + sLen
						cTag = k
						mstr = mstr .. element
					else
						if string.len(mstr) > 0 then
							allTab[current] = allTab[current] .. mstr
							self:addDataToRenderTab(copyVar, tab, mstr, (sIndex), current, s_Len)
						end
						current = current+1
						useLen = 0          -- 重算占用长度
						str = ""            -- 重新填充字符
						s_Len = 0
						break
					end
				end
				for i=1,cTag do
					table.remove(txtTab, 1)
				end
			end	
		end
		-- 填充字符
		for k,element in pairs(txtTab) do
			local sLen = self:accountTextLen(element, tab.size)
			if (useLen + sLen) <= num then 
				useLen = useLen + sLen -- 记录字符已占用该行长度
				str = str .. element   -- 拼接该行字符
			else
				allTab[current] =  str -- 储存已经装满字符的行 
				self:addDataToRenderTab(copyVar, tab, str, 1, current, useLen)
				current = current + 1  -- 开辟新的一行
				useLen = sLen          -- 重算占用长度
				str = element          -- 重新填充字符
			end
			if k == #txtTab then -- 最后一行字符占用情况
				if useLen <= num then 
					allTab[current] = str
					self:addDataToRenderTab(copyVar, tab, str, 1, current, useLen)
				end
			end
		end
	end
	return allTab, copyVar
end

--创建控件
function MRichLabel:creatViewObj(params)
	if not params.image then 
        local lab = MUI.MLabel.new({
            text=params.text,
            size=params.size,
        	anchorpoint=cc.p(0, 1),
            font = params.font})
        --设置颜色
        if params.color then
        	lab:setTextColor(params.color)
        end
        lab:setPosition(cc.p(params.x, params.y))
        lab:setTouchSwallowEnabled(false)
        lab:setName("rich_" .. params.number)
        params.scene:addView(lab)
	    --设置点击事件
		lab:setViewTouched(true)
		lab:setIsPressedNeedScale(false)
		lab:setIsPressedNeedColor(false)
	    lab:onMViewClicked(function ( pView )
			-- body
			if self.listener then 
				self.listener(pView,params.number) 
			end
		end )
		local useWidth = lab:getContentSize().width
	    local useHeight = lab:getContentSize().height
        return lab,useWidth,useHeight
	else
		--图片
		local pImg = MUI.MImage.new(params.image, {scale9=false})
		params.scene:addView(pImg)
		pImg:setAnchorPoint(cc.p(0, 1))
		pImg:setPosition(params.x, params.y)
		--设置点击事件
		pImg:setViewTouched(true)
		pImg:setIsPressedNeedScale(false)
		pImg:setIsPressedNeedColor(false)
		pImg:onMViewClicked(function ( pView )
			-- body
			if self.listener then 
				self.listener(pView,params.number) 
			end
		end )
	    --计算缩放值
	    local fSx = self.fontsize / pImg:getContentSize().width
	    local fSy = self.fontsize / pImg:getContentSize().height
		pImg:setScaleX(fSx)
		pImg:setScaleY(fSy)
		--默认大小
		local useWidth = self.fontsize
	    local useHeight = self.fontsize
		return pImg,useWidth,useHeight
	end
end

-- 设置监听函数
function  MRichLabel:setClickEventListener(_listener)
	self.listener = _listener
end

-- 解析输入的文本
-- _str：内容
-- _param：参数
function MRichLabel:parseString(_str, _param)
	local tTmp = json.decode(_str)
	if tTmp then
		for k,v in pairs(tTmp) do
			--如果是图片
			if v.image then
				v.text = "口"
			end
			-- 未指定number则自动生成(number：用于标志点击的key)
			if not v.number then
				v.number = k 
			end 
			self:tab_addDataTo(v, _param)
			if v.color then
				--存在颜色标志(转化为cc.3b)
				v.color = getC3B(v.color)
			end
		end
	end
	return tTmp
end

-- 拆分出单个字符
function MRichLabel:comminuteText(str,n)
    local list = {}
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
        local char = string.sub(str, i, i + shift - 1)
        i = i + shift
        table.insert(list, char)
    end
	return list, len
end

--添加到渲染列表中
function MRichLabel:addDataToRenderTab(copyVar, tab, text, index, current, strLen)
	local tag = #copyVar + 1
	copyVar[tag] = {}
	self:tab_addDataTo(copyVar[tag], tab)
	copyVar[tag].text = text 
	copyVar[tag].index = index                  -- 该行的第几个字符开始
	copyVar[tag].row = current                  -- 第几行
	copyVar[tag].breadth = strLen   			-- 所占宽度
	copyVar[tag].tag = tag	-- 唯一下标
end

-- 获取一个格式化后的浮点数
function MRichLabel:str_formatToNumber(number, num)
    local s = "%." .. num .. "f"
    return tonumber(string.format(s, number))
end

--对table重新赋值（按下标）
function MRichLabel:tab_addDataTo(tab, src)
    for k,v in pairs(src) do
        tab[k] = v
    end
end

-- 全角 半角string.len()
function MRichLabel:accountTextLen(str, tsize)
	local list = self:comminuteText(str,1)
	local aLen = 0
	for k,v in pairs(list) do
		local a = string.len(v)
		self.pLabelHide:setString(v,false)
		local width = self.pLabelHide:getContentSize().width
		a = tsize / width
     	local b = self:str_formatToNumber(ChineseSize / a, 4)
     	aLen = aLen + b
	end	
	return aLen
end

--通过标志找到控件
-- _nNum：设置table参数传的number值，没有的话默认下标
function MRichLabel:findViewByNumber( _nNum )
	-- body
	local pView = nil
	if not _nNum then
		return pView
	end
	pView =  self:findViewByName("rich_" .. _nNum)
	return pView
end

--刷新某个label的内容
function MRichLabel:updateLbByNum( _nNum, _sStr ,_color)
	-- body
	_sStr = _sStr or ""
	local pLb = self:findViewByNumber(_nNum)
	if pLb then
		local nOldWidth = pLb:getWidth()
		pLb:setString(_sStr,false)
		if _color then
			pLb:setColor(getC3B(_color))
		end
		local nNowWidth = pLb:getWidth()
		--如果宽度大小改变了，需要调整位置
		if nOldWidth ~= nNowWidth then
			--找出第几行
			local nRow = 1
			local bFind = false
			--找出所有改行的控件
			local tCurRowNum = {}
			for k, v in pairs (self.copyVar) do
				if v.number == _nNum then
					nRow = v.row
					bFind = true
				end
				if bFind then
					if v.row == nRow and v.number ~= _nNum then
						table.insert(tCurRowNum, v.number)
					end
				end
			end
			--调整位置
			if table.nums(tCurRowNum) > 0 then
				--记录重新设置位置后的位置
				local nX = pLb:getPositionX() + pLb:getWidth()
				for k, v in pairs (tCurRowNum) do
					local pView = self:findViewByNumber(v)
					if pView then
						pView:setPositionX(nX)
						nX = nX + pView:getWidth()
					end
				end
			end
		end
	end
end

return MRichLabel
