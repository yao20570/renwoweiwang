----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-05 14:11:20
-- Description: 每日特惠奖励子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemEverydayPreference = class("ItemEverydayPreference", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemEverydayPreference:ctor(  )
	--解析文件
	parseView("item_everyday_preference", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemEverydayPreference:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:myInit()
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemEverydayPreference", handler(self, self.onItemEverydayPreferenceDestroy))
end

function ItemEverydayPreference:myInit()
	self.tTitleImg ={
		"#v2_fonts_1yuan.png",
		"#v2_fonts_3yuan.png",
		"#v2_fonts_6yuan.png",
	}
	self.tRewardImg ={
		"#v1_img_chufalibao.png",
		"#v2_img_3yuanlibao.png",
		"#v2_img_6yuanlibao.png",
	}

	self.pIconEffects ={}

	self.bIsAddEffect = false
end

-- 析构方法
function ItemEverydayPreference:onItemEverydayPreferenceDestroy(  )
end

function ItemEverydayPreference:setupViews(  )
	-- self.pDefault=self:findViewByName("default")
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)

	self:onMViewClicked(handler(self, self.onItemClicked))

	self.pImgTitle = self:findViewByName("img_title")
	self.pImgReward = self:findViewByName("img_icon")
	self.pTxtTip1 = self:findViewByName("txt_tip1")  		--立赠元宝
	setTextCCColor(self.pTxtTip1,_cc.blue)

	self.pTxtTip2 = self:findViewByName("txt_tip2")
	self.pTxtBtnTip = self:findViewByName("txt_btn_tip")	--按钮上的文字
	setTextCCColor(self.pTxtBtnTip,_cc.gray)

	local pLayBtn=self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(pLayBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(1, 10117))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.pLayIcon=self:findViewByName("lay_icon")

end

function ItemEverydayPreference:updateViews(  )
	-- body

	if self.tTitleImg[self.nIndex] then
		self.pImgTitle:setCurrentImage(self.tTitleImg[self.nIndex])
	else
		self.pImgTitle:setCurrentImage(self.tTitleImg[1])

	end
	if self.tRewardImg[self.nIndex] then
		self.pImgReward:setCurrentImage(self.tRewardImg[self.nIndex])
	else
		self.pImgReward:setCurrentImage(self.tRewardImg[1])
	end
	if self.tData.gs and #self.tData.gs then

		for i=1,#self.tData.gs do
			local v=self.tData.gs[i]
			if v.k==e_type_resdata.money then
				self.pTxtTip1:setString(string.format(getConvertedStr(9,10072),v.v))
			end
		end
	end
	--限购次数
	self.pTxtTip2:setString(getConvertedStr(9,10073))
	self.pTxtBtnTip:setString(string.format(getConvertedStr(9,10074),self.tData.l))
	-- self.pBtn:updateBtnText(string.format(getConvertedStr(9,10075),self.tData.m))

	if self.tData.b == 0 then
		self.pBtn:updateBtnText(getConvertedStr(3,10328))
		self.pBtn:setBtnEnable(true)
		self.pBtn:setToGray(true)--setBtnEnable(false)

		if self.nIndex ~=1 then
			self:removeEffect()
		end
	
	else
		if self.nIndex ~=1 and not self.bIsAddEffect then
			self:addSpecialEffect()
			self.bIsAddEffect = true
		end
		if self.nIndex == 3 then
			self:addEffects()
		end
		self.pBtn:updateBtnText(string.format(getConvertedStr(9,10075),self.tData.m))
		self.pBtn:setBtnEnable(true)
	end
end

function ItemEverydayPreference:addEffects(  )
	-- body
	if not self.pParitcle then
		local pParitcleB = createParitcle("tx/other/lizi_huode_xjz_lzdh_001.plist")
		-- pParitcleB:setScale(0.8)
		pParitcleB:setPosition(self.pImgReward:getPositionX(), self.pImgReward:getPositionY())
		self.pLayIcon:addView(pParitcleB,5)
		self.pParitcle = pParitcleB
	end
end

function ItemEverydayPreference:removeEffect(  )
	-- body
	
	self:stopAllActions()
	
	if self.pParitcle then
		self.pParitcle:removeSelf()
		self.pParitcle = nil
	end
	for k,v in pairs(self.pIconEffects) do
 		v:removeSelf()
 		v= nil
 	end
 	self.pIconEffects = {}
end

function ItemEverydayPreference:setData( _tData,_nIndex )
	-- body
	self.tData=_tData or self.tData
	self.nIndex=_nIndex or 1

	self:updateViews()

end

function ItemEverydayPreference:onBtnClicked( )
	-- body
	if  self.tData.b == 0 then
		TOAST(getConvertedStr(9,10086))
		return
	else
		local tRechargeData=getRechargeDataByKey(self.tData.r)
		if tRechargeData then
			-- dump(tRechargeData)
			reqRecharge(tRechargeData)
		end
	end
	
end
function ItemEverydayPreference:onItemClicked( ... )
	-- body
	local tObject = {} 
	tObject.nType = e_dlg_index.dlgeverypreferencedetail --dlg类型
	tObject.tData = self.tData
	sendMsg(ghd_show_dlg_by_type,tObject)
end


function ItemEverydayPreference:addSpecialEffect()
 	-- body
 	addTextureToCache("tx/other/rwww_ksdh_qsaq")
 
 	if not self.pIconEffects[1] then
	 	self.pIconEffects[1] = MUI.MImage.new(self.tRewardImg[self.nIndex])
	 	self.pLayIcon:addChild(self.pIconEffects[1],17)
		self.pIconEffects[1]:setOpacity(0)
	 	
	 	self.pIconEffects[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	
	 	self.pIconEffects[1]:setPosition(self.pImgReward:getPositionX(),self.pImgReward:getPositionY())

	 	local fadeTo4 = cc.FadeTo:create(0,0)
		local fadeTo5 = cc.FadeTo:create(0.5,255 * 0.3)
		local fadeTo6 = cc.FadeTo:create(0.5,0)
		self.pIconEffects[1]:runAction(cc.RepeatForever:create(cc.Sequence:create(fadeTo4,fadeTo5,fadeTo6)))

	 end
	 if not self.pIconEffects[2] then
	 	self.pIconEffects[2] = MUI.MImage.new("#rwww_ksdh_qsaq_002.png")
		self.pIconEffects[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pIconEffects[2]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayIcon:addChild(self.pIconEffects[2],3)
		centerInView(self.pLayIcon,self.pIconEffects[2])
		-- self.pIconEffects[2]:setPositionY(self.pIconEffects[2]:getPositionY() + 18)
	end

	if not self.pIconEffects[3] then
	 	self.pIconEffects[3] = MUI.MImage.new("#rwww_ksdh_qsaq_002.png")
		self.pIconEffects[3]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pIconEffects[3]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayIcon:addChild(self.pIconEffects[3],3)
		centerInView(self.pLayIcon,self.pIconEffects[3])
		-- self.pIconEffects[4]:setPositionY(self.pIconEffects[4]:getPositionY() + 18)
	end
	if not self.pIconEffects[4] then
	 	self.pIconEffects[4] = MUI.MImage.new("#rwww_ksdh_qsaq_002.png")
		self.pIconEffects[4]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pIconEffects[4]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayIcon:addChild(self.pIconEffects[4],3)
		centerInView(self.pLayIcon,self.pIconEffects[4])
		-- self.pIconEffects[5]:setPositionY(self.pIconEffects[5]:getPositionY() + 18)
	end

	local delay1 = cc.DelayTime:create(0.33)
	local delay2 = cc.DelayTime:create(0.33)
	local delay3 = cc.DelayTime:create(0.33)
	local callback1 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		self.pIconEffects[2]:setRotation(random)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.38,0.92)
		local scale3 = cc.ScaleTo:create(0.55,1.5)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pIconEffects[2]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback2 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.38,0.92)
		local scale3 = cc.ScaleTo:create(0.55,1.5)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pIconEffects[3]:setRotation(random)
		self.pIconEffects[3]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback3 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.38,0.92)
		local scale3 = cc.ScaleTo:create(0.55,1.5)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pIconEffects[4]:setRotation(random)
		self.pIconEffects[4]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	self:runAction(cc.RepeatForever:create(cc.Sequence:create(callback1,delay1,callback2,delay2,callback3,delay3)))

 end 

return ItemEverydayPreference


