----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-07 16:37:14
-- Description: 官员界面列表单元
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemVoteLayer = class("ItemVoteLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemVoteLayer:ctor(  )
	-- body
	self:myInit()
	parseView("item_vote_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemVoteLayer:myInit(  )
	-- body
	self.tLbValues = nil
	self.nhandler = nil
	self.pCurData = nil
	self.nCnt = 5
	self.nType = 1
end

--解析布局回调事件
function ItemVoteLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemVoteLayer",handler(self, self.onItemVoteLayerDestroy))
end

--初始化控件
function ItemVoteLayer:setupViews( )
	-- body
	--
	self.pLayRoot = self:findViewByName("root")
	self.tLbValues = {}
	for i = 1, 5 do
		local label = self:findViewByName("lb_value_"..i)		
		label:setString("")
		self.tLbValues[i] = label
	end
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pLayBtn:setVisible(false)
	self.pBtn =	getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_RED, getConvertedStr(6, 10334))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
	setMCommonBtnScale(self.pLayBtn, self.pBtn, 0.8)
end

-- 修改控件内容或者是刷新控件数据
function ItemVoteLayer:updateViews( )
	-- body	

end

function ItemVoteLayer:showOfficialsInfo( tData )
	-- body
	self.pCurData = tData or nil
	if self.pCurData then
		--dump(self.pCurData, "self.pCurData", 100)
		self:setColumns(5)
		local tvalues = self.pCurData:getFormatStrGroup()
		for i = 1, 5 do
			if tvalues[i] then
				self.tLbValues[i]:setVisible(true)
				self.tLbValues[i]:setString(tvalues[i].text)
				setTextCCColor(self.tLbValues[i], tvalues[i].color)
			else
				self.tLbValues[i]:setVisible(false)
			end
		end	
	end	
end

function ItemVoteLayer:showCandidateInfo( tData )
	-- body
	self.pCurData = tData or nil
	if self.pCurData then
		self:setColumns(5)
		local tvalues = self.pCurData:getFormatStrGroup()		
		for i = 1, 5 do
			if tvalues[i] then
				self.tLbValues[i]:setVisible(true)
				self.tLbValues[i]:setString(tvalues[i].text)
				setTextCCColor(self.tLbValues[i], tvalues[i].color)
			else
				self.tLbValues[i]:setVisible(false)
			end
		end	
	end		
end

function ItemVoteLayer:showGeneralInfo( tData )
	-- body
	self.pCurData = tData or nil
	if self.pCurData then
		self:setColumns(4)
		local tvalues = self.pCurData:getGeneralFormatStr()
		for i = 1, 5 do
			if tvalues[i] then
				self.tLbValues[i]:setVisible(true)
				self.tLbValues[i]:setString(tvalues[i].text)
				setTextCCColor(self.tLbValues[i], tvalues[i].color)
			else
				self.tLbValues[i]:setVisible(false)
			end
		end	
	end	
end

function ItemVoteLayer:showRankTitles( _tData, _tPos )
	-- body
	if not _tData then
		return
	end
	tvalues = _tData
	local nWidth = self:getWidth()
	for i = 1, 5 do
		if tvalues[i] then
			self.tLbValues[i]:setVisible(true)
			self.tLbValues[i]:setString(tvalues[i])
			self.tLbValues[i]:setPositionX(nWidth*_tPos[i])
		else
			self.tLbValues[i]:setVisible(false)
		end
	end	
	self.pLayBtn:setVisible(false)
end

-- 析构方法
function ItemVoteLayer:onItemVoteLayerDestroy(  )
	-- body
end

--按钮点击回调
function ItemVoteLayer:onBtnClicked( pview )
	-- body
	if self.nhandler then
		self.nhandler(self.pCurData)
	end
end

--设置按钮handler
function ItemVoteLayer:setOperateHandler( _handler )
	-- body
	self.nhandler = _handler
end

--获取按钮
function ItemVoteLayer:getBtn(  )
	-- body
	return self.pBtn
end

--设置显示显示列数
function ItemVoteLayer:setColumns( _Cnt )
	-- body
	local nCnt = 5
	if _Cnt and _Cnt > 0 then
		nCnt = _Cnt
	end
	local wid = self.pLayRoot:getWidth()/nCnt
	for i = 1, 5 do 
		if i <= nCnt then
			self.tLbValues[i]:setVisible(true)
			self.tLbValues[i]:setPositionX(wid/2 + (i - 1)*wid)
			if i == nCnt then
				self.pLayBtn:setPositionX(wid/2 + (i - 1)*wid - self.pLayBtn:getWidth()/2)
			end
		else
			self.tLbValues[i]:setVisible(false)
		end		
	end
	self.nCnt = nCnt
end

--设置空显示
function ItemVoteLayer:showEmpty( _str )
	-- body
	for i = 1, 5 do 
		if i == 1 then
			self.tLbValues[i]:setVisible(true)
			self.tLbValues[i]:setPositionX(self.pLayRoot:getWidth()/2)
			self.tLbValues[i]:setString(_str)
			setTextCCColor(self.tLbValues[i], _cc.gray)
		else
			self.tLbValues[i]:setVisible(false)
		end		
	end
	self.pLayBtn:setVisible(false)
	--self.pBtn:setVisible(false)
end
function ItemVoteLayer:resetLayoutSize( _nwidth, _nheight )
	-- body
	self:setLayoutSize(_nwidth, _nheight)
	centerInView(self, self.pLayRoot)
end

function ItemVoteLayer:setBtnVisible(_bVisivle)
	-- body
	self.pLayBtn:setVisible(_bVisivle or false)
end
return ItemVoteLayer


