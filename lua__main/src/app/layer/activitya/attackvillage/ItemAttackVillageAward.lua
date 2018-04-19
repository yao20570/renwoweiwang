----------------------------------------------------- 
-- Author: maheng
-- Date: 2018-02-28 17:08:13
-- 攻城拔寨奖励子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemAttackVillageAward = class("ItemAttackVillageAward", function()
	return ItemActGetReward.new()
end)
function ItemAttackVillageAward:ctor(  )
	self.nTargetType = 0
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemAttackVillageAward",handler(self, self.onDestroy))	
end

function ItemAttackVillageAward:regMsgs(  )
end

function ItemAttackVillageAward:unregMsgs(  )
end

function ItemAttackVillageAward:onResume(  )
	self:regMsgs()
end

function ItemAttackVillageAward:onPause(  )
	self:unregMsgs()
end


function ItemAttackVillageAward:onDestroy(  )
	self:onPause()
end

function ItemAttackVillageAward:setupViews(  )
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


function ItemAttackVillageAward:updateViews(  )
	if not self.tConf then
		return
	end
	--标题
	local tStr = {}
	if self.tConf.nTargetLv > 0 then
		--击飞指定等级的城池
		tStr = {
			{text = getConvertedStr(6, 10764), color = _cc.white},
			{text = self.tConf.nTargetNum, color = _cc.green},
			{text = getConvertedStr(6, 10765), color = _cc.white},
			{text = self.tConf.nTargetLv, color = _cc.green},
			{text = getConvertedStr(6, 10766), color = _cc.white}
		}
		self.nTargetType = 2
	else
		--至少击飞任意等级的玩家城池
		tStr = {
			{text = getConvertedStr(6, 10768), color = _cc.white},
			{text = self.tConf.nTargetNum, color = _cc.green},
			{text = getConvertedStr(6, 10769), color = _cc.white}
		}
		self.nTargetType = 1
	end
	self.pTxtBanner:setString(tStr)

	--物品列表
	local tDropList = self.tConf.tAwards
	self:setGoodsListViewData(tDropList)

	local tData = Player:getActById(e_id_activity.attackvillage)
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

function ItemAttackVillageAward:setData(_tConf)
	self.tConf = _tConf
	self:updateViews()
end

function ItemAttackVillageAward:onGetClicked( pView )
	if self.isCanGet then
		SocketManager:sendMsg("reqAttackVillage", {self.tConf.nIndex}, function(__msg, __oldMsg)
			if __msg.body then
				--奖励动画展示
				showGetAllItems(__msg.body.ob, 1)
			end
		end)
	else		
		-- 跳到世界
	    sendMsg(ghd_home_show_base_or_world, 2)
	    --关闭活动a界面
	    closeDlgByType( e_dlg_index.actmodela, false)
	end
end


return ItemAttackVillageAward


