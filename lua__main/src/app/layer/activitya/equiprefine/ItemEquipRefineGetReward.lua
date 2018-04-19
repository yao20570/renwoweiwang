----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2018-02-27 11:13
-- Description: 通用领奖列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemEquipRefineGetReward = class("ItemEquipRefineGetReward", function()
	return ItemActGetReward.new()
end)

local nGreenQuality = 2 --绿色品质

function ItemEquipRefineGetReward:ctor(  )
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemEquipRefineGetReward",handler(self, self.onItemEquipRefineGetRewardDestroy))	
end

function ItemEquipRefineGetReward:regMsgs(  )
end

function ItemEquipRefineGetReward:unregMsgs(  )
end

function ItemEquipRefineGetReward:onResume(  )
	self:regMsgs()
end

function ItemEquipRefineGetReward:onPause(  )
	self:unregMsgs()
end


function ItemEquipRefineGetReward:onItemEquipRefineGetRewardDestroy(  )
	self:onPause()
end

function ItemEquipRefineGetReward:setupViews(  )
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10327))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet
	
	local tConTable = {}
	--文本
	local tLabel = {
		{"0",getC3B(_cc.green)},
		{"/0",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	self.pBtnGet:setBtnExText(tConTable) 

end


function ItemEquipRefineGetReward:updateViews(  )
	if not self.tConf then
		return
	end
	--标题
	local tStr = {
		{text = getConvertedStr(7, 10340), color = _cc.white},
		{text = self.tConf.nTarTimes, color = _cc.green},
		{text = getConvertedStr(7, 10341), color = _cc.white}
	}
	self.pTxtBanner:setString(tStr)

	--物品列表
	local tDropList = self.tConf.tAwards
	self:setGoodsListViewData(tDropList)

	local tData = Player:getActById(e_id_activity.equiprefine)
	if not tData then
		return
	end
    --是否已经领取
    local bIsGot = tData:getIsRewarded(self.tConf.nIndex)

    if bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")

    	self.pBtnGet:setVisible(false)
    	self.pBtnGet:setExTextVisiable(false)
    else
    	self:hideRewardStateImg()
    	self.pBtnGet:setVisible(true)
    	self.pBtnGet:setExTextVisiable(true)
    	if tData.nTrainTimes > self.tConf.nTarTimes then
    		self.pBtnGet:setExTextLbCnCr(1, self.tConf.nTarTimes)
    	else
    		self.pBtnGet:setExTextLbCnCr(1, tData.nTrainTimes)
    	end
    	self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(self.tConf.nTarTimes))
    	--是否可领取
    	self.isCanGet = tData:getIsCanReward(self.tConf.nIndex)
    	if self.isCanGet then
    		self.pBtnGet:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10213))
    	else
    		self.pBtnGet:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(3, 10367))
    	end
    end
end

function ItemEquipRefineGetReward:setData(_tConf)
	self.tConf = _tConf
	self:updateViews()
end

function ItemEquipRefineGetReward:onGetClicked( pView )
	if self.isCanGet then
		SocketManager:sendMsg("reqEquipRefineReward", {self.tConf.nIndex}, function(__msg, __oldMsg)
			if __msg.body then
				--奖励动画展示
				showGetAllItems(__msg.body.ob, 1)
			end
		end)
	else
		--跳到洗炼铺界面
		local pObj = {}
		pObj.nType = e_dlg_index.smithshop
		pObj.nFuncIdx = n_smith_func_type.train
		local sUuid, nHeroId = nil, nil
		--遍历3种类型的武将, 找到武将身上第一件绿色品质以上的装备
		for i = 1, 3 do
			local tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(i)
			local bFind = false
			for _, pHero in pairs(tHeroList) do
				local tEquipVos = Player:getEquipData():getEquipVosByKindInHero(pHero.nId)
				for k, equipVo in pairs(tEquipVos) do
					if equipVo:getQuality() >= nGreenQuality and not equipVo:getIsCurrRefineLvMax() then
						sUuid = equipVo.sUuid
						nHeroId = equipVo.nHeroId
						bFind = true
						break
					end
				end
				if bFind then
					break
				end
			end
			if bFind then
				break
			end
		end
		pObj.sUuid = sUuid
		pObj.nHeroId = nHeroId
		sendMsg(ghd_show_dlg_by_type, pObj)
	end
end


return ItemEquipRefineGetReward


