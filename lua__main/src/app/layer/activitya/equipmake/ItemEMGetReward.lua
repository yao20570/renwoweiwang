-- ItemEMGetReward.lua
----------------------------------------------------- 
-- author: xst
-- updatetime: 2018-02-24 10:33:20
-- Description: 领奖列表子项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemEMGetReward = class("ItemEMGetReward", function()
	return ItemActGetReward.new()
end)

function ItemEMGetReward:ctor(  )
	self:myInit()
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemEMGetReward",handler(self, self.onItemEMGetRewardDestroy))	
end


function ItemEMGetReward:myInit()
	self.nCId 		= 0 --序号
	self.nEn  		= 0   --件数
	self.nQuality 	= 0   --装备品质
	self.nType 		= 0   --装备种类 0代表全部
	self.tAw 		= {}  --奖励
	self.nstatus    = 0   --状态，0为未完成，1为完成未领取，2为已领取
end

function ItemEMGetReward:regMsgs(  )
end

function ItemEMGetReward:unregMsgs(  )
end

function ItemEMGetReward:onResume(  )
	self:regMsgs()
end

function ItemEMGetReward:onPause(  )
	self:unregMsgs()
end


function ItemEMGetReward:onItemEMGetRewardDestroy(  )
	self:onPause()
end

function ItemEMGetReward:setupViews()
	--条件
	local pLayGroupTitle = self.pLayGroupTitle

    self.pGroupTitle =  MUI.MLabel.new({
    		text = "第1天",
    		size = 20,
    		anchorpoint = cc.p(0.5, 0.5),
    	})
    pLayGroupTitle:addView(self.pGroupTitle)
    centerInView(pLayGroupTitle, self.pGroupTitle)
    self.pGroupTitle:setAnchorPoint(0, 0.5)
    self.pGroupTitle:setPositionX(5)

    --领取按钮层
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet

	-- self.pImgGot:setPositionY(self.pImgGot:getPositionY()-10)
	-- self.pLbState:setPositionY(self.pLbState:getPositionY()-10)
	-- self.pLbState:setPositionX(self.pLbState:getPositionX()+5)
	-- self.pLbState:setString("0/0")
	-- self.pLbState:setVisible(true)
	local tConTable = {}
	--文本
	local tLabel = {
		{"0",getC3B(_cc.green)},
		{"/0",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	self.pBtnGet:setBtnExText(tConTable) 
end


function ItemEMGetReward:updateViews()
	-- if not self.tLogData then
	-- 	return
	-- end
	-- --标题
	local colorStr = getColorByQuality(self.nQuality)
	self.pGroupTitle:setString(string.format(getConvertedStr(1, 10355), self.nEn, colorStr, getEquipTextByQuality(self.nQuality),getEquipTextByKind(self.nType)))
	--物品列表
	local tDropList = self.tAw
	--奖励列表
	self:setGoodsListViewData(tDropList)

	local tAct = Player:getActById(e_id_activity.equipmake)
	if not tAct then
		return
	end
	self.pBtnGet:setExTextLbCnCr(1, tAct:getAlEn(self.nCId))
    self.pBtnGet:setExTextLbCnCr(2, "/"..tAct:getConfEn(self.nCId))
    
    --是否已经领取
    local bIsGot = tAct:getIsRewarded(self.nCId)
    if bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")
    	self:setLabelVisible(not bIsGot)
    else
    	self:hideRewardStateImg()
    end
    self.pBtnGet:setVisible(not bIsGot)
    --是否可领取
    local bCanGet = tAct:getIsCanReward(self.nCId)
    if bCanGet then
    	self.pBtnGet:updateBtnType(TypeCommonBtn.M_YELLOW)
    	self.pBtnGet:updateBtnText(getConvertedStr(7, 10086))
    end
    --是否未达到
    local bNotLog = tAct:getNotLog(self.nCId)
    if bNotLog then
    	self.pBtnGet:updateBtnType(TypeCommonBtn.M_BLUE)
    	self.pBtnGet:updateBtnText(getConvertedStr(3, 10367))
    end
end 

function ItemEMGetReward:setItemData(_tLogData)
	if _tLogData then
		self.nCId = _tLogData.ci or self.nCId
		self.nEn  = _tLogData.en or self.nEn
		self.nQuality = _tLogData.q or self.nQuality
		self.nType = _tLogData.k or self.nType
		self.tAw = _tLogData.aw or self.nType
	end
	self:updateViews()
end
 

--领取点击事件
function ItemEMGetReward:onGetClicked( pView )
	local tAct = Player:getActById(e_id_activity.equipmake)
	if not tAct then
		return
	end
	--可以领取
	if tAct:getIsCanReward(self.nCId) then
		SocketManager:sendMsg("equipmake", {self.nCId}, function(__msg)
			-- dump(__msg, "__msg")
		    if  __msg.head.state == SocketErrorType.success then 
		        if __msg.head.type == MsgType.equipmake.id then
		       		if __msg.body.ob then
						--获取物品效果
						showGetItemsAction(__msg.body.ob)
		       		end
		        end
		    else
		        --弹出错误提示语
		        TOAST(SocketManager:getErrorStr(__msg.head.state))
		    end
		end)
	--未完成跳转界面
	elseif tAct:getNotLog(self.nCId) then
		if showBuildOpenTips(e_build_ids.tjp, true) == false then
			TOAST(getConvertedStr(7, 10217))
			return
		end		
		local nQualityMax = getEquipQualityMax()
		local nQualityLock = 1
		for i=1, nQualityMax do
			local bIsLock = true
			local tEquipDatas = getEquipsInSmith(i)
			for j=1,#tEquipDatas do
				if Player:getPlayerInfo().nLv >= tEquipDatas[j].nMakeLv then
					bIsLock = false
					break
				end
			end
			if bIsLock then
				nQualityLock = i
				break
			end
		end
		if self.nQuality >= nQualityLock then--对应品质装备未解锁
			TOAST(getConvertedStr(6, 10597))
			return
		end
		--计算对应品质装备
		local tEquipDatas = getEquipsInSmith(self.nQuality)
		local nEquipID = nil
		local nType = self.nType
		if self.nType == 0 then
			nType = 1
		end
		for j=1,#tEquipDatas do
			if nType == tEquipDatas[j].nKind then
				nEquipID = tEquipDatas[j].sTid
			end
		end			
		--dump(tEquipDatas, "tEquipDatas", 100)
		local pObj = {}
		pObj.nType = e_dlg_index.smithshop 	--跳到铁匠铺
		pObj.nEquipID = nEquipID
		pObj.nFuncIdx = n_smith_func_type.build
		sendMsg(ghd_show_dlg_by_type,pObj)
	end
end

return ItemEMGetReward