-- Author: maheng
-- Date: 2018-03-15 21:5:24
-- 纣王碎片使用提示


local DlgAlert = require("app.common.dialog.DlgAlert")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgUseFragments = class("DlgUseFragments", function ()
	return DlgAlert.new(e_dlg_index.dlgusefragments)
end)

--构造
function DlgUseFragments:ctor()
	-- body
	self:myInit()	
	parseView("dlg_use_fragments", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgUseFragments:myInit()
	-- body

end
  
--解析布局回调事件
function DlgUseFragments:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgUseFragments",handler(self, self.onDestroy))
end

--初始化控件
function DlgUseFragments:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6, 10079))
	self.pLayIcon 		= 		self:findViewByName("lay_icon")
	self.pLbTip 		= 		self:findViewByName("lb_tip")
	self.pLeftBtn = self:getLeftButton()
	self.pRightBtn = self:getRightButton()

	self.pLbTip:setString(getTextColorByConfigure(getTipsByIndex(20141)))

	self:setLeftBtnText(getConvertedStr(6, 10787))
	self:setLeftBtnType(TypeCommonBtn.L_BLUE)
	self:setLeftHandler(handler(self, self.onExChangeItem))
	self:setRightDisabledHandler(function (  )
		-- body
		TOAST(getTipsByIndex(750))
	end)

	-- local tBtnTable = {}
	-- --文本
	-- tBtnTable.tLabel = {
	-- 	{getConvertedStr(6, 10789), getC3B(_cc.pwhite)},
	-- }	
	-- tBtnTable.awayH = -15
	-- self.pLeftBtn:setBtnExText(tBtnTable, false)

	self:setRightBtnText(getConvertedStr(6, 10788))
	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	self:setRightHandler(handler(self, self.onMakeHero))

	local tBtnTable = {}
	tBtnTable.img = "#v2_img_i100214.png"
	--文本
	tBtnTable.tLabel = {
		{"",getC3B(_cc.green)},
		{"/",getC3B(_cc.pwhite)},
		{"",getC3B(_cc.white)},
	}	
	tBtnTable.awayH = -15
	self.pRightBtn:setBtnExText(tBtnTable, false)
end

-- 修改控件内容或者是刷新控件数据
function DlgUseFragments:updateViews()

	local pItem = Player:getBagInfo():getItemDataById(e_id_item.zwpiece) 
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, pItem)
	else
		self.pIcon:setCurData(pItem)
	end
	self.pRightBtn:setExTextLbCnCr(1, pItem.nCt)
	local sNeed = tostring(getGlobleParam("zhouwangDebris")	or "")
	self.pRightBtn:setExTextLbCnCr(3, sNeed)
	local tData =Player:getHeroInfo():getHeroByKey(200641)
	self.pRightBtn:setBtnEnable(tData == nil)
end

--兑换道具
function DlgUseFragments:onExChangeItem(_pView)
	-- body
	print("兑换道具")
	local pItem1 = getGoodsByTidFromDB(e_id_item.zwpiece)
	-- dump(pItem1, "pItem1", 100)
	local tDrop = getDropById(pItem1.sDropId)
	pItem2 = tDrop[1]
	-- dump(pItem2, "pItem2", 100)	
	local sStr = string.format(getTipsByIndex(20140), pItem1.sName, pItem2.sName)
	showDlgUseStuffByTip(pItem1.sTid, getTextColorByConfigure(sStr))		
end

--合成武将
function DlgUseFragments:onMakeHero(_pView)
	-- body
	print("合成武将")
	local makeHero = function ( _nCnt )
		-- body
		SocketManager:sendMsg("makeHerobyZhowwangPiece", {_nCnt}, handler(self, self.onResponse))	
	end
	local nNeed = tonumber(getGlobleParam("zhouwangDebris")	or 0)
	local pItem = Player:getBagInfo():getItemDataById(e_id_item.zwpiece) 
    local nBuy = nNeed - pItem.nCt    
    local nCost = nBuy*pItem.nPrice
	if pItem.nCt < nNeed then			
	    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(7, 10034))

	    pDlg:setContent(getTextColorByConfigure(string.format(getTipsByIndex(20142), nCost, nBuy)))
		pDlg:setRightHandler(function (  )    
			if getIsResourceEnough(e_type_resdata.money, nCost)	then
		 		makeHero(nBuy)
		        closeDlgByType(e_dlg_index.alert, false)  
			else
		        local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		        if(not pDlg) then
		            pDlg = DlgAlert.new(e_dlg_index.alert)
		        end
		        pDlg:setTitle(getConvertedStr(3, 10091))
		        pDlg:setContent(getConvertedStr(6, 10081))
		        local btn = pDlg:getRightButton()
		        btn:updateBtnText(getConvertedStr(6, 10291))
		        btn:updateBtnType(TypeCommonBtn.L_YELLOW)
		        pDlg:setRightHandler(function (  )            
		            local tObject = {}
		            tObject.nType = e_dlg_index.dlgrecharge --dlg类型
		            sendMsg(ghd_show_dlg_by_type,tObject) 
		            closeDlgByType(e_dlg_index.alert)  
		        end)
		        pDlg:showDlg(bNew)   		
		    end				 	       
	    end)
	    pDlg:showDlg(bNew)
	else
		makeHero(0)
	end    
    
end

function DlgUseFragments:onResponse( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then		
		closeDlgByType(e_dlg_index.dlgusefragments)		
		--奖励
		if __msg.body.o and #__msg.body.o > 0 then
            --奖励动画展示	
			local tHero = nil
			for k, v in pairs(__msg.body.o) do
				if v.k >= 200001 and v.k <= 299999 then
					tHero = copyTab(v)
					break
				end
			end
			if tHero then
				local tDataList = {}
				local tReward = {}
				tReward.d = {}
				tReward.g = {}
				table.insert(tReward.d, copyTab(tHero))
				table.insert(tReward.g, copyTab(tHero))
				table.insert(tDataList, tReward)

				--dump(tDataList, "tDataList", 100)
				--打开招募展示英雄对话框
			    local tObject = {}
			    tObject.nType = e_dlg_index.showheromansion --dlg类型
			    tObject.tReward = tDataList
			    tObject.nHandler = handler(self, function ( ... )
			    	-- body
			    	showGetAllItems(__msg.body.o, 1)
			    end)
			    sendMsg(ghd_show_dlg_by_type,tObject)
			else
				--播放获得物品
				showGetAllItems(__msg.body.o)
			end
		else
			TOAST(getConvertedStr(1, 10167))
		end
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end	
end

--析构方法
function DlgUseFragments:onDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgUseFragments:regMsgs( )
	-- body
	--注册刷新背包消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))	
end

-- 注销消息
function DlgUseFragments:unregMsgs(  )
	-- body
	--注销刷新背包消息
	unregMsg(self, gud_refresh_baginfo)		
end


--暂停方法
function DlgUseFragments:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgUseFragments:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgUseFragments
