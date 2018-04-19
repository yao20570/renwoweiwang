----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 09:52:00
-- Description: 乱军详情界面
-----------------------------------------------------

-- 乱军详情界面
local DlgCommon = require("app.common.dialog.DlgCommon")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemActBtn = require("app.layer.activitymodel.ItemActBtn")
local SysCityCollections = require("app.layer.world.SysCityCollections")

local nGoodsCol = 4

local DlgWildArmyDetail = class("DlgWildArmyDetail", function()
	return DlgCommon.new(e_dlg_index.wildarmy, 706-130,130)--650 - 60 - 130, 130)
end)

function DlgWildArmyDetail:ctor(  )
	parseView("dlg_wild_army_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWildArmyDetail:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView, false) --加入内容层

	self:setTitle(getConvertedStr(3, 10013))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWildArmyDetail",handler(self, self.onDlgWildArmyDetailDestroy))
end

-- 析构方法
function DlgWildArmyDetail:onDlgWildArmyDetailDestroy(  )
    self:onPause()
end

function DlgWildArmyDetail:regMsgs(  )
end

function DlgWildArmyDetail:unregMsgs(  )
end

function DlgWildArmyDetail:onResume(  )
	self:regMsgs()
end

function DlgWildArmyDetail:onPause(  )
	self:unregMsgs()
end

function DlgWildArmyDetail:setupViews(  )
	--ui位置更新
	local tUiPos = {
		{sUiName = "lay_info", nTopSpac = 12},
		{sUiName = "lay_space", nTopSpac = 10},
		{sUiName = "lay_goods", nTopSpac = 0},
		{sUiName = "lay_btn_attack", nBottomSpac = 20},
	}
	restUiPosByData(tUiPos, self.pView)
	--ui位置更新

	local pLayInfo = self:findViewByName("lay_info")
	setGradientBackground(pLayInfo)
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtPos = self:findViewByName("txt_pos")
	self.pTxtMoveTime = self:findViewByName("txt_move_time")
	setTextCCColor(self.pTxtMoveTime, _cc.green)
	local pTxtSpaceTip = self:findViewByName("txt_space_tip")
	pTxtSpaceTip:setString(getConvertedStr(3, 10125))
	self.pTxtTip = self:findViewByName("txt_tip")
	setTextCCColor(self.pTxtTip, _cc.red)

	-- local pLayBtnCancel = self:findViewByName("lay_btn_cancel")
	-- local pBtnCancel = getCommonButtonOfContainer(pLayBtnCancel,TypeCommonBtn.L_RED)
	-- pBtnCancel:onCommonBtnClicked(handler(self, self.onBtnCancelClicked))
	-- pBtnCancel:updateBtnText(getConvertedStr(3, 10015))

	local pLayBtnAttack = self:findViewByName("lay_btn_attack")
	self.pBtnAttack = getCommonButtonOfContainer(pLayBtnAttack,TypeCommonBtn.L_BLUE)
	self.pBtnAttack:onCommonBtnClicked(handler(self, self.onBtnAttackClicked))
	self.pBtnAttack:updateBtnText(getConvertedStr(3, 10016))

	local nArmyLimit = getWorldInitData("armyLimit")
	local nKilledNum = Player:getWorldData():getKilledWildArmyNum()
	local tBtnTable = {}
	local tLabel = {
		{getConvertedStr(7,10303), getC3B(_cc.white)}, --今日已攻打乱军: 
		{nKilledNum, getC3B(_cc.blue)},
		{"/", getC3B(_cc.white)},
		{nArmyLimit, getC3B(_cc.white)}
	}
	tBtnTable.tLabel = tLabel
	self.pBtnExText = self.pBtnAttack:setBtnExText(tBtnTable)

	-- local pLayGoods = self:findViewByName("lay_goods")
	-- self.pListView = MUI.MListView.new {
	-- 	viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, 148),
	-- 	direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
	-- 	itemMargin = {left =  5,
 --             right =  5,
 --             top =  5,
 --             bottom =  5},
 --    }
 --    pLayGoods:addView(self.pListView)
 --    centerInView(pLayGoods, self.pListView )

 	self.pLayRewards = self:findViewByName("lay_goods")
	self.pListView = MUI.MListView.new {
	    viewRect   = cc.rect(0, 0, self.pLayRewards:getContentSize().width, self.pLayRewards:getContentSize().height),
	    direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	    itemMargin = {left =  0,
	        right =  0,
	        top =  5,
	        bottom =  5},
	}
	self.pLayRewards:addView(self.pListView)
	self.pListView:setItemCount(0) 
	self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))

    self.tDropList = {}

    --添加活动便签
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
--列表回调
function DlgWildArmyDetail:onListViewItemCallBack( _index, _pView)
    local pTempView = _pView
    if pTempView == nil then
        pTempView = SysCityCollections.new()
    end
    local nBeginX, nBeginY, nOffsetX, nOffsetY = 40, 0, 160, 0
    local nIndex = (_index - 1) * nGoodsCol

    for i=1,nGoodsCol do
    	local tTempData = self.tDropList[nIndex + i]
    	if tTempData then
    		pTempView:setIcon(i, tTempData)
    	else
    		pTempView:setIcon(i, nil)
    	end
    end
    return pTempView
end

function DlgWildArmyDetail:updateViews(  )
	if not self.tData then
		return
	end
	--乱军图标
	WorldFunc.getWildArmyIconOfContainer(self.pLayIcon, self.tData.nRebelId, true)
	-- --乱军动画
	-- if not self.pArmyArm then
	-- 	local pArmyArm = WorldFunc.getWildArmyArmOfContainer(self.pLayIcon, self.tData.nRebelId)
	-- 	if pArmyArm then
	-- 		self.pArmyArm = pArmyArm
	-- 		self.pLayIcon:setScale(0.8)	
	-- 	end
	-- end
	
	local tEnemyData = getWorldEnemyData(self.tData.nRebelId)
	if not tEnemyData then
		return
	end

	self.pTxtName:setString(tEnemyData.name.." ".. getLvString(tEnemyData.level))
	self.pTxtPos:setString(getConvertedStr(3, 10109)  .. getWorldPosString(self.tData.nX, self.tData.nY))

	--获取新手阶段攻打乱军的行军速度加成
	local nRatio = getArmyRatioInNewGuide(tEnemyData.level)
	
	local nNeedTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY, nRatio)
	local sNeedTime = formatTimeToMs(nNeedTime)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. sNeedTime)


	--掉落物品
	local tDropList = {}
	local tWuWangAct=Player:getActById(e_id_activity.wuwang)
	if tWuWangAct then
		tDropList = getDropById(tEnemyData.actdrop)
	else
		tDropList = getDropById(tEnemyData.drop)
	end
	local nPrevCount = #self.tDropList
	self.tDropList = tDropList
	local tActDropList = {}
	
	local sortList = {
		[100155] = 1,
		[100154] = 2,
		[e_type_resdata.coin] = 3,
		[e_type_resdata.wood] = 4,
		[e_type_resdata.food] = 5,
	}
	local function sortFunc(a, b) 
		if sortList[a.sTid] and sortList[b.sTid] then
			return sortList[a.sTid] < sortList[b.sTid]
		elseif sortList[a.sTid] and not sortList[b.sTid] then
			return true
		elseif not sortList[a.sTid] and sortList[b.sTid] then
			return false
		else 
			return a.nQuality > b.nQuality
		end
	end
	table.sort(self.tDropList, sortFunc)

	if #self.tDropList <= 0 then --经测试，self.pListView:notifyDataSetChange(true)，数据为0时会出错
        self.pListView:removeAllItems()
    else
        if nPrevCount ~= #tDropList then
            self.pListView:removeAllItems()
            self.pListView:setItemCount(math.ceil(#self.tDropList/nGoodsCol))
    --         self.pListView:setItemCount(#self.tDropList)
    --         self.pListView:setItemCallback(function ( _index, _pView ) 
    --             local pItemData = self.tDropList[_index]
    --             local pTempView = _pView
    --             if pTempView == nil then
    --                 pTempView = IconGoods.new(TypeIconGoods.HADMORE)
    --             end
    --             pTempView:setScale(0.8)
    --             pTempView:setCurData(pItemData)
    --             pTempView:setMoreText(pItemData.sName)
				-- pTempView:setMoreTextColor(getColorByQuality(pItemData.nQuality))	
    --             return pTempView
    --         end)

            -- 载入所有展示的item
            self.pListView:reload()
        else
            self.pListView:notifyDataSetChange(true)
        end
    end

    --可以打
    self.bIsCanAtk = Player:getWorldData():getWildArmyIsCanAtk(tEnemyData.prelv)
	if self.bIsCanAtk then
		self.pTxtTip:setVisible(false)
  		-- self.pBtnAttack:setBtnEnable(true)
  		self.pBtnAttack:updateBtnText(getConvertedStr(3, 10016))
	else
		local tStr = getTextColorByConfigure(string.format(getTipsByIndex(20016), Player:getWorldData():getCanAtkWildArmyLv()))
		self.pTxtTip:setString(tStr)
		self.pTxtTip:setVisible(true)
		-- self.pBtnAttack:setBtnEnable(false)
		self.pBtnAttack:updateBtnText(getConvertedStr(3, 10552))
	end

	--刷新今日已击杀乱军数量
	local nKilledNum = Player:getWorldData():getKilledWildArmyNum()
	self.pBtnExText:setLabelCnCr(2, nKilledNum)

end

--tData:ViewDotMsg
function DlgWildArmyDetail:setData( tData )
	self.tData = tData
	self:updateViews()
end

function DlgWildArmyDetail:onBtnCancelClicked(  )
	self:closeDlg(false)
end

function DlgWildArmyDetail:onBtnAttackClicked(  )
	--可以打
	if self.bIsCanAtk then
		--发送消息打开dlg
		local tObject = {
		    nType = e_dlg_index.battlehero, --dlg类型
		    nIndex = 3,--野军
		    tViewDotMsg = self.tData,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	else--不可以打
		SocketManager:sendMsg("reqSearchWildArmy", {}, function( __msg )
			if  __msg.head.state == SocketErrorType.success then
		        if __msg.head.type == MsgType.reqSearchWildArmy.id then
		        	closeDlgByType(e_dlg_index.wildarmy, false)
		        	sendMsg(ghd_world_location_dotpos_msg, {nX = __msg.body.x, nY = __msg.body.y, isClick = true})
		        end
		    else
		        TOAST(SocketManager:getErrorStr(__msg.head.state))
		    end
		end)
	end
end

return DlgWildArmyDetail