----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-01-22 14:18:52
-- Description: 寻访美人
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgSearchBeauty = class("DlgSearchBeauty", function()
	return DlgBase.new(e_dlg_index.searchbeauty)
end)

NEED_RECOMMON = 5

function DlgSearchBeauty:ctor(  )

	self:myInit()

	parseView("dlg_search_beauty", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function DlgSearchBeauty:onParseViewCallback( pView )
	self.pView = pView
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSearchBeauty",handler(self, self.onDestroy))
end

--初始化控件
function DlgSearchBeauty:setupViews()
	--banner
	-- self.pLayBannerBg 	= self.pView:findViewByName("lay_banner_bg")
	-- setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_xfmr)

	self.pLayTop 		= self.pView:findViewByName("lay_top")	--top层

	self.pTxtDesc 		= self.pView:findViewByName("txt_desc")	--说明

	self.pLayImgYL 		= self.pView:findViewByName("lay_img_yl") --图标按钮
	local pImgYl = MUI.MImage.new("#v1_img_wangquanzhengshou.png")
	pImgYl:setViewTouched(true)
	pImgYl:setIsPressedNeedColor(false)
	pImgYl:onMViewClicked(handler(self, self.onYlClicked))
	pImgYl:setAnchorPoint(cc.p(0.5,0.5))
	pImgYl:setPosition(self.pLayImgYL:getContentSize().width/2, self.pLayImgYL:getContentSize().height/2)
	self.pLayImgYL:addView(pImgYl,2)

	self.pYlBtn	 = self.pView:findViewByName("lay_yl_btn") --预览按钮
	self.pYlBtn:setBackgroundImage("#v2_img_jiangliyulan.png") --getCommonButtonOfContainer(self.pYLBtn ,TypeCommonBtn.M_YELLOW, getConvertedStr(9, 10090))
	self.pYlBtn:setViewTouched(true)
	self.pYlBtn:setPositionY(self.pYlBtn:getPositionY() + 5)
	self.pYlBtn:onMViewClicked(handler(self, self.onYlClicked))
	local pYLLabel = MUI.MLabel.new({text = getConvertedStr(9, 10090), size = 20})
	pYLLabel:setAnchorPoint(cc.p(0.5, 0.5))
	local size = self.pYlBtn:getContentSize()
	pYLLabel:setPosition(cc.p(size.width/2, size.height/2+4))
	self.pYlBtn:addView(pYLLabel)


	self.pLbDes 		= self.pView:findViewByName("lb_des")
	setTextCCColor(self.pLbDes,"898fa9")

	self.pLayContent 	= self.pView:findViewByName("lay_content")
	self.pLyHeroInfo 	= self.pView:findViewByName("ly_hero_info") --英雄显示层
	self.pLyShowHero 	= self.pView:findViewByName("ly_show_hero") --英雄显示
	
	self.pLyDown 		= self.pView:findViewByName("ly_down") --英雄信息显示层

	self.pLbHeroTips1			= 		self.pView:findViewByName("lb_hero_tips_1")
	self.pLbHeroTips1:setString(getConvertedStr(5,10020))
	-- self.pLbHeroTips2			= 		self.pView:findViewByName("lb_hero_tips_2")
	-- self.pLbHeroTips2:setString(getConvertedStr(1,10331))
	self.pLbHeroTalent			= 		self.pView:findViewByName("lb_hero_talent")   	 --资质1
	setTextCCColor(self.pLbHeroTalent,_cc.white)
	self.pLbHeroTalentAdd		= 		self.pView:findViewByName("lb_hero_talent_add")  --资质2
	setTextCCColor(self.pLbHeroTalentAdd,_cc.green)
	
	-- self.pLbHeroQuality			=	    self.pView:findViewByName("lb_hero_quality")  --品质


	-- self.pImgKuang1				=		self.pView:findViewByName("img_kuang1")--框下边
	-- self.pImgKuang1:setFlippedX(true)
	-- self.pImgKuang1:setFlippedY(true)
	-- self.pImgKuang2				=		self.pView:findViewByName("img_kuang2")--框上边

	
	self.pLyAttrBtn 			=		self.pView:findViewByName("ly_attr_btn")--属性跳转按钮
	self.pLyAttrBtn:setViewTouched(true)
	self.pLyAttrBtn:onMViewClicked(handler(self,self.onInfoClick))


	if not self.tLetterList then
		self.tLetterList = {}
		for i=1, 5 do
			local pLetter = self.pView:findViewByName("ly_letter_"..i)--属性跳转按钮
			pLetter:setViewTouched(true)
			pLetter:setIsPressedNeedScale(false)
			pLetter:onMViewClicked(function(_pView)
					local good = getGoodsByTidFromDB(100177)
					openIconInfoDlg(_pView, good)
				end)
			if pLetter then
				table.insert(self.tLetterList, pLetter)
			end
		end
	end

	-- self.pLyBar = self.pView:findViewByName("ly_bar")
	-- self.pBarLv = MCommonProgressBar.new({bar = "v1_bar_blue_5.png",barWidth = 396, barHeight = 16})
	-- self.pLyBar:addView(self.pBarLv,100)
	-- centerInView(self.pLyBar,self.pBarLv)
		
	
	
	self.pLyBtnL = self.pView:findViewByName("ly_btn_l")
	self.pBtnL = getCommonButtonOfContainer(self.pLyBtnL,TypeCommonBtn.M_YELLOW)
	self.pBtnL:onCommonBtnClicked(handler(self, self.onLeftClicked))
	local tConTable = {}
	local tLabel = {
	 {"0",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.fontSize = 25
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pBtnL:setBtnExText(tConTable) 
	self.pBtnL:setButtonImage("#v2_btn_xunfang1ci.png")


	self.pLyBtnR = self.pView:findViewByName("ly_btn_r")
	self.pBtnR = getCommonButtonOfContainer(self.pLyBtnR,TypeCommonBtn.M_YELLOW)
	self.pBtnR:onCommonBtnClicked(handler(self, self.onRightClicked))
	local tConTable = {}
	local tLabel = {
	 {"0",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.fontSize = 25
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pBtnR:setBtnExText(tConTable,1.5)
	self.pBtnR:setButtonImage("#v2_btn_xunfang10ci.png")


	self.pLbTenTips = self.pView:findViewByName("lb_ten_tips")
	self.pLbTenTips:setString(getConvertedStr(1,10342))
	setTextCCColor(self.pLbTenTips, "898fa9")
end

function DlgSearchBeauty:myInit()
end


function DlgSearchBeauty:onInfoClick()
	local tData = Player:getActById(e_id_activity.searchbeauty)
	if tData then
		local tHeroData = getHeroDataById(tData.nHeroId)
		if tHeroData then
			local tObject = {}
			tObject.nType = e_dlg_index.heroinfo --dlg类型
			tObject.tData = tHeroData
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
	end
end

--更新低部按钮
function DlgSearchBeauty:updateBottomBtns( )
	local tData = Player:getActById(e_id_activity.searchbeauty)
	if tData then
		--右边按钮变成转10次
		self.pBtnR:setExTextLbCnCr(1, tData:getBuyTenPrice())
		self.pBtnR:setExTextVisiable(true)
		--免费还是显示一次
		local nFreeNum = tData:getFreeTurn()
		if nFreeNum > 0 then
			--左边按钮变成免费
			self.pBtnL:onCommonBtnClicked(handler(self, self.onFreeClicked))
			self.pBtnL:setExTextVisiable(false)
			self.pBtnL:setBtnEnable(true)
		else
			--左边按钮变成转1次
			self.pBtnL:onCommonBtnClicked(handler(self, self.onLeftClicked))
			self.pBtnL:setExTextVisiable(true)
			self.pBtnL:setExTextLbCnCr(1, tData:getBuyPrice())
			self.pBtnL:setBtnEnable(true)
		end
	end
end

--奖励预览
function DlgSearchBeauty:onYlClicked()
	local tData = Player:getActById(e_id_activity.searchbeauty)
	if not tData then
		return
	end
	local nHave = tData:getCurLetter()
	local dorpId = 51764
	if nHave >= NEED_RECOMMON then
		dorpId = 51765
	end
	local tDropList = getDropById(dorpId)

	if not tDropList then
		return
	end

	local tItemKVList = {}
	for i=1,#tDropList do
		table.insert(tItemKVList, {k = tDropList[i].sTid, v = tDropList[i].nCt})
	end

	local tObject = {}
	tObject.nType = e_dlg_index.beautygift --dlg类型
	tObject.tData = tItemKVList
	sendMsg(ghd_show_dlg_by_type,tObject)
end

function DlgSearchBeauty:onFreeClicked()

end

function DlgSearchBeauty:updateLetterStatus()
	local tData = Player:getActById(e_id_activity.searchbeauty)
	if not tData then
		return
	end

	--已有几封推荐信
	local nHave = tData:getCurLetter()
	local nNeed  = tData:getNeedLetter()
	local sStr 	= ""
	--没集齐
	if nHave < nNeed then
		local sStr_1 = "<font color='#ffffff'>"..getConvertedStr(1, 10347).."</font>"
		local sStr_2 = "<font color='#ffffff'>"..getConvertedStr(1, 10348).."</font>"
		local sStr_3 = "<font color='#ffffff'>"..tostring(nHave).."</font>"
		sStr = string.format(getConvertedStr(1,10346),sStr_1,sStr_2,sStr_3)
	else
		--已经招募
		if tData:getIsGet() then
			local sStr_1 = "<font color='#f5d93d'>"..getConvertedStr(1, 10354).."</font>"
			local sStr_2 = "<font color='#bc46ff'>"..getConvertedStr(1, 10353).."</font>"
			sStr = sStr_1 .. sStr_2
		else
			local sStr_1 = "<font color='#f5d93d'>"..getConvertedStr(1, 10349).."</font>"
			local sStr_2 = "<font color='#bc46ff'>"..getConvertedStr(1, 10348).."</font>"
			sStr = sStr_1 .. sStr_2
		end
	end
	self.pLbDes:setString(sStr)
	
	if self.tLetterList then
		for i=1, #self.tLetterList do
			if i <= nHave then
				self.tLetterList[i]:setCurrentImage("#v2_bar_dianliangtuijian.png")
			else
				self.tLetterList[i]:setCurrentImage("#v2_bar_meidianliangtuijian.png")
			end
		end
	end


	if sDesc then
		local sStr_1 = "<font color='#31d840'>"..getConvertedStr(1, 10280).."</font>"
		local sStr_2 = "<font color='#77d4fd'>"..sDesc.."</font>"
		local sStr_3 = "<font color='#"..sQColor.."'>"..sQuality.."</font>"

		self.pLbAdvanceTips:setString(string.format(getConvertedStr(1,10286),sStr_1,sStr_2,sStr_3))
	end

end

--寻访一次
function DlgSearchBeauty:onLeftClicked()
	--购买
	local nCost = 0
	local tData = Player:getActById(e_id_activity.searchbeauty)
	if tData then
		nCost = tData:getBuyPrice()
	end
	local strTips = {
	    {color=_cc.pwhite,text=getConvertedStr(1, 10343)},
	    {color=_cc.blue,text=string.format(getConvertedStr(1, 10344), tostring(1))},
	}
	--临时数据
	local nHave = 0 
	if tData then
		nHave = tData:getCurLetter()
	end
	--展示购买对话框
	showBuyDlg(strTips,nCost,function (  )			
		--发送请求
		SocketManager:sendMsg("searchBeautyOne", {}, function ( __msg, __oldMsg)
 			-- dump(__msg)
 			if __msg and  __msg.head.state == SocketErrorType.success then
 				closeDlgByType(e_dlg_index.showheromansion, false)
 				if __msg and __msg.body and __msg.body.o then
 					self:showGetHero(__msg.body.o, 1, nHave)
 				end
 			end
		end)
	end)
end

--寻访十次
function DlgSearchBeauty:onRightClicked()
	--购买
	local nCost = 0
	local tData = Player:getActById(e_id_activity.searchbeauty)
	if tData then
		nCost = tData:getBuyTenPrice()
	end
	local strTips = {
	    {color=_cc.pwhite,text=getConvertedStr(1, 10343)},
	    {color=_cc.blue,text= string.format(getConvertedStr(1, 10344), tostring(10))},
	}
	--临时数据
	local nHave = 0 
	if tData then
		nHave = tData:getCurLetter()
	end
	--展示购买对话框
	showBuyDlg(strTips,nCost,function ( )
	   	--发送请求
		SocketManager:sendMsg("searchBeautyTen", {}, function ( __msg, __oldMsg) 
			--dump(__msg)
 			if __msg and  __msg.head.state == SocketErrorType.success then
 				closeDlgByType(e_dlg_index.showheromansion, false)
 				if __msg and __msg.body and __msg.body.o then
 					-- dump(__msg.body.o)
 					local list = self:sortRewards(__msg.body.o)
 					self:showGetHero(list, 10, nHave)
 				end
 			end
		end)
	end)
end

function DlgSearchBeauty:sortRewards(_list)
	if not _list then
	   return {}
	end
	for i=1, #_list do
		--是否有英雄
		if bJudgeHeroData(_list[i]) then
			local heroData = copyTab(_list[i])
			table.remove(_list, i)
			local bHave = false
			for j=#_list, 1, -1 do
				--找到最后一个推荐信
				if bJudgeRecommend(_list[j]) then
					table.insert(_list, j+1, heroData)
					bHave = true
					break
				end
			end
			if not bHave then
				table.insert(_list, i, heroData)
			end
			break
		end
	end
	return _list
end

--展示获得英雄
function DlgSearchBeauty:showGetHero(_data, _type, _nHave)
	local tData = Player:getActById(e_id_activity.searchbeauty)

	if not _data or not tData then
		return
	end

	if type(_data) ~= "table" then
		return
	end

	local tDataList = {}
	for k,v in pairs(_data) do
		local tReward = {}
		tReward.d = {}
		tReward.g = {}
		table.insert(tReward.d, copyTab(v))
		table.insert(tReward.g, copyTab(v))
		table.insert(tDataList,tReward)
	end

	--左边按钮数据
	local tLBtnData = {}
	if not _type or _type == 1 then
		tLBtnData.nBtnType = TypeCommonBtn.L_YELLOW
		tLBtnData.nPrice = tData:getBuyPrice()
		tLBtnData.nClickedFunc = handler(self, self.onLeftClicked)
		tLBtnData.sBtnStr = string.format(getConvertedStr(1, 10345), _type)
	elseif _type == 10 then
		tLBtnData.nBtnType = TypeCommonBtn.L_YELLOW
		tLBtnData.nPrice = tData:getBuyTenPrice()
		tLBtnData.nClickedFunc = handler(self, self.onRightClicked)
		tLBtnData.sBtnStr = string.format(getConvertedStr(1, 10345), _type)
	end
	tLBtnData.bIsEnable = true
 
	--打开招募展示英雄对话框
    local tObject = {}
    tObject.nType = e_dlg_index.showheromansion --dlg类型
    tObject.tReward = tDataList
    tObject.tLBtnData = tLBtnData
  	tObject.nRecommonNum = _nHave
  	tObject.bShowContinue = true
    sendMsg(ghd_show_dlg_by_type,tObject)
end

--控件刷新
function DlgSearchBeauty:updateViews()
	local tData = Player:getActById( e_id_activity.searchbeauty )
	if not tData then
		self:closeDlg(false)
		return
	end
	if tData then
		--设置标题
		self:setTitle(tData.sName)

		--活动时间
		if not self.pActTime then
			self.pActTime = createActTime(self.pLayTop, tData, cc.p(0,150))
			if self.pActTime.pLyMain then
				self.pActTime.pLyMain:setBackgroundImage("#daitu.png")
			end
		else
			self.pActTime:setCurData(tData)
		end

		--描述
		self.pTxtDesc:setString(tData.sDesc)

	end

	--显示资质
	local tHeroData = getHeroDataById(tData:getHeroId())
	if tHeroData and tHeroData.getBaseTotalTalent then
		self.pLbHeroTalent:setString(tHeroData:getBaseTotalTalent())
	end
	if tHeroData and tHeroData.getExTotalTalent then
		local x = self.pLbHeroTalent:getPositionX()
		self.pLbHeroTalentAdd:setPositionX(x + self.pLbHeroTalent:getContentSize().width+5)
		self.pLbHeroTalentAdd:setString("+"..tHeroData:getExTotalTalent())
	end

	-- if tHeroData and tHeroData.nQuality then
	-- 	local path = getHeroKuangByQuality(tHeroData.nQuality)
	-- 	self.pImgKuang1:setCurrentImage(path)
	-- 	self.pImgKuang2:setCurrentImage(path)

	-- 	self.pLbHeroQuality:setString(getHeroTextByQuality(tHeroData.nQuality))

	-- 	setTextCCColor(self.pLbHeroQuality, getColorByQuality(tHeroData.nQuality))
	-- end

	-- if tHeroData.sImg then
	-- 	if not self.pHeroImg then

	-- 	    self.pHeroImg = creatHeroView(tHeroData.sImg)
	-- 	    self.pHeroImg:setPosition(0, 0)
	-- 		self.pLyShowHero:addView( self.pHeroImg, 0)
 
	-- 		-- local pParitcle =  createParitcle("tx/other/lizi_wujzsxg_0001.plist")--删除
	-- 		-- pParitcle:setPosition(self.pLyShowHero:getWidth()/2, self.pLyShowHero:getHeight()/2)
	-- 		-- self.pLyShowHero:addView(pParitcle,99)

	-- 	else
	-- 		self.pHeroImg:updateHeroView(tHeroData.sImg)
 
	-- 	end 
	-- 	--todo
	-- end

    --更新按钮
	self:updateBottomBtns()
	self:updateLetterStatus()
end


--更新横条
function DlgSearchBeauty:updateBar()
 
end

function DlgSearchBeauty:onGetClicked()
	SocketManager:sendMsg("getBeauty", {10, 1}, function ( __msg, __oldMsg) --time	int	传1次或10次 type	int	0免费 1花费
			-- dump(__msg)
	end)
end

--析构方法
function DlgSearchBeauty:onDestroy(  )
	-- body
	self:onPause()
end



--注册消息
function DlgSearchBeauty:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end
--注销消息
function DlgSearchBeauty:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgSearchBeauty:onPause( )
	-- removeTextureFromCache("tx/other/sg_tx_jmtx_smjsj")
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgSearchBeauty:onResume( _bReshow )
	-- addTextureToCache("ui/other/sg_tx_jmtx_smjsj")
	self:updateViews()
	self:regMsgs()
end

--前往充值界面
function DlgSearchBeauty:onRechargeClicked( pView )
	local tObject = {}
	tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)   
end


return DlgSearchBeauty