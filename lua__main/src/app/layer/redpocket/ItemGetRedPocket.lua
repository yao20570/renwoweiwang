-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-27 17:05:40 星期四
-- Description: 物品 item 项目  TypeItemInfoSize（大小类型） 532*100 570*130
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local ItemGetRedPocket = class("ItemGetRedPocket", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemGetRedPocket:ctor( )
	-- body
	self:myInit()
	parseView("item_get_red_pocket", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemGetRedPocket:myInit(  )
	-- body

end

--解析布局回调事件
function ItemGetRedPocket:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemGetRedPocket",handler(self, self.onDestroy))
end

--初始化控件
function ItemGetRedPocket:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLbName = self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.mred)
	self.pLbTime = self:findViewByName("lb_time")
	setTextCCColor(self.pLbTime, _cc.mred)
	self.pLbNum = self:findViewByName("lb_num")
	setTextCCColor(self.pLbNum, _cc.mred)
	self.pLayBest = self:findViewByName("lay_best")
	self.pLbTip = self:findViewByName("lb_tip")
	setTextCCColor(self.pLbTip, _cc.yellow)
	self.pLbTip:setString(getConvertedStr(6, 10619))
	self.pImgQB = self:findViewByName("img_qb")	

	self.pLayBest = self:findViewByName("lay_best")
	self.pLayBest:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function ItemGetRedPocket:updateViews( )
	-- body
	if self.tCurData then
		self.pLbName:setString(self.tCurData.name)		
		self.pLbTime:setString(self:formatShowTime(self.tCurData.time))
		self.pLbNum:setString(self.tCurData.money)
		self.pImgQB:setPositionX(self.pLbNum:getPositionX() - self.pLbNum:getWidth() - self.pImgQB:getWidth()/2-10)
		if self.tCurData.name == Player:getPlayerInfo().sName then
			setTextCCColor(self.pLbName, _cc.red)
		else
			setTextCCColor(self.pLbName, _cc.mred)
		end
		local pActorVo 	 = 			ActorVo.new()
  		pActorVo:initData(self.tCurData.ac, nil, nil)
  		if not self.pIcon then
  			self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.item, pActorVo, TypeIconHeroSize.M)
  			self.pIcon:setIconIsCanTouched(false)
  		else
  			self.pIcon:setCurData(pActorVo)
  		end

  		self.pLayBest:setVisible(self.tCurData.bBest) 
	end
end

function ItemGetRedPocket:formatShowTime( fTime )
	local sStr = ""
	local tData = os.date("*t", fTime/1000)
	local fCurTime = getSystemTime()
	local tCurData = os.date("*t", fCurTime)
	local fDisTime = fTime/1000 - fCurTime
	if(tCurData.year == tData.year and tData.yday == tCurData.yday) then -- 同一天
		if(tData.hour <= 9) then
			tData.hour = "0" .. tData.hour
		end
		if(tData.min <= 9) then
			tData.min = "0" .. tData.min
		end
		sStr = tData.hour .. ":" .. tData.min .. ":" .. tData.sec
	-- elseif(tCurData.year == tData.year and tCurData.yday-tData.yday == 1) then -- 昨天
	-- 	if(tData.hour <= 9) then
	-- 		tData.hour = "0" .. tData.hour
	-- 	end
	-- 	if(tData.min <= 9) then
	-- 		tData.min = "0" .. tData.min
	-- 	end
	-- 	sStr = getConvertedStr(5, 10135) .. tData.hour .. ":" .. tData.min
	else
		sStr = formatTime(fTime)
	end
	return sStr
end

-- 析构方法
function ItemGetRedPocket:onDestroy(  )
	-- body
end

function ItemGetRedPocket:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

return ItemGetRedPocket