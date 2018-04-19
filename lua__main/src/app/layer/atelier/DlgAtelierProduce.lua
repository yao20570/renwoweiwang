-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-08 19:28:23 星期一
-- Description: 工坊生产界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemSelect = require("app.layer.atelier.ItemSelect")
local MImgLabel = require("app.common.button.MImgLabel")
local DlgAtelierProduce = class("DlgAtelierProduce", function()
	-- body
	return DlgBase.new(e_dlg_index.atelierproduce)
end)
--_flag 1--生产 2--预生产
function DlgAtelierProduce:ctor( _flag , _queueIdx)
	-- body
	self:myInit(_flag , _queueIdx)
	parseView("dlg_atelier_produce", handler(self, self.onParseViewCallback))
end

function DlgAtelierProduce:myInit( _flag , _queueIdx)
	-- body
	self._nFlag = _flag or 1--默认是添加生产项
	self._nQueueIdx = _queueIdx or 1--队列号
	self._nCurSelectedQ = Player:getBuildData():getBuildById(e_build_ids.atelier):getProduceRecord()--当前选中品质
	self._nCurCostItemIDx = 1--生产物品序号
	self.tQSelectGroup = nil --品质选择分组
	self.tCostItemGroup = nil --消耗图纸分组
	self.isCanPro = true--是否可以生产
end

--解析布局回调事件
function DlgAtelierProduce:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(9)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgAtelierProduce",handler(self, self.onDlgDlgAtelierProduceDestroy))
end

--初始化控件
function DlgAtelierProduce:setupViews(  )
	-- body	
	--设置标题
	self:setTitle(getConvertedStr(6,10177))

	--顶层
	self.pLayTop = self:findViewByName("lay_top")
	--标题1
	self.ptitle1 = self:findViewByName("lb_title1")
	self.ptitle1:setString(getConvertedStr(6, 10201))
	--材料等级选择
	self.tQSelectGroup = {}
	local x = 30
	local y = 16
	local tAtelierProduction = getAtelierProductionParam()
	for i ,v in pairs(tAtelierProduction) do 
		--print(i.."--------------------")
		local itemSelectQuality = ItemSelect.new(ItemSelect_Select_Type.Bg)
		itemSelectQuality.Idx = i
		local data = {}
		data.sName = v.name
		data.nQuality = v.quality
		data.nLimitLv = v.workshoplv	
		if v.icon then
			data.sIcon = "#"..v.icon..".png" 
		else
			data.sIcon = "ui/daitu.png"	
		end		
		itemSelectQuality:setCurData(data)
		itemSelectQuality:setPosition(self.pLayTop:getWidth()/2 + (i-2)*200 - 70, y)
		itemSelectQuality:onMViewClicked(handler(self, self.selectQualityCallBack))		
		self.pLayTop:addView(itemSelectQuality, 10)
		table.insert(self.tQSelectGroup, itemSelectQuality)
	end
	self.tQSelectGroup[self._nCurSelectedQ]:selected()	
	--中层
	self.pLayCenter = self:findViewByName("lay_center")
	--标题2
	self.ptitle2 = self:findViewByName("lb_title2")
	self.ptitle2:setString(getConvertedStr(6, 10203))
	--消耗图纸显示层
	self.pLayScroll = self:findViewByName("lay_scroll")	

	--底层
	self.pLayBot = self:findViewByName("lay_bot")
	--标题3
	self.ptitle3 = self:findViewByName("lb_title3")
	self.ptitle3:setString(getConvertedStr(6, 10204))
	--图纸消耗
	self.pLayTZ = self:findViewByName("lay_par_1")
	self.pLbTuzhi = MImgLabel.new({text="", size = 20, parent = self.pLayTZ})
	self.pLbTuzhi:hideImg()
	self.pLbTuzhi:setAnchorPoint(0,0.5)
	--self.pLbTuzhi:setImg("#v1_img_qianbi.png")
	self.pLbTuzhi:followPos("left",0,0,10)		
	setTextCCColor(self.pLbTuzhi, _cc.green)
	--富文本银币消耗
	self.pLayTQ = self:findViewByName("lay_par_2")
	self.pLbTQ = MImgLabel.new({text="", size = 20, parent = self.pLayTQ})
	self.pLbTQ:setAnchorPoint(0,0.5)
	self.pLbTQ:setImg("#v1_img_tongqian.png")
	self.pLbTQ:followPos("left",0,0,10)		
	--富木材银币消耗
	self.pLayMC = self:findViewByName("lay_par_3")
	self.pLbMC = MImgLabel.new({text="", size = 20, parent = self.pLayMC})
	self.pLbMC:setAnchorPoint(0,0.5)
	self.pLbMC:setImg("#v1_img_mucai.png")
	self.pLbMC:followPos("left",0,0,10)		
	--消耗预留
	self.pLayTemp = self:findViewByName("lay_par_4")
	--预计生产时间
	self.pLbTimer = self:findViewByName("lb_timer")
	local sStr = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10202)},
		{color=_cc.red, text=getConvertedStr(6, 10200)},
	}
	self.pLbTimer:setString(sStr)	
	--底部按钮层
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBotBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10177))
	self.pBotBtn:onCommonBtnClicked(handler(self, self.onProduceBtnClicked))
	--初始化请求花费时间
	self:rqProduceTime(self._nCurSelectedQ)
end

--控件刷新
function DlgAtelierProduce:updateViews(  )
	-- body
	--self.tQSelectGroup
	for k, v in pairs(self.tQSelectGroup) do						
		v:updateViews()
	end
	self:updateScrollView()
end

--设置生产参数
function DlgAtelierProduce:setAtelierProduceParam( _flag , _queueIdx )
	-- body
	self._nFlag = _flag or 1--默认是添加生产项
	self._nQueueIdx = _queueIdx or 1--队列号	
end

--析构方法
function DlgAtelierProduce:onDlgDlgAtelierProduceDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgAtelierProduce:regMsgs(  )
	-- body
	--注册工坊数据刷信息消息
	regMsg(self, ghd_refresh_atelier_msg, handler(self, self.updateCostInfo))	
	--注册王宫数据刷新消息
	regMsg(self, ghd_refresh_palace_msg, handler(self, self.updateCostInfo))
	--注册预计生产时间刷新消息
	regMsg(self, ghd_refresh_atelier_protime_msg, handler(self, self.refreshProduceTime))
	--注册玩家信息刷新
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateCostInfo))
end
--注销消息
function DlgAtelierProduce:unregMsgs(  )
	-- body
	--注销工坊数据刷信息消息
	unregMsg(self, ghd_refresh_atelier_msg)
	--注销王宫数据刷新消息
	unregMsg(self, ghd_refresh_palace_msg)
	--注销预计生产时间刷新消息
	unregMsg(self, ghd_refresh_atelier_protime_msg)	
	--注销玩家信息刷新
	unregMsg(self, gud_refresh_playerinfo)	
end

--暂停方法
function DlgAtelierProduce:onPause( )
	-- body		
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgAtelierProduce:onResume( _bReshow )
	-- body		
	if _bReshow then
		--初始化请求花费时间	
		self:rqProduceTime(self._nCurSelectedQ)
	end	
	self:updateViews()
	self:regMsgs()
end
--生产按钮点击事件回调
function DlgAtelierProduce:onProduceBtnClicked( pView )
	-- body
	local itemId = self.tCostItemGroup[self._nCurCostItemIDx].tCurData.sTid
	local proId = self._nQueueIdx
	local flag = self._nFlag
	SocketManager:sendMsg("addProduceItem", {itemId, proId, flag}, handler(self, self.addProduceItemCallBack))
end

--刷新滑动框的内容
function DlgAtelierProduce:updateScrollView(  )
	-- body
	--清理子控件
	if self.pLayScroll then
		self.tCostItemGroup = {}
		self.pLayScroll:removeAllChildren()
	else
		return
	end	
	local tItemsData = getAtelierCostItemsByQuality(self._nCurSelectedQ)	
	local pcontentView = nil
	self._nCurCostItemIDx = nil--回复选择物品序号
	--根据材料数量重新设置滑动视图的高度
	local itemsNum = table.nums(tItemsData)
	local nrow = math.ceil(itemsNum/4)--行数
	local ncol = 4--列数	
	if nrow > 2 then
		local pScrollView = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, self.pLayScroll:getWidth(), self.pLayScroll:getHeight()),        
 			touchOnContent = false,
        	direction=MUI.MScrollLayer.DIRECTION_VERTICAL,
 			bothSize =cc.size(self.pLayScroll:getWidth(), self.pLayScroll:getHeight()*nrow/2)})
		pScrollView:setBounceable(false)
		self.pLayScroll:addView(self.pScrollView, 10)
		pcontentView = MUI.MLayer.new()
		pcontentView:setContentSize(self.pLayScroll:getWidth(), self.pLayScroll:getHeight()*nrow/2)	
		pScrollView:addView(pcontentView, 10)
		centerInView(pScrollView,pcontentView)
	else
		pcontentView = self.pLayScroll
	end		
	local pLbTip  = MUI.MLabel.new({
    text="",
    size=20,
    anchorpoint=cc.p(0.5, 0.5),
    dimensions = cc.size(600, 0),
    })
	pLbTip:setPosition(pcontentView:getWidth()/2, pcontentView:getHeight() - 30)		
	if self._nCurSelectedQ == 1 then
		pLbTip:setString(getTextColorByConfigure(getTipsByIndex(20040)), false)
	elseif self._nCurSelectedQ == 2 then
		pLbTip:setString(getTextColorByConfigure(getTipsByIndex(20136)), false)
	elseif self._nCurSelectedQ == 3 then			
		pLbTip:setString(getTextColorByConfigure(getTipsByIndex(20137)), false)
	end		
	pcontentView:addView(pLbTip, 10)
	local nScale = 0.8	
	if itemsNum > 0 then				
		for i ,v in pairs(tItemsData) do
			local curCol = i%ncol--当前列数
			if curCol == 0 then
				curCol = ncol
			end			
			local curRow = math.ceil(i/ncol)--当前行数
			local tmpIcon = ItemSelect.new(ItemSelect_Select_Type.Gou)
			tmpIcon:setScale(nScale)
			--设置位置
			local x = 45 + 139*(curCol - 1)
			local y = 140*(nrow - curRow) - 10
			local nItemWidth = tmpIcon:getWidth()
			if itemsNum <= ncol then--单行显示
				local nMid = math.ceil(itemsNum/2)
				if itemsNum %2 == 0 then
					x = pcontentView:getWidth()/2 + (i - nMid - 1)*nItemWidth
				else
					x = pcontentView:getWidth()/2 + (i - nMid)*nItemWidth - nItemWidth/2
				end				
				y = pcontentView:getHeight()/2 - 90
			end
			tmpIcon:setPosition(x, y)			
			tmpIcon.Idx = i
			tmpIcon:setCurData(v)
			tmpIcon:onMViewClicked(handler(self, self.selectItemCallBack))		
			pcontentView:addView(tmpIcon)
			table.insert(self.tCostItemGroup, tmpIcon)
			if v.nCt > 0 and self._nCurCostItemIDx == nil then
				self._nCurCostItemIDx = i
			end
		end
		if not self._nCurCostItemIDx then
			self._nCurCostItemIDx = 1
		end			
		--默认选择第一个
		self.tCostItemGroup[self._nCurCostItemIDx]:selected()			
	else--没有工坊生产图纸
		local tLabel = {}
		tLabel.str = getConvertedStr(6, 10761)
		local pNullTip = getLayNullUiImgAndTxt(tLabel)
		pcontentView:addView(pNullTip)
		centerInView(pcontentView, pNullTip)
	end		
	self:updateCostInfo()--刷星消耗信息
end

--选择品质
function DlgAtelierProduce:selectQualityCallBack( _tselecteditem )
	-- body
	if _tselecteditem then
		_tselecteditem:selected()		
		for k, v in pairs(self.tQSelectGroup) do					
			if v.Idx ~= _tselecteditem.Idx then
				v:unselected()
			end
		end
		local selectQ = _tselecteditem.Idx
		--选中品质变化的情况下刷新下拉列表
		if selectQ ~= self._nCurSelectedQ then
			self._nCurSelectedQ = selectQ			
			self:updateScrollView()
			self:updateCostInfo()			
			self:rqProduceTime(self._nCurSelectedQ)
			Player:getBuildData():getBuildById(e_build_ids.atelier):setProduceRecord(self._nCurSelectedQ)
		end	

	end
end

--选中图纸回调
function DlgAtelierProduce:selectItemCallBack( _tselecteditem )
 	-- body
 	--dump(_icon.tCurData, "costitem=", 100)
 	if _tselecteditem then
 		--对应的icon设置为选中状态
 		_tselecteditem:selected()
 		--其他icon设置为非选中状态
 		for i, v in pairs(self.tCostItemGroup) do
 			if v.Idx ~= _tselecteditem.Idx then
 				--设置非选中状态
 				v:unselected()
 			end
 		end
 		if self._nCurCostItemIDx ~= _tselecteditem.Idx then
 			self._nCurCostItemIDx = _tselecteditem.Idx
 			self:updateCostInfo() 	
 		end 		
 	end
 end 
 --刷新消耗信息显示
function DlgAtelierProduce:updateCostInfo(  )
	-- body
	local tAtelierProduction = getAtelierProductionParam()
	self.isCanPro = false
	self.tResList = {}
	self.tResList[e_resdata_ids.lc] = 0
	self.tResList[e_resdata_ids.bt] = 0
	self.tResList[e_resdata_ids.mc] = 0
	self.tResList[e_resdata_ids.yb] = 0
	if tAtelierProduction then
		local tCurCostInfo = tAtelierProduction[self._nCurSelectedQ]
		if tCurCostInfo then
			self.isCanPro = true	
			if self._nCurCostItemIDx then
				local pTuziItem = self.tCostItemGroup[self._nCurCostItemIDx].tCurData 						
				self.pLbTuzhi:setString(pTuziItem.sName..getConvertedStr(6, 10199)..tCurCostInfo.num)
				if self.tCostItemGroup[self._nCurCostItemIDx].tCurData.nCt >= tCurCostInfo.num then
					setTextCCColor(self.pLbTuzhi, _cc.green)
				else
					setTextCCColor(self.pLbTuzhi, _cc.red)
					self.isCanPro = false
				end					
			else
				self.pLbTuzhi:setString(tCurCostInfo.itemname..getConvertedStr(6, 10199)..tCurCostInfo.num)
				setTextCCColor(self.pLbTuzhi, _cc.red)
				self.isCanPro = false
			end
						
			--银币消耗
			local tmpcolor = _cc.red
			local nCoincost = tonumber(tCurCostInfo.coincost)
			self.tResList[e_resdata_ids.yb] = nCoincost
			if getIsResourceEnough(e_resdata_ids.yb, nCoincost) then
				tmpcolor = _cc.green
			else
				self.isCanPro = false
			end
			local tStr1 = {
					{color=tmpcolor,text=formatCountToStr(Player:getPlayerInfo().nCoin)},
					{color=_cc.blue,text=getConvertedStr(6, 10115)},
					{color=_cc.pwhite,text=formatCountToStr(nCoincost)},					
				}
			self.pLbTQ:setString(tStr1, false)
	
			--木材消耗
			tmpcolor = _cc.red
			local nwoodcost = tonumber(tCurCostInfo.woodcost)
			self.tResList[e_resdata_ids.mc] = nwoodcost
			if getIsResourceEnough(e_resdata_ids.mc, nwoodcost) then
				tmpcolor = _cc.green
			else
				self.isCanPro = false
			end
			local tStr2 = {
					{color=tmpcolor,text=formatCountToStr(Player:getPlayerInfo().nWood)},
					{color=_cc.blue,text=getConvertedStr(6, 10115)},
					{color=_cc.pwhite,text=formatCountToStr(nwoodcost)},
					
			}
			self.pLbMC:setString(tStr2, false)

		end
	end
end
--请求添加生产队列回调
function DlgAtelierProduce:addProduceItemCallBack( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then				
		if __msg.body then			
			if self._nFlag == 1 then--成功添加生产项
				TOAST(getConvertedStr(6, 10435))
			else--成功预约
				TOAST(getConvertedStr(6, 10436))
			end
			closeDlgByType(e_dlg_index.atelierproduce)	
		end			
	else	
		local tAtelierProduction = getAtelierProductionParam()
		if tAtelierProduction then
			local tCurCostInfo = tAtelierProduction[self._nCurSelectedQ]
			if tCurCostInfo then
				if self.tCostItemGroup[self._nCurCostItemIDx].tCurData.nCt < tCurCostInfo.num then
					TOAST(string.format(getConvertedStr(9,10146),self.tCostItemGroup[self._nCurCostItemIDx].tCurData.sName))
				else
					local nResID = nil
					if __msg.head.state == 233 then --银币不足
						nResID = e_resdata_ids.yb
					elseif __msg.head.state == 231 then--木材不足
						nResID = e_resdata_ids.mc
					elseif __msg.head.state == 232 then--粮草不足
						nResID = e_resdata_ids.lc
					elseif __msg.head.state == 230 then--铁矿不足			
						nResID = e_resdata_ids.bt
					else
						TOAST(SocketManager:getErrorStr(__msg.head.state))	
						return	
					end
					if nResID then
						if self and self.tResList then
							goToBuyRes(nResID,self.tResList)
						else
							goToBuyRes(nResID)
						end 
						
					end				
					
				end	
			end
		end
	end
end

function DlgAtelierProduce:refreshProduceTime(  )
	-- body
	--计时器
	local ntime = Player:getBuildData():getBuildById(e_build_ids.atelier):getProduceTime()
	local sStr = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10202)},
		{color=_cc.red, text=formatTimeToHms(ntime)},
	}
	self.pLbTimer:setString(sStr)	
end
--请求预计生产时间
function DlgAtelierProduce:rqProduceTime( nId )
	-- body
	if not nId then
		return
	end
	local itemid = nId 
	SocketManager:sendMsg("getProduceTime", {itemid}, handler(self, self.rqProduceTimeCallBack))
end

function DlgAtelierProduce:rqProduceTimeCallBack( __msg )
	-- body
	--dump(__msg.body)
	if __msg.head.state == SocketErrorType.success	then				
		if __msg.body then

		end			
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end	
end
return DlgAtelierProduce