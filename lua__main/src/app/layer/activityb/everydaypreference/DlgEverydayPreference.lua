----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-05 13:52:52
-- Description: 每日特惠
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local ItemEverydayPreference  = require("app.layer.activityb.everydaypreference.ItemEverydayPreference")
require("app.layer.task.EffectTBoxDatas")

local DlgEverydayPreference = class("DlgEverydayPreference", function()
	return DlgBase.new(e_dlg_index.everydaypreference)
end)

function DlgEverydayPreference:ctor(  )
	parseView("dlg_everyday_preference", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function DlgEverydayPreference:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	self:myInit()
	self:setupViews()

	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgEverydayPreference",handler(self, self.onDlgEverydayPreferenceDestroy))
end

function DlgEverydayPreference:myInit(  )
	-- body
	self.tActData=nil
	self.tAllItemInfo=nil
	self.pParitcle = nil --粒子特效
	-- self.tBoxEffects = nil
	self.pSpecialEffects = {}
end

function DlgEverydayPreference:setupViews()
	self.tActData = Player:getActById(e_id_activity.everydaypreference)
	-- body
	--设置标题
	self:setTitle(self.tActData.sName)
	self.pLayList = self:findViewByName("lay_list")
	local pLayTop = self:findViewByName("img_title")
	pLayTop:setIgnoreOtherHeight(true)
	--描述
	-- self.pLbDesc = self:findViewByName("lb_tip")
	-- self.pLbDesc:setString(tData.sDesc)
	--banner
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_mrth)

	self.pTxtTitleBtn = self:findViewByName("txt_title_btn")
	self.pTxtTitleBtn:setString(getConvertedStr(9,10070))

	self.pLayReward = self:findViewByName("lay_reward")
	

	self.pImgBx = self:findViewByName("img_bx")
	self.pImgBx:setViewTouched(true)
	self.pImgBx:setIsPressedNeedColor(false)
	self.pImgBx:onMViewClicked(handler(self, self.onGetReward))
	self.pImgBtn = self:findViewByName("img_btn")

	local pTxtTip1=self:findViewByName("txt_tip1")
	local pTxtTip2=self:findViewByName("txt_tip2")
	local pTxtTip3=self:findViewByName("txt_tip3")
	local pTxtTip4=self:findViewByName("txt_tip4")
	setTextCCColor(pTxtTip1,_cc.gray)
	setTextCCColor(pTxtTip2,_cc.gray)
	setTextCCColor(pTxtTip3,_cc.gray)
	setTextCCColor(pTxtTip4,_cc.gray)
	pTxtTip1:setString(getConvertedStr(9,10079))
	pTxtTip2:setString(getConvertedStr(9,10080))
	pTxtTip3:setString(getConvertedStr(9,10081))
	pTxtTip4:setString(getConvertedStr(9,10082))


end


--控件刷新
function DlgEverydayPreference:updateViews()
	self.tActData = Player:getActById(e_id_activity.everydaypreference)
	if not self.tActData then
		self:closeDlg(false)
	 	return 
	end
	-- dump(self.tActData,"dlgeverydaypreference 71")

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLayBannerBg, self.tActData, cc.p(0, 242))
	else
		self.pActTime:setCurData(self.tActData)
	end

	self.tAllItemInfo = self.tActData.tPs or self.tAllItemInfo

	-- --更新列表数据
	if not self.pListView then
		--列表
		local pSize = self.pLayList:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {
				left   = 0,
	            right  = 0,
	            top    = 0, 
	            bottom = 10}
	    }
	    self.pLayList:addView(self.pListView)
		local nCount = table.nums(self.tAllItemInfo)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView = ItemEverydayPreference.new()
			end
			pTempView:setData(self.tAllItemInfo[_index],_index)
		    return pTempView
		end)
		self.pListView:reload()
	else
		self.pListView:notifyDataSetChange(true)
	end

	if self.tActData.nT==0 then 		--未领取 
		self.pTxtTitleBtn:setString(getConvertedStr(9,10070))
		self.pImgBx:setCurrentImage("#v1_img_guojia_renwubaoxiang1.png")

		self.pImgBx:setVisible(true)
		self:addEffects()
		self:addSpecialEffect()
		-- showBreathTx(self.pImgBx)
		
		self.pImgBtn:setToGray(false)
		
	elseif self.tActData.nT == 1 then 	--已领取
		self:removeEffect()
		self.pImgBx:setViewTouched(false)

		self.pTxtTitleBtn:setString(getConvertedStr(9,10071))
		self.pImgBx:setCurrentImage("#v1_img_guojia_renwubaoxiang3.png")
		self:removeEffect()
		showGrayTx(self.pImgBx, false)
		self.pImgBtn:setToGray(true)
	end
end

function DlgEverydayPreference:onGetReward(  )
	-- body
	if self.tActData.nT == 0 then
		SocketManager:sendMsg("getEverydayPreference", {}, function(__msg)
			-- body

			if __msg.body and __msg.body.o then
				--奖励领取表现(包含有武将的情况走获得武将流程)
				showGetItemsAction(__msg.body.o)	
				self.tActData:updateEverydayRewardState(__msg.body)
				sendMsg(gud_refresh_activity)
				-- self:updateViews()
			end
		end)
	end
end

function DlgEverydayPreference:addSpecialEffect()
 	-- body
 	addTextureToCache("tx/other/rwww_ksdh_qsaq")
 
 	if not self.pSpecialEffects[1] then
	 	self.pSpecialEffects[1] = MUI.MImage.new("#rwww_ksdh_qsaq_003.png")
	 	self.pLayReward:addChild(self.pSpecialEffects[1],6)
	 	self.pSpecialEffects[1]:setScale(1.7)
	 	self.pSpecialEffects[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	centerInView(self.pLayReward,self.pSpecialEffects[1])
	 	self.pSpecialEffects[1]:setPositionY(self.pSpecialEffects[1]:getPositionY() + 18)

	 end
	 if not self.pSpecialEffects[2] then
	 	self.pSpecialEffects[2] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[2]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[2],3)
		centerInView(self.pLayReward,self.pSpecialEffects[2])
		self.pSpecialEffects[2]:setPositionY(self.pSpecialEffects[2]:getPositionY() + 18)
	end
	if not self.pSpecialEffects[3] then
	 	self.pSpecialEffects[3] = MUI.MImage.new("#v1_img_guojia_renwubaoxiang1.png")
		self.pSpecialEffects[3]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		-- self.pSpecialEffects[3]:setScale(0.8)
		self.pSpecialEffects[3]:setOpacity(0)
		self.pImgBx:addChild(self.pSpecialEffects[3],110)
		centerInView(self.pImgBx,self.pSpecialEffects[3])
	end
	showFloatTx(self.pImgBx,0.5)
	showFloatTx(self.pSpecialEffects[3],0.5,0.5 * 255,0)

	if not self.pSpecialEffects[4] then
	 	self.pSpecialEffects[4] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[4]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[4]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[4],3)
		centerInView(self.pLayReward,self.pSpecialEffects[4])
		self.pSpecialEffects[4]:setPositionY(self.pSpecialEffects[4]:getPositionY() + 18)
	end
	if not self.pSpecialEffects[5] then
	 	self.pSpecialEffects[5] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[5]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[5]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[5],3)
		centerInView(self.pLayReward,self.pSpecialEffects[5])
		self.pSpecialEffects[5]:setPositionY(self.pSpecialEffects[5]:getPositionY() + 18)
	end

	local delay1 = cc.DelayTime:create(0.33)
	local delay2 = cc.DelayTime:create(0.33)
	local delay3 = cc.DelayTime:create(0.33)
	local callback1 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		self.pSpecialEffects[2]:setRotation(random)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.38,0.92)
		local scale3 = cc.ScaleTo:create(0.55,1.5)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[2]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
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
		self.pSpecialEffects[4]:setRotation(random)
		self.pSpecialEffects[4]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
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
		self.pSpecialEffects[5]:setRotation(random)
		self.pSpecialEffects[5]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	self.pLayReward:runAction(cc.RepeatForever:create(cc.Sequence:create(callback1,delay1,callback2,delay2,callback3,delay3)))

 end 

function DlgEverydayPreference:addEffects(  )
	-- body
	if not self.pParitcle then
		local pParitcleB = createParitcle("tx/other/lizi_huode_xjz_lzdh_001.plist")
		pParitcleB:setScale(0.8)
		pParitcleB:setPosition(self.pImgBx:getPositionX(), self.pImgBx:getPositionY())
		self.pLayReward:addView(pParitcleB,5)
		self.pParitcle = pParitcleB
	end
end

function DlgEverydayPreference:removeEffect(  )
	-- body
	
	self.pImgBx:stopAllActions()
	self.pLayReward:stopAllActions()
	if self.pParitcle then
		self.pParitcle:removeSelf()
		self.pParitcle = nil
	end
	for k,v in pairs(self.pSpecialEffects) do
 		v:removeSelf()
 		v= nil
 	end
 	self.pSpecialEffects = {}
end


--析构方法
function DlgEverydayPreference:onDlgEverydayPreferenceDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgEverydayPreference:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end
--注销消息
function DlgEverydayPreference:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgEverydayPreference:onPause( )
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgEverydayPreference:onResume(_bReshow)
	self:updateViews()
	self:regMsgs()
end


return DlgEverydayPreference