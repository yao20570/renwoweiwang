----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2018-02-27 17:04
-- Description: 通用领奖列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemArtifactMakeGetReward = class("ItemArtifactMakeGetReward", function()
	return ItemActGetReward.new()
end)

local nGreenQuality = 2 --绿色品质

function ItemArtifactMakeGetReward:ctor(  )
	self.nTargetType = 1 	--活动任务类型
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemArtifactMakeGetReward",handler(self, self.onItemArtifactMakeGetRewardDestroy))	
end

function ItemArtifactMakeGetReward:regMsgs(  )
end

function ItemArtifactMakeGetReward:unregMsgs(  )
end

function ItemArtifactMakeGetReward:onResume(  )
	self:regMsgs()
end

function ItemArtifactMakeGetReward:onPause(  )
	self:unregMsgs()
end


function ItemArtifactMakeGetReward:onItemArtifactMakeGetRewardDestroy(  )
	self:onPause()
end

function ItemArtifactMakeGetReward:setupViews(  )
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


function ItemArtifactMakeGetReward:updateViews(  )
	if not self.tConf then
		return
	end
	--标题
	local tStr = {}
	if self.tConf.nTargetLv > 0 then
		--至少打造x件神器到x级
		tStr = {
			{text = getConvertedStr(7, 10342), color = _cc.white},
			{text = self.tConf.nTargetNum, color = _cc.green},
			{text = getConvertedStr(7, 10344), color = _cc.white},
			{text = self.tConf.nTargetLv, color = _cc.green},
			{text = getConvertedStr(7, 10337), color = _cc.white}
		}
		self.nTargetType = 2
	else
		--至少打造x件神器
		tStr = {
			{text = getConvertedStr(7, 10342), color = _cc.white},
			{text = self.tConf.nTargetNum, color = _cc.green},
			{text = getConvertedStr(7, 10343), color = _cc.white}
		}
		self.nTargetType = 1
	end
	self.pTxtBanner:setString(tStr)

	--物品列表
	local tDropList = self.tConf.tAwards
	self:setGoodsListViewData(tDropList)

	local tData = Player:getActById(e_id_activity.artifactmake)
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
    	self.pBtnGet:setExTextLbCnCr(1, self.tConf.nPro)
    	self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(self.tConf.nTargetNum))
    	--是否可领取
    	self.isCanGet = tData:getIsCanReward(self.tConf.nIndex)
    	if self.isCanGet then
    		self.pBtnGet:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10213))
    	else
    		self.pBtnGet:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(3, 10367))
    	end
    end
end

function ItemArtifactMakeGetReward:setData(_tConf)
	self.tConf = _tConf
	self:updateViews()
end

function ItemArtifactMakeGetReward:onGetClicked( pView )
	if self.isCanGet then
		SocketManager:sendMsg("reqArtifactMakeReward", {self.tConf.nIndex}, function(__msg, __oldMsg)
			if __msg.body then
				--奖励动画展示
				showGetAllItems(__msg.body.ob, 1)
			end
		end)
	else
		--跳到神兵界面
		local nWeaponId = nil
		local tWeaponList = Player:getWeaponInfo():getWeaponList()
		if self.nTargetType == 1 then
			for k, weapon in pairs(tWeaponList) do
				if weapon.nWeaponId == nil then
					nWeaponId = weapon.nId
					break
				end
			end
		else
			--先找到已打造但不满足等级的神器
			for k, weapon in pairs(tWeaponList) do
				if weapon.nWeaponId and weapon.nWeaponLv < self.tConf.nTargetLv then
					nWeaponId = weapon.nId
					break
				end
			end
			--如果没有已打造神器默认选中第一个未打造的神器
			if nWeaponId == nil then
				for k, weapon in pairs(tWeaponList) do
					if weapon.nWeaponId == nil then
						nWeaponId = weapon.nId
						break
					end
				end
			end
		end
		if nWeaponId == nil then
			return
		end
		local tObject = {}
		tObject.nType = e_dlg_index.dlgweaponinfo --dlg类型
		tObject.nIndex = nWeaponId - 200
		sendMsg(ghd_show_dlg_by_type, tObject)
	end
end


return ItemArtifactMakeGetReward


