-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-24 15:12:23 星期一
-- Description: 背包界面的普通页面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemInfo = require("app.module.ItemInfo")

local BagNormalLayer = class("BagNormalLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function BagNormalLayer:ctor(_itemType, _tSize)

	self:setContentSize(_tSize)
	self:myInit(_itemType)

	--注册析构方法
	self:setDestroyHandler("BagNormalLayer",handler(self, self.onBagNormalLayerDestroy))
	
end

--初始化参数
function BagNormalLayer:myInit(_itemType)
	-- body
	self.nItemType = _itemType or e_item_types.consum --物品类型1-消耗品，2-材料 3-其他
	self.pData = {} --物品数据	

	
	self:setupViews()
	self:updateViews()
end

--初始化控件
function BagNormalLayer:setupViews( )
	-- body	
	--root层
end

-- 修改控件内容或者是刷新控件数据
function BagNormalLayer:updateViews(  )
	-- body
	--根据物品类型获取物品列表
	local titemdatas = Player:getBagInfo():getItemsByType(self.nItemType)
	--dump(titemdatas, "titemdatas", 100)
	self:setCurData(titemdatas)
	-- body
	local pSize = self:getContentSize()
	if not self.pListView then
		self.pListView = MUI.MListView.new {
	    	bgColor = cc.c4b(255, 255, 255, 250),
	    	viewRect = cc.rect(20, 0, 600, pSize.height - 10),
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
		self:addView(self.pListView, 10)
		centerInView(self, self.pListView)	
		self.pListView:setItemCount(#self.pData)
		self.pListView:reload(true)  
	else		
		self.pListView:notifyDataSetChange(true, #self.pData)
	end	
end

--析构方法
function BagNormalLayer:onBagNormalLayerDestroy(  )
	-- body	
end

--设置数据 _data itemlist
function BagNormalLayer:setCurData(_data)
	if _data and #_data > 0 then
		self.pData = _data
	else
		self.pData = {}
	end	
end

--获取物品列表数据
function BagNormalLayer:getData()
	return self.pData
end

--打开上阵英雄界面
function BagNormalLayer:openLineHeroLayer()
	--打开对话框
    local tObject = {}
    tObject.nType = e_dlg_index.dlgherolineup --dlg类型
    sendMsg(ghd_show_dlg_by_type,tObject)
end

--
function BagNormalLayer:onListViewItemCallBack(  _index, _pView  )
		-- body	
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemInfo.new(TypeItemInfoSize.L)                        
        pTempView:setViewTouched(false)
        pTempView:setClickCallBack(handler(self, function (pview, tData)
        	if tData.sTid == e_id_item.dalaba then
				local DlgWorldLaba = require("app.layer.chat.DlgWorldLaba")
			    local pDlg, bNew = getDlgByType(nDlgType)
			    if not pDlg then
			    	pDlg = DlgWorldLaba.new()
			    end
			    pDlg:showDlg(bNew)	
			elseif tData.sTid == e_id_item.expItemS  then
				self:openLineHeroLayer()
			elseif tData.sTid == e_id_item.expItemM  then
				self:openLineHeroLayer()
			elseif tData.sTid == e_id_item.expItemB  then
				self:openLineHeroLayer()
			elseif tData.sTid == e_item_ids.gmt then
				local tObject = {}
				tObject.nType = e_dlg_index.rename --dlg类型
				sendMsg(ghd_show_dlg_by_type,tObject)	
			elseif tData.sTid == e_id_item.sjqc then--使用随机迁城
				local nIndex = 0
				local nX, nY = Player:getWorldData():getMyCityDotPos() --玩家城池的坐标刷新				
				local nBlockId = WorldFunc.getBlockId(nX, nY)
				SocketManager:sendMsg("reqWorldMigrate", {nIndex, nBlockId, nX, nY, 0})
			elseif tData.sTid == e_id_item.bossCallL or tData.sTid == e_id_item.bossCallH 
			or tData.sTid == e_id_item.bossCallS then --Boss召唤物
				sendMsg(ghd_world_dot_near_my_city, {nDotType = e_type_builddot.null, bIsClicked = true,nJumpType=e_jumpto_world_type.activity})
   				closeDlgByType(e_dlg_index.bag, false)
   			elseif tData.sTid == e_id_item.bossToken then --Boss信物
   				local tObject = {}
		    	tObject.nType = e_dlg_index.wuwang --dlg类型
		    	tObject.nTabIndex = 3
		    	sendMsg(ghd_show_dlg_by_type,tObject)
   				closeDlgByType(e_dlg_index.bag, false)
   			elseif isRedPocket(tData.sTid) then
				local tObject = {}
		    	tObject.nType = e_dlg_index.dlgredpocketsend --dlg类型
		    	tObject.nRedPocket = tData.sTid
		    	sendMsg(ghd_show_dlg_by_type,tObject)
		   	--如是可兑换物品(如银币兑换券、弓兵购买符..等有配置兑换id的物品, 点击使用购买)
		    elseif tData.nExchange then
		    	--获取商店数据
		    	local tShopBase = getShopBaseData(tData.nExchange)
		    	local tObject = {
				    nType = e_dlg_index.shopbatchbuy, --dlg类型
				    tShopBase = tShopBase
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
			elseif tData.sTid == e_id_item.zwpiece  then--纣王碎片
				if tData.nCt > 0 then
					local tObject = {}
			    	tObject.nType = e_dlg_index.dlgusefragments --dlg类型
			    	sendMsg(ghd_show_dlg_by_type,tObject)				
				end
			elseif tData.sTid == e_id_item.arenaToken  then--竞技场挑战令
				ShowDlgUseArenatToken()
    		else
    			
    			if tData.sDropId ~= 0 then
    				local tDropData = getDropById(tData.sDropId)
    				if tDropData and #tDropData == 1 then
    					if tDropData[1].nId == e_resdata_ids.yb 
				        	or tDropData[1].nId == e_resdata_ids.bt
				        	or tDropData[1].nId == e_resdata_ids.mc
				        	or tDropData[1].nId == e_resdata_ids.lc  then
				        	showUseItemDlg(tData.sTid,nil,tDropData[1].nId)    	-- body
				        end
				    else
    					showUseItemDlg(tData.sTid)    	-- body	

    				end
    			else
    				showUseItemDlg(tData.sTid)    	-- body	
    			end	
	        end	        
        end))	
    end
    local tItemData = self.pData[_index]
    pTempView:setCurData(tItemData)
    pTempView:setIsIconCanTouched(true)
    pTempView:changeExToHad()
    pTempView:setIconNew()
	if tItemData.nCanUse == 1 then		
		pTempView.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		pTempView.pBtn:updateBtnText(getConvertedStr(6, 10128))
		pTempView:setBtnVisible(true)			
	else
		if tItemData.sSell then
			pTempView.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			pTempView.pBtn:updateBtnText(getConvertedStr(6, 10138))
			pTempView:setBtnVisible(true)
		else
			pTempView:setBtnVisible(false)
		end
	end
    return pTempView
end
--获取当前物品数量
function BagNormalLayer:getItemCnt(  )
	-- body
	local nCnt = 0
	if self.pListView then
		nCnt = self.pListView:getItemCount()
	end
	return nCnt
end
return BagNormalLayer
