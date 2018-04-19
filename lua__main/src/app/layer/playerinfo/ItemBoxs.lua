-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-9 11:45:40 星期四
-- Description: 头像分类
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")


local nRowHWidthBot = 120	--底部文字行高度
local nRowH = 100	--行高度
local nTitleH = 80	--标题区域高度
local nRowNum = 5   --每行显示个数
local nItemWidth= 600   --每行显示个数
local ItemBoxs = class("ItemBoxs", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType：TypeItemIconsSize（大小类型）
function ItemBoxs:ctor( _data , nId )
	-- body
	self:myInit()
	if _data then
		self.tCurData = _data
	end
	if nId then
		self.sID = nId	
	end
	
	parseView("lay_icon_show", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemBoxs:myInit(  )
	-- body
	self.sID = ""
	self.tIcons = {}
end

--解析布局回调事件
function ItemBoxs:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemBoxs",handler(self, self.onDestroy))
end

--初始化控件
function ItemBoxs:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLayTitle = self:findViewByName("lat_title")	
	self.pImgL = self:findViewByName("img_left")
	self.pImgR = self:findViewByName("img_right")
	self.pImgL:setFlippedX(true)
	self.pLbTitle = self:findViewByName("lb_title")

	self.pLayCont = self:findViewByName("lay_cont")
	self.pLayRoot:setBackgroundImage("ui/daitu.png",{scale9 = false})
end

-- 修改控件内容或者是刷新控件数据
function ItemBoxs:updateViews( )
	-- body
	--dump(self.tCurData, "self.tCurData", 100)
	if not self.tCurData or #self.tCurData <= 0 then
		return
	end	

	local pBoxData = self.tCurData[1]	
	
	local bShowHadMore = false
	if pBoxData.nTime and tonumber(pBoxData.nTime) > 0 then		
		bShowHadMore = true
	end

	local nRowHeight = nRowH
	if bShowHadMore then
		nRowHeight = nRowHWidthBot
	end

	local nRow = math.ceil(#self.tCurData/nRowNum)

	local nHeight = nTitleH + nRow*nRowHeight	
	--设置标题
	self.pLbTitle:setString(pBoxData.sIntroduce, false)
	self.pLbTitle:setPositionX(self.pLayTitle:getWidth()/2)
	self.pImgL:setPositionX(self.pLayTitle:getWidth()/2 - self.pLbTitle:getWidth()/2 - 20)
	self.pImgR:setPositionX(self.pLayTitle:getWidth()/2 + self.pLbTitle:getWidth()/2 + 20)		

	local nY = nHeight - nTitleH - nRowHeight
	local nCnt = #self.tCurData
	local bDouble = nCnt%2 == 0	
	local nScale = 0.8
	for k, v in pairs(self.tCurData) do
		local x = 0
		local y = 0
		if nCnt <= nRowNum then
			local nMid = math.ceil(nCnt/2)
			if bDouble then
				x = self.pLayCont:getWidth()/2 + (k - nMid - 1)*(120) + 60				
			else
				x = self.pLayCont:getWidth()/2 + (k - nMid)*(120)				
			end				
		else
			x = 65 + ((k - 1)%nRowNum)*120
		end
		y = nY - math.floor((k-1)/nRowNum)*nRowHeight
		if not self.tIcons[k] then
			local pIcon = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.box)			
			pIcon:setIconIsCanTouched(true)
			pIcon:setIconClickedCallBack(self._IconHandler)			
			pIcon:setScale(nScale)
			self.pLayCont:addView(pIcon,2)
			self.tIcons[k] = pIcon
		end			
		if bShowHadMore then
			self.tIcons[k]:setPosition(x - self.tIcons[k]:getWidth()/2*nScale, y)		
		else
			self.tIcons[k]:setPosition(x - self.tIcons[k]:getWidth()/2*nScale, y - 25)		
		end				
		self.tIcons[k]:setCurData(v)			
		self.tIcons[k]:setIconSelected(self.sID == v.sTid)
	end
	local nCnt = #self.tCurData 
	for k, v in pairs(self.tIcons) do
		if k <= nCnt then
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end
	if pBoxData.nTime > 0 then
		regUpdateControl(self, handler(self, self.onUpdateTime))		
	else
		unregUpdateControl(self)--停止计时刷新
	end

	self:setContentSize(cc.size(nItemWidth , nHeight))	
	self.pLayRoot:setContentSize(cc.size(nItemWidth , nHeight))	
	self.pLayTitle:setPosition((nItemWidth - self.pLayTitle:getWidth())/2,nHeight - nTitleH)
	self.pLayCont:setContentSize(cc.size(nItemWidth , nRow*nRowHeight))
end

function ItemBoxs:onUpdateTime(  )
	-- body
	for k, v in pairs(self.tIcons) do
		local pData = self.tCurData[k]
		if v:isVisible() and pData and pData.nTime > 0 then
			if pData:getBoxCdTime() > 0 then
				local nLeftTime = pData:getBoxCdTime()
				v:setMoreText(getIconBoxUseTime(nLeftTime))
			else				
				v:setMoreText(getConvertedStr(6, 10652))
			end
			if v.pLbMore then
				v.pLbMore:setScale(1 / 0.8)
			end
		else
			v:setMoreText("")
		end
	end	
end

-- 析构方法
function ItemBoxs:onDestroy(  )
	-- body
	self:onPause()
end

function ItemBoxs:setCurData( _data , nId)
	-- body
	self.tCurData = _data
	self.sID = nId or ""
	self:updateViews()
end

function ItemBoxs:setIconClickHandler( _handler )
	-- body
	self._IconHandler = _handler
	for k, v in pairs(self.tIcons) do
		v:setIconClickedCallBack(self._IconHandler)			
	end		
end

-- 注册消息
function ItemBoxs:regMsgs( )
	-- body
end

-- 注销消息
function ItemBoxs:unregMsgs(  )
	-- body
end


--暂停方法
function ItemBoxs:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)--停止计时刷新
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function ItemBoxs:onResume(  )
	-- body
	self:updateViews()
	-- 注册消息
	self:regMsgs()		
end
return ItemBoxs