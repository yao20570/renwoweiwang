----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-25 09:56:02
-- Description: 魔兵详情
-----------------------------------------------------
-- 魔兵详情界面
local DlgCommon = require("app.common.dialog.DlgCommon")
local IconGoods = require("app.common.iconview.IconGoods")
local SysCityCollections = require("app.layer.world.SysCityCollections")

local nGoodsCol = 4

local DlgMoBingDetail = class("DlgMoBingDetail", function()
	return DlgCommon.new(e_dlg_index.wildarmy,706-130,130)-- 650 - 60 - 130+116, 130)
end)

function DlgMoBingDetail:ctor(  )
	parseView("dlg_wild_army_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgMoBingDetail:onParseViewCallback( pView )
	self:addContentView(pView, false) --加入内容层

	self:setTitle(getConvertedStr(3, 10496))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgMoBingDetail",handler(self, self.onDlgMoBingDetailDestroy))
end

-- 析构方法
function DlgMoBingDetail:onDlgMoBingDetailDestroy(  )
    self:onPause()
end

function DlgMoBingDetail:regMsgs(  )
end

function DlgMoBingDetail:unregMsgs(  )
end

function DlgMoBingDetail:onResume(  )
	self:regMsgs()
end

function DlgMoBingDetail:onPause(  )
	self:unregMsgs()
end

function DlgMoBingDetail:setupViews(  )
	local pLayInfo = self:findViewByName("lay_info")
	setGradientBackground(pLayInfo)
	
	local pImgFlag = self:findViewByName("img_flag")
	--旗子
	pImgFlag:setCurrentImage("#v2_img_emobiaozhi.png")

	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtPos = self:findViewByName("txt_pos")
	self.pTxtMoveTime = self:findViewByName("txt_move_time")
	setTextCCColor(self.pTxtMoveTime, _cc.green)
	local pTxtSpaceTip = self:findViewByName("txt_space_tip")
	pTxtSpaceTip:setString(getConvertedStr(3, 10500))
	self.pTxtTip = self:findViewByName("txt_tip")
	setTextCCColor(self.pTxtTip, _cc.red)

	local pLayBtnAttack = self:findViewByName("lay_btn_attack")
	self.pBtnAttack = getCommonButtonOfContainer(pLayBtnAttack,TypeCommonBtn.L_BLUE)
	self.pBtnAttack:onCommonBtnClicked(handler(self, self.onBtnAttackClicked))
	self.pBtnAttack:updateBtnText(getConvertedStr(3, 10016))

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
    self.tDropList = {}

    --奖励图纸
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

end

--列表回调
function DlgMoBingDetail:onListViewItemCallBack( _index, _pView)
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


function DlgMoBingDetail:updateViews(  )
	if not self.tData then
		return
	end
	--魔君图标
	WorldFunc.getMoBingIconOfContainer(self.pLayIcon, self.tData.nRebelId, true)
	
	local tMoBingData = getAwakeArmyData(self.tData.nRebelId)
	if not tMoBingData then
		return
	end

	self.pTxtName:setString(tMoBingData.name.." ".. getLvString(tMoBingData.level))
	self.pTxtPos:setString(getConvertedStr(3, 10109)  .. getWorldPosString(self.tData.nX, self.tData.nY))

	local nNeedTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY)
	local sNeedTime = formatTimeToMs(nNeedTime)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. sNeedTime)

	--掉落物品
	local tDropList = getDropById(tMoBingData.drop)
	local nPrevCount = #self.tDropList
	self.tDropList = tDropList

	local sortList = {
		[100155] = 1,
		[100154] = 2,
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

            -- self.pListView:setItemCount(#self.tDropList)
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
    self.bIsCanAtk = Player:getWorldData():getWildArmyIsCanAtk(tMoBingData.prelv) 
	if self.bIsCanAtk then
		self.pTxtTip:setVisible(false)
  		-- self.pBtnAttack:setBtnEnable(true)
  		self.pBtnAttack:updateBtnText(getConvertedStr(3, 10016))
	else
		local tStr = getTextColorByConfigure(string.format(getTipsByIndex(20035), Player:getWorldData():getCanAtkWildArmyLv()))
		self.pTxtTip:setString(tStr)
		self.pTxtTip:setVisible(true)
		-- self.pBtnAttack:setBtnEnable(false)
		self.pBtnAttack:updateBtnText(getConvertedStr(3, 10552))
	end
end

--tData:ViewDotMsg
function DlgMoBingDetail:setData( tData )
	self.tData = tData
	self:updateViews()
end

function DlgMoBingDetail:onBtnCancelClicked(  )
	self:closeDlg(false)
end

function DlgMoBingDetail:onBtnAttackClicked(  )
	if self.bIsCanAtk then
		--发送消息打开dlg
		local tObject = {
		    nType = e_dlg_index.battlehero, --dlg类型
		    nIndex = 3,--野军
		    tViewDotMsg = self.tData,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	else
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

return DlgMoBingDetail