----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-19 16:48:57
-- Description: 攻城掠地（首次攻城）
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
require("app.layer.task.EffectTBoxDatas")
local FirstAttkCity = class("FirstAttkCity", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function FirstAttkCity:ctor(  )
    -- self:setContentSize(_tSize)
	--解析文件
	parseView("first_attk_city", handler(self, self.onParseViewCallback))
end

--解析界面回调
function FirstAttkCity:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FirstAttkCity", handler(self, self.onFirstAttkCityDestroy))

end

-- 析构方法
function FirstAttkCity:onFirstAttkCityDestroy(  )
    self:onPause()
end

function FirstAttkCity:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function FirstAttkCity:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function FirstAttkCity:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function FirstAttkCity:onPause(  )
	self:unregMsgs()
end

function FirstAttkCity:setupViews(  )
	self.pImgBx= self:findViewByName("img_reward")
	self.pImgBx:setViewTouched(true)
	self.pImgBx:setIsPressedNeedColor(false)
	self.pImgBx:onMViewClicked(handler(self, self.onGetDailyReward))

	self.pImgBtn= self:findViewByName("img_btn")
	self.pImgBtn:setViewTouched(true)
	self.pImgBtn:setIsPressedNeedColor(false)
	self.pImgBtn:onMViewClicked(handler(self, self.onGoClicked))

	self.pLayReward = self:findViewByName("lay_reward")
	self.pImgState = self:findViewByName("img_state")
	self.pTxtTip = self:findViewByName("txt_tip")
	self.tLayItem ={}
	for i=1,4 do 
		local pItem = {}
		pItem.pLaySlot=self:findViewByName("lay_slot" .. i)
			
		pItem.pLbName=self:findViewByName("lb_item_name" .. i)
		pItem.pLayNumBg=self:findViewByName("lay_num_bg" .. i)
		pItem.pLbNum=self:findViewByName("lb_num" .. i)

		table.insert(self.tLayItem,pItem)
	end

	self:addItem()

end

function FirstAttkCity:updateViews(  )
	self.tActData=Player:getActById(e_id_activity.attackcity)
	if not self.tActData then
		return
	end
	--每日宝箱
	if self.tActData.nDbg==0 then 		--未领取 
		-- self.pTxtTitleBtn:setString(getConvertedStr(9,10070))
		self.pImgBx:setCurrentImage("#v1_img_guojia_renwubaoxiang2.png")

		self.pImgBx:setVisible(true)
		self:addEffects()
		showBreathTx(self.pImgBx)
		
	elseif self.tActData.nDbg == 1 then 	--已领取
		-- self.pImgBx:setViewTouched(false)

		self.pImgBx:setCurrentImage("#v1_img_guojia_renwubaoxiang3.png")
		self:removeEffect()
		showGrayTx(self.pImgBx, false)
		self.pImgBx:setVisible(false)
	end

	if self.pLayRedS then
		showRedTips(self.pLayRedS, 0,1)

	end

	--首次攻城
	if self.tActData:getFirstAttkCityState() == 1 then -- 未完成

		self.pImgBtn:setCurrentImage("#v2_btn_qianwang.png")
		self.pImgBtn:setVisible(true)

		self.pImgBtn:setToGray(false)
		self.pImgBtn:setViewTouched(true)
		self.pImgState:setVisible(false)
		self.pTxtTip:setVisible(true)
		

	elseif self.tActData:getFirstAttkCityState() == 2 then --已完成
		self.pImgBtn:setCurrentImage("#v2_btn_lingqu.png")
		self.pImgBtn:setVisible(true)

		self.pImgBtn:setToGray(false)
		self.pImgBtn:setViewTouched(true)
		self.pTxtTip:setVisible(false)
		self.pImgState:setVisible(false)

		if not self.pLayRedS then
			local pLayRed = MUI.MLayer.new(true)
			pLayRed:setLayoutSize(26, 26)		
			pLayRed:setPosition(self.pImgBtn:getWidth()-45, self.pImgBtn:getHeight() - 22)
            pLayRed:setIgnoreOtherHeight(true)
			self.pImgBtn:addChild(pLayRed, 100)
			self.pLayRedS = pLayRed
		end
		showRedTips(self.pLayRedS, 0,1)


	elseif self.tActData:getFirstAttkCityState() == 3 then --已领取
		self.pImgBtn:setVisible(false)
		self.pTxtTip:setVisible(false)
		self.pImgState:setVisible(true)

	end

	local bIsOpen = Player:getPlayerInfo().nLv >= 45
	if bIsOpen then
		self.pTxtTip:setString(getConvertedStr(9,10124))
		setTextCCColor(self.pTxtTip,_cc.white)
		self.pImgBtn:setViewTouched(true)
		self.pImgBtn:setToGray(false)
	else
		self.pTxtTip:setString(getConvertedStr(9,10125))
		setTextCCColor(self.pTxtTip,_cc.red)
		self.pImgBtn:setViewTouched(false)
		self.pImgBtn:setToGray(true)

	end

end
function FirstAttkCity:addEffects(  )
	-- body
	if not self.tBoxEffects then
		self.tBoxEffects = self:getBoxEffects(self.pImgBx, self.pImgBx:getWidth()/2, self.pImgBx:getHeight()/2, 10)
	end
	if not self.pParitcle then
		local pParitcleB = createParitcle("tx/other/lizi_mlz_sf_001.plist")
		pParitcleB:setPosition(self.pImgBx:getPositionX(), self.pImgBx:getPositionY())
		self.pLayReward:addView(pParitcleB,30)
		self.pParitcle = pParitcleB
	end
end
function FirstAttkCity:getBoxEffects(pview, fx, fy, nZorder)
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
function FirstAttkCity:removeEffect(  )
	-- body
	if self.tBoxEffects then
		for i=1,#self.tBoxEffects do
			self.tBoxEffects[i]:stop()
			MArmatureUtils:removeMArmature(self.tBoxEffects[i])
		end
		self.tBoxEffects = nil		
	end
	if self.pParitcle then
		self.pParitcle:removeSelf()
		self.pParitcle = nil
	end
end

function FirstAttkCity:addItem(  )
	local tTemp = getAttkCityInitData("firstblood")

	local tDropData= getDropById(tTemp.value)
	if tDropData then
		-- dump(tDropData)
		for i= 1 ,4 do
			if tDropData[i] then
				local pImgIcon = MUI.MImage.new(tDropData[i].sIcon)
				-- pImgIcon:setScale(0.8)
				-- pImgIconBg:setPosition(nX,nBoxY)
				self.tLayItem[i].pLaySlot:addView(pImgIcon, 1)
				centerInView(self.tLayItem[i].pLaySlot,pImgIcon)
				self.tLayItem[i].pLbNum:setString(tDropData[i].nCt)
				self.tLayItem[i].pLbName:setString(tDropData[i].sName)

				self.tLayItem[i].pLayNumBg:setLayoutSize(self.tLayItem[i].pLbNum:getWidth()+10, self.tLayItem[i].pLayNumBg:getHeight())
				centerInView(self.tLayItem[i].pLayNumBg,self.tLayItem[i].pLbNum)
				self.tLayItem[i].pLayNumBg:setPositionX(self.tLayItem[i].pLaySlot:getWidth() - self.tLayItem[i].pLayNumBg:getWidth() - 3)
				self.tLayItem[i].pLaySlot:setViewTouched(true)
				self.tLayItem[i].pLaySlot:setIsPressedNeedScale(false)
				self.tLayItem[i].pLaySlot:setIsPressedNeedColor(true)
				self.tLayItem[i].pLaySlot:onMViewClicked(function (_pView )
					-- body
					if tDropData[i].nGtype == e_type_goods.type_hero then
						local tObject = {}
						tObject.nType = e_dlg_index.heroinfo --dlg类型
						tObject.tData = tDropData[i]
						tObject.bShowBaseData = true
						sendMsg(ghd_show_dlg_by_type,tObject)
					else
						openIconInfoDlg(_pView,tDropData[i])
					end
				end)

			end
		end

	end

end

function FirstAttkCity:onGetDailyReward(  )
	-- body
	if self.tActData.nDbg == 0 then

		SocketManager:sendMsg("getAttkCityDailyReward", {}, function(__msg)
			-- body

			if __msg.body and __msg.body.ob then
				--奖励领取表现(包含有武将的情况走获得武将流程)
				showGetItemsAction(__msg.body.ob)	
				self.tActData.nDbg = __msg.body.dbg
				-- self:updateViews()
				sendMsg(gud_refresh_activity)
			end
		end)
	else
		TOAST(getConvertedStr(9,10123))
	end
end

function FirstAttkCity:onGoClicked(  )

	if self.tActData:getFirstAttkCityState() == 1 then -- 未完成

		local nX, nY = Player:getWorldData():getMyCityDotPos()
		local nBlockId = WorldFunc.getBlockId(nX, nY)
		local tWorldCitys = getWorldCityDataByMapId(nBlockId)
		local tTarget = nil 
		if tWorldCitys then
			local tMyCountryCityList = Player:getCountryData():getCountryCitys()  --本国城池
			table.sort(tWorldCitys,function ( a,b )
				-- body
				return a.kind > b.kind
			end)
			if tMyCountryCityList and #tMyCountryCityList > 0 then
				for k,v in pairs(tWorldCitys) do
					for kk,vv in pairs(tMyCountryCityList) do 
						if v.id ~= vv.nID then   --找到一个非本国城池
							tTarget = v
						end
					end 
				end
			else   --没有本国城池的时候就返回第一个
				tTarget=tWorldCitys[1]
			end
		end
		if tTarget then
			local fX,fY = tTarget.tMapPos.x, tTarget.tMapPos.y
			sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
		else
			sendMsg(ghd_world_locaction_my_city_msg)
		end
		closeDlgByType(e_dlg_index.attkcity)
	elseif self.tActData:getFirstAttkCityState() == 2 then -- 已完成
		SocketManager:sendMsg("getFirstAttkCityReward", {}, function(__msg)
			-- body

			if __msg.body and __msg.body.ob then
				--奖励领取表现(包含有武将的情况走获得武将流程)
				showGetItemsAction(__msg.body.ob)	
				self.tActData:refreshDatasByServer(__msg.body)
				-- self:updateViews()
				sendMsg(gud_refresh_activity)
			end
		end)
	end
	-- body
	-- if self.tActData.nT == 0 then
	-- 	SocketManager:sendMsg("getEverydayPreference", {}, function(__msg)
	-- 		-- body

	-- 		if __msg.body and __msg.body.o then
	-- 			--奖励领取表现(包含有武将的情况走获得武将流程)
	-- 			showGetItemsAction(__msg.body.o)	
	-- 			self.tActData:updateEverydayRewardState(__msg.body)
	-- 			self:updateViews()
	-- 		end
	-- 	end)
	-- end
end


return FirstAttkCity



