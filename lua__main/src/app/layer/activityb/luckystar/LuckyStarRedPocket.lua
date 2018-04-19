----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-26 10:34:57
-- Description: 福星高照（开红包）
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")

local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local LuckyStarRedPocket = class("LuckyStarRedPocket", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function LuckyStarRedPocket:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lucky_star_red_pocket", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LuckyStarRedPocket:onParseViewCallback( pView )
	-- self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:myInit()
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LuckyStarRedPocket", handler(self, self.onLuckyStarRedPocketDestroy))

end

function LuckyStarRedPocket:myInit(  )
	-- body
	self.tRewardData = {}
	self.tRewardRockAction = {}
	self.tRewardParitcle = {}
	self.tRewardGotImg = {}
end

-- 析构方法
function LuckyStarRedPocket:onLuckyStarRedPocketDestroy(  )
    self:onPause()
end

function LuckyStarRedPocket:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function LuckyStarRedPocket:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function LuckyStarRedPocket:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function LuckyStarRedPocket:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)--停止计时刷新
end

function LuckyStarRedPocket:setupViews(  )
	self.pLbTime = self:findViewByName("txt_time")
	self.pTxtOpenNum = self:findViewByName("lay_open_num")
	self.pLayBg = self:findViewByName("lay_bg")

	self.pLayBarBg2 = self:findViewByName("lay_bar2")

	self.pTxtPoint = self:findViewByName("txt_point")
	self.pTxtDesc = self:findViewByName("txt_desc")

	self.pImgBtnOne = self:findViewByName("img_btn_one")
	self.pImgBtnOne:setViewTouched(true)
	self.pImgBtnOne:setIsPressedNeedColor(false)
	self.pImgBtnOne:onMViewClicked(handler(self, self.onOpenOneClicked))
	self.pImgBtnServeral = self:findViewByName("img_btn_serveral")
	self.pImgBtnServeral:setViewTouched(true)
	self.pImgBtnServeral:setIsPressedNeedColor(false)
	self.pImgBtnServeral:onMViewClicked(handler(self, self.onOpenServeralClicked))

	self.pTxtRight = self:findViewByName("txt_right")

	self.tItemSlot ={}
	self.tTxtNums ={}

	self.tTxtPostPer = {}  --数字的位置在bar的长度里占的比例
	for i=1,5 do
		local pTxt = self:findViewByName("txt_item_num"..i)
		local pSlot=self:findViewByName("lay_slot"..i)
		local tTemp ={pTxtNum = pTxt , pSlot = pSlot }
		table.insert(self.tItemSlot,tTemp)
		local pTxtNum=self:findViewByName("txt_num"..i)
		table.insert(self.tTxtNums,pTxtNum)
		local nPer = pTxtNum:getPositionX() / 520
		table.insert(self.tTxtPostPer,nPer)

	end

	--右上角加号
	self.pImgAdd = self:findViewByName("img_add")
	self.pImgAdd:setViewTouched(true)
	self.pImgAdd:setIsPressedNeedScale(false)
	self.pImgAdd:onMViewClicked(handler(self, self.onAddClicked))

	self.pLayRight = self:findViewByName("lay_right")
	self.pLayRight:setViewTouched(true)
	self.pLayRight:setIsPressedNeedScale(false)
	self.pLayRight:onMViewClicked(handler(self, self.onAddClicked))



	self.pLayBar = self:findViewByName("lay_bar")--进度条层

	self.pProgressBar = MCommonProgressBar.new({bar = "v2_bar_yellow_fuxinggaozhao.png",barWidth = 520, barHeight = 20})
	self.pLayBarBg2:addView(self.pProgressBar)
	centerInView(self.pLayBarBg2, self.pProgressBar)	
	self.pProgressBar:setPositionY(self.pProgressBar:getPositionY() + 2)

	self:initTickAndBox()
	regUpdateControl(self,handler(self,self.updateCd))
end

function LuckyStarRedPocket:updateViews(  )
	local tActData=Player:getActById(e_id_activity.luckystar)
	if not tActData then
		return
	end
	-- --积分刷新
	local nCurDp = tActData.nOc
	local nPrevProcess = 0
	local nNextProcess = 0
	local nNeedPoint = 0
	local nPoint1   = 0 		--超出当前进度的数量
	local nPer = 0
	local nIndex = 0
	local nAllMaxScore =self.tRewardData[table.nums(self.tRewardData)].point
	for i = 1,#self.tRewardData do

		if nCurDp >= self.tRewardData[i].point then
			nIndex = i
		end
	end
	if nIndex >= #self.tRewardData then
		nPer = 100
	elseif nIndex == 0 then
		nPrevProcess = 0
		nNextProcess = self.tTxtPostPer[1]

		nNeedPoint = self.tRewardData[1].point
		nPoint1 = nCurDp
	else
		nPrevProcess = self.tTxtPostPer[nIndex]
		nNextProcess = self.tTxtPostPer[nIndex+1]
		nNeedPoint = self.tRewardData[nIndex + 1].point - self.tRewardData[nIndex].point
		nPoint1 = nCurDp - self.tRewardData[nIndex].point

	end
	if nPer == 0 then
		nPer =((nPoint1/nNeedPoint) * (nNextProcess - nPrevProcess) + nPrevProcess )* 100
	end
	self.pProgressBar:setPercent(nPer)
	
	for i = 1,#self.tRewardData do
		local pTempView = self.tItemSlot[i].pSlot:findViewByName("iconImg")
		if pTempView then
			self:setRewardState(i,pTempView, self.tItemSlot[i].pSlot)
		end
	end
	

	
	local tItemData=Player:getBagInfo():getItemDataById(100178)
	local nNum = 0
	if tItemData and tItemData.nCt > 0 then
		nNum = tItemData.nCt
	end
	self.pTxtRight:setString(tostring(nNum))
	local tStr = string.format(getConvertedStr(9,10132),tActData.nF)
	self.pTxtPoint:setString(tStr)

	local tStr2 = getTextColorByConfigure(string.format(getConvertedStr(9,10133),tActData.nOc))
	self.pTxtOpenNum:setString(tStr2)

	self.pTxtDesc:setString(tActData.sDesc)


end

function LuckyStarRedPocket:initTickAndBox(  )
	-- body
	local tActData=Player:getActById(e_id_activity.luckystar)
	if not tActData then
		return
	end

	local tL1 =luaSplit(tActData.sOa ,"|")
	self.tRewardData = {}
	for i=1, #tL1 do
		local tData={}
		local tTemp1 = luaSplit(tL1[i],"-")
		if tTemp1 and #tTemp1 == 2 then
			tData.point=tonumber(tTemp1[1])
			local tTemp2 = luaSplit(tTemp1[2],":")
			tData.k = tTemp2[1]
			tData.v = tTemp2[2]
		end
		table.insert(self.tRewardData,tData)

	end
	local nTWidth = 520
	local nSY = self.pLayBar:getHeight()/2 + 2
	
	for k, v in pairs(self.tRewardData) do

		local pTxtNum = self.tTxtNums[k]
		local nX =pTxtNum:getPositionX() 
		local nTickY =pTxtNum:getPositionY() + 15

		--刻度线
		if k <  table.nums(self.tRewardData) then--
			local pImg = MUI.MImage.new("#v1_line_blue2.png", {scale9 = true,capInsets=cc.rect(1,5, 1, 1)})
			pImg:setLayoutSize(2, 28)

			pImg:setPosition(nX, nTickY)
			self.pLayBarBg2:addView(pImg, 9)	
		end

	    pTxtNum:setString("("..v.point..")")
	    local pItemData = getGoodsByTidFromDB(v.k)
	    local pTempView = IconGoods.new(TypeIconGoods.NORMAL)
	    pTempView:setAnchorPoint(0.5,0.5)
	    self:setRewardState(k,pTempView, self.tItemSlot[k].pSlot)
	   
	    local pItemNum = self.tItemSlot[k].pTxtNum
	    pItemNum:setString("X"..tostring(v.v))
        pTempView:setScale(0.7)
        pTempView:setCurData(pItemData)
        pTempView:removeIconBg()
        pTempView:setName("iconImg")
        pTempView:setPosition(self.tItemSlot[k].pSlot:getWidth()/2,self.tItemSlot[k].pSlot:getHeight()/2 )
        -- centerInView(self.tItemSlot[k].pSlot)
        self.tItemSlot[k].pSlot:addView(pTempView)

	end
end
--pView --icongoods ,
function LuckyStarRedPocket:setRewardState(_nIndex,_pView,_pParent)
	local tActData=Player:getActById(e_id_activity.luckystar)
	if not tActData then
		return
	end
	local tData = self.tRewardData[_nIndex]
	if tActData:getRewardState(tData.point) == 2 then   --可领取
	    showRockTx2(_pView)
	    self:addRewardAction(_nIndex,_pParent,_pView.tCurData)
	    _pView:setIconClickedCallBack(function (  )
	    	-- body
	    	SocketManager:sendMsg("getLuckStarReward", {tData.point},handler(self,self.onOpenRedPocketCallback))
	    	_pView:setIconClickedCallBack(nil)
	    	self:stopRockAction(_nIndex,_pView)
	    	self:addRewardGot(_nIndex,_pParent,_pView)
	    end)
	elseif tActData:getRewardState(tData.point) == 3 then 		--已领取
	    self:addRewardGot(_nIndex,_pParent,_pView)
	end

end

function LuckyStarRedPocket:addRewardAction( _nIndex ,_parent,_tCurData)
	-- body
	if not self.tRewardRockAction[_nIndex] then
		if _tCurData then
			local pItem = MUI.MImage.new(_tCurData.sIcon)
			_parent:addView(pItem, 51)
			centerInView(_parent,pItem)
			pItem:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pItem:setOpacity(255*0.3)
			pItem:setScale(0.7)
			showRockTx2(pItem)
			self.tRewardRockAction[_nIndex]=pItem
		end
	end
	--粒子效果
	if not self.tRewardParitcle[_nIndex] then

		local pParitcleD = createParitcle("tx/other/lizi_zjmhdbx_zjm_01.plist")
		pParitcleD:setPosition(_parent:getWidth() / 2 ,_parent:getHeight() / 2)
		_parent:addView(pParitcleD, 99)
		centerInView(_parent,pParitcleD)
		self.tRewardParitcle[_nIndex] = pParitcleD
	end
end
--停止摇摆动作
function LuckyStarRedPocket:stopRockAction( _nIndex,_pView )
	-- body
	_pView:stopAllActions()
	_pView:setRotation(0)
	if self.tRewardRockAction[_nIndex] then
		self.tRewardRockAction[_nIndex]:stopAllActions()
		self.tRewardRockAction[_nIndex]:removeSelf()
		self.tRewardRockAction[_nIndex] = nil
	end

	if self.tRewardParitcle[_nIndex] then
		self.tRewardParitcle[_nIndex]:removeSelf()
		self.tRewardParitcle[_nIndex]=nil
	end
	
end
function LuckyStarRedPocket:addRewardGot( _nIndex,_parent ,_pGrayView)
	-- body
	if not self.tRewardGotImg[_nIndex] then

		local pItem = MUI.MImage.new("#v2_fonts_yilingqu.png")
		_parent:addView(pItem, 51)
		centerInView(_parent,pItem)
		pItem:setScale(0.8)
		self.tRewardGotImg[_nIndex]=pItem
		_pGrayView:setToGray(true)
	end


end
--时间更新函数
function LuckyStarRedPocket:updateCd()
	local tActData = Player:getActById(e_id_activity.luckystar)
	if not tActData then
		return
	end
	local sTime = tActData:getRemainTime2()
	self.pLbTime:setString(sTime)
end

function LuckyStarRedPocket:onOpenOneClicked(  )
	-- -- body
	local tItemData=Player:getBagInfo():getItemDataById(100178)
	local nNum = 0
	if tItemData and tItemData.nCt > 0 then
		nNum = 0
	else
		nNum = 1
	end
	if nNum == 1 then
		local tItemData = getGoodsByTidFromDB(100178)
		local tActData=Player:getActById(e_id_activity.luckystar)
		if not tActData then
			return
		end
		local nCostMoney = tActData.nRg --需要消耗的黄金
		local strTips = {
		    {color=_cc.pwhite, text = string.format(getConvertedStr(7, 10273), tItemData.sName)},
		    {color=_cc.yellow, text = nCostMoney..getConvertedStr(7, 10036)},
		    {color=_cc.pwhite, text = string.format(getConvertedStr(9, 10143), 1, tItemData.sName)},
		}
		--展示购买对话框
		showBuyDlg(strTips, nCostMoney,function (  )
			SocketManager:sendMsg("luckyStarOpenOne",{nNum},handler(self,self.onOpenRedPocketCallback))
		end, 1, true)
	else
		SocketManager:sendMsg("luckyStarOpenOne", {nNum},handler(self,self.onOpenRedPocketCallback))
	end

end


function LuckyStarRedPocket:onOpenServeralClicked(  )
	local tObject = {} 
	tObject.nType = e_dlg_index.dlgluckystaropenall --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
	
end

function LuckyStarRedPocket:onOpenRedPocketCallback( __msg )
	-- body
	if  __msg.head.state == SocketErrorType.success then
		if __msg.body and __msg.body.o then
			--奖励领取表现(包含有武将的情况走获得武将流程)
			if __msg.head.type == MsgType.getLuckStarReward.id or __msg.head.type == MsgType.buyLuckStarRedPocket.id then
				showGetItemsAction(__msg.body.o)	
			else
				self:showGetReward(__msg.body)	
			end
			
			
		end
		local tActData = Player:getActById(e_id_activity.luckystar)
		tActData:refreshDatasByServer(__msg.body)
		sendMsg(gud_refresh_activity)
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end

end


--展示获得英雄
function LuckyStarRedPocket:showGetReward(_tData)
	
	if not _tData then
		return
	end
	local nLuckyPoint = 0
	local tTemp = {}
	for k,v in pairs(_tData.o) do
		if v.k == e_type_resdata.luckypoint then
			nLuckyPoint = nLuckyPoint + v.v
		end
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
	local tRBtnData = {}
	tRBtnData.nBtnType = TypeCommonBtn.L_BLUE
	tRBtnData.sBtnStr =getConvertedStr(1, 10059)
	-- tRBtnData.nClickedFunc = function (  )
	-- 	-- body
	-- 	closeDlgByType(e_dlg_index.showheromansion, false)
	-- end
	local tLabel = {
		{getConvertedStr(9, 10144), getC3B(_cc.white)},
		{tostring(nLuckyPoint), getC3B(_cc.green)},
	}
	local tConTable = {}

	tConTable.tLabel=tLabel
	tRBtnData.tConTable=tConTable
	
	tRBtnData.bIsEnable = true


	--打开获得物品对话框对话框
    local tObject = {}
    tObject.nType = e_dlg_index.showheromansion --dlg类型
    tObject.tReward = tDataList
    tObject.tRBtnData = tRBtnData
    tObject.sBottomTip = getConvertedStr(9,10101)
    tObject.bHideGo = true
    sendMsg(ghd_show_dlg_by_type,tObject)
end

--购买消耗道具
function LuckyStarRedPocket:onAddClicked()
	local tActData=Player:getActById(e_id_activity.luckystar)
	if not tActData then
		return
	end
	local nCostMoney = tActData.nRg --需要消耗的黄金
	local tCost = {k = e_resdata_ids.ybao,v=nCostMoney}
    local tObject = {}
	tObject.nType = e_dlg_index.buystuff --dlg类型
	tObject.nItemId = 100178
	tObject.tCost = tCost
	tObject.tHandler = handler(self,self.reqBuyRedPocket)
	sendMsg(ghd_show_dlg_by_type, tObject)
end

function LuckyStarRedPocket:reqBuyRedPocket( _nNum )
	-- body
	SocketManager:sendMsg("buyLuckStarRedPocket",{_nNum},handler(self,self.onOpenRedPocketCallback))
end

return LuckyStarRedPocket



