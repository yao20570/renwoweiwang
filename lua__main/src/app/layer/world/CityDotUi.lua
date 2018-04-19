----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-18 15:40:39
-- Description: 玩家城池视图点 ui层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local CityDotUi = class("CityDotUi", function()
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	return pView
end)

function CityDotUi:ctor( pCityDot )
	self.pCityDot = pCityDot
	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
	--解析文件
	parseView("layout_world_city_ui", handler(self, self.onParseViewCallback))
end

--解析界面回调
function CityDotUi:onParseViewCallback( pView )
	self.pCCSView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CityDotUi",handler(self, self.onCityDotUiDestroy))
end

-- 析构方法
function CityDotUi:onCityDotUiDestroy(  )
    self:onPause()
end

function CityDotUi:regMsgs(  )
end

function CityDotUi:unregMsgs(  )
end

function CityDotUi:onResume(  )
	self:regMsgs()
end

function CityDotUi:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function CityDotUi:setupViews(  )
	--cd条
	local pLayBarCd = self:findViewByName("lay_bar_cd")
	local pSize = pLayBarCd:getContentSize()

	--召唤信息
	self.pLayCallInfo = self:findViewByName("lay_callinfo")
	pLayBarCd:setBackgroundImage("ui/bar/v1_bar_bscd.png")
	self.pCallCdBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/daitu.png",
		   	 	button="ui/update_bin/v1_ball.png",
		    	barfg="ui/bar/v1_bar_blue_sc.png"
		    }, 
		    {
		    	scale9 = false, 
		    	touchInButton=false
		    })
		    :setSliderSize(124, 16)
		    :align(display.LEFT_BOTTOM)
    --设置为不可触摸
    self.pCallCdBar:setViewTouched(false)
	pLayBarCd:addView(self.pCallCdBar, 10)
	local nX, nY = self.pCallCdBar:getPosition()
	self.pCallCdBar:setPosition(nX+1, nY+5)

	--cd文字
	self.pTxtCd = self:findViewByName("txt_cd")
	--召唤
	self.pImgCall = self:findViewByName("img_call")
	self.pImgCallIcon = self:findViewByName("img_call_icon")
	


	--城战
	self.pImgWar = self:findViewByName("img_war")
	self.pImgWarIcon = self:findViewByName("img_war_icon")
	self.pLayFlagEffect = self:findViewByName("lay_flag_effect")
end

function CityDotUi:updateViews(  )
	--显示城战
	if self.tViewDotMsg then
		if self.tViewDotMsg.bIsHasCityWar then
			self.pImgWar:setVisible(true)
			self.pImgWarIcon:setVisible(true)
			self.pLayFlagEffect:setVisible(true)
			self:showCityWarEffect(true)
		else
			self.pImgWar:setVisible(false)
			self.pImgWarIcon:setVisible(false)
			self.pLayFlagEffect:setVisible(false)
			self:showCityWarEffect(false)
		end
	else
		self.pImgWar:setVisible(false)
		self.pImgWarIcon:setVisible(false)
		self.pLayFlagEffect:setVisible(false)
		self:showCityWarEffect(false)
	end

	--更新召唤信息
	self:updateCallInfo()

	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
end

--更新玩家召唤信息
function CityDotUi:updateCallInfo( )
	--容错
	if not self.tViewDotMsg then
		self.pCityDot:setNameVisible(true)
		return
	end

	--同国家
	if self.tViewDotMsg.nDotCountry == Player:getPlayerInfo().nInfluence then
		local tCallInfo = self.tViewDotMsg:getCallInfo()
		if tCallInfo then
			--显示
			local nCd = tCallInfo:getReCallCd()
			if nCd > 0 then
				self.pLayCallInfo:setVisible(true)
				self.pCityDot:setNameVisible(false)
				--更新cd
				regUpdateControl(self, handler(self, self.updateCd))
				self:updateCd()
				return
			end
		end
	end

	--隐藏
	self.pLayCallInfo:setVisible(false)
	self.pCityDot:setNameVisible(true)
	unregUpdateControl(self)
end

--tViewDotMsg
function CityDotUi:setData( tViewDotMsg )
	self.tViewDotMsg = tViewDotMsg
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

--倒计时
function CityDotUi:updateCd(  )
	--容错
	if not self.tViewDotMsg then
		return
	end
	local tCallInfo = self.tViewDotMsg:getCallInfo()
	if not tCallInfo then
		return
	end

	local nCd = tCallInfo:getReCallCd()
	if nCd > 0 then
		local tStr = {
			{color = _cc.green, text = tostring(tCallInfo.nResponse)},
			{color = _cc.pwhite, text = string.format("/%s  %s", tCallInfo.nCanCallPlayer, formatTimeToMs(nCd))},
		}
		self.pTxtCd:setString(tStr, false)
		--设置相机类型
		WorldFunc.setCameraMaskForView(self.pTxtCd)
		if tCallInfo.nCallCdMax > 0 then
			self.pCallCdBar:setSliderValue(nCd/tCallInfo.nCallCdMax*100)
		end
	else
		self:setVisible(false)
		unregUpdateControl(self)
	end
end

--国战特效显示
function CityDotUi:showCityWarEffect( bIsShow )
	if bIsShow then
		if not self.pWarArm then
			local pWarArm = MArmatureUtils:createMArmature(EffectWorldDatas["sysCityUiFlag"], 
			self.pLayFlagEffect, 
			0, 
			cc.p(25, 25),
		    function (  )
			end, Scene_arm_type.world)
			pWarArm:play(-1)
			self.pWarArm = pWarArm
		else
			self.pWarArm:play(-1)
		end
	else
		if self.pWarArm then
			self.pWarArm:stop()
		end
	end
end

return CityDotUi


