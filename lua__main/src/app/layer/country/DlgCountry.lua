-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-06-5 15:10:23 星期一
-- Description: 国家界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
-- local ItemCountryEntry = require("app.layer.country.ItemCountryEntry")
-- local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
-- local DecreeLayer = require("app.layer.country.DecreeLayer")
-- local KingLayer = require("app.layer.country.KingLayer")
local ItemCountryPro = require("app.layer.country.ItemCountryPro")
local DlgCountry = class("DlgCountry", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgcountry)
end)

function DlgCountry:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_country", handler(self, self.onParseViewCallback))
end

function DlgCountry:myInit(  )
	-- body
	self.pLbTipGroup = nil
	self.tOfficial = {}
	self.tItemPros = {}
end

--解析布局回调事件
function DlgCountry:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(10)

	--设置标题
	self:setTitle(getCountryName(Player:getPlayerInfo().nInfluence))
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgCountry",handler(self, self.onDestroy))
end

function DlgCountry:setupViews(  )
	-- body
	self.pLayRoot = self:findViewByName("lay_cont")
	self.pLayMain = self:findViewByName("lay_main")
	--官员
	for i = 1, 3 do
		if not self.tOfficial[i] then
			local pLayIcon = self:findViewByName("lay_icon_"..i)
			local pLbName = self:findViewByName("lb_official_"..i)
			local pIcon = getIconGoodsByType(pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.item, nil, TypeIconHeroSize.M)
			self.tOfficial[i] = {pIcon=pIcon, pLbName=pLbName}
		end
	end
	--圣旨
	self.pLayShengzhi = self:findViewByName("lay_shengzhi")
	self.pLbCont = self:findViewByName("lb_cont")
	setTextCCColor(self.pLbCont,_cc.cred)

	self.pLbKingName = self:findViewByName("lb_kingname")
	self.pLbTime = self:findViewByName("lb_time")
	self.pLbTip = self:findViewByName("lb_tip")

	setTextCCColor(self.pLbKingName,_cc.cblack)
	setTextCCColor(self.pLbTime,_cc.cblack)
	setTextCCColor(self.pLbTip,_cc.cblack)
	self.pLbTip:setString(getConvertedStr(9,10232))
	self.pLbTip:setVisible(false)

	--官员
	self.pLayOfficial = self:findViewByName("lay_par_1")
	self.pLayOfficialRed = self:findViewByName("lay_official_red")
	self.pLayRiZhi = self:findViewByName("lay_par_2")

	--圣旨部分初始化
	local sStrDef = getTextColorByConfigure(getTipsByIndex(10014))
	self.pLbDef = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
    		valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = getC3B(_cc.cblack),--cc.c3b(255, 255, 255),
		    dimensions = cc.size(350, 0),
		    })	
	self.pLbDef:setString(sStrDef, false)
	self.pLbDef:setPosition(self.pLayShengzhi:getWidth()/2, self.pLayShengzhi:getHeight()/2)
	self.pLayShengzhi:addView(self.pLbDef, 10)

	self.pLayShengzhi:setViewTouched(false)
	self.pLayShengzhi:onMViewClicked(handler(self, self.onEditShengZhi))

	--官员日志初始化
	self.pLayOfficial:setViewTouched(true)
	self.pLayOfficial:onMViewClicked(handler(self, self.onEnterOfficial))
	if b_open_ios_shenpi then
		self.pLayOfficial:setVisible(false)
	end

	self.pLayRiZhi:setViewTouched(true)
	self.pLayRiZhi:onMViewClicked(handler(self, self.onEnterCountryLog))	

	local nX = 19 --347
	local nY = self.pLayMain:getHeight() - 10
	local nRow = 0
	for i = 1, 8 do
		local bIsLarge = false
		if i % 2 == 1 then
			nX = 17
			if i % 4 == 1 then
				bIsLarge = true
			else
				bIsLarge = false
			end
		else
			if i % 4 == 2 then   --短的
				nX = 381
				bIsLarge = false

			else
				nX = 271
				bIsLarge = true
			end
		end
		nRow = math.ceil(i/2)
		if not self.tItemPros[i] then
			local pItem = ItemCountryPro.new(i,bIsLarge)
			pItem:setPosition(nX, nY - nRow*(pItem:getHeight() + 10))
			self.pLayMain:addView(pItem, 10)
		end		
	end	
end
--编辑圣旨跳转
function DlgCountry:onEditShengZhi(  )
	-- body
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	local ntimes = tonumber(getCountryParam("maxModifyNoticeTimes"))
	local nleft = ntimes - tCountryDatavo.nAfficheCnt
	if nleft > 0 then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgsenddecree --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)	
	else
		TOAST(getConvertedStr(6, 10467))
	end		
end
--国家官员
function DlgCountry:onEnterOfficial(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgcountryofficials --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

function DlgCountry:onEnterCountryLog(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgcountrylog --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

--控件刷新
function DlgCountry:updateViews(  )
	-- body		
	--官员刷新
	local tposter = Player:getCountryData():getPoliticiansPoster()
	for i = 1, 3 do
		local pIcon = self.tOfficial[i].pIcon
		local pLbName = self.tOfficial[i].pLbName
		if tposter[i] then
			pIcon:setCurData(tposter[i])
			pLbName:setString(tposter[i].sName, false)
			setTextCCColor(pLbName,_cc.white)
			-- pLbName:setVisible(true)
		else
			pIcon:setCurData({nQuality = 1})
			pLbName:setString(getConvertedStr(9,10233), false)
			setTextCCColor(pLbName,_cc.pwhite)

			local sImg = "#v1_img_youxiangjianying03.png"
			if i == 1 then
				sImg = "#v1_img_youxiangjianying03.png"
			elseif i == 2 then
				sImg = "#v1_img_youxiangjianying.png"
			elseif i == 3 then
				sImg = "#v1_img_youxiangjianying02.png"
			end
			-- pIcon:setIconBg("#v1_img_touxiangkuanghui.png")
			pIcon:setIconImg(sImg,6)
			pIcon:setIsShowNumber(false)

			-- pLbName:setVisible(false)
		end
	end

	--国家圣旨数据刷新
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	if tCountryDatavo:isHaveKing() == true then
		local sStr =getCountryShortName(Player:getPlayerInfo().nInfluence) .. getConvertedStr(9, 10243)..tCountryDatavo.tKingVo.sKName

		self.pLbKingName:setString(sStr, false)
		self.pLbTime:setString(formatTimeYMD(tCountryDatavo.nAfficheTime), false)
		self.pLbTime:setVisible(true)	

		self.pLbKingName:setPositionX(self.pLbTime:getPositionX() - self.pLbTime:getWidth() - 10)
		
		self.pLbDef:setVisible(false)	
		--圣旨更新
		self.pLbCont:setVisible(true)
		local sSubStr, sSubStr2 = SubUTF8String(tCountryDatavo.sAffiche, 232)

		self.pLbCont:setString(sSubStr, false)		
	else		
		self.pLbKingName:setString(getConvertedStr(3, 10139), false)
		self.pLbTime:setVisible(false)		
		self.pLbDef:setVisible(true)
		self.pLbCont:setVisible(false)
	end
	if tCountryDatavo:isKing() == true then--当前玩家是国王		
		self.pLayShengzhi:setViewTouched(true)
		self.pLbTip:setVisible(true)
	else
		self.pLayShengzhi:setViewTouched(false)		
		self.pLbTip:setVisible(false)
	end


	--红点刷新
	self:updateRedTips()

	-- gRefreshViewsAsync(self, 4, function ( _bEnd, _index )
	-- 	-- body
	-- 	if _index == 1 then
	-- 		local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	-- 		if not tCountryDatavo then
	-- 			return
	-- 		end
	-- 		if not self.pLbTipGroup then
	-- 			self.pLbTipGroup = {}
	-- 			for i = 1, 9 do		
	-- 				local plabel = self:findViewByName("lb_tip_"..i)			
	-- 				self.pLbTipGroup[i] = plabel
	-- 			end	
	-- 		end
	-- 		local str1 = {}	
	-- 		if tCountryDatavo:isHaveKing() == true then
	-- 			str1 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10304)},
	-- 				{color=_cc.blue,text = (tCountryDatavo.tKingVo.sKName or "")},
	-- 				{color=_cc.blue,text = getLvString(tCountryDatavo.tKingVo.nKLv, false)},
	-- 			}
	-- 		else
	-- 			str1 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10304)},
	-- 				{color=_cc.pwhite,text = getConvertedStr(3, 10139)},
	-- 			}
	-- 		end
	-- 		self.pLbTipGroup[1]:setString(str1, false)--国王

	-- 		local str2 = {
	-- 			{color=_cc.pwhite,text = getConvertedStr(6, 10305)},
	-- 			{color=_cc.pwhite,text = getLvString(tCountryDatavo.nCLv, false)},
	-- 		}
	-- 		self.pLbTipGroup[2]:setString(str2, false)--国家等级
	-- 		if not self.tcountrydevelop then
	-- 			self.tcountrydevelop = getCountryDevelop()
	-- 		end
	-- 		local str3 = {
	-- 			{color=_cc.pwhite,text = getConvertedStr(6, 10306)},
	-- 			{color=_cc.blue,text = tCountryDatavo.nExploit},	
	-- 			{color=_cc.pwhite,text = "/"..table.nums(self.tcountrydevelop)},	
	-- 		}		
	-- 		self.pLbTipGroup[3]:setString(str3, false)--国家开发

	-- 		if not self.tCountryExp then
	-- 			self.tCountryExp = getCountryExpFromDB()
	-- 		end
	-- 		local str4 = {
	-- 			{color=_cc.pwhite,text = getConvertedStr(6, 10307)},
	-- 			{color=_cc.green,text = tCountryDatavo.nCExp},	
	-- 			{color=_cc.pwhite,text = "/"..self.tCountryExp[tCountryDatavo.nCLv].exp},	
	-- 		}
	-- 		self.pLbTipGroup[4]:setString(str4, false)--国家经验	

	-- 		local tofficial = getNationTransport(tCountryDatavo.nOfficial)
	-- 		local str5 = nil
	-- 		if tofficial then
	-- 			str5 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10308)},
	-- 				{color=_cc.purple,text = tofficial.name},	
	-- 			}
	-- 		else
	-- 			str5 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10308)},
	-- 				{color=_cc.pwhite,text = getConvertedStr(3, 10139)},	
	-- 			}
	-- 		end
	-- 		self.pLbTipGroup[5]:setString(str5, false)--玩家官职

	-- 		if not self.tbanneret  then
	-- 			self.tbanneret = getCountryBanneret()				
	-- 		end
	-- 		local str6 = nil
	-- 		if self.tbanneret[tCountryDatavo.nNobility] then
	-- 			local data = self.tbanneret[tCountryDatavo.nNobility]
	-- 			str6 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10309)},
	-- 				{color=_cc.yellow,text = data.name},	
	-- 			}		
	-- 		else
	-- 			str6 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10309)},
	-- 				{color=_cc.pwhite,text = getConvertedStr(3, 10139)},	
	-- 			}
	-- 		end
	-- 		self.pLbTipGroup[6]:setString(str6, false)--玩家爵位

	-- 		local str7 = nil
	-- 		local nPrestige = Player:getPlayerInfo().nPrestige
	-- 		if nPrestige > 0 then			
	-- 			str7 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(7, 10258)},
	-- 				{color=_cc.yellow,text = formatCountToStr(nPrestige)},	
	-- 			}		
	-- 		else
	-- 			str7 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(7, 10258)},
	-- 				{color=_cc.pwhite,text = getConvertedStr(3, 10139)},	
	-- 			}
	-- 		end
	-- 		self.pLbTipGroup[7]:setString(str7, false)--玩家战功

	-- 		local str8 = nil
	-- 		if tCountryDatavo.nRank > 0 then			
	-- 			str8 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10310)},
	-- 				{color=_cc.yellow,text = tCountryDatavo.nRank},	
	-- 			}		
	-- 		else
	-- 			str8 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10310)},
	-- 				{color=_cc.pwhite,text = getConvertedStr(3, 10139)},	
	-- 			}
	-- 		end
	-- 		self.pLbTipGroup[8]:setString(str8, false)--玩家爵位排名

	-- 		local str9 = nil
	-- 		if self.tbanneret[tCountryDatavo.nNobility] then	
	-- 			local data = self.tbanneret[tCountryDatavo.nNobility]	
	-- 			--加成
	-- 			local attr = luaSplit(data.attr, ":")
	-- 			local tattr = getBaseAttData(tonumber(attr[1]))
	-- 			local nvalue = attr[2]
	-- 			str9 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10311)},
	-- 				{color=_cc.pwhite,text = tattr.sName},
	-- 				{color=_cc.green,text = "+"..nvalue},	
	-- 			}		
	-- 		else
	-- 			str9 = {
	-- 				{color=_cc.pwhite,text = getConvertedStr(6, 10311)},
	-- 				{color=_cc.pwhite,text = getConvertedStr(3, 10139)},	
	-- 			}
	-- 		end
	-- 		self.pLbTipGroup[9]:setString(str9, false)--爵位加成
	
	-- 	elseif _index == 2 then
	-- 		--国家旗帜
	-- 		if not self.pImgQiZhi then
	-- 			self.pImgQiZhi = self:findViewByName("img_qizhi")
	-- 		end			
	-- 		self.pImgQiZhi:setCurrentImage(getBigCountryFlagImg3(Player:getPlayerInfo().nInfluence))

	-- 		--国家开发按钮
	-- 		if not self.pBtnCountry then
	-- 			local pLayBtnCountry = self:findViewByName("lay_btn_country")
	-- 			self.pBtnCountry = getCommonButtonOfContainer(pLayBtnCountry, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10213))
	-- 			self.pBtnCountry:onCommonBtnClicked(handler(self, self.onCountryBtnClicked))
	-- 		end
	-- 		--爵位晋升按钮		
	-- 		if not self.pBtnJueWei then
	-- 			local pLayBtnJueWei = self:findViewByName("lay_juewei")
	-- 			self.pBtnJueWei = getCommonButtonOfContainer(pLayBtnJueWei, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10303))
	-- 			self.pBtnJueWei:onCommonBtnClicked(handler(self, self.onJueWeiBtnClicked))
	-- 		end
	-- 		--国家名将
	-- 		if not self.pMingJiangEntry then
	-- 			self.pLayMingjiang = self:findViewByName("lay_mingjiang") 
	-- 			self.pMingJiangEntry = ItemCountryEntry.new()
	-- 			self.pMingJiangEntry:setImg("#v1_img_guojiamingjiang.png")
	-- 			self.pLayMingjiang:addView(self.pMingJiangEntry, 10)
	-- 			self.pMingJiangEntry:setTitle(getConvertedStr(6, 10320))
	-- 			centerInView(self.pLayMingjiang, self.pMingJiangEntry)
	-- 			self.pMingJiangEntry:setViewTouched(true)	
	-- 			self.pMingJiangEntry:onMViewClicked(function ( pview )
	-- 				-- body
	-- 				-- local tObject = {}
	-- 				-- tObject.nType = e_dlg_index.dlgchoicecountry --dlg类型
	-- 				-- sendMsg(ghd_show_dlg_by_type,tObject)
	-- 			end)
	-- 		end
	-- 		self.pMingJiangEntry:setVisible(false)

	-- 		--国家官员
	-- 		if not  self.pGuanYuanEntry then
	-- 			self.pLayGuanYuan = self:findViewByName("lay_guanyuan")
	-- 			self.pGuanYuanEntry = ItemCountryEntry.new()
	-- 			self.pGuanYuanEntry:setImg("#v1_img_guojiaguanyuan.png")
	-- 			self.pLayGuanYuan:addView(self.pGuanYuanEntry, 10)	
	-- 			centerInView(self.pLayGuanYuan, self.pGuanYuanEntry)
	-- 			self.pGuanYuanEntry:setTitle(getConvertedStr(6, 10321))
	-- 			self.pGuanYuanEntry:setViewTouched(true)
	-- 			self.pGuanYuanEntry:onMViewClicked(function ( pview )
	-- 				-- body
	-- 				local tObject = {}
	-- 				tObject.nType = e_dlg_index.dlgcountryofficials --dlg类型
	-- 				sendMsg(ghd_show_dlg_by_type,tObject)
	-- 			end)
	-- 			if b_open_ios_shenpi then
	-- 				self.pGuanYuanEntry:setVisible(false)
	-- 			end
	-- 		end
	-- 		--国家荣誉
	-- 		if not self.pRongyuEntry then
	-- 			self.pLayRongYu = self:findViewByName("lay_rongyu")
	-- 			self.pRongyuEntry = ItemCountryEntry.new()
	-- 			self.pRongyuEntry:setImg("#v1_img_guojiarongyu.png")
	-- 			self.pLayRongYu:addView(self.pRongyuEntry,10)
	-- 			centerInView(self.pLayRongYu, self.pRongyuEntry)
	-- 			self.pRongyuEntry:setTitle(getConvertedStr(6, 10322))
	-- 			self.pRongyuEntry:setViewTouched(true)
	-- 			self.pRongyuEntry:onMViewClicked(function ( ... )
	-- 				-- body
	-- 				local tObject = {}
	-- 				tObject.nType = e_dlg_index.dlgcountryglory --dlg类型
	-- 				sendMsg(ghd_show_dlg_by_type,tObject)
	-- 			end)
	-- 		end

	-- 		--国家日志	
	-- 		if not self.pRiZhiEntry then
	-- 			self.pLayRiZhi = self:findViewByName("lay_rizhi")
	-- 			self.pRiZhiEntry = ItemCountryEntry.new()
	-- 			self.pRiZhiEntry:setImg("#v1_img_guojairizhi.png")
	-- 			self.pLayRiZhi:addView(self.pRiZhiEntry,10)
	-- 			centerInView(self.pLayRiZhi, self.pRiZhiEntry)
	-- 			self.pRiZhiEntry:setTitle(getConvertedStr(6, 10323))
	-- 			self.pRiZhiEntry:setViewTouched(true)
	-- 			self.pRiZhiEntry:onMViewClicked(function ( pView )
	-- 				-- body
	-- 				local tObject = {}
	-- 				tObject.nType = e_dlg_index.dlgcountrylog --dlg类型
	-- 				sendMsg(ghd_show_dlg_by_type,tObject)
	-- 			end)			
	-- 		end 

	-- 		if not self.pLayBot then
	-- 			self.pLayBot = self:findViewByName("lay_bot")
	-- 		end
	-- 		local NWidthEnter = 100
	-- 		local nWidth = (self.pLayBot:getWidth() - NWidthEnter*3)/4
	-- 		-- self.pLayGuanYuan:setPositionX(nWidth)
	-- 		-- self.pLayRongYu:setPositionX(nWidth + (nWidth + NWidthEnter))
	-- 		-- self.pLayRiZhi:setPositionX(nWidth + (nWidth + NWidthEnter)*2)
	-- 	elseif _index == 3 then

	-- 		--中部圣旨和国王膜拜
	-- 		if not self.pTabHost then
	-- 			local pLayTabHost = self:findViewByName("lay_tabhost")
	-- 			self.pTabHost = FCommonTabHost.new(pLayTabHost,1,1,{getConvertedStr(6, 10324), getConvertedStr(6, 10325)}, handler(self, self.getLayerByKey))
	-- 			self.pTabHost:setLayoutSize(pLayTabHost:getLayoutSize())				
	-- 			--self.pTabHost:setPositionY(10)
	-- 			self.pTabHost:setTabChangedHandler(function ( _key, _nType )
	-- 				-- body
	-- 				local tCountryDatavo = Player:getCountryData():getCountryDataVo()	
	-- 				if _key == "tabhost_key_2" and tCountryDatavo:isHaveKing() == true then
	-- 					--获取当前膜拜次数
	-- 					SocketManager:sendMsg("getWorshipTimes", {})	
	-- 				end
	-- 			end)
	-- 			pTabMgr = self.pTabHost.pTabManager
	-- 			pTabMgr:setImgBag("#v2_btn_blue1aa.png", "#v2_btn_blue2bb.png")
	-- 			self.pTabHost:removeLayTmp1()
	-- 			self.pTabHost:removeLayTmp2()
	-- 			pLayTabHost:addView(self.pTabHost, 10)
	-- 			centerInView(pLayTabHost, self.nTabHost)
	-- 			self.pTabHost:setDefaultIndex(1) 
	-- 		end
	-- 		local tCountryDatavo = Player:getCountryData():getCountryDataVo()			
	-- 		if tCountryDatavo and tCountryDatavo:isHaveKing() == true then
	-- 			self.pTabHost.tTabItems[2]:setViewEnabled(true)				
	-- 			self.pTabHost.tTabItems[2]:hideTabLock()
	-- 		else
	-- 			--不存在国王时候，国王标签页关闭				
	-- 			self.pTabHost.tTabItems[2]:showTabLock()
	-- 			self.pTabHost.tTabItems[2]:setViewEnabled(false)
	-- 			self.pTabHost.tTabItems[2]:onMViewDisabledClicked(handler(self, function (  )
	-- 				-- body
	-- 				TOAST(getTipsByIndex(529))
	-- 			end))
	-- 			self.pTabHost:setDefaultIndex(1)	
	-- 		end
	-- 	elseif _index == 4 then
	-- 		--红点
	-- 		self:updateRedTips()
	-- 	end		
	-- end)
end

--析构方法
function DlgCountry:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgCountry:regMsgs(  )
	-- body
	--
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))	
	--红点
	regMsg(self, ghd_country_home_menu_red_msg, handler(self, self.updateRedTips))
	--膜拜红点
	regMsg(self, ghd_mobai_red_msg, handler(self, self.updateRedTips))
	--背包数据刷新
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateRedTips))
	--玩家信息刷新修改	
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateRedTips))	
			

end
--注销消息
function DlgCountry:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_country_msg)
	unregMsg(self, ghd_country_home_menu_red_msg)
	unregMsg(self, ghd_mobai_red_msg)
	unregMsg(self, gud_refresh_baginfo)	
	unregMsg(self, gud_refresh_playerinfo)	
end

--暂停方法
function DlgCountry:onPause( )
	-- body
	removeTextureFromCache("tx/other/tx_treasurebox")	
	self:unregMsgs()		
end

--继续方法
function DlgCountry:onResume( )
	-- body
	addTextureToCache("tx/other/tx_treasurebox")	
	self:updateViews()
	self:regMsgs()
end

--国家开发
-- function DlgCountry:onCountryBtnClicked( pView )
-- 	-- body
-- 	local tdevelop = getCountryDevelop()
-- 	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
-- 	if tCountryDatavo and tdevelop and tCountryDatavo.nExploit < table.nums(tdevelop) then
-- 		local tObject = {}
-- 		tObject.nType = e_dlg_index.dlgcountrydevelop --dlg类型
-- 		sendMsg(ghd_show_dlg_by_type,tObject)
-- 	else
-- 		TOAST(getConvertedStr(6, 10444))
-- 	end
-- end
--爵位
-- function DlgCountry:onJueWeiBtnClicked( pview )
-- 	-- body
-- 	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
-- 	local tbanneret = getCountryBanneret()
-- 	local tNobilityData = tbanneret[tCountryDatavo.nNobility + 1]	--下一级的爵位数据
-- 	if tNobilityData then
-- 		local tObject = {}
-- 		tObject.nType = e_dlg_index.dlgnobilitypromote --dlg类型
-- 		sendMsg(ghd_show_dlg_by_type,tObject)
-- 	else
-- 		TOAST(getTipsByIndex(437))
-- 	end
-- end

--通过key值获取内容层的layer
-- function DlgCountry:getLayerByKey( _sKey, _tKeyTabLt )
-- 	-- body
-- 	local pLayer = nil
-- 	local pdata = {}
-- 	if( _sKey == _tKeyTabLt[1] ) then
-- 		pLayer = DecreeLayer.new()	
-- 	elseif (_sKey == _tKeyTabLt[2] ) then		
-- 		pLayer = KingLayer.new()					
-- 	end
-- 	return pLayer
-- end

function DlgCountry:updateRedTips(  )
	-- body
	-- if not self.pLayRed1 then
	-- 	self.pLayRed1 = self:findViewByName("lay_red_1")
	-- end	
	-- if not self.pLayRed2 then
	-- 	self.pLayRed2 = self:findViewByName("lay_red_2")
	-- end	
	-- if not self.pLayRed3 then
	-- 	self.pLayRed3 = self:findViewByName("lay_red_3")
	-- end	
	--国家官员	
	showRedTips(self.pLayOfficialRed, 0, Player:getCountryData():getOfficialRedNum(), 2)		
	-- --国家荣誉
	-- if self.pRongyuEntry then
	-- 	self.pRongyuEntry:updateRedTips(Player:getCountryData():getCountryHonorRedNum())
	-- end
	-- --国王膜拜	
	-- if self.pLayRed1 then		
	-- 	--dump(Player:getCountryData():getMobaiRedNum(), "MobaiRedNum", 100)
	-- 	showRedTips(self.pLayRed1, 0, Player:getCountryData():getMobaiRedNum())
	-- end
	-- --爵位
	-- if self.pLayRed2 then
	-- 	showRedTips(self.pLayRed2, 0, Player:getCountryData():getNobilityRedNum())
	-- end
	-- --国家开发
	-- if self.pLayRed3 then
	-- 	showRedTips(self.pLayRed3, 0, Player:getCountryData():getDevelopRedNum())
	-- end	
end
return DlgCountry