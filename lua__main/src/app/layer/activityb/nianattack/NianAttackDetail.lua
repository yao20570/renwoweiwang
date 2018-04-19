----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-1-24 20:24:00
-- Description: 年兽来袭详情
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local NianAttackDetailGift = require("app.layer.activityb.nianattack.NianAttackDetailGift")
local IconGoods = require("app.common.iconview.IconGoods")

local e_hit_rate = {
	ten = 1,
	fifty = 2,
}

local NianAttackDetail = class("NianAttackDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function NianAttackDetail:ctor( _tSize )
	self.nCurrHitStyle = 0 --攻击模式
    self:setContentSize(_tSize)
	--解析文件
	parseView("lay_nian_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NianAttackDetail:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)
	addTextureToCache("tx/other/rwww_nslx_gjgx")
	-- addTextureToCache("tx/other/rwww_gcld_txtx")
	addTextureToCache("tx/other/rwww_ksdh_qsaq")
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("NianAttackDetail", handler(self, self.onNianAttackDetailDestroy))
end

-- 析构方法
function NianAttackDetail:onNianAttackDetailDestroy(  )
    self:onPause()
    removeTextureFromCache("tx/other/rwww_nslx_gjgx")	
	-- removeTextureFromCache("tx/other/rwww_gcld_txtx")
	removeTextureFromCache("tx/other/rwww_ksdh_qsaq")	
end

function NianAttackDetail:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function NianAttackDetail:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function NianAttackDetail:onResume(  )
	self:regMsgs()
	self:updateViews()
	regUpdateControl(self, handler(self, self.updateCd))
end

function NianAttackDetail:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function NianAttackDetail:setupViews(  )
	self.pTxtCd = self:findViewByName("txt_cd") --剩余时间
	self.pTxtRedPoket = self:findViewByName("txt_redpoket") --已有红包数
	self.pTxtName = self:findViewByName("txt_name")
	self.pImgGetState = self:findViewByName("img_get_state")
	self.pImgGetState:setVisible(false)
	self.pTxtHp = self:findViewByName("txt_hp")
	self.pLayNian = self:findViewByName("lay_nian")
	self.pImgNian = self:findViewByName("img_nian")

	--动画层
	local nX, nY = 295, 681
	self.pLayHurmArm = MUI.MLayer.new()
	self.pLayHurmArm:setLayoutSize(100, 100)
	self.pLayNian:addView(self.pLayHurmArm, 10)
	self.pLayHurmArm:setPosition(nX, nY)

	--数字层
	self.pLayHurmNum = MUI.MLayer.new()
	self.pLayHurmNum:setAnchorPoint(0.5, 0.5)
	self.pLayHurmNum:setLayoutSize(100, 100)
	self.pLayHurmNum:setVisible(false)
	self.pLayNian:addView(self.pLayHurmNum, 10)
	self.tLayHurmPos = cc.p(456 + 15, 762)

	--暴击文字
	self.pImgCritTxt = MUI.MImage.new("#v2_fonts_baoji_ns.png")
	self.pLayHurmNum:addView(self.pImgCritTxt)
	--暴击后面的字
	self.pTxtCritNum = MUI.MLabelAtlas.new({text="0", png="ui/atlas/v2_img_beishu_nianshou.png", pngw=22, pngh=41, scm=48})
	self.pLayHurmNum:addView(self.pTxtCritNum)
	self.pTxtCritNum:setAnchorPoint(0, 0)
	--暴击下面的字
	self.pTxtHurmNum = MUI.MLabelAtlas.new({text="0", png="ui/atlas/v2_img_shanghaishuzi_ns.png", pngw=22, pngh=41, scm=48})
	self.pLayHurmNum:addView(self.pTxtHurmNum)
	self.pTxtHurmNum:setPosition(50, 12)


	--血量
	local pLayHpBarBg = self:findViewByName("lay_hp_bar_bg")
	self.pBarHp = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/daitu.png",
		   	 	button="ui/daitu.png",
		    	barfg="#v2_bar_nianshou_a.png"
		    }, 
		    {
		    	scale9 = false, 
		    	touchInButton=false
		    })
		    :setSliderSize(341, 20)
		    :align(display.LEFT_BOTTOM)
    self.pBarHp:setViewTouched(false)
    pLayHpBarBg:addView(self.pBarHp)
    self.pBarHp:setPosition((374 - 341)/2+4, (24 - 20)/2)
    -- centerInView(pLayHpBarBg, self.pBarHp)

    --
    local pLayBtnHelp = self:findViewByName("lay_btn_help")
    pLayBtnHelp:setViewTouched(true)
	pLayBtnHelp:setIsPressedNeedScale(false)
	pLayBtnHelp:setIsPressedNeedColor(false)
	pLayBtnHelp:onMViewClicked(handler(self, self.onHelpBtnClicked))

    --攻击
    self.pImgBtnAttack = self:findViewByName("img_btn_attack")
	self.pImgBtnAttack:setViewTouched(true)
	self.pImgBtnAttack:setIsPressedNeedScale(false)
	self.pImgBtnAttack:setIsPressedNeedColor(true)
	self.pImgBtnAttack:onMViewClicked(handler(self, self.onAttackBtnClicked))

	local pLayMiddle = self:findViewByName("lay_middle")
	pLayMiddle:setViewTouched(true)
	pLayMiddle:setIsPressedNeedScale(false)
	pLayMiddle:setIsPressedNeedColor(false)
	pLayMiddle:onMViewClicked(handler(self, self.onAttackBtnClicked))

    --单选
	local pTxtCheckBox1 = self:findViewByName("txt_checkbox1")
	pTxtCheckBox1:setString(getConvertedStr(3, 10709))
	self.pTxtCheckBox1 = pTxtCheckBox1
	self.pImgCheckBox1 = self:findViewByName("img_checkbox1")
	self.pLayBtnCheckbox1 = self:findViewByName("lay_btn_checkbox1")
	self.pLayBtnCheckbox1:setViewTouched(true)
	self.pLayBtnCheckbox1:setIsPressedNeedScale(false)
	self.pLayBtnCheckbox1:setIsPressedNeedColor(false)
	self.pLayBtnCheckbox1:onMViewClicked(handler(self, self.onCheckBoxBtn1Clicked))

	local pTxtCheckBox2 = self:findViewByName("txt_checkbox2")
	pTxtCheckBox2:setString(getConvertedStr(3, 10710))
	self.pTxtCheckBox2 = pTxtCheckBox2
	self.pImgCheckBox2 = self:findViewByName("img_checkbox2")
	self.pLayBtnCheckbox2 = self:findViewByName("lay_btn_checkbox2")
	self.pLayBtnCheckbox2:setViewTouched(true)
	self.pLayBtnCheckbox2:setIsPressedNeedScale(false)
	self.pLayBtnCheckbox2:setIsPressedNeedColor(false)
	self.pLayBtnCheckbox2:onMViewClicked(handler(self, self.onCheckBoxBtn2Clicked))

	self.pTxtFree = self:findViewByName("txt_free")
	self.pTxtFree:setString(getConvertedStr(3, 10714))

	--花费
	local pLayGoldCost = self:findViewByName("lay_gold_cost")
	self.pImgLabelCost = MImgLabel.new({text="", size = 20, parent = pLayGoldCost})
	self.pImgLabelCost:setImg(getCostResImg(e_type_resdata.money), 1, "left")
	local tSize = pLayGoldCost:getContentSize()
	self.pImgLabelCost:followPos("center", tSize.width/2, tSize.height/2, 1)

	--水平翻转
	local pImgArrow = self:findViewByName("img_yellow_arrow2")
	pImgArrow:setFlippedX(true)
	local pImgLantern = self:findViewByName("img_lantern2")
	pImgLantern:setFlippedX(true)
	local pImgRedBg = self:findViewByName("img_bottom_bg2")
	pImgRedBg:setFlippedX(true)

	--我的伤害值
	self.pTxtMyHurt = self:findViewByName("txt_my_hurt")

	--伤害bar
	local pLayHurtBarBg = self:findViewByName("lay_hurt_bar_bg")
	self.pBarHurt = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/daitu.png",
		   	 	button="ui/daitu.png",
		    	barfg="#v2_bar_nianshoush_a.png"
		    }, 
		    {
		    	scale9 = false, 
		    	touchInButton=false
		    })
		    :setSliderSize(618, 25)
		    :align(display.LEFT_BOTTOM)
    self.pBarHurt:setViewTouched(false)
    pLayHurtBarBg:addView(self.pBarHurt)
    self.pBarHurt:setPosition(5, 0)
    -- centerInView(pLayHurtBarBg, self.pBarHurt)

    --伤害百分比占多度值
    self.tHurtPercent = {
    	[1] = 8,
    	[2] = 29,
    	[3] = 50,
    	[4] = 71,
    	[5] = 92,
	}
	--线位置
	local nBgX, nY = pLayHurtBarBg:getPosition()
	local nBarWidth = pLayHurtBarBg:getWidth()
	self.tHurtLinePosX = {}
	for i=1,#self.tHurtPercent do
		local nPercent = self.tHurtPercent[i]
		table.insert(self.tHurtLinePosX, nBgX + nBarWidth * (nPercent/100))
	end

    --5个礼包
    local pBottomContent = self:findViewByName("lay_content_bottom")
    self.tItemGift = {}
    self.pActData = Player:getActById(e_id_activity.nianattack)
    local pActData = self.pActData
    if pActData then
    	local tGiftList = pActData.tGiftList
    	local nGiftCount = #tGiftList
    	if nGiftCount > 0 then
	    	for i=1,nGiftCount do
	    		local nX = self.tHurtLinePosX[i]
	    		if nX then
		    		local tHARes = tGiftList[i]
		    		--伤害Bar线
			    	local pImgLine = MUI.MImage.new("#V2_line_hong_ns.png")
					pBottomContent:addView(pImgLine, 1)
					pImgLine:setPosition(nX, nY + 24/2)
					
					--伤害值
					local pTxtDegree = MUI.MLabel.new({text = tostring(tHARes.nHarm), size = 20})
					pBottomContent:addView(pTxtDegree, 1)
					pTxtDegree:setPosition(nX, nY - 20)

					--礼包
					local pGift = NianAttackDetailGift.new(self)
					pBottomContent:addView(pGift, 2)
					pGift:setPosition(nX - 96/2, nY + 40)
					table.insert(self.tItemGift, pGift)
				end
		    end
		end
	end

	-- --按钮选择图片
	-- self.pImgGiftSel = MUI.MImage.new("#v2_img_texiao_ns.png")
	-- pBottomContent:addView(self.pImgGiftSel, 2)

    --红色三角形
    self.pImgTriangle = self:findViewByName("img_triangle")

    --领奖按钮
    local pLayBtnGift = self:findViewByName("lay_btn_gift")
    self.pLayBtnGift = pLayBtnGift
    local pBtnGet = getCommonButtonOfContainer(pLayBtnGift, TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10386))
    pBtnGet:onCommonBtnClicked(handler(self, self.onGiftBtnClicked))
    pBtnGet:showLingTx()

    --层
	local pLayItems = self:findViewByName("lay_items")
	self.tGoodsList = {}
	local nX, nY, nOffsetX = 20, 10, 100
	for i=1,4 do
		local pIconView = IconGoods.new(TypeIconGoods.HADMORE)
		pIconView:setIconIsCanTouched(true)
		pIconView:setScale(0.8)
		pLayItems:addView(pIconView)
		pIconView:setPosition(nX, nY)
		nX = nX + nOffsetX
		table.insert(self.tGoodsList, pIconView)
	end

    --每一次打开的时候
	self:updateGiftSel()

	--结果
	self.pLayResult = self:findViewByName("lay_result")
	self.pLayResult:setTouchEnabled(true)
end

function NianAttackDetail:updateGiftSel(  )
	local nAwardHarm = nil
	local pActData = self.pActData
	if pActData then
		nAwardHarm = pActData:getLowAwardHarm()
	end
	if nAwardHarm then
		self:selectGiftByHarm(nAwardHarm)
	else
		if self.nCurrGiftHarm then
			self:selectGiftByHarm(self.nCurrGiftHarm)
		else
			if pActData then
				local tGiftList = pActData.tGiftList
				local tGift = tGiftList[#tGiftList]
				if tGift then
					self:selectGiftByHarm(tGift:getHarm())
				end
			end
		end
	end
end

function NianAttackDetail:updateViews(  )
	--容错
	self.pActData = Player:getActById(e_id_activity.nianattack)
	local pActData = self.pActData
	if not pActData then
		return
	end

	--时间
	self:updateCd()
	--红包数
	self:updateRedPocket(pActData:getRedPocket())
	--礼包集
	self:updateHarmGifts()
	--年兽信息
	self.pTxtName:setString(getConvertedStr(3, 10712)..getLvString(pActData.nBossLv))

	self.pBarHp:setSliderValue(pActData.nBossHp/pActData.nBossHpMax*100)
	self.pTxtHp:setString(string.format("%s/%s", pActData.nBossHp, pActData.nBossHpMax))

	self.pTxtMyHurt:setString(pActData.nMyHurt)

	local nPercent = pActData:getHarmPercent(self.tHurtPercent)
	self.pBarHurt:setSliderValue(nPercent)

	if pActData.nBossHp == 0 then
		self.pLayResult:setVisible(true)
	else
		self.pLayResult:setVisible(false)
	end

	--更新钱
	self:updateCost()

	--更新按钮数据
	self:updateGetBtn()
end

--活动剩余时间
function NianAttackDetail:updateCd(  )
	local pActData = self.pActData
	if pActData then
		local nTime = pActData:getRemainCd()
		if nTime then
			self.pTxtCd:setString(getConvertedStr(6, 10432).. getTimeLongStr(nTime,false,true))	
		end
	end
end

--更新福气红包获得数
function NianAttackDetail:updateRedPocket( nRedPocket )
	--播放红包
	if self.nRedPocket and self.nRedPocket < nRedPocket then
		showGetAllItems({{k = 100178, v = nRedPocket - self.nRedPocket}})
	end
	self.nRedPocket = nRedPocket
	--显示红包显示
	local nCount = nRedPocket
	local tStr = {
	    {color=_cc.white,text=getConvertedStr(3, 10711)},
	    {color=_cc.yellow,text=nCount},
	}
	self.pTxtRedPoket:setString(tStr)
end

--更新花费
function NianAttackDetail:updateCost(  )
	local pActData = self.pActData
	if not pActData then
		return
	end

	local nCurr = pActData.nAttackedCount
	local nFree = pActData.nFreeAttackCount
	if nCurr < nFree then
		local tStr = {
		    {color=_cc.blue,text=math.max(nFree - nCurr,0)},
		    {color=_cc.white,text="/"..nFree},
		}	
		self.pImgLabelCost:setString(tStr)
		self.pImgLabelCost:hideImg()
		self.nCurrHitStyle = 0

		self.pTxtFree:setVisible(true)
		self.pTxtCheckBox1:setVisible(false)
		self.pImgCheckBox1:setVisible(false)
		self.pLayBtnCheckbox1:setVisible(false)
		self.pTxtCheckBox2:setVisible(false)
		self.pImgCheckBox2:setVisible(false)
		self.pLayBtnCheckbox2:setVisible(false)
	else
		--从免费变成非免费
		if self.nCurrHitStyle == 0 then
			self.nCurrHitStyle = 1
		end

		self.pTxtFree:setVisible(false)
		self.pTxtCheckBox1:setVisible(true)
		self.pImgCheckBox1:setVisible(true)
		self.pLayBtnCheckbox1:setVisible(true)
		self.pTxtCheckBox2:setVisible(true)
		self.pImgCheckBox2:setVisible(true)
		self.pLayBtnCheckbox2:setVisible(true)

		local nOneCost = pActData.nCost
		local nCost = nOneCost * self.nCurrHitStyle 
		local tStr = {
		    {color=_cc.white,text= nCost},
		}
		self.pImgLabelCost:setString(tStr)
		self.pImgLabelCost:showImg()

		if self.nCurrHitStyle == 10 then
			self.pImgCheckBox1:setCurrentImage("#v2_img_gouxuan.png")
			self.pImgCheckBox2:setCurrentImage("#v2_img_gouxuankuang.png")
		elseif self.nCurrHitStyle == 50 then
			self.pImgCheckBox1:setCurrentImage("#v2_img_gouxuankuang.png")
			self.pImgCheckBox2:setCurrentImage("#v2_img_gouxuan.png")
		else
			self.pImgCheckBox1:setCurrentImage("#v2_img_gouxuankuang.png")
			self.pImgCheckBox2:setCurrentImage("#v2_img_gouxuankuang.png")
		end
	end
end

--设置是否领取按钮状态
--nState :1 可领, 2 已领 ,3 未达
function NianAttackDetail:setGetBtnState( nState )
	if nState == 1 then
		self.pLayBtnGift:setVisible(true)
		self.pImgGetState:setVisible(false)
	else
		self.pLayBtnGift:setVisible(false)
		self.pImgGetState:setVisible(true)
		if nState == 2 then
			self.pImgGetState:setCurrentImage("#v2_fonts_yilingqu.png")
		else
			self.pImgGetState:setCurrentImage("#v2_fonts_weidadao.png")
		end
	end
end

--设置当前选中的按钮
function NianAttackDetail:updateGetBtn(  )
	if not self.nCurrGiftHarm then
		return
	end
	local pActData = self.pActData
	if pActData then
		local nState = pActData:getHarmGiftState(self.nCurrGiftHarm)
		self:setGetBtnState(nState)
	end
end

--
function NianAttackDetail:selectGiftByHarm( nHarm )
	if not nHarm then
		return
	end

	for i=1,#self.tItemGift do
		self.tItemGift[i]:setSelected(false)
	end
	self.nCurrGiftHarm = nHarm
	local pActData = self.pActData
	if pActData then
		local tGift = pActData:getHarmGift()
		for i=1,#tGift do
			if tGift[i]:getHarm() == nHarm then
				if self.tItemGift[i] then
					local nX, nY = self.tItemGift[i]:getPosition()
					-- self.pImgGiftSel:setPosition(nX+96/2, nY+96/2)
					self.tItemGift[i]:setSelected(true)
					self.pImgTriangle:setPositionX(nX+96/2)
					--商品
					local tAward = tGift[i]:getAward()
					if tAward then
						for j=1,#self.tGoodsList do
							local pIconView = self.tGoodsList[j]
							local tAwardData = tAward[j]
							if tAwardData then
								local nGoodsId = tAwardData.k
								local nCt = tAwardData.v
								local tGoods = getGoodsByTidFromDB(nGoodsId)
								if tGoods then
								    pIconView:setCurData(tGoods) 
									pIconView:setMoreTextColor(getColorByQuality(tGoods.nQuality))
								end
								pIconView:setNumber(nCt)
								pIconView:setVisible(true)
							else
								pIconView:setVisible(false)
							end
						end
					end
				end
				break
			end
		end
	end
	self:updateGetBtn()
end

--更新伤害礼品集
function NianAttackDetail:updateHarmGifts(  )
	local pActData = self.pActData
    if pActData then
    	local tGiftList = pActData.tGiftList
		for i=1,#self.tItemGift do
			local tHARes = tGiftList[i]
			if tHARes then
				self.tItemGift[i]:setData(tHARes)
				self.tItemGift[i]:updateViews()
			end
		end
	end
end

--选框1
function NianAttackDetail:onCheckBoxBtn1Clicked(  )
	if self.nCurrHitStyle == 10 then
		self.nCurrHitStyle = 1
	else
		self.nCurrHitStyle = 10
	end
	self:updateCost()
end

--选框2
function NianAttackDetail:onCheckBoxBtn2Clicked(  )
	if self.nCurrHitStyle == 50 then
		self.nCurrHitStyle = 1
	else
		self.nCurrHitStyle = 50
	end
	self:updateCost()
end

--帮助按钮点击
function NianAttackDetail:onHelpBtnClicked(  )
	-- local tObject = {}
	-- tObject.nType = e_dlg_index.dlgactivitydesc
	-- tObject.nActId = e_id_activity.nianattack
	-- sendMsg(ghd_show_dlg_by_type,tObject)
	local pActData = self.pActData
	if not pActData then
		return
	end
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10726))
    pDlg:setContentLetter(pActData.sDesc)
    pDlg:setRightHandler(function ()            
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew)
end

--攻击按钮点击
function NianAttackDetail:onAttackBtnClicked(  )
	local pActData = self.pActData
	if not pActData then
		return
	end
	local nOneCost = pActData.nCost
	local nCost = nOneCost * self.nCurrHitStyle 
	if nCost == 0 then
	 	SocketManager:sendMsg("reqNianAttack", {1, 1}, handler(self, self.onGetDataFunc))
	else
		local sStr = ""
		if self.nCurrHitStyle == 10 then
			sStr = getConvertedStr(3, 10715)
		elseif self.nCurrHitStyle == 50 then
			sStr = getConvertedStr(3, 10716)
		else
			sStr = getConvertedStr(3, 10717)
		end

		--购买
		local strTips = {
		    {color=_cc.pwhite,text=sStr},--扩充招募队列
		}
		--展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
		    SocketManager:sendMsg("reqNianAttack", {self.nCurrHitStyle, 0}, handler(self, self.onGetDataFunc))
		end)
	end
end

--点击领取礼包
function NianAttackDetail:onGiftBtnClicked(  )
	if not self.nCurrGiftHarm then
		return
	end
	SocketManager:sendMsg("reqNianHurtGift", {self.nCurrGiftHarm}, handler(self, self.onGetDataFunc))
end

--数据返回
function NianAttackDetail:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqNianAttack.id then

        	if self.showAttackBossEffect then
        		self:showAttackBossEffect(__msg.body.harm, __msg.body.crit)
        	end
        elseif __msg.head.type == MsgType.reqNianHurtGift.id then
        	showGetAllItems(__msg.body.ob)
        	--更新礼包选中
        	if self.updateGiftSel then
				self:updateGiftSel()
			end
        end
    else
    	TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--播放伤害特效
--nHarm:伤害
--nCrit:暴击次数
function NianAttackDetail:showAttackBossEffect( nHarm, nCrit )
	if not nHarm or not nCrit then
		return
	end

	--年兽来袭攻击序列帧特效
	local tArmData1  = 
		{
			nFrame = 6, -- 总帧数
			pos = {62, -90}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 5,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "rwww_nslx_gjgx2_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 6, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayHurmArm, 
        1, 
        cc.p(0,0),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.normal)
    if pArm then
    	pArm:setFrameEventCallFunc(function ( _nCur )
    		if _nCur == 3 then
    			self:showNianRedEffect()
			elseif _nCur == 4 then
				self:showHurmNumEffect(nHarm, nCrit)
			end
		end)
        pArm:play(1)
    end

    --
	local tArmData2  = 
		{
			nFrame = 8, -- 总帧数
			pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 2,-- 初始的缩放值
			nBlend = 0, -- 需要加亮
		   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "rwww_nslx_gjgx_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 8, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}

	local pArm = MArmatureUtils:createMArmature(
        tArmData2, 
        self.pLayHurmArm, 
        2, 
        cc.p(0,0),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.normal)
    if pArm then
        pArm:play(1)
    end
end

--播放年兽受击闪红效果 
function NianAttackDetail:showNianRedEffect(  )
	--第一层（也就是原年兽图片，做个缩放效果）
	-- 时间     缩放值
	-- 0秒       100%
	-- 0.04秒     98%
	-- 0.13秒     100%  
	self.pImgNian:setScale(1)
	local pSeqAct = cc.Sequence:create({
		cc.ScaleTo:create(0.04, 0.98),
		cc.ScaleTo:create(0.13 - 0.04, 1),
		}
	)
	self.pImgNian:runAction(pSeqAct)


	local nZoder = self.pImgNian:getLocalZOrder()
	local nX, nY = self.pImgNian:getPosition()
	--第二层  （将原年兽图片，复制多一层）
	-- 时间    透明度    缩放值     是否加亮    
	-- 0秒       0%        100%        加亮 
	-- 0.04秒    100%      98%         加亮
	-- 0.13秒    60%       100%        加亮
	-- 0.25秒    0%        100%        加亮
	if self.pImgNianRed2 then
		self.pImgNianRed2:setVisible(true)
	else
		self.pImgNianRed2 = MUI.MImage.new("ui/rwww_nstp_mmp_001.png")
		self.pLayNian:addView(self.pImgNianRed2, nZoder + 1)
		self.pImgNianRed2:setPosition(nX, nY)
		self.pImgNianRed2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end
	self.pImgNianRed2:setScale(1)
	self.pImgNianRed2:setOpacity(0)
	local pSeqAct = cc.Sequence:create({
		cc.Spawn:create({
						cc.FadeTo:create(0.04, 255),
		    			cc.ScaleTo:create(0.04, 0.98),
		    		}),
		cc.Spawn:create({
						cc.FadeTo:create(0.13 - 0.04, 255*0.6),
		    			cc.ScaleTo:create(0.13 - 0.04, 1),
		    		}),
		cc.Spawn:create({
						cc.FadeTo:create(0.25 - 0.13, 0),
		    			cc.ScaleTo:create(0.25 - 0.13, 1),
		    		}),
		}
	)
	self.pImgNianRed2:runAction(pSeqAct)
	

	--第三层    （将原年兽图片，复制多一层，然后进行颜色改红（颜色值：#FFFF0004））
	-- 时间     透明度     缩放值   是否加亮
	-- 0秒       100%       101%      加亮
	-- 0.5秒     0%         105%       加亮

	if self.pImgNianRed3 then
		self.pImgNianRed3:setVisible(true)
	else
		self.pImgNianRed3 = MUI.MImage.new("ui/rwww_nstp_mmp_001.png")
		self.pImgNianRed3:setColor(cc.c3b(255, 0, 0))
		self.pLayNian:addView(self.pImgNianRed3, nZoder + 1)
		self.pImgNianRed3:setPosition(nX, nY)
		self.pImgNianRed2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end
	self.pImgNianRed3:setScale(1.01)
	self.pImgNianRed3:setOpacity(255)
	local pSeqAct =cc.Spawn:create({
						cc.FadeTo:create(0.5, 0),
		    			cc.ScaleTo:create(0.5, 1.05),
		    		})
	self.pImgNianRed3:runAction(pSeqAct)
end

--播放伤害数值特效
function NianAttackDetail:showHurmNumEffect( nHarm, nCrit)
	self.pLayHurmNum:setPosition(self.tLayHurmPos)
	self.pLayHurmNum:setVisible(true)	
	if nCrit > 0 then
		self.pImgCritTxt:setVisible(true)
		if nCrit > 1 then
			self.pTxtCritNum:setVisible(true)
			self.pTxtCritNum:setString(":"..nCrit)
			--位置
			local nX, nY = 50, 50
			nX = nX - self.pTxtCritNum:getContentSize().width/2
			self.pImgCritTxt:setPosition(nX, nY)
			self.pTxtCritNum:setPosition(nX + self.pImgCritTxt:getContentSize().width/2, nY - 20)
		else
			self.pTxtCritNum:setVisible(false)
			--位置
			local nX, nY = 50, 50
			self.pImgCritTxt:setPosition(nX, nY)
		end
	else
		self.pImgCritTxt:setVisible(false)
		self.pTxtCritNum:setVisible(false)
	end

	self.pTxtHurmNum:setString(":"..nHarm)
	-- 时间    透明度   缩放值     位移（Y）
	-- 0秒       100%    59%          0
	-- 0.13秒    100%    110%         0
	-- 0.21秒    100%    100%         0
	-- 0.54秒    100%    100%         0
	-- 1秒        0      100%         14
	self.pLayHurmNum:setScale(0.59)
	self.pLayHurmNum:setOpacity(1)
	local pSeqAct = cc.Sequence:create({
		cc.Spawn:create({
						cc.FadeTo:create(0.13, 255),
		    			cc.ScaleTo:create(0.13, 1.1),
		    		}),
		cc.Spawn:create({
						cc.FadeTo:create(0.21 - 0.13, 255),
		    			cc.ScaleTo:create(0.21 - 0.13, 1),
		    		}),
		cc.Spawn:create({
						cc.FadeTo:create(0.54 - 0.21, 255),
		    			cc.ScaleTo:create(0.54 - 0.21, 1),
		    		}),
		cc.Spawn:create({
						cc.FadeTo:create(1 - 0.54, 0),
		    			cc.MoveBy:create(1 - 0.54, cc.p(0, 14)),
		    		}),
		}
	)
	self.pLayHurmNum:runAction(pSeqAct)
end

return NianAttackDetail



