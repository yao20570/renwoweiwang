----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-25 09:56:02
-- Description: 纣王详情
-----------------------------------------------------
-- 魔兵详情界面
local DlgCommon = require("app.common.dialog.DlgCommon")
local IconGoods = require("app.common.iconview.IconGoods")
local DlgZhouWangDetail = class("DlgZhouWangDetail", function()
	return DlgCommon.new(e_dlg_index.zhouwangdetail)
end)

function DlgZhouWangDetail:ctor(  )
	parseView("dlg_zhouwang_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgZhouWangDetail:onParseViewCallback( pView )
	self:addContentView(pView, false) --加入内容层

	self:setTitle(getConvertedStr(3, 10501))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgZhouWangDetail",handler(self, self.onDlgZhouWangDetailDestroy))
end

-- 析构方法
function DlgZhouWangDetail:onDlgZhouWangDetailDestroy(  )
    self:onPause()
    unregUpdateControl(self)
end

function DlgZhouWangDetail:regMsgs(  )
	--世界Boss被击杀
	regMsg(self, gud_world_dot_disappear_msg, handler(self, self.onBossKilled))
end

function DlgZhouWangDetail:unregMsgs(  )
	--世界Boss被击杀
	unregMsg(self, gud_world_dot_disappear_msg)
end

function DlgZhouWangDetail:onResume(  )
	self:regMsgs()
end

function DlgZhouWangDetail:onPause(  )
	self:unregMsgs()
end

function DlgZhouWangDetail:setupViews(  )
	self.pImgFlag = self:findViewByName("img_flag")

	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtPos = self:findViewByName("txt_pos")
	self.pTxtMoveTime = self:findViewByName("txt_move_time")
	setTextCCColor(self.pTxtMoveTime, _cc.green)
	local pTxtSpaceTip = self:findViewByName("txt_space_tip")
	pTxtSpaceTip:setString(getConvertedStr(3, 10504))
	self.pTxtTip = self:findViewByName("txt_tip")
	setTextCCColor(self.pTxtTip, _cc.red)
	self.pTxtTroops = self:findViewByName("txt_troops")

	local pLayBtnAttack = self:findViewByName("lay_btn_attack")
	self.pBtnAttack = getCommonButtonOfContainer(pLayBtnAttack,TypeCommonBtn.L_BLUE)
	self.pBtnAttack:onCommonBtnClicked(handler(self, self.onBtnAttackClicked))
	self.pBtnAttack:updateBtnText(getConvertedStr(3, 10502))

	local pLayGoods = self:findViewByName("lay_goods")
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, 148),
		direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		itemMargin = {left =  5,
             right =  5,
             top =  5,
             bottom =  5},
    }
    pLayGoods:addView(self.pListView)
    centerInView(pLayGoods, self.pListView )
    self.tDropList = {}
end

function DlgZhouWangDetail:updateViews(  )
	if not self.tData then
		return
	end
	--魔君图标
	WorldFunc.getBossIconOfContainer(self.pLayIcon, self.tData.nBossLv, true)

	--旗子
	WorldFunc.setWorldBossFlag(self.pImgFlag, self.tData.nBossLv)
	
	--表数据
	local tAwakeBoss = self.tAwakeBoss
	if not tAwakeBoss then
		return
	end

	--兵力
	self.pTxtTroops:setString(getConvertedStr(3, 10124) .. tostring(tAwakeBoss.nTroops))

	self.pTxtName:setString(tAwakeBoss.name)
	self.pTxtPos:setString(getConvertedStr(3, 10109)  .. getWorldPosString(self.tData.nX, self.tData.nY))

	local nRatio = WorldFunc.getBossSpeedAdd(self.tData.nBossLv)
	local nNeedTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY, nRatio)
	local sNeedTime = formatTimeToMs(nNeedTime)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. sNeedTime)


	--掉落物品 不显示数量
	local sStr = getAwakeInitData("baseBossAward") --100156:1;2:1000;3:1000
	local tStr = luaSplitMuilt(sStr, ";", ":")
	local tDropList = {}
	for i=1,#tStr do
		local nGoodsId = tonumber(tStr[i][1])
		if nGoodsId then
			local tDrop = getGoodsByTidFromDB(nGoodsId)
			if tDrop then
				table.insert(tDropList, tDrop)
			end
		end
	end

	local nPrevCount = #self.tDropList
	self.tDropList = tDropList
	if #self.tDropList <= 0 then --经测试，self.pListView:notifyDataSetChange(true)，数据为0时会出错
        self.pListView:removeAllItems()
    else
        if nPrevCount ~= #tDropList then
            self.pListView:removeAllItems()
            self.pListView:setItemCount(#self.tDropList)
            self.pListView:setItemCallback(function ( _index, _pView ) 
                local pItemData = self.tDropList[_index]
                local pTempView = _pView
                if pTempView == nil then
                    pTempView = IconGoods.new(TypeIconGoods.HADMORE)
                end
                pTempView:setScale(0.8)
                pTempView:setCurData(pItemData)
                pTempView:setMoreText(pItemData.sName)
				pTempView:setMoreTextColor(getColorByQuality(pItemData.nQuality))	
                return pTempView
            end)
            -- 载入所有展示的item
            self.pListView:reload()
        else
            self.pListView:notifyDataSetChange(true)
        end
    end

    --更新cd
    self:updateCd()
end

--tData:ViewDotMsg
function DlgZhouWangDetail:setData( tData )
	self.tData = tData
	self.tAwakeBoss = nil
	if self.tData then
		self.tAwakeBoss = getAwakeBossData(self.tData.nBossLv, Player:getWuWangDiff())
	end
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

function DlgZhouWangDetail:updateCd( )
	if self.tData then
		local nCd = self.tData:getBossLeaveCd()
		if nCd > 0 then
			local sStr = getConvertedStr(3, 10503) .. formatTimeToMs(nCd)
			self.pTxtTip:setString(sStr)
		else
			unregUpdateControl(self)
		end
	end
end

function DlgZhouWangDetail:onBtnCancelClicked(  )
	self:closeDlg(false)
end


function DlgZhouWangDetail:onBtnAttackClicked(  )
	if not self.tData then
		return
	end
	--表数据
	local tAwakeBoss = self.tAwakeBoss
	if not tAwakeBoss then
		return
	end

	--等级限制
	local nLvNeed = getAwakeInitData("evilOpen")
	if nLvNeed and Player:getPlayerInfo().nLv < nLvNeed then
		TOAST(string.format(getTipsByIndex(20097),nLvNeed))

		-- TOAST(string.format(getConvertedStr(3, 10517), nLvNeed))
		return
	end

	local nX, nY = self.tData.nX, self.tData.nY

	--不可以跨区
	if not Player:getWorldData():getIsCanWarByPos(nX, nY, e_war_type.boss) then
		TOAST(getTipsByIndex(20032))
		return
	end
					
	--已经有战斗列表
	if self.tData.bIsHasBossWar then
		--获取Boss战列表
		SocketManager:sendMsg("reqWorldBossWarList",{nX, nY, tAwakeBoss})
		self:closeDlg(false)
	else
		--二次确认
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    local tStr = {
	        {color=_cc.white,text=getConvertedStr(3, 10506)},
	        {color=_cc.blue,text= string.format("%s",tAwakeBoss.name)},
	        {color=_cc.white,text=getConvertedStr(3, 10507)},
	    }
	    pDlg:setContent(tStr)
	    pDlg:setRightHandler(function (  )
	    	pDlg:closeDlg(false)

	    	--发起Boss战
	        SocketManager:sendMsg("reqWorldBossWar" ,{nX, nY})
	        closeDlgByType( e_dlg_index.zhouwangdetail, false)
		end)
	    pDlg:showDlg(bNew)
	end
end

--不存在，被击杀了
function DlgZhouWangDetail:onBossKilled( )
	if self.tData then
		local tViewDotMsg = Player:getWorldData():getBossViewDotByPos(self.tData.nX, self.tData.nY)
		if not tViewDotMsg then
			TOAST(getConvertedStr(3, 10505))
			self:closeDlg(false)
		end
	end
end

return DlgZhouWangDetail