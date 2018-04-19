----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-03-01 09:52:00
-- Description: 幽魂详情界面
-----------------------------------------------------

-- 乱军详情界面
local DlgCommon = require("app.common.dialog.DlgCommon")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemActBtn = require("app.layer.activitymodel.ItemActBtn")
local SysCityCollections = require("app.layer.world.SysCityCollections")

local nGoodsCol = 4

local DlgGhostdomDetail = class("DlgGhostdomDetail", function()
	return DlgCommon.new(e_dlg_index.ghostdomdetail, 706-130,130)--650 - 60 - 130, 130)
end)

function DlgGhostdomDetail:ctor(  )
	parseView("dlg_wild_army_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgGhostdomDetail:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView, false) --加入内容层

	self:setTitle(getConvertedStr(9, 10163))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgGhostdomDetail",handler(self, self.onDlgGhostdomDetailDestroy))
end

-- 析构方法
function DlgGhostdomDetail:onDlgGhostdomDetailDestroy(  )
    self:onPause()
end

function DlgGhostdomDetail:regMsgs(  )
end

function DlgGhostdomDetail:unregMsgs(  )
end

function DlgGhostdomDetail:onResume(  )
	self:regMsgs()
end

function DlgGhostdomDetail:onPause(  )
	self:unregMsgs()
end

function DlgGhostdomDetail:setupViews(  )
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
	pTxtSpaceTip:setString(getConvertedStr(9, 10185))
	self.pTxtTip = self:findViewByName("txt_tip")
	setTextCCColor(self.pTxtTip, _cc.red)

	local pLayBtnAttack = self:findViewByName("lay_btn_attack")
	self.pBtnAttack = getCommonButtonOfContainer(pLayBtnAttack,TypeCommonBtn.L_BLUE)
	self.pBtnAttack:onCommonBtnClicked(handler(self, self.onBtnAttackClicked))
	self.pBtnAttack:updateBtnText(getConvertedStr(3, 10016))


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
function DlgGhostdomDetail:onListViewItemCallBack( _index, _pView)
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

function DlgGhostdomDetail:updateViews(  )
	if not self.tData then
		return
	end
	--幽魂图标
	local tEnemyData = nil
	WorldFunc.getWildArmyIconOfContainer(self.pLayIcon, self.tData.nGId, true,false,e_type_builddot.ghostdom)
	tEnemyData = getWorldGhostdomData(self.tData.nGId)

	if not tEnemyData then
		return
	end

	self.pTxtName:setString(tEnemyData.name)--.." ".. getLvString(tEnemyData.level2))
	self.pTxtPos:setString(getConvertedStr(3, 10109)  .. getWorldPosString(self.tData.nX, self.tData.nY))

	local nNeedTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY)
	local sNeedTime = formatTimeToMs(nNeedTime)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. sNeedTime)


	--掉落物品
	local tDropList = {}
	-- local tWuWangAct=Player:getActById(e_id_activity.wuwang)
	-- if tWuWangAct then
	-- 	tDropList = getDropById(tEnemyData.actdrop)
	-- else
	tDropList = getDropById(tEnemyData.drop)
	-- end
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
  

            -- 载入所有展示的item
            self.pListView:reload()
        else
            self.pListView:notifyDataSetChange(true)
        end
    end

end

--tData:ViewDotMsg
function DlgGhostdomDetail:setData( tData )
	
	self.tData = tData
	self:updateViews()
end

function DlgGhostdomDetail:onBtnCancelClicked(  )
	self:closeDlg(false)
end

function DlgGhostdomDetail:onBtnAttackClicked(  )
	--可以打
	--发送消息打开dlg
	local tObject = {
	nType = e_dlg_index.battlehero, --dlg类型
	nIndex = 7,--幽魂
	tViewDotMsg = self.tData,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

return DlgGhostdomDetail