-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-27 11:12:23 星期六
-- Description: vip等级和进度层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local VipLevelLayer = class("VipLevelLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function VipLevelLayer:ctor(_bShow)
	-- body
	self:myInit(_bShow)
	parseView("vip_level_layer_privileges", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("VipLevelLayer",handler(self, self.onVipLevelLayerDestroy))	
end

--初始化参数
function VipLevelLayer:myInit(_bShow)
	-- body
	self.bShowSecBtn = _bShow or false
	self.nVipTarget = Player:getPlayerInfo().nVip + 1

end

--解析布局回调事件
function VipLevelLayer:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function VipLevelLayer:setupViews( )
	--body
	self.pLayRoot = self:findViewByName("root")
	self.pLayBtn1 = self:findViewByName("lay_btn_1")
	self.pLayBtn2 = self:findViewByName("lay_btn_2")
	self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1, TypeCommonBtn.O_BLUE, getConvertedStr(6,10291), false)	
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2, TypeCommonBtn.O_BLUE, getConvertedStr(6,10770), false)	

	--进度条背景
	self.pLayBarBg = self:findViewByName("lay_bar_bg")
	self.pProgressBar = MCommonProgressBar.new({bar = "v2_bar_chongzhi_a.png",barWidth = 239, barHeight = 13})
	self.pLayBarBg:addView(self.pProgressBar, 10)
	centerInView(self.pLayBarBg, self.pProgressBar)	
	self.pProgressBar:setPositionY(self.pLayBarBg:getHeight()/2 + 1)
	self.pProgressBar:setProgressBarText("1/3")
	--imgVIP
	self.pImgVip = self:findViewByName("img_vip")
	--固定文字标签
	self.pLbTip1 = self:findViewByName("lb_tip_1")
	setTextCCColor(self.pLbTip1, _cc.white)
	self.pLbTip1:setString(getConvertedStr(6, 10292), false)
	self.pLbTip2 = self:findViewByName("lb_tip_2")
	setTextCCColor(self.pLbTip2, _cc.white)
	self.pLbTip2:setString(getConvertedStr(6, 10293), false)

	self.pLbTip3 = self:findViewByName("lb_tip_3")
	setTextCCColor(self.pLbTip3, _cc.white)	
	self.pLbTip3:setString(string.format(getConvertedStr(9,10085),"1",getGlobleParam("exchangeRate")), false)

	--黄金数目
	self.pLbGold = self:findViewByName("lb_gold")
	setTextCCColor(self.pLbGold, _cc.yellow)
	self.pLbGold:setString(getConvertedStr(6, 10103), false)
	--下一个Vip等级
	self.pLbNextVipLv = self:findViewByName("lb_viplv")
	setTextCCColor(self.pLbNextVipLv, _cc.yellow)
	self.pLbNextVipLv:setString(getVipLvString(2))
	
	self.pLbVipMax = self:findViewByName("lb_vipmax")	
	setTextCCColor(self.pLbVipMax, _cc.pwhite)
	self.pLbVipMax:setString(getConvertedStr(6, 10437), false)
	setTextCCColor(self.pLbVipMax, _cc.yellow)
	self.pLbVipMax:setVisible(false)
	--当前VIP等级
	self.pLbCurVipLv = MUI.MLabelAtlas.new({text="4", 
        png="ui/atlas/v1_img_tequandengji.png", pngw=20, pngh=32, scm=48})
	local nX = self.pImgVip:getPositionX() + 30
	local nY = self.pImgVip:getPositionY() - 30
	self.pLbCurVipLv:setPosition(nX, nY)
    self.pLayRoot:addView(self.pLbCurVipLv, 10)
end

-- 修改控件内容或者是刷新控件数据
function VipLevelLayer:updateViews(  )
	-- body	
	if self.bShowSecBtn then
		self.pLayBtn1:setPosition(510, 88)
		self.pLayBtn2:setPosition(510, 19)
		self.pBtn2:setBtnVisible(true)
	else
		self.pLayBtn1:setPosition(510, 67)
		self.pBtn2:setBtnVisible(false)		
	end	
	--刷新目标的Vip等级
	if self.nVipTarget <= Player:getPlayerInfo().nVip then
		self.nVipTarget=Player:getPlayerInfo().nVip + 1 
	end		
	local tvip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip + 1)	
	if tvip then--有下一个VIP等级
		local tVipTarget = getAvatarVIPByLevel(self.nVipTarget)
		local nCurVip = Player:getPlayerInfo().nVip			
		self.pLbCurVipLv:setString(tostring(nCurVip), false)
		self.pLbGold:setString(tostring(tVipTarget.exp - Player:getPlayerInfo().nVipExp)..getConvertedStr(6, 10103), false)
		self.pLbNextVipLv:setString(getVipLvString(self.nVipTarget), false)	
		self.pProgressBar:setProgressBarText(Player:getPlayerInfo().nVipExp.."/"..tVipTarget.exp)
		if tVipTarget.exp == 0 then
			self.pProgressBar:setPercent(0)
		else
			if Player:getPlayerInfo().nVipExp > tvip.exp then
				self.pProgressBar:setPercent(100)
			else
				self.pProgressBar:setPercent(Player:getPlayerInfo().nVipExp/tVipTarget.exp*100)
			end			
		end

		self.pLbVipMax:setVisible(false)
		self.pLbTip1:setVisible(true)
		self.pLbTip2:setVisible(true)		
		self.pLbGold:setVisible(true)
		self.pLbNextVipLv:setVisible(true)
	else
		--当前VIP等级已满
		tvip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
		if tvip then
			local nCurVip = Player:getPlayerInfo().nVip	
			local nCurVip = Player:getPlayerInfo().nVip	
			self.pLbCurVipLv:setString(tostring(nCurVip), false)						
			self.pProgressBar:setProgressBarText(Player:getPlayerInfo().nVipExp.."/"..tvip.exp)
			if tvip.exp == 0 then
				self.pProgressBar:setPercent(0)
			else
				if Player:getPlayerInfo().nVipExp > tvip.exp then
					self.pProgressBar:setPercent(100)
				else
					self.pProgressBar:setPercent(Player:getPlayerInfo().nVipExp/tvip.exp*100)
				end
			end
			self.pLbVipMax:setVisible(true)
			self.pLbTip1:setVisible(false)
			self.pLbTip2:setVisible(false)			
			self.pLbGold:setVisible(false)
			self.pLbNextVipLv:setVisible(false)
		end
	end	 	
	self.pLbGold:setPositionX(self.pLbTip1:getPositionX() + self.pLbTip1:getWidth()/2 + 5)
	self.pLbTip2:setPositionX(self.pLbGold:getPositionX() + self.pLbGold:getWidth() + 5)	
	self.pLbNextVipLv:setPositionX(self.pLbTip2:getPositionX() + self.pLbTip2:getWidth() + 5)
end

function VipLevelLayer:setVipTarget( _nLv )
	-- body
	self.nVipTarget=_nLv or Player:getPlayerInfo().nVip + 1
	self:updateViews()
end

--析构方法
function VipLevelLayer:onVipLevelLayerDestroy(  )
	-- body
end

--
function VipLevelLayer:getBtnLeft(  )
 	-- body
 	return self.pBtn1
end

function VipLevelLayer:getBtnRight(  )
 	-- body
 	return self.pBtn2
end 

-- function VipLevelLayer:moveRightBtnPos( x, y )
-- 	-- body
	-- self.pLayBtn2:setPosition(self.pLayBtn2:getPositionX() + (x or 0), self.pLayBtn2:getPositionY() + (y or 0))
-- end
return VipLevelLayer