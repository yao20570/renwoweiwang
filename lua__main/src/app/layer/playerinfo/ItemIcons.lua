-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-9 11:45:40 星期四
-- Description: 头像分类
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")


local nRowH = 120	--行高度
local nTitleH = 80	--标题区域高度
local nRowNum = 4   --每行显示个数
local ItemIcons = class("ItemIcons", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemIcons:ctor(_data , nId  )
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
function ItemIcons:myInit(  )
	-- body
	self.sID = ""
	self.tIcons = {}
end

--解析布局回调事件
function ItemIcons:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemIcons",handler(self, self.onDestroy))
end

--初始化控件
function ItemIcons:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLayTitle = self:findViewByName("lat_title")	
	self.pImgL = self:findViewByName("img_left")
	self.pImgR = self:findViewByName("img_right")
	self.pImgL:setFlippedX(true)
	self.pLbTitle = self:findViewByName("lb_title")

	self.pLatCont = self:findViewByName("lay_cont")
end

-- 修改控件内容或者是刷新控件数据
function ItemIcons:updateViews( )
	-- body
	if not self.tCurData or #self.tCurData <= 0 then
		return
	end
	--dump(self.tCurData, "self.tCurData", 100)
	local nRow = math.ceil(#self.tCurData/nRowNum)

	local nHeight = nTitleH + nRow*nRowH


	local pIconData = self.tCurData[1]
	--设置标题
	self.pLbTitle:setString(pIconData.sIntroduce, false)
	self.pLbTitle:setPositionX(self.pLayTitle:getWidth()/2)
	self.pImgL:setPositionX(self.pLayTitle:getWidth()/2 - self.pLbTitle:getWidth()/2 - 20)
	self.pImgR:setPositionX(self.pLayTitle:getWidth()/2 + self.pLbTitle:getWidth()/2 + 20)	
	self:setContentSize(cc.size(self:getWidth() , nHeight))	
	self.pLayRoot:setContentSize(cc.size(self:getWidth() , nHeight))	
	self.pLayTitle:setPositionY(nHeight - nTitleH)
	self.pLatCont:setContentSize(cc.size(self:getWidth() , nRow*nRowH))
	local nY = nHeight - nTitleH - nRowH + 20
	local nCnt = #self.tCurData
	local bDouble = nCnt%2 == 0
	for k, v in pairs(self.tCurData) do
		local x = 0
		local y = 0
		if nCnt <= nRowNum then
			local nMid = math.ceil(nCnt/2)
			if bDouble then
				x = self.pLatCont:getWidth()/2 + (k - nMid - 1)*(144) + 18				
			else
				x = self.pLatCont:getWidth()/2 + (k - nMid)*(144) - 54				
			end			
		else
		  	x = 30 + ((k - 1)%nRowNum)*(144)			
		end  	
		y = nY - math.floor((k-1)/nRowNum)*nRowH	
		if not self.tIcons[k] then
			local pIcon = IconGoods.new(TypeIconGoods.NORMAL, type_icongoods_show.item)
			pIcon:setIconIsCanTouched(true)
			pIcon:setIconClickedCallBack(self._IconHandler)
			pIcon:setPosition(x, y)
			self.pLatCont:addView(pIcon,2)
			self.tIcons[k] = pIcon
		end					
		self.tIcons[k]:setCurData(v)			
		self.tIcons[k]:setIconSelected(self.sID == v.sTid)
	end
	 
	for k, v in pairs(self.tIcons) do
		if k <= nCnt then
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end
end

-- 析构方法
function ItemIcons:onDestroy(  )
	-- body
end

function ItemIcons:setCurData( _data , nId)
	-- body
	self.tCurData = _data
	self.sID = nId or ""
	self:updateViews()
end

function ItemIcons:setIconClickHandler( _handler )
	-- body
	self._IconHandler = _handler
	for k, v in pairs(self.tIcons) do
		v:setIconClickedCallBack(self._IconHandler)			
	end		
end
return ItemIcons