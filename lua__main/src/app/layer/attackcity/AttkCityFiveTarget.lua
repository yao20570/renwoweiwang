----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-20 13:52:57
-- Description: 攻城掠地（五日目标）
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemAttkCity = require("app.layer.attackcity.ItemAttkCity")

local nTipIndex = 20115

local AttkCityFiveTarget = class("AttkCityFiveTarget", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function AttkCityFiveTarget:ctor(  )
    -- self:setContentSize(_tSize)
	--解析文件
	parseView("attk_city_five_target", handler(self, self.onParseViewCallback))
end

--解析界面回调
function AttkCityFiveTarget:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:myInit()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("AttkCityFiveTarget", handler(self, self.onAttkCityFiveTargetDestroy))

end

function AttkCityFiveTarget:myInit(  )
	-- body
	self.tTitles={getConvertedStr(9,10110),
				getConvertedStr(9,10111),
				getConvertedStr(9,10112),
				getConvertedStr(9,10113),
				getConvertedStr(9,10114),
				}
	self.nTabIndex=tonumber(getLocalInfo("acTargetTab", "1"))
	self.tTabItems ={}

	self.tCurDayInfo = {}
	self.tActData=Player:getActById(e_id_activity.attackcity)
	self.tRewardData = getAttkCityBxData()

	self.tTaskData = getAttkCityTaskData()

	self.tBxItem ={}

	self.tBoxEffects={}
	self.tParitcle = {}
	self.tBxStateImg = {}

	self.pLvEffect={}
	self.pLanEffect={}
	
end

function AttkCityFiveTarget:setupViews(  )
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	local pMBanner = setMBannerImage(self.pLayBannerBg,TypeBannerUsed.gcld)
	pMBanner:setMBannerOpacity(255*0.5)
	self.pLayBar = self:findViewByName("lay_bar_bg")--进度条层

	self.pProgressBar = MCommonProgressBar.new({bar = "v2_bar_yellow_11.png",barWidth = 515, barHeight = 20})
	self.pLayBar:addView(self.pProgressBar)
	centerInView(self.pLayBar, self.pProgressBar)	
	self.pProgressBar:setPositionY(self.pProgressBar:getPositionY() + 1)

	self:initTickAndBox()

	self.pLayList=self:findViewByName("lay_list")
	self.pLayTabTitle = self:findViewByName("lay_tab_title")
	self.tTxtTips ={}
	for i=1,3 do
		local pTxtTip = self:findViewByName("txt_tip"..i)
		table.insert(self.tTxtTips,pTxtTip)
	end
	

	local pLayTab=self:findViewByName("lay_tab")
	for i= 1,5 do 
		local pImgLock = self:findViewByName("img_lock"..i)
		pImgLock:setVisible(true)
		local pTabItem = self:findViewByName("lay_tab" .. i)
		pTabItem:setViewTouched(true)
		pTabItem:onMViewClicked(handler(self, self.onTabItemClicked))
		
		pTabItem:setIsPressedNeedColor(false)
		pTabItem:setIsPressedNeedScale(false)
		local pTabTitle = self:findViewByName("txt_tab_title" .. i)
		pTabTitle:setString(self.tTitles[i])
		pTabItem.nIndex = i
		pTabItem:setOpacity(255 * 0.7)
		local tTab = {tab = pTabItem,lock = pImgLock }
		table.insert(self.tTabItems,tTab)
	end

	self:setBottomTip()

	
end

function AttkCityFiveTarget:updateViews(  )
	self.tActData=Player:getActById(e_id_activity.attackcity)
	if not self.tActData then
		return
	end
	--积分刷新
	local nCurDp = self.tActData.nP
	local nMaxScore =self.tRewardData[table.nums(self.tRewardData)].cost
	self.pProgressBar:setPercent(nCurDp/nMaxScore*100)
	local nCurDay = self.tActData:getCurDay()

	for i = 1 , nCurDay do
		self.tTabItems[i].lock:setVisible(false)
		self.tTabItems[i].tab:setOpacity(255)

	end

	for i=1,#self.tBxItem do
		local tTemp = self.tBxItem[i]
		local nState=self.tActData:getBxState(tTemp.id,tTemp.point) 
		if tTemp.nType == 1 then
			if nState == 1 then 		--未达到
				tTemp.bxImg:setCurrentImage("#v1_img_guojia_renwubaoxiang1.png")
				tTemp.bxImg:setVisible(true)
				self:removeEffect(i)
				showGrayTx(tTemp.bxImg, false)
			elseif nState == 2 then

				tTemp.bxImg:setCurrentImage("#v1_img_guojia_renwubaoxiang2.png")
				-- tTemp.bxImg:setVisible(false)
				self:addEffects(i)
				showBreathTx(tTemp.bxImg)
			elseif nState == 3 then
				tTemp.bxImg:setCurrentImage("#v1_img_guojia_renwubaoxiang3.png")	
				tTemp.bxImg:setVisible(true)
				self:removeEffect(i)
				showGrayTx(tTemp.bxImg, false)
			end
		elseif tTemp.nType == 2 then  --绿装
			
			if nState == 2 then
				if tTemp.bxImgBg then
					self:addSpecialEffectGreen(tTemp.bxImgBg,i)
				end
				showFloatTx(tTemp.bxImg,0.75)
			elseif nState == 3 then
				self:removeSpecialEffect(tTemp)
				self:addGotImg(tTemp)
			end
		elseif tTemp.nType == 3 then  --蓝装
			if nState == 2 then
				if tTemp.bxImgBg then
					self:addSpecialEffectBlue(tTemp.bxImgBg,i)
				end
				showFloatTx(tTemp.bxImg,0.75)
			elseif nState == 3 then
				self:removeSpecialEffect(tTemp)
				self:addGotImg(tTemp)
				
			end
		end

	end
	self:onTabItemClicked(self.tTabItems[self.nTabIndex].tab)
end

function AttkCityFiveTarget:addSpecialEffectGreen( _pView ,_nIndex)
 	-- body
 	addTextureToCache("tx/other/rwww_gcld_txtx")
 	addTextureToCache("tx/other/p1_tx_jzjs")

 	if not self.pLvEffect[1] then
	 	self.pLvEffect[1] = MUI.MImage.new("#v2_img_xsylu.png")
	 	_pView:addChild(self.pLvEffect[1],10)
	 	centerInView(_pView,self.pLvEffect[1])
	 end
	 if not self.pLvEffect[2] then
	 	self.pLvEffect[2] = MUI.MImage.new("#rwww_gcld_txtx_01.png")
		self.pLvEffect[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLvEffect[2]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		_pView:addChild(self.pLvEffect[2],15)
		centerInView(_pView,self.pLvEffect[2])
	end
	local tData=self.tRewardData[_nIndex]
	if not self.pLvEffect[3] then
		local tIcon = luaSplit(tData.icon,";")
		local sIcon = "#" .. tIcon[1] .. ".png"

	 	self.pLvEffect[3] = MUI.MImage.new(sIcon)
		self.pLvEffect[3]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLvEffect[3]:setScale(0.8)
		self.pLvEffect[3]:setOpacity(0.2*255)
		_pView:addChild(self.pLvEffect[3],110)
		centerInView(_pView,self.pLvEffect[3])
	end
	if not self.pLvEffect[4] then
	 	self.pLvEffect[4] = MUI.MImage.new("#sg_guqt__2_sa1_003.png")
		self.pLvEffect[4]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLvEffect[4]:setScale(0.46)
		-- self.pLvEffect2:setOpacity(0)
		_pView:addChild(self.pLvEffect[4],20)
		centerInView(_pView,self.pLvEffect[4])
	end

	if not self.pLvEffect[5] then
	 	self.pLvEffect[5] = MUI.MImage.new("#rwww_gcld_txtx_01.png")
		self.pLvEffect[5]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLvEffect[5]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		_pView:addChild(self.pLvEffect[5],15)
		centerInView(_pView,self.pLvEffect[5])
	end
	if not self.pLvEffect[6] then
	 	self.pLvEffect[6] = MUI.MImage.new("#rwww_gcld_txtx_01.png")
		self.pLvEffect[6]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLvEffect[6]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		_pView:addChild(self.pLvEffect[6],15)
		centerInView(_pView,self.pLvEffect[6])
	end

	local rotate1 = cc.RotateTo:create(0.75, 180)
	local rotate2 = cc.RotateTo:create(0.75, 360)
	self.pLvEffect[1]:runAction(cc.RepeatForever:create(cc.Sequence:create(rotate1,rotate2)))

	local delay1 = cc.DelayTime:create(0.33)
	local delay2 = cc.DelayTime:create(0.33)
	local delay3 = cc.DelayTime:create(0.33)
	local callback1 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		self.pLvEffect[2]:setRotation(random)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.46,1)
		local scale3 = cc.ScaleTo:create(0.54,1.56)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.46,255)
		local fadeTo3 = cc.FadeTo:create(0.54,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pLvEffect[2]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback2 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.46,1)
		local scale3 = cc.ScaleTo:create(0.54,1.56)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.46,255)
		local fadeTo3 = cc.FadeTo:create(0.54,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pLvEffect[5]:setRotation(random)
		self.pLvEffect[5]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback3 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.46,1)
		local scale3 = cc.ScaleTo:create(0.54,1.56)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.46,255)
		local fadeTo3 = cc.FadeTo:create(0.54,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pLvEffect[6]:setRotation(random)
		self.pLvEffect[6]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	_pView:runAction(cc.RepeatForever:create(cc.Sequence:create(callback1,delay1,callback2,delay2,callback3,delay3)))

	showFloatTx(self.pLvEffect[3],0.75,0.7 * 255,0.2*255)

	local scale4 = cc.ScaleTo:create(0,0.46)
	local scale5 = cc.ScaleTo:create(0.7,0.78)
	local scale6 = cc.ScaleTo:create(0.7,1.17)

	local fadeTo4 = cc.FadeTo:create(0,0)
	local fadeTo5 = cc.FadeTo:create(0.7,255 * 0.8)
	local fadeTo6 = cc.FadeTo:create(0.7,0)

	local spawn4 = cc.Spawn:create(scale4,fadeTo4)
	local spawn5 = cc.Spawn:create(scale5,fadeTo5)
	local spawn6 = cc.Spawn:create(scale6,fadeTo6)
	self.pLvEffect[4]:runAction(cc.RepeatForever:create(cc.Sequence:create(spawn4,spawn5,spawn6)))

 end 

function AttkCityFiveTarget:addSpecialEffectBlue( _pView ,_nIndex)
 	-- body
 	addTextureToCache("tx/other/rwww_gcld_txtx")
 	addTextureToCache("tx/other/p1_tx_jzjs")

 	if not self.pLanEffect[1] then
	 	self.pLanEffect[1] = MUI.MImage.new("#v2_img_xsylan.png")
	 	_pView:addChild(self.pLanEffect[1],10)
	 	centerInView(_pView,self.pLanEffect[1])
	 end
	 if not self.pLanEffect[2] then
	 	self.pLanEffect[2] = MUI.MImage.new("#rwww_gcld_txtx_02.png")
		self.pLanEffect[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLanEffect[2]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		_pView:addChild(self.pLanEffect[2],15)
		centerInView(_pView,self.pLanEffect[2])
	end
	local tData=self.tRewardData[_nIndex]
	if not self.pLanEffect[3] then
		local tIcon = luaSplit(tData.icon,";")
		local sIcon = "#" .. tIcon[1] .. ".png"

	 	self.pLanEffect[3] = MUI.MImage.new(sIcon)
		self.pLanEffect[3]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLanEffect[3]:setScale(0.8)
		self.pLanEffect[3]:setOpacity(0.2*255)
		_pView:addChild(self.pLanEffect[3],110)
		centerInView(_pView,self.pLanEffect[3])
	end
	if not self.pLanEffect[4] then
	 	self.pLanEffect[4] = MUI.MImage.new("#sg_guqt__2_sa1_003.png")
		self.pLanEffect[4]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLanEffect[4]:setScale(0.46)
		-- self.pLvEffect2:setOpacity(0)
		_pView:addChild(self.pLanEffect[4],20)
		centerInView(_pView,self.pLanEffect[4])
	end

	if not self.pLanEffect[5] then
	 	self.pLanEffect[5] = MUI.MImage.new("#rwww_gcld_txtx_02.png")
		self.pLanEffect[5]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLanEffect[5]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		_pView:addChild(self.pLanEffect[5],15)
		centerInView(_pView,self.pLanEffect[5])
	end
	if not self.pLanEffect[6] then
	 	self.pLanEffect[6] = MUI.MImage.new("#rwww_gcld_txtx_02.png")
		self.pLanEffect[6]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pLanEffect[6]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		_pView:addChild(self.pLanEffect[6],15)
		centerInView(_pView,self.pLanEffect[6])
	end

	local rotate1 = cc.RotateTo:create(0.75, 180)
	local rotate2 = cc.RotateTo:create(0.75, 360)
	self.pLanEffect[1]:runAction(cc.RepeatForever:create(cc.Sequence:create(rotate1,rotate2)))

	local delay1 = cc.DelayTime:create(0.33)
	local delay2 = cc.DelayTime:create(0.33)
	local delay3 = cc.DelayTime:create(0.33)
	local callback1 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		self.pLanEffect[2]:setRotation(random)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.46,1)
		local scale3 = cc.ScaleTo:create(0.54,1.56)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.46,255)
		local fadeTo3 = cc.FadeTo:create(0.54,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pLanEffect[2]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback2 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.46,1)
		local scale3 = cc.ScaleTo:create(0.54,1.56)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.46,255)
		local fadeTo3 = cc.FadeTo:create(0.54,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pLanEffect[5]:setRotation(random)
		self.pLanEffect[5]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback3 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.46,1)
		local scale3 = cc.ScaleTo:create(0.54,1.56)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.46,255)
		local fadeTo3 = cc.FadeTo:create(0.54,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pLanEffect[6]:setRotation(random)
		self.pLanEffect[6]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	_pView:runAction(cc.RepeatForever:create(cc.Sequence:create(callback1,delay1,callback2,delay2,callback3,delay3)))
	-- self.pLvEffect2:runAction(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3,callback1,delay1)))
	-- self.pLvEffect5:runAction(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3,callback2,delay1)))
	-- self.pLvEffect6:runAction(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3,callback3,delay1)))

	showFloatTx(self.pLanEffect[3],0.75,0.7 * 255,0.2*255)

	local scale4 = cc.ScaleTo:create(0,0.46)
	local scale5 = cc.ScaleTo:create(0.7,0.78)
	local scale6 = cc.ScaleTo:create(0.7,1.17)

	local fadeTo4 = cc.FadeTo:create(0,0)
	local fadeTo5 = cc.FadeTo:create(0.7,255 * 0.8)
	local fadeTo6 = cc.FadeTo:create(0.7,0)

	local spawn4 = cc.Spawn:create(scale4,fadeTo4)
	local spawn5 = cc.Spawn:create(scale5,fadeTo5)
	local spawn6 = cc.Spawn:create(scale6,fadeTo6)
	self.pLanEffect[4]:runAction(cc.RepeatForever:create(cc.Sequence:create(spawn4,spawn5,spawn6)))

 end 

 function AttkCityFiveTarget:removeSpecialEffect( _tItem)
 	-- body
 	if not _tItem then
 		return
 	end
 	_tItem.bxImg:stopAllActions()
	_tItem.bxImgBg:stopAllActions()
	centerInView(_tItem.bxImgBg,_tItem.bxImg)

 	if _tItem.nType == 2 then  		--绿装
 		for k,v in pairs(self.pLvEffect) do
 			v:removeSelf()
 			v= nil
 		end
 		self.pLvEffect = {}
 	elseif _tItem.nType == 3 then
 		for k,v in pairs(self.pLanEffect) do
 			v:removeSelf()
 			v= nil
 		end
 		self.pLanEffect = {}

 	end
	
 end
 function AttkCityFiveTarget:addGotImg( _tItem )
 	-- body
 	local pImg = _tItem.bxImg:findViewByName("gotImg")
 	if not pImg then  		--绿装
 		if not self.pGreenGotImg then
 			pImg = MUI.MImage.new("#v1_fonts_yilingqu.png")
			pImg:setName("gotImg")
			pImg:setScale(0.8)
			_tItem.bxImg:addChild(pImg,15)
			centerInView(_tItem.bxImg,pImg)
 		end
 	end

 end

function AttkCityFiveTarget:initTickAndBox(  )
	-- body
	if not self.tRewardData or table.nums(self.tRewardData) <=0 then
		return
	end
	local nTWidth = 510
	local nSY = self.pLayBar:getHeight()/2 + 2
	local nMaxScore =self.tRewardData[table.nums(self.tRewardData)].cost
	-- local nMaxScore = tRewardData[nLastIndex].cost
	for k, v in pairs(self.tRewardData) do
		local nX = v.cost/nMaxScore*nTWidth + (self.pLayBar:getWidth() - nTWidth)/2
		local nTickY = nSY
		local nLableY = nSY
		local nBoxY = nSY
		if k%2 == 0 then
			nTickY = nSY - 15
			nLableY = nSY - 50
			nBoxY = nSY - 60
		else
			nTickY = nSY + 15
			nLableY = nSY + 50
			nBoxY = nSY + 60
		end

		--刻度线
		if k <  table.nums(self.tRewardData) then--
			local pImg = MUI.MImage.new("#v1_line_blue2.png", {scale9 = true,capInsets=cc.rect(1,5, 1, 1)})
			pImg:setLayoutSize(2, 28)

			pImg:setPosition(nX + 1, nTickY)
			self.pLayBar:addView(pImg, 9)	
		end

		local tCurBx = {}
		tCurBx.point=v.cost
		tCurBx.id=v.id
		tCurBx.nType = v.visual
		local tIcon = luaSplit(v.icon,";")

		local sIcon1 = "#v1_img_guojia_renwubaoxiang1.png"
		
		local pImgIconBg = nil
		if tIcon[2]  then
			local sIcon2 = "#" .. tIcon[2] .. ".png"
			pImgIconBg = MUI.MImage.new(sIcon2)
			-- pImgIconBg:setScale(0.8)
			pImgIconBg:setPosition(nX,nBoxY)
			self.pLayBar:addView(pImgIconBg, 9)
			sIcon1 = "#" .. tIcon[1] .. ".png"

		end
		local pImgIcon = MUI.MImage.new(sIcon1)
		pImgIcon:setScale(0.8)
		if pImgIconBg then
			pImgIconBg:addChild(pImgIcon,100)
			centerInView(pImgIconBg,pImgIcon)
		else
			pImgIcon:setPosition(nX,nBoxY)
			self.pLayBar:addView(pImgIcon, 9)
		end
		
		--刻度标签
	    local pLabel = MUI.MLabel.new({
	        text="("..v.cost..")",
	        size=16,
	        anchorpoint=cc.p(0.5, 0.5)
	    })
	    local nLabelX = nX - pImgIcon:getWidth() / 2 - 18 
	    pLabel:setPosition(nLabelX, nLableY)
	    self.pLayBar:addView(pLabel, 9)

	 --    pImgIcon:setViewTouched(true)
		-- pImgIcon:setIsPressedNeedScale(false)
		-- pImgIcon:setIsPressedNeedColor(true)
		-- pImgIcon:onMViewClicked(function (_pView )
		--     -- body
		-- 	local tObject = {} 
		-- 	tObject.nType = e_dlg_index.acbxdetail --dlg类型
		-- 	tObject.tData = v
		-- 	sendMsg(ghd_show_dlg_by_type,tObject)
		-- end)
		if pImgIconBg then
			
			tCurBx.bxImgBg = pImgIconBg
			 pImgIconBg:setViewTouched(true)
			pImgIconBg:setIsPressedNeedScale(false)
			pImgIconBg:setIsPressedNeedColor(true)
			pImgIconBg:onMViewClicked(function (_pView )
		    -- body
			local tObject = {} 
			tObject.nType = e_dlg_index.acbxdetail --dlg类型
			tObject.tData = v
			sendMsg(ghd_show_dlg_by_type,tObject)
		end)
		else
			pImgIcon:setViewTouched(true)
			pImgIcon:setIsPressedNeedScale(false)
			pImgIcon:setIsPressedNeedColor(true)
			pImgIcon:onMViewClicked(function (_pView )
		    -- body
			local tObject = {} 
			tObject.nType = e_dlg_index.acbxdetail --dlg类型
			tObject.tData = v
			sendMsg(ghd_show_dlg_by_type,tObject)
		end)
		
		end
		tCurBx.bxImg = pImgIcon

		table.insert(self.tBxItem,tCurBx)
	end
end
--标签页
function AttkCityFiveTarget:onTabItemClicked(_pView)
	-- body
	-- local nActIdx = (self.nDayIdx-1)*3 + _nIndex
	local nIndex = _pView.nIndex
	for k, v in pairs (self.tTabItems) do
		if v.tab.nIndex == nIndex then
			v.tab:setBackgroundImage("#v2_btn_yellow6.png")
			self.nTabIndex = nIndex
			self:onTabChanged()
			self:setBottomTip()
		else
			v.tab:setBackgroundImage("#v2_btn_blue6.png")
		end
	end
end

function AttkCityFiveTarget:onTabChanged( )
	
	-- --更新列表数据
	self.tCurDayInfo = self.tTaskData[self.nTabIndex]
	local nCurDay = self.tActData:getCurDay()
	if self.tCurDayInfo then
		if not self.pListView then
			--列表
			local pSize = self.pLayList:getContentSize()
			self.pListView = MUI.MListView.new {
				viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
				direction  = MUI.MScrollView.DIRECTION_VERTICAL,
				itemMargin = {
					left   = 20,
		            right  = 0,
		            top    = 0, 
		            bottom = 10}
		    }
		    self.pLayList:addView(self.pListView)
			local nCount = table.nums(self.tCurDayInfo)
			self.pListView:setItemCount(nCount)
			self.pListView:setItemCallback(function ( _index, _pView ) 
			    local pTempView = _pView
			    if pTempView == nil then
			    	pTempView = ItemAttkCity.new()
				end
				local nProcess = self.tActData:getProcessById(self.tCurDayInfo[_index].id)
				pTempView:setData(self.tCurDayInfo[_index],nProcess,nCurDay)
			    return pTempView
			end)
			self.pListView:reload()
		else
			self.pListView:scrollToBegin()
			self.pListView:notifyDataSetChange(true,table.nums(self.tCurDayInfo))
		end
	end

end

function AttkCityFiveTarget:setBottomTip(  )
	-- body
	local nTip = nTipIndex + (3 * (self.nTabIndex -1))
	for i=1,3 do 
		self.tTxtTips[i]:setString(getTipsByIndex(nTip))
		nTip=nTip + 1
	end

end

function AttkCityFiveTarget:addEffects( _nIndex )
	-- body
	local tItem=self.tBxItem[_nIndex].bxImg
	if not self.tBoxEffects[_nIndex] then
		self.tBoxEffects[_nIndex] = self:getBoxEffects(tItem, tItem:getWidth()/2, tItem:getHeight()/2, 10)
	end
	if not self.tParitcle[_nIndex] then
		
		local pParitcleB = createParitcle("tx/other/lizi_mlz_sf_001.plist")
		pParitcleB:setPosition(tItem:getWidth()/2, tItem:getHeight()/2)
		tItem:addChild(pParitcleB,30)
		self.tParitcle[_nIndex] = pParitcleB
	end
end


function AttkCityFiveTarget:removeEffect( _nIndex )
	-- body
	if self.tBoxEffects[_nIndex] then
		for i=1,#self.tBoxEffects[_nIndex] do
			self.tBoxEffects[_nIndex][i]:stop()
			MArmatureUtils:removeMArmature(self.tBoxEffects[i])
		end
		self.tBoxEffects[_nIndex] = nil		
	end
	if self.tParitcle[_nIndex] then
		self.tParitcle[_nIndex]:removeSelf()
		self.tParitcle[_nIndex] = nil
	end
end
function AttkCityFiveTarget:getBoxEffects(pview, fx, fy, nZorder)
	-- body
	local pArmActions = {}
	for i=1,5 do
		local pArmAction = MArmatureUtils:createMArmature(
			EffectTBoxDatas["tbox"..i], 
			pview, 
			nZorder, 
			cc.p(fx, fy),
		    function (  )
			end, Scene_arm_type.normal)
		pArmAction:play(-1)
		table.insert(pArmActions, pArmAction)
	end
	return pArmActions
end
--添加装备宝箱的状态图片
-- function AttkCityFiveTarget:addSpecialBxState( _nIndex )
-- 	-- body
-- 	if not self.tBxStateImg[_nIndex] then
-- 		local tImg = MUI.MImage.new()
-- 	end
-- end
-- 析构方法
function AttkCityFiveTarget:onAttkCityFiveTargetDestroy(  )
    self:onPause()
end



function AttkCityFiveTarget:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
	
end

function AttkCityFiveTarget:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
	
end

function AttkCityFiveTarget:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function AttkCityFiveTarget:onPause(  )
	saveLocalInfo("acTargetTab", tostring(self.nTabIndex))
	self:unregMsgs()
end


return AttkCityFiveTarget



