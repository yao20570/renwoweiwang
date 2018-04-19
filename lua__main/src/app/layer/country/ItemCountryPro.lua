----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-04-08 11:44:14
-- Description: 国家功能项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemCountryPro = class("ItemCountryPro", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemCountryPro:ctor( _nIndex,_bIsLarge )
	-- body
	self:myInit()
	self.nIdx = _nIndex or self.nIdx
	if _bIsLarge then
		parseView("item_country_pro_l", handler(self, self.onParseViewCallback))
	else
		parseView("item_country_pro_s", handler(self, self.onParseViewCallback))

	end
end
--暂停方法
function ItemCountryPro:onPause( )
	-- body
	self:unregMsgs()		
end

function ItemCountryPro:onResume( )
	-- body	
	self:updateViews()
	self:regMsgs()
end
--注册消息
function ItemCountryPro:regMsgs(  )
	-- body
	--
	regMsg(self, gud_refresh_countrytask, handler(self, self.updateViews))
	regMsg(self, gud_refresh_countryhelp, handler(self, self.updateViews))	
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))	
	regMsg(self, ghd_refresh_country_treasure, handler(self, self.updateViews))
	regMsg(self, gud_refresh_country_tnoly, handler(self, self.updateViews))
	regMsg(self, gud_refresh_country_honor_msg, handler(self, self.updateViews))

end
--注销消息
function ItemCountryPro:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_countrytask)
	unregMsg(self, gud_refresh_countryhelp)	
	unregMsg(self, gud_refresh_country_msg)
	unregMsg(self, ghd_refresh_country_treasure)
	unregMsg(self, gud_refresh_country_tnoly)
	unregMsg(self, gud_refresh_country_honor_msg)
end

--初始化成员变量
function ItemCountryPro:myInit(  )
	-- body
	self.nIdx = 1
	self.tCurData = nil
end

--解析布局回调事件
function ItemCountryPro:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()	
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCountryPro",handler(self, self.onDestroy))
end

--初始化控件
function ItemCountryPro:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_default")
	self.pLayTip = self:findViewByName("lb_tip")
	self.pLayTip:setVisible(false)
	-- self.pLayPar1 = self:findViewByName("lb_par_1")
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	if self.nIdx == e_type_country_sys_pos.countrytnoly then--国家科技
		
		self:onMViewClicked(handler(self, self.onTnolyBtnClicked))	
		self.pLayRoot:setBackgroundImage("ui/big_img_sep/v2_fonts_guojiakeji.jpg")
		self.pLayTip:setVisible(true)

	elseif self.nIdx == e_type_country_sys_pos.countryshop then--国家商店	
			
		self:onMViewClicked(handler(self, self.onJumpCountryShop))
		self.pLayRoot:setBackgroundImage("ui/big_img_sep/v2_fonts_guojiashangdian.jpg")

		
	elseif self.nIdx == e_type_country_sys_pos.countryhelp then--国家互助
		
		self:onMViewClicked(handler(self, self.onHelpBtnClicked))
		self.pLayRoot:setBackgroundImage("ui/big_img_sep/v2_fonts_guojiahuzhu.jpg")


	elseif self.nIdx == e_type_country_sys_pos.countrytask then--国家任务
		
		self:onMViewClicked(handler(self, self.onJumpCountryTask))	
		self.pLayRoot:setBackgroundImage("ui/big_img_sep/v2_fonts_guojiarenwu.jpg")
		self.pLayTip:setVisible(true)

										
	elseif self.nIdx == e_type_country_sys_pos.countrytreasure then--国家宝藏
		
		self:onMViewClicked(handler(self, self.onTreasureBtnClicked))
		self.pLayRoot:setBackgroundImage("ui/big_img_sep/v2_fonts_guojiabaozang.jpg")
		self.pLayTip:setVisible(true)


	elseif self.nIdx == e_type_country_sys_pos.countryglory then--国家荣誉
		
		self:onMViewClicked(handler(self, self.onHonoryBtnClicked))	

		self.pLayRoot:setBackgroundImage("ui/big_img_sep/v2_fonts_guojiarongyu.jpg")

	elseif self.nIdx == e_type_country_sys_pos.countryofficial then--国家爵位
		self:onMViewClicked(handler(self, self.onJueWeiBtnClicked))	
		self.pLayRoot:setBackgroundImage("ui/big_img_sep/v2_fonts_guojiajuewei.jpg")
		self.pLayTip:setVisible(true)
	elseif self.nIdx == e_type_country_sys_pos.countrycity then--国家城池
		
		self:onMViewClicked(handler(self, self.onCityBtnClicked))	
		self.pLayRoot:setBackgroundImage("ui/big_img_sep/v2_fonts_guojiachengchi.jpg")

	end
end

-- 修改控件内容或者是刷新控件数据
function ItemCountryPro:updateViews( )
	-- body
	-- if not self.tCurData then
	-- 	return
	-- end
	-- local pData = self.tCurData

	if self.nIdx == e_type_country_sys_pos.countrytnoly then--国家科技
		--捐献次数
		local nDonateLimit = tonumber(getCountryParam("donateLimit"))
		local nLeftDonate = Player:getCountryTnoly().nLeftDonate
		local str = {
			{text = getConvertedStr(7, 10430),color = _cc.white},
			{text = nLeftDonate,color = _cc.green},
			{text = "/"..nDonateLimit,color = _cc.white}
		}
		self.pLayTip:setString(str)
		local nRedNum = Player:getCountryTnoly():getRedNum()
		showRedTips(self.pLayRoot, 0, nRedNum, 2)

	elseif self.nIdx == e_type_country_sys_pos.countryshop then--国家商店	
		

		
	elseif self.nIdx == e_type_country_sys_pos.countryhelp then--国家互助
		local pData = Player:getCountryHelpData()
		local nRedNum = pData:getCountryHelpRed()
		showRedTips(self.pLayRoot, 0, nRedNum, 2)

	elseif self.nIdx == e_type_country_sys_pos.countrytask then--国家任务
		local pData = Player:getCountryTaskData()
		--倒计时刷新
		local nLeft = pData:getCdTime()
		if nLeft > 0 then
			local sStr = {
				{color=_cc.white,text=getConvertedStr(3,10042)},
				{color=_cc.red,text=formatTimeToMs(nLeft)},
			}
			self.pLayTip:setString(sStr, false)
			regUpdateControl(self, handler(self, self.onUpdateTask))
		else
			self.pLayTip:setString("")
			unregUpdateControl(self)
		end
		local nRedNum = pData:getCountryTaskRed()
		showRedTips(self.pLayRoot, 0, nRedNum, 2)
										
	elseif self.nIdx == e_type_country_sys_pos.countrytreasure then--国家宝藏
		local pTreasureData = Player:getCountryTreasureData()
		local nLeftTime1 = pTreasureData:getRefreshLeftTime()
		if nLeftTime1 then
			if nLeftTime1>0 then
				local sStr = {
					{color=_cc.white,text=getConvertedStr(9,10225)},
					{color=_cc.red,text=formatTimeToMs(nLeftTime1)},
				}
				self.pLayTip:setString(sStr, false)
				regUpdateControl(self, handler(self, self.onUpdateTreasure))

			else
				self.pLayTip:setString("")
				unregUpdateControl(self)

			end
		end
		showRedTips(self.pLayRoot, 0, pTreasureData:getRedNum(), 2)

	elseif self.nIdx == e_type_country_sys_pos.countryglory then--国家荣誉
		local pCountryData = Player:getCountryData()
		showRedTips(self.pLayRoot, 0, pCountryData:getCountryHonorRedNum(), 2)				
	elseif self.nIdx == e_type_country_sys_pos.countryofficial then--国家爵位

		local tCountryDatavo = Player:getCountryData():getCountryDataVo()
		local tbanneret = getCountryBanneret()
		local nNobility	= tCountryDatavo.nNobility
		if tbanneret and tbanneret[nNobility] then		
				
			local data = tbanneret[nNobility]
			local sStr = {
				{color=_cc.white,text=getConvertedStr(9,10226)},
				{color=_cc.green,text=data.name},
			}		
			self.pLayTip:setString(sStr, false)	
		end
		local pCountryData = Player:getCountryData()
		showRedTips(self.pLayRoot, 0, pCountryData:getNobilityRedNum(), 2)
	elseif self.nIdx == e_type_country_sys_pos.countrycity then--国家城池
		

	end

end
--任务倒计时刷新
function ItemCountryPro:onUpdateTask(  )
	-- body
	local pData = Player:getCountryTaskData()
	if not pData then
		return
	end
	--倒计时刷新
	local nLeft = pData:getCdTime()
	if nLeft > 0 then
		local sStr = {
			{color=_cc.pwhite,text=getConvertedStr(3,10042)},
			{color=_cc.red,text=formatTimeToMs(nLeft)},
		}		
		self.pLayTip:setString(sStr, false)		
	else
		self.pLayTip:setString("")
		unregUpdateControl(self)
	end	
end
--宝藏倒计时刷新
function ItemCountryPro:onUpdateTreasure(  )
	-- body
	local nLeftTime1 = Player:getCountryTreasureData():getRefreshLeftTime()
	if nLeftTime1 then
		if nLeftTime1>0 then
			local sStr = {
				{color=_cc.pwhite,text=getConvertedStr(9,10225)},
				{color=_cc.red,text=formatTimeToMs(nLeftTime1)},
			}
			self.pLayTip:setString(sStr, false)
			regUpdateControl(self, handler(self, self.onUpdateTreasure))

		else
			self.pLayTip:setString("")
			unregUpdateControl(self)
		end
	end
end

function ItemCountryPro:onJumpCountryShop( ... )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgcountryshop --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

function ItemCountryPro:onJumpCountryTask( ... )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgtaskcountry --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

-- 爵位
function ItemCountryPro:onJueWeiBtnClicked( pview )
	-- body
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	local tbanneret = getCountryBanneret()
	local tNobilityData = tbanneret[tCountryDatavo.nNobility + 1]	--下一级的爵位数据
	if tNobilityData then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgnobilitypromote --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	else
		TOAST(getTipsByIndex(437))
	end
end
--国家荣誉
function ItemCountryPro:onHonoryBtnClicked( ... )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgcountryglory --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--国家城池
function ItemCountryPro:onCityBtnClicked(  )
	local tObject = {
	    nType = e_dlg_index.countrycity, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

function ItemCountryPro:onHelpBtnClicked()
	local tObject = {}
	tObject.nType = e_dlg_index.newcountryhelp --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

--国家科技
function ItemCountryPro:onTnolyBtnClicked()
	local tObject = {}
	tObject.nType = e_dlg_index.dlgcountrytnoly --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end


--国家宝藏
function ItemCountryPro:onTreasureBtnClicked( ... )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgcountrytreasure --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

-- 析构方法
function ItemCountryPro:onDestroy(  )
	-- body
	self:onPause()
end

function ItemCountryPro:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end
return ItemCountryPro


