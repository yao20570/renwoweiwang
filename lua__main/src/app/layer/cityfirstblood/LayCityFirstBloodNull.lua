----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-24 11:39:27
-- Description: 城池首杀 未杀
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local LayCityFirstBloodReward = require("app.layer.cityfirstblood.LayCityFirstBloodReward")
local LayCityFirstBloodNull = class("LayCityFirstBloodNull", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function LayCityFirstBloodNull:ctor(  )
	--解析文件
	parseView("lay_city_first_blood_null", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LayCityFirstBloodNull:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LayCityFirstBloodNull", handler(self, self.onLayCityFirstBloodNullDestroy))
end

-- 析构方法
function LayCityFirstBloodNull:onLayCityFirstBloodNullDestroy(  )
    self:onPause()
end

function LayCityFirstBloodNull:regMsgs(  )
end

function LayCityFirstBloodNull:unregMsgs(  )
end

function LayCityFirstBloodNull:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function LayCityFirstBloodNull:onPause(  )
	self:unregMsgs()
end

function LayCityFirstBloodNull:setupViews(  )
	local pLayReward = self:findViewByName("lay_reward")
	self.pReward = LayCityFirstBloodReward.new()
	pLayReward:addView(self.pReward)
	centerInView(pLayReward, self.pReward)

	self.pTxtTip = self:findViewByName("txt_bottom_tip")

	local pLayBtn = self:findViewByName("lay_btn_go")
	self.pBottomBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10162))
	self.pBottomBtn:onCommonBtnClicked(handler(self, self.onBottomClicked))
end

function LayCityFirstBloodNull:updateViews(  )
	if not self.nKind then
		return
	end

	-- 开州后可攻打			
	-- 开启阿房宫后可攻打			
	-- 以上两句提示，分别对应4-6,7类型城池		
	local nWorldOpenState = Player:getWorldData():getWorldOpenState()
	if self.nKind >= e_kind_city.zhouxian and self.nKind <= e_kind_city.zhoucheng then
		if nWorldOpenState >= 1 then 
			self.pTxtTip:setString(getConvertedStr(3, 10539))
			setTextCCColor(self.pTxtTip, _cc.pwhite)
			self.pBottomBtn:setBtnEnable(true)
		else
			self.pTxtTip:setString(getConvertedStr(3, 10537))
			setTextCCColor(self.pTxtTip, _cc.red)
			self.pBottomBtn:setBtnEnable(false)
		end
	elseif self.nKind == e_kind_city.mingcheng then
		if nWorldOpenState >= 2 then 
			self.pTxtTip:setString(getConvertedStr(3, 10539))
			setTextCCColor(self.pTxtTip, _cc.pwhite)
			self.pBottomBtn:setBtnEnable(true)
		else
			self.pTxtTip:setString(getConvertedStr(3, 10538))
			setTextCCColor(self.pTxtTip, _cc.red)
			self.pBottomBtn:setBtnEnable(false)
		end
	else
		self.pTxtTip:setString(getConvertedStr(3, 10539))
		setTextCCColor(self.pTxtTip, _cc.pwhite)
		self.pBottomBtn:setBtnEnable(true)
	end

	----------------------------------------------
	if self.bIsFromTotal then --从总览过来
		self.pTxtTip:setVisible(false)
		self.pBottomBtn:setVisible(false)
	else
		--玩家所在区域时显示
		local nMyBlockId = Player:getWorldData():getMyCityBlockId()
		if self.nBlockId == nMyBlockId then
			self.pTxtTip:setVisible(true)
			self.pBottomBtn:setVisible(true)
		else
			self.pTxtTip:setVisible(false)
			self.pBottomBtn:setVisible(false)
		end
	end
end

--nKind:城池类型
--nBlockId:指定国家区域
--bIsFromTotal:是否从总览过来
function LayCityFirstBloodNull:setData( nKind, nBlockId, bIsFromTotal )
	self.nKind = nKind
	self.nBlockId = nBlockId
	self.bIsFromTotal = bIsFromTotal
	self.pReward:setData(self.nKind)
	self:updateViews()
end

function LayCityFirstBloodNull:onBottomClicked( )
	--直接定位
	local function locationToTarget( nSysCityId  )
		local tCityData = getWorldCityDataById(nSysCityId)
		if tCityData then
    		sendMsg(ghd_world_location_mappos_msg, {fX = tCityData.tMapPos.x, fY = tCityData.tMapPos.y, isClick = true})
    		closeAllDlg()
    	end
    end

    --主逻辑
	local nWorldOpenState = Player:getWorldData():getWorldOpenState()
	local nMyBlockId = Player:getWorldData():getMyCityBlockId()

	local tCityDataDict = getWorldCityData()
	if nWorldOpenState == 0 then --开郡
		--跳1~3 
		for nSysCityId,tCityData in pairs(tCityDataDict) do
			if tCityData.map == nMyBlockId and tCityData.kind == self.nKind then
				locationToTarget(nSysCityId)
				return
			end
		end
	elseif nWorldOpenState == 1 then --开州
		local tBlockData = getWorldMapDataById(nMyBlockId)
		if not tBlockData then
			return
		end
		--要跳转的是州
		if self.nKind >= e_kind_city.zhouxian and self.nKind <= e_kind_city.zhoucheng then
			if tBlockData.type == e_type_block.jun then --自己当前在郡
				for nSysCityId,tCityData in pairs(tCityDataDict) do
					if tCityData.map == tBlockData.subordinate and tCityData.kind == self.nKind then
						locationToTarget(nSysCityId)
						return
					end
				end
			elseif tBlockData.type == e_type_block.zhou then --当前在州
				for nSysCityId,tCityData in pairs(tCityDataDict) do
					if tCityData.map == nMyBlockId and tCityData.kind == self.nKind then
						locationToTarget(nSysCityId)
						return
					end
				end
			end
		else --要跳的是郡（只能是郡，因为宫还没开)
			--跳1~3 
			local tBlockData = getWorldMapDataById(nMyBlockId)
			if not tBlockData then
				return
			end
			if tBlockData.type == e_type_block.jun then --自己当前在郡
				for nSysCityId,tCityData in pairs(tCityDataDict) do
					if tCityData.map == nMyBlockId and tCityData.kind == self.nKind then
						locationToTarget(nSysCityId)
						return
					end
				end
			elseif tBlockData.type == e_type_block.zhou then --当前在州
				local tBlockDataDict = getWorldMapData()
				for k,v in pairs(tBlockDataDict) do
					if v.subordinate == nMyBlockId then
						for nSysCityId,tCityData in pairs(tCityDataDict) do
							if tCityData.map == v.id and tCityData.kind == self.nKind then
								locationToTarget(nSysCityId)
								return
							end
						end
					end
				end
			end
		end
	elseif nWorldOpenState == 2 then --开了宫 哪里都可以去
		--先优先级自己所在的区域
		for nSysCityId,tCityData in pairs(tCityDataDict) do
			if tCityData.map == nMyBlockId and tCityData.kind == self.nKind then
				locationToTarget(nSysCityId)
				return
			end
		end

		--其次再跳转任意区域
		for nSysCityId,tCityData in pairs(tCityDataDict) do
			if tCityData.kind == self.nKind then
				locationToTarget(nSysCityId)
				return
			end
		end
	end
end

return LayCityFirstBloodNull


