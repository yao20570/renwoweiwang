----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-09 15:37:26
-- Description: 腊八拉霸
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local IconGoods = require("app.common.iconview.IconGoods")
local SingleLaba = require("app.layer.activityb.laba.SingleLaba")
local MImgLabel = require("app.common.button.MImgLabel")

local nAllGoodsCnt = 8

local nOneBuy = 1
local nTenBuy = 10
local nFreeType = 0
local nPriceType = 1

local DlgLaba = class("DlgLaba", function()
	return DlgBase.new(e_dlg_index.laba)
end)

function DlgLaba:ctor(  )
	parseView("dlg_laba", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgLaba:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容
	self:addContentTopSpace()
	self:myInit()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgLaba",handler(self, self.onDlgLabaDestroy))
end

-- 析构方法
function DlgLaba:onDlgLabaDestroy(  )
    self:onPause()
end

function DlgLaba:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
	regMsg(self, ghd_laba_stop, handler(self, self.onFinish))

end

function DlgLaba:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
	unregMsg(self, ghd_laba_stop)
end

function DlgLaba:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgLaba:onPause(  )
	self:unregMsgs()
end

function DlgLaba:myInit(  )
	-- body
	self.tData=nil
	self.bIsBest = false
	self.bIsRolling = false

	self.nCurBtnIndex = 0 --本次抽取的是哪个级别的按钮

	self.tBestParitcle ={}

	self.tOb = {}
end

function DlgLaba:setupViews(  )

	--停止层
	self.pLayStop = self:findViewByName("lay_stop")
	self.pLayStop:setViewTouched(true)
	self.pLayStop:setIsPressedNeedColor(false)
	self.pLayStop:setIsPressedNeedScale(false)
	self.pLayStop:setVisible(false)

	self.pLayStop:onMViewClicked(handler(self, self.onStopLabaForce))


	self.pLayTop = self:findViewByName("lay_top")
	self.pContentBg=self:findViewByName("lay_content")
	-- --banner
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_lblb)

	self.pTxtDesc = self:findViewByName("txt_desc")
	self.pLayImgYl= self:findViewByName("lay_img_yl")  --预览
	local pImgYl = MUI.MImage.new("#v1_img_wangquanzhengshou.png")
	pImgYl:setViewTouched(true)
	pImgYl:setIsPressedNeedColor(false)
	pImgYl:onMViewClicked(handler(self, self.onYlClicked))

	pImgYl:setAnchorPoint(cc.p(0,0))
	self.pLayImgYl:addView(pImgYl,2)

	local pLayYlBtn = self:findViewByName("lay_yl_btn")
	local pYlBtn = getCommonButtonOfContainer(pLayYlBtn ,TypeCommonBtn.M_YELLOW, getConvertedStr(9, 10090))
	pYlBtn:onCommonBtnClicked(handler(self, self.onYlClicked))
	setMCommonBtnScale(pLayYlBtn, pYlBtn, 0.7)
	pYlBtn:updateBtnTextSize(23)

	self.tBestRewardList ={}
	for i=1,4 do
		local pLayReward = self:findViewByName("lay_zj_slot".. i)
		table.insert(self.tBestRewardList,pLayReward)
	end

	self.pLayBtnLeft= self:findViewByName("lay_btn_left")
	self.pBtnLeft = getCommonButtonOfContainer(self.pLayBtnLeft, TypeCommonBtn.L_BLUE, getConvertedStr(9, 10091),false)
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onGetOnce))

	self.pLayBtnCenter= self:findViewByName("lay_btn_center")
	self.pBtnCenter = getCommonButtonOfContainer(self.pLayBtnCenter, TypeCommonBtn.L_YELLOW, getConvertedStr(9, 10092),false)
	self.pBtnCenter:onCommonBtnClicked(handler(self, self.onGetTen))

	self.pLayBtnRight= self:findViewByName("lay_btn_right")
	self.pBtnRight = getCommonButtonOfContainer(self.pLayBtnRight, TypeCommonBtn.L_BLUE, getConvertedStr(9, 10093),false)
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onGetFifty))
	-- setMCommonBtnScale(pLayBtnShare, self.pBtnShare, 0.9)

	self.pLayLaba1 = self:findViewByName("lay_laba1")
	self.pLayLaba2 = self:findViewByName("lay_laba2")
	self.pLayLaba3 = self:findViewByName("lay_laba3")

	--添加3个拉霸滚动层
	self.pLaba1 = SingleLaba.new(self.pLayLaba1:getWidth(),self.pLayLaba1:getHeight(),1)
	self.pLayLaba1:addView(self.pLaba1)
	self.pLaba2 = SingleLaba.new(self.pLayLaba1:getWidth(),self.pLayLaba1:getHeight(),2)
	self.pLayLaba2:addView(self.pLaba2)
	self.pLaba3 = SingleLaba.new(self.pLayLaba1:getWidth(),self.pLayLaba1:getHeight(),3)
	self.pLayLaba3:addView(self.pLaba3)

	self.pLaba1:initLaba(3,2,1)
	self.pLaba2:initLaba(4,3,2)
	self.pLaba3:initLaba(1,4,3)

	self.pMask1 = MUI.MImage.new("#v2_img_labazhegai.png")
	self.pMask1:setAnchorPoint(0,0)
	

	self.pLayLaba1:addView(self.pMask1)

	self.pMask1:setVisible(false)

	self.pMask2 = MUI.MImage.new("#v2_img_labazhegai.png")
	self.pMask2:setAnchorPoint(0,0)
	

	self.pLayLaba2:addView(self.pMask2)
	self.pMask2:setVisible(false)


	self.pMask3 = MUI.MImage.new("#v2_img_labazhegai.png")
	self.pMask3:setAnchorPoint(0,0)
	

	self.pLayLaba3:addView(self.pMask3)
	self.pMask3:setVisible(false)

	self.pLayBest = self:findViewByName("lay_best")
	self.pLayBest:setVisible(false)

	-- self.pLaba1:playLaba()
	-- self.pLaba2:playLaba()
	-- self.pLaba3:playLaba()

	--抽一次文字
	self.pImgLeftLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtnLeft})
	self.pImgLeftLabel:setImg(getCostResImg(e_type_resdata.money), 1, "left")
	self.pImgLeftLabel:followPos("center", self.pLayBtnLeft:getContentSize().width/2, self.pLayBtnLeft:getContentSize().height + 20, 3)

	--抽10次文字
	self.pImgCenterLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtnCenter})
	self.pImgCenterLabel:setImg(getCostResImg(e_type_resdata.money), 1, "left")
	self.pImgCenterLabel:followPos("center", self.pLayBtnCenter:getContentSize().width/2, self.pLayBtnCenter:getContentSize().height + 20, 3)

	--抽50次文字
	self.pImgRightLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtnRight})
	self.pImgRightLabel:setImg(getCostResImg(e_type_resdata.money), 1, "left")
	self.pImgRightLabel:followPos("center", self.pLayBtnRight:getContentSize().width/2, self.pLayBtnRight:getContentSize().height + 20, 3)

	--中间折扣
	self.pImgDiscountCenter =  MUI.MImage.new("#v1_img_kejiman.png")
  	self.pImgDiscountCenter:setAnchorPoint(0,1)
  	self.pImgDiscountCenter:setScale(0.8)
  	self.pBtnCenter:addView(self.pImgDiscountCenter,99)
  	self.pImgDiscountCenter:setPosition(0,self.pBtnCenter:getContentSize().height)
  	self.pTxtDiscountCenter = MUI.MLabel.new({text = "1", size = 20})
  	self.pTxtDiscountCenter:setRotation(-45)
  	self.pTxtDiscountCenter:setAnchorPoint(0.5,0.5)
  	self.pImgDiscountCenter:addChild(self.pTxtDiscountCenter,100)
  	self.pTxtDiscountCenter:setPosition(27, self.pImgDiscountCenter:getHeight() - 20)
  	--右边折扣
  	self.pImgDiscountRight =  MUI.MImage.new("#v1_img_xinpin.png")
  	self.pImgDiscountRight:setAnchorPoint(0,1)
  	self.pImgDiscountRight:setScale(0.8)
  	self.pBtnRight:addView(self.pImgDiscountRight,99)
  	self.pImgDiscountRight:setPosition(0,self.pBtnRight:getContentSize().height)
  	self.pTxtDiscountRight = MUI.MLabel.new({text = "1", size = 20})
  	self.pTxtDiscountRight:setRotation(-45)
  	self.pTxtDiscountRight:setAnchorPoint(0.5,0.5)
  	self.pImgDiscountRight:addChild(self.pTxtDiscountRight,100)
  	self.pTxtDiscountRight:setPosition(27, self.pImgDiscountRight:getHeight() - 20)

  	--灯光动画
	self:setBgTx()
end


--控件刷新
function DlgLaba:updateViews()

	self.tData = Player:getActById(e_id_activity.laba)
	if not self.tData then
		self:closeDlg(false)
		return
	end
	if self.tData then
		--设置标题
		self:setTitle(self.tData.sName)

		--活动时间
		if not self.pActTime then
			self.pActTime = createActTime(self.pLayTop, self.tData, cc.p(0,242))
		else
			self.pActTime:setCurData(self.tData)
		end

		--描述
		self.pTxtDesc:setString(self.tData.sDesc)

	end
	local nIndex = 1 
	for k,v in pairs(self.tData.tShow) do
		local pIcon=self.tBestRewardList[nIndex]:findViewByName("slot"..nIndex)
		if not pIcon then
        
	        pIcon = IconGoods.new(TypeIconGoods.NORMAL)
	        pIcon:setAnchorPoint(0,0)
	        -- centerInView(self.tBestRewardList[nIndex],pIcon)
	        pIcon:setName("slot"..nIndex)
	        self.tBestRewardList[nIndex]:addView(pIcon)
	        pIcon:setIconScale(0.8)
    	end
    	local pItemData = getGoodsByTidFromDB(v.v)
	    if pItemData then
            pIcon:setCurData(pItemData)
            -- pIcon:setMoreText(pItemData.sName)
            -- pIcon:setMoreTextColor(_cc.pwhite)
        end
        -- pIcon:setNumber(v.v)

        nIndex = nIndex + 1 
	end

	if self.tData:isHaveFree() then

		self.pImgLeftLabel:hideImg()
		self.pImgLeftLabel:setString(string.format(getConvertedStr(9,10099),tostring(self.tData:getFreeNum())))
			-- self.pImgLeftLabel:setPo
	else
		self.pImgLeftLabel:showImg()
		self.pImgLeftLabel:setString(tostring(self.tData:getPrice(1)))
	end

	self.pImgCenterLabel:setString(tostring(self.tData:getPrice(10)))
	self.pImgRightLabel:setString(tostring(self.tData:getPrice(50)))

	if self.tData.nR10 < 1 then
		self.pImgDiscountCenter:setVisible(true)
		local nDiscount = self.tData.nR10 * 10
		self.pTxtDiscountCenter:setString(string.format(getConvertedStr(9,10100),tostring(nDiscount)))
	else
		self.pImgDiscountCenter:setVisible(false)
	end

	if self.tData.nR50 < 1 then
		self.pImgDiscountRight:setVisible(true)
		local nDiscount = self.tData.nR50 * 10
		self.pTxtDiscountRight:setString(string.format(getConvertedStr(9,10100),tostring(nDiscount)))
	else
		self.pImgDiscountRight:setVisible(false)
	end

end

function DlgLaba:setBgTx()
	addTextureToCache("tx/other/rwww_qmlb_w")
	local pLight1 = MUI.MImage.new("#rwww_qmlb_w_01.png")
	self.pContentBg:addView(pLight1)
	centerInView(self.pContentBg,pLight1)
	pLight1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pLight1:setOpacity(0)
	pLight1:setScale(2)
	local pLight2 = MUI.MImage.new("#rwww_qmlb_w_02.png")
	self.pContentBg:addView(pLight2)
	centerInView(self.pContentBg,pLight2)
	pLight2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pLight2:setOpacity(0)
	pLight2:setScale(2)
	local pLight3 = MUI.MImage.new("#rwww_qmlb_w_03.png")
	self.pContentBg:addView(pLight3)
	centerInView(self.pContentBg,pLight3)
	pLight3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pLight3:setOpacity(0)
	pLight3:setScale(2)
	local pLight4 = MUI.MImage.new("#rwww_qmlb_w_04.png")
	self.pContentBg:addView(pLight4)
	centerInView(self.pContentBg,pLight4)
	pLight4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pLight4:setOpacity(0)
	pLight4:setScale(2)

	local delay1 = cc.DelayTime:create(0.4)
	local delay2 = cc.DelayTime:create(0.4)
	local delay3 = cc.DelayTime:create(0.4)

	function callback1(  )
		-- body
		local action0_1 = cc.FadeTo:create(0, 0)
		local action0_2 = cc.FadeTo:create(0.8, 255*1)
		local action0_3 = cc.FadeTo:create(0.8, 0)
		local action1 = cc.RepeatForever:create(cc.Sequence:create(action0_1, action0_2,action0_3))
		pLight1:runAction(action1)
	end
	function callback2(  )
		-- body
		local action0_1 = cc.FadeTo:create(0, 0)
		local action0_2 = cc.FadeTo:create(0.8, 255*1)
		local action0_3 = cc.FadeTo:create(0.8, 0)
		local action1 = cc.RepeatForever:create(cc.Sequence:create(action0_1, action0_2,action0_3))
		pLight2:runAction(action1)
	end
	function callback3(  )
		-- body
		local action0_1 = cc.FadeTo:create(0, 0)
		local action0_2 = cc.FadeTo:create(0.8, 255*1)
		local action0_3 = cc.FadeTo:create(0.8, 0)
		local action1 = cc.RepeatForever:create(cc.Sequence:create(action0_1, action0_2,action0_3))
		pLight3:runAction(action1)
	end
	function callback4(  )
		-- body
		local action0_1 = cc.FadeTo:create(0, 0)
		local action0_2 = cc.FadeTo:create(0.8, 255*1)
		local action0_3 = cc.FadeTo:create(0.8, 0)
		local action1 = cc.RepeatForever:create(cc.Sequence:create(action0_1, action0_2,action0_3))
		pLight4:runAction(action1)
	end
	local action3 = cc.CallFunc:create(callback1)
	local action4 = cc.CallFunc:create(callback2)
	local action5 = cc.CallFunc:create(callback3)
	local action6 = cc.CallFunc:create(callback4)

	self.pContentBg:runAction(cc.Sequence:create(action3,delay1,action4,delay2 ,action5, delay3,action6))

end

function DlgLaba:onYlClicked(  )
	-- body

	local tObject = {}
    tObject.nType = e_dlg_index.labarewarddetail --dlg类型
  
    sendMsg(ghd_show_dlg_by_type,tObject)
end

function DlgLaba:onGetOnce(  )
	-- body

	if self.bIsRolling then
		return
	end
	self.nCurBtnIndex=1

	self.pLaba1:setRollingState(true)
	self.pLaba2:setRollingState(true)
	self.pLaba3:setRollingState(true)

	local nCost = 0
	
	if self.tData then
		if self.tData:isHaveFree() then
			SocketManager:sendMsg("getLabaReward", {1}, handler(self, self.getRewardCallback))
		else
			local strTips = {
			    {color=_cc.pwhite,text=getConvertedStr(9, 10095)},
			    {color=_cc.blue,text=tostring(1)..getConvertedStr(3, 10324)},
			}
			--展示购买对话框
			showBuyDlg(strTips,self.tData.nPrice,function (  )
			    SocketManager:sendMsg("getLabaReward", {1}, handler(self, self.getRewardCallback))
			end)
		end
	end
	-- self.pLaba1:setTarget(2)
	-- self.pLaba2:setTarget(2)
	-- self.pLaba1:setTarget(3)

	
	-- SocketManager:sendMsg("getLabaReward", {10}, handler(self, self.getRewardCallback))
end

function DlgLaba:onGetTen(  )
	-- body
	if self.bIsRolling then
		return
	end
	self.nCurBtnIndex=10
	self.pLaba1:setRollingState(true)
	self.pLaba2:setRollingState(true)
	self.pLaba3:setRollingState(true)

	if self.tData:isHaveFree() then
		TOAST(getConvertedStr(9,10094))
		return
	else
		local strTips = {
		    {color=_cc.pwhite,text=getConvertedStr(9, 10095)},
		    {color=_cc.blue,text=tostring(10)..getConvertedStr(3, 10324)},
		}
		--展示购买对话框
		showBuyDlg(strTips,self.tData.nPrice*10 * self.tData.nR10 ,function (  )
		    SocketManager:sendMsg("getLabaReward", {10}, handler(self, self.getRewardCallback))
		end)
	end
end
function DlgLaba:onGetFifty(  )
	-- body
	if self.bIsRolling then
		return
	end
	self.nCurBtnIndex=50
	self.pLaba1:setRollingState(true)
	self.pLaba2:setRollingState(true)
	self.pLaba3:setRollingState(true)

	if self.tData:isHaveFree() then
		TOAST(getConvertedStr(9,10094))
		return
	else
		local strTips = {
		    {color=_cc.pwhite,text=getConvertedStr(9, 10095)},
		    {color=_cc.blue,text=tostring(50)..getConvertedStr(3, 10324)},
		}
		--展示购买对话框
		showBuyDlg(strTips,self.tData.nPrice*50* self.tData.nR50,function (  )
		    SocketManager:sendMsg("getLabaReward", {50}, handler(self, self.getRewardCallback))
		end)
	end
end

function DlgLaba:getRewardCallback( __msg, __oldMsg )
	-- body
	closeDlgByType(e_dlg_index.showheromansion, false)
	if __msg.head.type == MsgType.getLabaReward.id then 			--领取宝箱奖励
		if __msg.head.state == SocketErrorType.success then
			--后面完善表现
			if __msg.body.r then
				--三个一样

				self.tData:updateFn(__msg.body)
				self:updateViews()
				
				if __msg.body.r[1] == __msg.body.r[2] and __msg.body.r[1] == __msg.body.r[3] then
					self.bIsBest = true
				else
					self.bIsBest = false
				end
				self.pMask1:setVisible(true)
				self.pMask2:setVisible(true)
				self.pMask3:setVisible(true)

				self.pLaba1:setTarget(__msg.body.r[1])
				self.pLaba2:setTarget(__msg.body.r[2])
				self.pLaba3:setTarget(__msg.body.r[3])

				self.bIsRolling = true
				self.pLayStop:setVisible(true)

				self.tOb = __msg.body.ob

				sendMsg(gud_refresh_activity)
			end
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end
--强制停止拉霸
function DlgLaba:onStopLabaForce(  )
	-- body
	sendMsg(ghd_laba_stop_force)
	self:afterFinish()
end

function DlgLaba:onFinish()
	if self.bIsBest then
		function callback2()
			self:afterFinish()
			-- self:showGetReward()
			self:removeBestParitcle()
		end
		local action1 = cc.CallFunc:create(handler(self,self.showBestAction))
		local action2=cc.CallFunc:create(callback2)
		local delay = cc.DelayTime:create(1)
		self:runAction(cc.Sequence:create(action1,delay,action2))
		
		return
	end
	self:afterFinish()
	
end

function DlgLaba:afterFinish(  )
	-- body
	self:showGetReward()
	self.pMask1:setVisible(false)
	self.pMask2:setVisible(false)
	self.pMask3:setVisible(false)
	self.pLayStop:setVisible(false)
end

function DlgLaba:showBestAction()
	self.pLayBest:setVisible(true)
	if #self.tBestParitcle <=0 then
		local pImg1 = MUI.MImage.new("#sg_jxfk_sa1_001.png")

		self.pLayBest:addView(pImg1)
		centerInView(self.pLayBest,pImg1)
		pImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		-- pImg1:setOpacity(0)
		pImg1:setScaleX(0.82)
		pImg1:setScaleY(0.96)

		local pImg2 = MUI.MImage.new("#sg_jxfk_sa1_001.png")
		self.pLayBest:addView(pImg2)
		centerInView(self.pLayBest,pImg2)
		pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg2:setScaleX(0.82)
		pImg2:setScaleY(0.96)


		local pScaleTo1_1 = cc.ScaleTo:create(0,0.82,0.96)
		local pFadeTo1_1 = cc.FadeTo:create(0, 0)
		local pAction1_1 = cc.Spawn:create(pScaleTo1_1,pFadeTo1_1)  --第二层的第一个动画
		local pScaleTo2_1 = cc.ScaleTo:create(0.17,0.85,1.05)
		local pFadeTo2_1 = cc.FadeTo:create(0.17, 255*0.55)
		local pAction2_1 = cc.Spawn:create(pScaleTo2_1,pFadeTo2_1) --第二层的第二个动画

		local pScaleTo3_1 = cc.ScaleTo:create(0.28,0.9,1.18)
		local pFadeTo3_1 = cc.FadeTo:create(0.28, 0)
		local pAction3_1 = cc.Spawn:create(pScaleTo3_1,pFadeTo3_1)  --第二层的第三个动画


		local pImg3 = MUI.MImage.new("#sg_jxfk_sa1_001.png")
		self.pLayBest:addView(pImg3)
		

		centerInView(self.pLayBest,pImg3)
		pImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg3:setScaleX(0.82)
		pImg3:setScaleY(0.96)

		local pDelay =cc.DelayTime:create(0.2)
		local pScaleTo1_2 = cc.ScaleTo:create(0,0.82,0.96)
		local pFadeTo1_2 = cc.FadeTo:create(0, 0)
		local pAction1_2 = cc.Spawn:create(pScaleTo1_2,pFadeTo1_2)  --第三层的第一个动画

		local pScaleTo2_2 = cc.ScaleTo:create(0.17,0.85,1.05)
		local pFadeTo2_2 = cc.FadeTo:create(0.17, 255*0.55)
		local pAction2_2 = cc.Spawn:create(pScaleTo2_2,pFadeTo2_2)  --第三层的第二个动画

		local pScaleTo3_2 = cc.ScaleTo:create(0.28,0.9,1.18)
		local pFadeTo3_2 = cc.FadeTo:create(0.28, 0)
		local pAction3_2 = cc.Spawn:create(pScaleTo3_2,pFadeTo3_2)  --第三层的第三个动画


		local pImg4 = MUI.MImage.new("#rwww_qmlb_w2_001.png")
		self.pLayBest:addView(pImg4)
		centerInView(self.pLayBest,pImg4)
		pImg4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg4:setScale(2)

		-- local pScaleTo1_3 = cc.ScaleTo:create(0,2)
		local pFadeTo1_3 = cc.FadeTo:create(0, 255)
		-- local pScaleTo2_2 = cc.ScaleTo:create(0.17,0.85,1.05)
		local pFadeTo2_4 = cc.FadeTo:create(0.17, 255*0.5)
		-- local pScaleTo3_2 = cc.ScaleTo:create(0.28,0.9,1.18)
		local pFadeTo3_3 = cc.FadeTo:create(0.43, 0)

		pImg2:runAction(cc.Sequence:create(pAction1_1,pAction2_1,pAction3_1))
		pImg3:runAction(cc.Sequence:create(pDelay,pAction1_2,pAction2_2,pAction3_2))
		pImg4:runAction(cc.Sequence:create(pFadeTo1_3,pFadeTo2_4,pFadeTo3_3))

		table.insert(self.tBestParitcle,pImg1)
		table.insert(self.tBestParitcle,pImg2)
		table.insert(self.tBestParitcle,pImg3)
		table.insert(self.tBestParitcle,pImg4)

	end
end

--展示获得英雄
function DlgLaba:showGetReward()
	self.bIsRolling = false
	if not self.tOb then
		return
	end

	local tTemp = {}
	for k,v in pairs(self.tOb) do
		if not tTemp[v.k] then
			tTemp[v.k] = v
		else
			tTemp[v.k].v =tTemp[v.k].v + v.v
		end
		
	end


	local tDataList = {}

	for k,v in pairs(tTemp) do
		local tReward = {}
		tReward.d = {}
		tReward.g = {}
		table.insert(tReward.d, copyTab(v))
		table.insert(tReward.g, copyTab(v))
		table.insert(tDataList,tReward)
	end

	--设置按钮数据
	local tLBtnData = {}
	tLBtnData.nBtnType = TypeCommonBtn.L_BLUE
	if self.nCurBtnIndex ~=  0 then
		tLBtnData.sBtnStr =string.format(getConvertedStr(9, 10096),self.nCurBtnIndex)
		tLBtnData.nPrice = self.tData:getPrice(self.nCurBtnIndex)
		if self.nCurBtnIndex == 1 then
			
			tLBtnData.nClickedFunc = handler(self, self.onGetOnce)
		elseif self.nCurBtnIndex == 10 then
			tLBtnData.nClickedFunc = handler(self, self.onGetTen)
		elseif self.nCurBtnIndex == 50 then
			tLBtnData.nClickedFunc = handler(self, self.onGetFifty)
		end
	end

	if self.tData:isHaveFree() then
		local nFree = self.tData:getFreeNum()
		tLBtnData.nPrice = 0
		local tConTable={}
		local tLabel = {
			{getConvertedStr(3, 10439), getC3B(_cc.white)},
			{tostring(nFree), getC3B(_cc.green)},
			{"/"..tostring(self.tData.nTfn), getC3B(_cc.white)},
		}

		tConTable.tLabel=tLabel
		tLBtnData.tConTable=tConTable
	end
	tLBtnData.bIsEnable = true


	--打开获得物品对话框对话框
    local tObject = {}
    tObject.nType = e_dlg_index.showheromansion --dlg类型
    tObject.tReward = tDataList
    tObject.tLBtnData = tLBtnData
    tObject.sBottomTip = getConvertedStr(9,10101)
    sendMsg(ghd_show_dlg_by_type,tObject)
end
function DlgLaba:removeBestParitcle()
	for i=1, #self.tBestParitcle do
		if self.tBestParitcle[i] then
			self.tBestParitcle[i]:removeSelf()
			self.tBestParitcle[i]= nil
		end
	end
	self.tBestParitcle ={}
end


return DlgLaba