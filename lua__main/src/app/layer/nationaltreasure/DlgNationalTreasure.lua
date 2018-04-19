-----------------------------------------------------
-- author: xiesite
-- updatetime:  2018-3-21 15:22:21
-- Description: 国家宝库
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
-- local LayerImperialWarTab = require("app.layer.nationaltreasure.LayerImperialWarTab")
-- local LayerTreasureTab = require("app.layer.nationaltreasure.LayerTreasureTab")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemTreasureGet = require("app.layer.nationaltreasure.ItemTreasureGet")
local ItemTreasureShow = require("app.layer.nationaltreasure.ItemTreasureShow")

local DlgNationalTreasure = class("DlgNationalTreasure", function()
	-- body
	return DlgBase.new(e_dlg_index.nationaltreasure)
end)

function DlgNationalTreasure:ctor(  )
	-- body
	self:myInit()
	parseView("lay_treasure_tab", handler(self, self.onParseViewCallback))
end

function DlgNationalTreasure:myInit(  )
	-- body
	--默认选择分页下标
	-- self.nCurIndex 	= 2
	-- self.tTabItems = {}
	-- self.nCurKey = nil
	--3个分页层
	-- self.tItemLays = {}
	-- self.classes = {LayerImperialWarTab, LayerTreasureTab}
 	-- self.tTitles = {getConvertedStr(1, 10389), getConvertedStr(1, 10390)}
end

--解析布局回调事件
function DlgNationalTreasure:onParseViewCallback( pView )
	--刷新数据
	SocketManager:sendMsg("asknationaltreasure", {},function() end)     
	-- body
	self:addContentView(pView) --加入内容层
	--设置标题
	self:setTitle(getConvertedStr(1, 10389))
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgNationalTreasure",handler(self, self.onDestroy))
end

--初始化控件
function DlgNationalTreasure:setupViews()
	-- self.pLyTab   = self:findViewByName("ly_list")
	-- self.pTabHost = FCommonTabHost.new(self.pLyTab,1,1,self.tTitles,handler(self, self.getLayerByKey), 1)
	-- self.pTabHost:setLayoutSize(self.pLyTab:getLayoutSize())
	-- self.pTabHost:removeLayTmp1()
	-- self.pTabHost:removeLayTmp2()
	-- self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
	-- self.pLyTab:addView(self.pTabHost,10)

	-- self.pTabHost:setDefaultIndex(self.nCurIndex)
 	self.pLyIcon = self:findViewByName("lay_icon") --图片层
 	self.pImgIcon =  self:findViewByName("img_icon") --图片层
 	self.pLbItems = self:findViewByName("lb_items") --物品提示

 	self.pLbDesc = self:findViewByName("lb_desc") --具体提示
 	self.pLyList2 = self:findViewByName("ly_list") --主公获得奖励列表
 	
 	self.pImgArrR = self:findViewByName("img_arr_r") --主公获得奖励列表
 	self.pImgArrR:setFlippedX(true)

 	self.pImgTitle = self:findViewByName("img_title") --图片标题

 	self.pLbTitle1 = self:findViewByName("lb_title_1") --说明1
	self.pLbTitle2 = self:findViewByName("lb_title_2") --说明2
	self.pLbTitle2:setString(getConvertedStr(1,10401))
	self.pLbTitle3 = self:findViewByName("lb_title_3") --说明3
 	
 	self.pLyList = self:findViewByName("ly_items") --物品列表
 	self.pLayBtn = self:findViewByName("lay_btn") --按钮层
 	
 	self.pImgBtn = self:findViewByName("img_btn")	--按钮
	self.pImgBtn:setViewTouched(true)
	self.pImgBtn:setIsPressedNeedScale(false)
	self.pImgBtn:onMViewClicked(handler(self, self.onClick))

 	self.pImgFonts = self:findViewByName("img_fonts") --按钮文字

 	self.pLayCost = self:findViewByName("lay_cost") --消费层
 	self.pLbJf = self:findViewByName("lb_jf")
 	local tResoueceData = getItemResourceData(20)
 	self.pLbJf:setString(tResoueceData.sName)
 	self.pLbJfCost = self:findViewByName("lb_jf_cost") --消耗积分
 	self.pLbYbCost = self:findViewByName("lb_yb_cost") --消耗元宝
 	
 	self:setBg()
end

function DlgNationalTreasure:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil	
	local tSize = self.pTabHost:getCurContentSize()
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = self.classes[1].new(tSize)	
		self.tItemLays[1] = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = self.classes[2].new(tSize)
		self.tItemLays[2] = pLayer
	end
	return pLayer
end

function DlgNationalTreasure:onTabChanged( _sKey, _nType )
	if _sKey == "tabhost_key_1" then
		self.tItemLays[1]:updateViews()
	elseif _sKey == "tabhost_key_2" then
		self.tItemLays[2]:updateViews()
	end
end


--设置默认打开分页
function DlgNationalTreasure:setDefOpenIndex(_index)
	self.pTabHost:setDefaultIndex(_index)
end

--控件刷新
function DlgNationalTreasure:updateViews(  )
	-- for k, v in pairs(self.tItemLays) do
	-- 	v:updateViews()
	-- end
 	local tData = Player:getNationalTreasureData()
 	if not tData then
 		return
 	end

	if not tData:isOpen() then
 		closeDlgByType(e_dlg_index.nationaltreasure, false)
 		return
 	end

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLyIcon,tData,cc.p(0,610))
	else
		self.pActTime:setCurData(tData)
	end

 	local nState = tData:getState()
    --	寻宝
 	if nState == TreasureType.xb then
 		local sItemStr = getEpangWarInitData("wabaoIcon")
 		local tItems = luaSplitMuilt(sItemStr,";")
 		self.tItems = {}
 		if tItems and #tItems >0 then
 			for i=1 , #tItems do
 				local item = {}
 				item.k = tonumber(tItems[i])
 				item.v = 1
 				table.insert(self.tItems, item)
 			end
 		end
 		sortGoodsList(self.tItems)
		self:setGoodsListViewData(getRewardItemsFromSever(self.tItems))

		local nNum = tData:getAwardNum()  --国家获得多少图纸
		self.pLbItems:setString(getTextColorByConfigure(string.format(getTipsByIndex(20147),getCountryName(Player:getPlayerInfo().nInfluence),nNum)),false)

		self.pLbDesc:setVisible(true)
		self.pLbDesc:setString(getTextColorByConfigure(getTipsByIndex(20148)),false)

		local nLeftNum = tData:getLeftNum()
		self.pLbTitle1:setString(string.format(getConvertedStr(1,10398), nLeftNum))
		self.pLbTitle3:setVisible(false)
		self:updateCostInfo()

		--已经用完次数
		if tData:isFinish() then
			self.pLayCost:setVisible(false)
			self.pLbTitle2:setVisible(true)
			self.pLayBtn:setVisible(false)
		else
			self.pLayCost:setVisible(true)
			self.pLbTitle2:setVisible(false)
			self.pLayBtn:setVisible(true)
			self.pImgTitle:setCurrentImage("#v2_fonts_huodongbaozang.png")
			self.pImgFonts:setCurrentImage("#v2_fonts_xunbao.png")
		end

		self.pLyList2:setVisible(false)
 	--	祝贺
 	elseif nState == TreasureType.zh then
 		self.pLyList2:setVisible(true)
 		local tNameList = tData:getNameList()
 		self:setTreasureNameListViewData(tNameList)

 		local tDropList = getDropById(51800)
 		self:setGoodsListViewData(tDropList)
 		self.pLbItems:setString(getTextColorByConfigure(getTipsByIndex(20149)), false)

 		self.pLbDesc:setVisible(false)
 		self.pLbTitle1:setString(getConvertedStr(1,10399))
 		self.pLbTitle3:setString(getConvertedStr(1,10400))
 		self.pLbTitle3:setVisible(true)
		self.pLayCost:setVisible(false)
		self.pLbTitle2:setVisible(false)

		self.pImgTitle:setCurrentImage("#v2_fonts_suijituzhi.png")
		self.pLayBtn:setVisible(true)
		--已经祝贺
		if tData:isCongratulate() then
			self.pImgFonts:setCurrentImage("#v2_fonts_yizhuhe.png")
			self.pImgBtn:setCurrentImage("#v2_btn_huodongjinsehui.png")
		else
			self.pImgFonts:setCurrentImage("#v2_fonts_zhuhe.png")
			self.pImgBtn:setCurrentImage("#v2_btn_huodongjinse.png")
		end
 	end
end

function DlgNationalTreasure:updateCostInfo()
 	local tData = Player:getNationalTreasureData()
 	if not tData then
 		return
 	end

	local nJf, nYb = tData:getCost()
	local nPoint = getMyGoodsCnt(e_type_resdata.royalscore)
	local nMoney = Player:getPlayerInfo().nMoney
	if nPoint >= nJf then
		self.pLbJfCost:setString(string.format(getConvertedStr(1,10418),nPoint).."/"..nJf)
	else
		self.pLbJfCost:setString(string.format(getConvertedStr(1,10416),nPoint).."/"..nJf)
	end 
	if nMoney >= nYb then
		self.pLbYbCost:setString(string.format(getConvertedStr(1,10418),nMoney).."/"..nYb)
	else
		self.pLbYbCost:setString(string.format(getConvertedStr(1,10416),nMoney).."/"..nYb)
	end
end

--列表项回调
function DlgNationalTreasure:onGoodsListViewCallBack( _index, _pView )
	-- body
	local tTempData = self.tDropList[_index]
    local pTempView = _pView
	if pTempView == nil then
		pTempView = ItemTreasureShow.new()
	end
 	local tData = Player:getNationalTreasureData()
 	if not tData then
 		return
 	end
 	pTempView:hideTips() 	
	pTempView:setCurData(tTempData) 
    return pTempView
end

--设置数据
-- tDropList:List<Pair<Integer,Long>>
function DlgNationalTreasure:setGoodsListViewData( tDropList )
	if not tDropList then
		return
	end
	self.tDropList = tDropList
	local nCurrCount = #self.tDropList
	--容错
	if not self.pListView then
		local pLayGoods = self.pLyList
		self.pListView = MUI.MListView.new {
		     	viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		        itemMargin = {left = 5,
		            right = 12,
		            top = 5,
		            bottom = 0},
		}
		pLayGoods:addView(self.pListView)
		centerInView(pLayGoods, self.pListView )
		self.pListView:setItemCallback(handler(self, self.onGoodsListViewCallBack))
		self.pListView:setItemCount(nCurrCount)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nCurrCount)
		local oldY = self.pListView.container:getPositionY()
		self.pListView:scrollTo(0, oldY, false)
	end
end


--列表项回调
function DlgNationalTreasure:onTreasureNameListViewCallBack( _index, _pView )
	-- body
	local tTempData = self.tNameList[_index]
    local pTempView = _pView
	if pTempView == nil then
		pTempView = ItemTreasureGet.new()--HADMORE
		
	end
	pTempView:setCurData(tTempData) 
    return pTempView
end

--设置数据
-- tDropList:List<Pair<Integer,Long>>
function DlgNationalTreasure:setTreasureNameListViewData( tNameList )
	if not tNameList then
		return
	end
	self.tNameList = tNameList
	local nCurrCount = #self.tNameList
	--容错
	if not self.pNameListView then
		local pLayGoods = self.pLyList2
		self.pNameListView = MUI.MListView.new {
		     	viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		        itemMargin = {left = 0,
		            right = 0,
		            top = 0,
		            bottom = 0},
		}
		pLayGoods:addView(self.pNameListView)
		centerInView(pLayGoods, self.pNameListView )
		self.pNameListView:setItemCallback(handler(self, self.onTreasureNameListViewCallBack))
		self.pNameListView:setItemCount(nCurrCount)
		self.pNameListView:reload(true)
	else
		self.pNameListView:notifyDataSetChange(true, nCurrCount)
		local oldY = self.pNameListView.container:getPositionY()
		self.pNameListView:scrollTo(0, oldY, false)
	end
end



function DlgNationalTreasure:onClick( )
	local tData = Player:getNationalTreasureData()
 	if not tData then
 		return
 	end

 	local nState = tData:getState()
 	if nState == TreasureType.xb then
 		--没用完
 		if not tData:isFinish() then
			local DlgAlert = require("app.common.dialog.DlgAlert")
		    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		    if(not pDlg) then
		        pDlg = DlgAlert.new(e_dlg_index.alert)
		    end
		    pDlg:setTitle(getConvertedStr(3, 10091))
		    local nJf, nYb = tData:getCost()
		    local sJf = nJf..getConvertedStr(1,10430)
		    local sYb = nYb..getConvertedStr(6,10103)
		    pDlg:setContent(string.format(getConvertedStr(1,10405),sJf,sYb))
		    pDlg:setRightHandler(function ()
				local nJf, nYb = tData:getCost()
				local nPoint = getMyGoodsCnt(e_type_resdata.royalscore)
				local nMoney = Player:getPlayerInfo().nMoney
				if nJf > nPoint then
					TOAST(getConvertedStr(1,10407))
					closeDlgByType(e_dlg_index.alert, false) 
					return
				end
				--黄金不足
				if nYb > nMoney then
					closeDlgByType(e_dlg_index.alert, false)
			        local pDlg_1, bNew_1 = getDlgByType(e_dlg_index.alert)
			        if(not pDlg_1) then
			            pDlg_1 = DlgAlert.new(e_dlg_index.alert)
			        end
			        pDlg_1:setTitle(getConvertedStr(3, 10091))
			        pDlg_1:setContent(getConvertedStr(6, 10081))
			        local btn = pDlg_1:getRightButton()
			        btn:updateBtnText(getConvertedStr(6, 10291))
			        btn:updateBtnType(TypeCommonBtn.L_YELLOW)
			        pDlg_1:setRightHandler(function (  )            
			            local tObject = {}
			            tObject.nType = e_dlg_index.dlgrecharge --dlg类型
			            sendMsg(ghd_show_dlg_by_type,tObject) 
			            closeDlgByType(e_dlg_index.alert)  
			        end)
			        pDlg_1:showDlg(bNew_1) 					
					return
				end
		    	SocketManager:sendMsg("nationaltreasure", {},function()  closeDlgByType(e_dlg_index.alert)  end)        
		        
		    end)
		    pDlg:showDlg(bNew)
 		end
 	elseif nState == TreasureType.zh then
 		--没有资格祝贺
 		if not tData:canCongratulate() then
 			TOAST(getConvertedStr(1, 10403))
 			return
 		end

 		if not tData:isCongratulate() then
 			SocketManager:sendMsg("treasurecongratu", {},function() end)
 		else
 			TOAST(getConvertedStr(1, 10404))
 		end
 	end
end

function DlgNationalTreasure:setBg( ) 
  if Player:getPlayerInfo().nInfluence == e_type_country.wuguo then--玩家所在国家
  		self.pImgIcon:setCurrentImage("ui/big_img_sep/v2_bg_xunfangbaozang_xingyu.jpg")

  elseif Player:getPlayerInfo().nInfluence == e_type_country.shuguo then
  		self.pImgIcon:setCurrentImage("ui/big_img_sep/v2_bg_xunfangbaozang_liubang.jpg")

  elseif Player:getPlayerInfo().nInfluence == e_type_country.weiguo then
  		self.pImgIcon:setCurrentImage("ui/big_img_sep/v2_bg_xunfangbaozang_yingzheng.jpg")
  end
end


--析构方法
function DlgNationalTreasure:onDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgNationalTreasure:regMsgs(  )
 	regMsg(self, ghd_national_treasure_update, handler(self, self.updateViews))
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateCostInfo))
end
--注销消息
function DlgNationalTreasure:unregMsgs( )
 	unregMsg(self, ghd_national_treasure_update)
	unregMsg(self, gud_refresh_playerinfo)
end

--暂停方法
function DlgNationalTreasure:onPause( )
	-- body		
	self:unregMsgs()	

end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgNationalTreasure:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	self:updateViews()
end

return DlgNationalTreasure