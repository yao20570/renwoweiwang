-----------------------------------------------------
-- author: xiesite
-- Date: 2017-11-7 11:37:23
-- Description: 英雄进阶到神将
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local ItemHeroInfo = require("app.layer.hero.ItemHeroInfo")

local DlgHeroAdvanceM = class("DlgHeroAdvanceM", function()
	-- body
	return DlgBase.new(e_dlg_index.mheroadvance)
end)

function DlgHeroAdvanceM:ctor(_tData)
	-- body
	self:myInit()
	self.tHeroData = _tData
	if self.tHeroData.recordAdvanceRedNum then
		self.tHeroData:recordAdvanceRedNum()
	end
	self:setTitle(getConvertedStr(5, 10015))
	parseView("dlg_hero_advance_m", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHeroAdvanceM:myInit(  )
	-- body
	self.tHeroData = nil --英雄数据
	self.tHeroListIcon = nil --英雄队列icon
	self.tCanAdvance = false --装备满足进阶条件
end

function DlgHeroAdvanceM:setupViews(  )
	-- 英雄信息层
	self.pLyHero_1 = self:findViewByName("ly_hero_1")
	self.pLyHero_2 = self:findViewByName("ly_hero_2")
	self.pImgArrow = self:findViewByName("img_arrow")

	self.tEquipIcon = {}
	for i=1,6 do
		local pLyEquip = self:findViewByName("ly_equip_"..i)
		pLyEquip:setZOrder(2)
		local pIcon = getIconEquipByType(pLyEquip, TypeIconEquip.ADD, i, nil, TypeIconGoodsSize.L)
		pIcon:setDescPosY(-12)
		if i <= 2 then
			pIcon:showDesc(getConvertedStr(1, 10296))
		elseif i <= 4 then
			pIcon:showDesc(getConvertedStr(1, 10297))
		else 
			pIcon:showDesc(getConvertedStr(1, 10298))
		end
		pIcon:setIconClickedCallBack(handler(self, self.onEquipIconClicked))
		pIcon:setCallBackParam(i)
		table.insert(self.tEquipIcon, pIcon)
	end

	--
	self.pLyTitle = self:findViewByName("ly_title")
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbTitle:setString(getConvertedStr(1,10292))

	self.pLbTitle = self:findViewByName("lb_tips")
	self.pLbTitle:setString(getConvertedStr(1,10293))

	self.pLyBtnL = self:findViewByName("ly_down_btn_l")
	self.pBtnL = getCommonButtonOfContainer(self.pLyBtnL, TypeCommonBtn.L_BLUE, getConvertedStr(1, 10294))
	self.pBtnL:onCommonBtnClicked(handler(self, self.onRefineClicked))

	self.pLyBtnR = self:findViewByName("ly_down_btn_r")
	self.pBtnR = getCommonButtonOfContainer(self.pLyBtnR, TypeCommonBtn.L_YELLOW, getConvertedStr(1, 10311))
	self.pBtnR:onCommonBtnClicked(handler(self, self.onAdvanceClicked))

	--完成提示
	self.pLyTips = self:findViewByName("ly_tips")
	self.pLbFinishTips = self:findViewByName("lb_finishTips")
	self.pLbFinishTips:setString(getConvertedStr(1,10303))
	setTextCCColor(self.pLbFinishTips, _cc.blue)

	self.pLbAdvanceTip = self:findViewByName("lb_advanceTip")
	self.pLbAdvanceTip:setString(getTextColorByConfigure(string.format(getTipsByIndex(20063), 120)))
	self:showHeroInfo()

	self.pLyEquip = self:findViewByName("ly_equip")
	self.pLyBottom = self:findViewByName("ly_bottom")
end

-- getHeroDataById
function DlgHeroAdvanceM:showHeroInfo()
	if not self.tHeroData then
		return false
	end

	if self.tHeroData then
		if not self.pCurView then
			self.pCurView = ItemHeroInfo.new(self.tHeroData,nil,false,true)
			self.pLyHero_1:addView(self.pCurView)
		end

		if not self.pNextView then
			self.pNextView = ItemHeroInfo.new(self.tHeroData,nil,true,true)
			self.pLyHero_2:addView(self.pNextView)
			self.pNextView:showAddArrow()
		end		
	end
end

function DlgHeroAdvanceM:onEquipIconClicked(pView, nKind)
	local sUuid = nil
	local tEquipVos = Player:getEquipData():getEquipVosByKindInHero(self.tHeroData.nId)
	local tEquipVo = tEquipVos[nKind]
	if tEquipVo then
		sUuid = tEquipVo.sUuid
	end
	local tObject = {
	    nType = e_dlg_index.equipbag, --dlg类型
	    nKind = nKind,
	    sUuid = sUuid,
	    nHeroId = self.tHeroData.nId,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--解析布局回调事件
function DlgHeroAdvanceM:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView,true) --加入内容层

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroAdvance",handler(self, self.onDestroy))
end


-- 修改控件内容或者是刷新控件数据
function DlgHeroAdvanceM:updateViews()
	if not self.tHeroData then
       return
	end	

	self:updateEquips()
	-- dump(self.tHeroData)
	if self.tHeroData.nIg == 1 then

		self.pLyTips:setVisible(true)
		self.pLyTitle:setVisible(false)
		self.pLyEquip:setVisible(false)
		self.pLyBottom:setVisible(false)

		self.pImgArrow:setVisible(false)
		self.pBtnR:setToGray(true)
	else
		self.pLyTips:setVisible(false)
		self.pLyTitle:setVisible(true)
		self.pLyEquip:setVisible(true)
		self.pLyBottom:setVisible(true)

		self.pImgArrow:setVisible(true)

		if self.tHeroData.nLv < tonumber(getHeroInitData("godAdvLv")) or not self.tCanAdvance then
			self.pBtnR:setToGray(true)
		else
			self.pBtnR:setToGray(false)
		end
	end

end

--设置数据
function DlgHeroAdvanceM:setCurData(_tData)
	-- body
	if not _tData then
		return 
	end
	self.tHeroData = _tData
	if self.tHeroData.recordAdvanceRedNum then
		self.tHeroData:recordAdvanceRedNum()
	end
	self:updateViews()
end

--点击进阶回调
function DlgHeroAdvanceM:onAdvanceClicked(pView)
	if self.tHelpData.nIg == 1 then
	   TOAST(getConvertedStr(1, 10300))
       return
	end

	if self.tHeroData.nLv < tonumber(getHeroInitData("godAdvLv")) then
	   TOAST(string.format(getConvertedStr(3,10402),getHeroInitData("godAdvLv")))
       return
	end

	if not self.tCanAdvance then
		TOAST(getConvertedStr(1, 10313))
		return
	end

	SocketManager:sendMsg("heroAdvance", {self.tHeroData.nId, 2}, handler(self, self.onGetDataFunc))
end

--去洗练铺
function DlgHeroAdvanceM:onRefineClicked( pView )
	local tObject = {
	    nType = e_dlg_index.smithshop,
	    nHeroId = self.tHeroData.nId,
	    nFuncIdx = n_smith_func_type.train
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--进阶回调
function DlgHeroAdvanceM:onGetDataFunc(__msg)
	dump(__msg)
	if __msg.head.state == SocketErrorType.success then
		if __msg.head.type == MsgType.heroAdvance.id then
			self.pAbandonView = self.pCurView
			self.pCurView = self.pNextView
			self.pNextView = nil
			self.pCurView:showAdvanceTX(self.pAbandonView, nil, true)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end

-- 析构方法
function DlgHeroAdvanceM:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgHeroAdvanceM:regMsgs( )
	-- 注册装备刷新
	regMsg(self, gud_equip_hero_equip_change, handler(self, self.updateViews))
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))

end

-- 注销消息
function DlgHeroAdvanceM:unregMsgs(  )
	-- 注销装备刷新
	unregMsg(self, gud_equip_hero_equip_change)
		-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
end

--暂停方法
function DlgHeroAdvanceM:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgHeroAdvanceM:onResume( )
	-- body
	self:setupViews()
	self:updateViews()
	self:regMsgs()
end

--更新武将装备
function DlgHeroAdvanceM:updateEquips()
	if not self.tHeroData then
		return
	end

	local nHeroId = self.tHeroData.nId
	self.tCanAdvance = true
	--获取更好的装备
	-- local tBettleEquipVos = Player:getEquipData():getHeroBetterEquipVos(nHeroId)

	--刷新装备
	local tEquipVos = Player:getEquipData():getEquipVosByKindInHero(nHeroId)
	for i=1,#self.tEquipIcon do
		local pIcon = self.tEquipIcon[i]
		local tEquipVo = tEquipVos[i]

		if tEquipVo then
			pIcon:setCurData(tEquipVo:getConfigData())
			pIcon:setIconType(TypeIconEquip.NORMAL)
			local tDarkLights = tEquipVo:getStarDarkLights()
			pIcon:initStarLayer(#tDarkLights, 0, tDarkLights)
		
			--如果背包有更好的装备则显示红点提示
			local bRedTip = false
			-- for j=1,#tBettleEquipVos do
			-- 	local tEquipData = tBettleEquipVos[j]:getConfigData()
			-- 	if tEquipData then
			-- 		if tEquipData.nKind == i then
			-- 			bRedTip = true
			-- 			break
			-- 		end
			-- 	end
			-- end
			-- if bRedTip then
			-- 	pIcon:setRedTipState(1)
			-- else
			-- 	pIcon:setRedTipState(0)
			-- end
			if tEquipVo:getSolidStarNum() < 4 or  tEquipVo:getConfigData().nQuality ~= 5 then
				self.tCanAdvance = false
				pIcon:setRedTipState(1)
				pIcon:setDescColor(_cc.red)
			else
				local nAttr = nil
				if i <= 2 then
					nAttr = e_id_hero_att.gongji
				elseif i <= 4 then
					nAttr = e_id_hero_att.fangyu
				elseif i <= 6 then
					nAttr = e_id_hero_att.bingli
				end
				if tEquipVo.tTrainAtbVos[1] 
						and tEquipVo.tTrainAtbVos[1].nAttrId == nAttr then
					pIcon:setRedTipState(0)
					pIcon:setDescColor(_cc.green)
				else
					pIcon:setRedTipState(1)
					pIcon:setDescColor(_cc.red)
				end
			end

		else
			self.tCanAdvance = false
			pIcon:setDescColor(_cc.red)
			pIcon:setRedTipState(0)
			pIcon:setIconType(TypeIconEquip.ADD)
			--如果有更新可以装备就要显示动态否则显示灰色
			local bIsAddImgAction = false
			-- for j=1,#tBettleEquipVos do
			-- 	local tEquipData = tBettleEquipVos[j]:getConfigData()
			-- 	if tEquipData then
			-- 		if tEquipData.nKind == i then
			-- 			bIsAddImgAction = true
			-- 			break
			-- 		end
			-- 	end
			-- end
			if bIsAddImgAction then
				pIcon:addImgAction()
			else
				pIcon:stopAddImgAction()
			end
		end
	end
end

return DlgHeroAdvanceM