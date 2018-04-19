-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-08 18:28:23 星期一
-- Description: 工坊界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemProductLine = require("app.layer.atelier.ItemProductLine")

local DlgAtelier = class("DlgAtelier", function()
	-- body
	return DlgBase.new(e_dlg_index.atelier)
end)

function DlgAtelier:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_atelier", handler(self, self.onParseViewCallback))
end

function DlgAtelier:myInit(  )
	-- body

end

--解析布局回调事件
function DlgAtelier:onParseViewCallback( pView )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10176))
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgAtelier",handler(self, self.onDlgDlgAtelierDestroy))
end

--初始化控件
function DlgAtelier:setupViews(  )
	-- body	
	
	local nActivityId=getIsShowActivityBtn(self.eDlgType)
    if nActivityId>0 then
    	self.pLayActBtn=self:findViewByName("lay_act_btn")
    	self.pActBtn = addActivityBtn(self.pLayActBtn,nActivityId)
    else
    	if self.pActBtn then
    		self.pActBtn:removeSelf()
    		self.pActBtn=nil
    	end
    end
end

--控件刷新
function DlgAtelier:updateViews(  )
	-- body
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if (_index == 1) then
			--固定标签
			if not self.pLbTip1 then
				self.pLbTip1 = self:findViewByName("lb_tip_1")	
				self.pLbTip2 = self:findViewByName("lb_tip_2")	
				self.pLbTip3 = self:findViewByName("lb_tip_3")

				--头顶横条(banner)
				local pBannerImage 			= 		self:findViewByName("lay_banner_bg")
				setMBannerImage(pBannerImage,TypeBannerUsed.gf)
			end
			--富文本刷新
			local  palacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
			local  _tSaturation = getSaturationDataFromDB(palacedata.nLv)
			local palacelv = palacedata.nLv or 0
			local minLimit = _tSaturation.minlimit or 0
			local maxLimit = _tSaturation.maxlimit or 0
			local tCityStatus = nil
			--国家百姓
			local tStr1 = {
				{color=_cc.white,text=getConvertedStr(6, 10180)},
				{color=_cc.blue,text=getResourcesStr(palacedata:getCountryPeopleCnt())},
				{color=_cc.white,text=getTipsByIndex(10003)}
			}
			self.pLbTip1:setString(tStr1, false)
			--dump(_tSaturation, "_tSaturation", 100)
			if palacedata.nPersonCt < minLimit then--配表数据
				tCityStatus = luaSplit(getTipsByIndex(10006), ":")
			elseif palacedata.nPersonCt > maxLimit then
				tCityStatus = luaSplit(getTipsByIndex(10004), ":")
			else
				tCityStatus = luaSplit(getTipsByIndex(10005), ":")
			end	
			--本城人口
			local tStr2 = {
				{color=_cc.white,text=getConvertedStr(6, 10181)},
				{color=_cc.green,text=palacedata.nPersonCt},--getResourcesStr(palacedata.nPersonCt)},
				{color=getC3B(tCityStatus[2]),text=" "..tCityStatus[1]}
			}	
			self.pLbTip2:setString(tStr2, false)	
			--城池情况
			local tStr3 = {
				{color=_cc.white,text=getConvertedStr(6, 10182)},
				{color=_cc.white,text=getConvertedStr(6, 10192)},
				{color=_cc.blue,text=palacelv},
				{color=_cc.white,text=getConvertedStr(6, 10193)},
				{color=_cc.blue,text=minLimit},
				{color=_cc.white,text=getConvertedStr(6, 10194)},
				{color=_cc.blue,text=maxLimit},
				{color=_cc.white,text=getConvertedStr(6, 10195)},		
			}	
			self.pLbTip3:setString(tStr3, false)	

			--底部按钮层
			if not self.pLayBtn then
				self.pLayBtn = self:findViewByName("lay_btn")
				self.pBotBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10178))
				self.pBotBtn:onCommonBtnClicked(handler(self, self.onBespeakBtnClicked))					
			end

		elseif (_index == 2) then
			--生产队列数据

			if not self.pLayRed then
				self.pLayRed = self:findViewByName("lay_red")
			end			
			local nItemCnt = 0
			local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)
			if atelierData then
				local nbuyProductLine = getNextProductLineCost(atelierData.nBuyQueue)
				nItemCnt = atelierData.nQueue
				if nbuyProductLine then--可以继续购买队列的情况下
					nItemCnt = nItemCnt + 1
				end
				local nvip = tonumber(getBuildParam("workshopVip"))
				if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then
					showRedTips(self.pLayRed, 0, atelierData.nQueue - #atelierData.tWaitQueue)
				else
					showRedTips(self.pLayRed, 0, 0)
				end
			end	

			--列表层
			if not self.pListView then
				self.pLayList = self:findViewByName("lay_list")
				self.pListView = MUI.MListView.new {
			    	bgColor = cc.c4b(255, 255, 255, 250),
			    	viewRect = cc.rect(20, 0, 600, self.pLayList:getHeight()),
			    	direction = MUI.MScrollView.DIRECTION_VERTICAL,
			    	itemMargin = {left =  0,
			    	right =  0,
			    	top =  10,
			    	bottom =  0}}
				self.pListView:setBounceable(true)   
				--上下箭头
				local pUpArrow, pDownArrow = getUpAndDownArrow()
				self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)					
				self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
				self.pLayList:addView(self.pListView, 10)
				centerInView(self.pLayList, self.pListView)
				self.pListView:setItemCount(nItemCnt)
				self.pListView:reload(true)
			else
				self.pListView:notifyDataSetChange(true, nItemCnt)
			end

		elseif (_index == 3) then
			local tGuideInterface = Player:getDayLoginData():getAlreadyGuidedView()
		    --判断有没有播放过建筑引导,即是不是第一次进来, 如果不是才引导		    		   
		    if tGuideInterface[e_dlg_index.atelier] then
		    	self:openGuideDlg()
				--doDelayForSomething(self, handler(self, self.openGuideDlg), 0.5)
		    end
		end
	end)
end

--析构方法
function DlgAtelier:onDlgDlgAtelierDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgAtelier:regMsgs(  )
	-- body
	--注册工坊数据刷信息消息
	regMsg(self, ghd_refresh_atelier_msg, handler(self, self.updateViews))	
	--注册王宫数据刷新消息
	regMsg(self, ghd_refresh_palace_msg, handler(self, self.updateViews))
	--购买VIP礼包消息
	regMsg(self, gud_vip_gift_bought_update_msg, handler(self, self.updateViews))
end
--注销消息
function DlgAtelier:unregMsgs(  )
	-- body
	--注销工坊数据刷信息消息
	unregMsg(self, ghd_refresh_atelier_msg)
	--注销王宫数据刷新消息
	unregMsg(self, ghd_refresh_palace_msg)
	--注销VIP礼包购买
	unregMsg(self, gud_vip_gift_bought_update_msg)
end

--暂停方法
function DlgAtelier:onPause( )
	-- body
	self:unregMsgs()
	closeDlgByType(e_dlg_index.atelierguide, false)	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgAtelier:onResume( _bReshow )
	-- body	
	if _bReshow and self.pListView then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
end

--预约生产按钮点击回调
function DlgAtelier:onBespeakBtnClicked( pView )
	-- body	
	--预约生产 跟随礼包
	local nvip = tonumber(getBuildParam("workshopVip"))
	if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then
		local tObject = {}
		tObject.nType = e_dlg_index.atelierbespeak --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)	
	else

		local tShopBase = {}
		tShopBase.id = e_id_item.gfys
    	-- dump(tShopBase, "tShopBase", 100)
		local tObject = {
		    nType = e_dlg_index.vipgitfgoodtip, --dlg类型
		    tShopBase = tShopBase,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end	
end

--列表项回调
function DlgAtelier:onListViewItemCallBack(_index, _pView)
	-- body	
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemProductLine.new(_index, true)                        
        pTempView:setViewTouched(false)
    end
    pTempView:setIndex(_index)
    return pTempView
end

--打开引导对话框
function DlgAtelier:openGuideDlg()
	-- body
	--条件判断
	local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)	
	if atelierData and atelierData:isCanOpenGuild() == true then
		local ncitychange = Player:getBuildData():getBuildById(e_build_ids.palace):getOwnCityPeopleChangeCnt()
		if ncitychange ~= 0 then
			local tObject = {}			
			tObject.nType = e_dlg_index.atelierguide --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)	
		end		
	end
end

return DlgAtelier