-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-21 11:00:51 星期五
-- Description: 建筑基础信息
-----------------------------------------------------

local Goods = require("app.data.Goods")

local Build = class("Build", Goods)


function Build:ctor(  )
	Build.super.ctor(self,e_type_goods.type_build)
	-- body
	self:buildInit()
end


function Build:buildInit(  )
	self.nCellIndex 			= 		nil 			--（int）格子下标
	self.nCanUp 				= 		nil 			--（int）是否可以升级（1可以 0不可以）
	self.nMaxLv 				= 		nil 			--（int）等级上限
	self.nCanRemove 			= 		nil 			--（int）是否可以拆除（1可以 0不可以）
	self.tOpenLimits 			= 		nil 			--（table）开放条件限制  1：0:玩家等级 / 2：建筑id：建筑等级 / 3：通关副本:0 / 4：通关任务:0
	self.nUpOrder    			= 		nil 			--（int）建筑顺序
	self.nSecUpOrder 			= 		nil             --建造顺序2
	self.sNotOpen 				= 		nil 			--未解锁说明

	self.bLocked  				= 		false 			--（int）--true：上锁， false:没未锁
	self.nState 				= 		e_build_state.free --（e_build_state）当前建筑状态
	self.tBuildActionBtns 		= 		nil 			--（table）建筑操作按钮
	self.bActivated				= 		true 	--是否已经激活 true 已经激活 false 未激活

	--升级数据
	self.fUpingCd 				= 		nil 			--（long）升级倒计时
	self.fUpingLastLoadTime 	= 		nil 			--（long）最后一次加载倒计时时间
	self.fRssTime 				= 		nil 			--（long）免费加速时间
	self.fUpingAllTime 			= 		nil 			--（long）升级总时间
	self.nUpingType 			= 		nil 			--（int）队列类型 1.默认队列 2.购买队列
	self.nHelp 					= 		nil  			-- 是否请求协助 1是0否
	self.nBuildTo 				= 		nil  			-- 募兵府改建成什么建筑(建筑类型, 只有在建筑创建中状态才有)
	self.nSurBuildTo 			= 		nil  			-- 资源田改建成什么建筑(建筑id, 只有在建筑创建中状态才有)
end


-- 用配置表DB中的数据来重置基础数据
function Build:initDatasByDB( tData )
	-- body
	self.sTid 					= 		tData.id 		--建筑id
	self.sName 					= 		tData.name 		--建筑名字
	self.sDes 					= 		tData.des 		--描述
	self.nCellIndex 			= 		tData.location 	--格子下标
	self.nCanUp 				= 		tData.islevel 	--是否可以升级（1可以 0不可以）
	self.nMaxLv 				= 		tData.maxlv 	--等级上限
	self.nCanRemove 			= 		tData.remove 	--是否可以拆除（1可以 0不可以）
	self.nUpOrder 				= 		tData.sequence  --建造顺序
	self.nSecUpOrder 			= 		tData.sequence2 --建造顺序2

	self.sNotOpen 				= 		tData.notopen 	--
	self:initOpenLimit(tData.open) 						--开放条件
end

--刷新升级数据
function Build:refreshUpingDatas( tData )
	self.sTid 					= 		tData.id or self.sTid		--建筑id
	if tData.id then
		local pBuildDBData = getBuildDataByIdFromDB(tData.id)
		self:initDatasByDB(pBuildDBData)
	end
	-- body
	self.fUpingCd 				= 		tData.cd or self.fUpingCd 			--（long）升级倒计时
	if tData.cd and tData.cd > 0 then
		self.fUpingLastLoadTime = 		getSystemTime() 			        --（long）最后一次加载倒计时时间
	end
	self.fRssTime 				= 		tData.rss or self.fRssTime 			--（long）免费加速时间
	self.fUpingAllTime 			= 		tData.nd or self.fUpingAllTime      --（long）升级总时间

	self.nLv 					= 		tData.lv or self.nLv 				--（int）刷新等级

	if tData.cd == nil or tData.cd <= 0 then
		self:setBuildState(e_build_state.free) --设置当前状态为空闲
	else
		if tData.od == 1 then  --指令类型 1.建筑升级 2.建筑拆除 3.建筑创建
			self.nState 			= 		e_build_state.uping 				--设置当前状态为升级中
		elseif tData.od == 2 then
			self.nState 			= 		e_build_state.removing 				--设置当前状态为拆除中
		elseif tData.od == 3 then
			self.nState 			= 		e_build_state.creating 				--设置当前状态为创建中
		end
	end

	self.nUpingType 			= 		tData.bd or self.nUpingType 		--（int）队列类型 1.默认队列 2.购买队列
	self.nHelp  				= 		tData.rh or self.nHelp 		        --是否请求协助 1是0否
	--如果活动升级后有loc数据进来
	if tData.loc then
		self.nCellIndex = tData.loc
	end
	self.nBuildTo 				= 		tData.rt or self.nBuildTo  			-- 募兵府改建成什么建筑(建筑类型, 只有在建筑创建中状态才有)
	self.nSurBuildTo 			= 		tData.bt or self.nSurBuildTo 		-- 资源田改建成什么建筑(建筑id, 只有在建筑创建中状态才有)
end

--设置建筑状态
function Build:setBuildState( _nState )
	-- body
	self.nState = _nState
	if self.nState == e_build_state.free then
		self.fUpingAllTime 		= 		nil 								--升级完成，把总时间设置为nil
		if self.sTid == e_build_ids.palace then
			--刷新活动红点
			sendMsg(gud_refresh_act_red)
		end
	end
end

--设置建筑升级倒计时
function Build:setUpingCd( _nCd )
	-- body
	self.fUpingCd = _nCd
end

--获得建造状态
function Build:getBuildState(  )
	-- body
	return self.nState
end

--初始化开放条件限制
function Build:initOpenLimit( _sStr )
	-- body
	if _sStr then
		self.tOpenLimits = luaSplit(_sStr, ":")
	end
end

--获得开放条件限制
function Build:getOpenLimit(  )
	-- body
	return self.tOpenLimits
end

--判断是否是满级
function Build:isBuildMaxLv(  )
	-- body
	if self.nLv < self.nMaxLv then
		return false
	else
		return true
	end
end

--获得升级所需的数据
function Build:getBuildUpLimits(  )
	-- body
	return getBuildUpLimitsFromDB(self.sTid,self.nLv)
end

--获得建筑升级时间（需求时间==总时间）
--注意：升级时间会受到多方面的影响，以后统一在这个方法里面处理
function Build:getBuildUpLvTime(  )
	-- body
	if self.fUpingAllTime then --如果存在后端发过来的总时间
		return self.fUpingAllTime
	end
	local lUpLvTime = nil
	local tUpDatas = self:getBuildUpLimits()
	if tUpDatas then
		lUpLvTime = tUpDatas.uptime
	end
	return lUpLvTime or 0
end

--获得建筑免费升级时间
--注意：升级时间会受到多方面的影响，以后统一在这个方法里面处理
function Build:getBuildUpLvFreeTime(  )
	-- body
	local lAllFree = 0
	--Vip免费时间
	local lRssVipTime = 0
	--获取Vip数据
	local tCurVip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
	if tCurVip then
		lRssVipTime = tCurVip.bulidspeed or 0
	end
	lAllFree = lAllFree + lRssVipTime

	return lAllFree
end

--获得金币完成所需要的值
--注意：加速消耗金币会受到多方面影响，统一处理，统一调用
function Build:getBuildFinishValue(  )
	-- body
	--完成需要的时间
	local lAllTime = self:getBuildUpLvTime()
	--获取建造buff
	local tBuildBuffVos = Player:getBuffData():getBuildBuffList()
	if tBuildBuffVos then
		if table.nums(tBuildBuffVos) > 0 then
			for nId, vo in pairs(tBuildBuffVos) do
				local tBuffData = getBuffDataByIdFromDB(nId)
				for k, v in pairs(tBuffData.tEffects) do
					lAllTime = (1 - tonumber(v[2])) * lAllTime
				end
			end
		end
	end
	--免费总时间
	local lAllFree = self:getBuildUpLvFreeTime()
	local fLeftSec = lAllTime - lAllFree
	return getGoldByTime(fLeftSec)
end

--获得当前金币完成所需要的值
--注意：加速消耗金币会受到多方面影响，统一处理，统一调用
function Build:getBuildCurrentFinishValue(  )
	-- body
	--完成需要的时间
	local lCurLeftTime = self:getBuildingFinalLeftTime()
	return getGoldByTime(lCurLeftTime)
end

-- 获取建筑升级剩下时间
-- return(int):返回剩余时长
function Build:getBuildingFinalLeftTime(  )
	if self.fUpingCd == nil then
		return 0
	end
	-- 单位是秒
	local fCurTime = getSystemTime()
	-- 总共剩余多少秒
	local fLeft = self.fUpingCd - (fCurTime - self.fUpingLastLoadTime)
	local fOverTime = nil --完成超时时间
	if(fLeft < 0) then 
		fOverTime = fLeft
		fLeft = 0
	end
	return fLeft, fOverTime
end

--目前是否可以升级
--nType: 是否需要建筑队列是否满足 1：需要 2：不需要
function Build:isBuildCanUp( nType )
	if self:getIsLocked() then
		return false, {getConvertedStr(3, 10433)}
	end

	nType = nType or 1
	local tTips = {}
	local bCan = true
	local nresId = nil
	local nTipIndex = 1
	if self:isBuildMaxLv() == true then
		bCan = false
		tTips[nTipIndex] = string.format(getConvertedStr(6,10535), self.sName) 
		nTipIndex = nTipIndex + 1
	end

	local tLimits = self:getBuildUpLimits()
	if tLimits then
		if nType == 1 then
			--建筑队列
			local nState = Player:getBuildData():getBuildingQueState()
			if nState ~= 0 then
				bCan = false
				tTips[nTipIndex] = getConvertedStr(1,10103)
				nTipIndex = nTipIndex + 1
			end 
		end		
		--主公等级限制
		if tonumber(tLimits.playerlv) > 0 then
			if Player:getPlayerInfo().nLv < tonumber(tLimits.playerlv) then
				bCan = false
				tTips[nTipIndex] = getConvertedStr(1,10104)
				nTipIndex = nTipIndex + 1
			end
		end
		--王宫等级限制
		if tonumber(tLimits.palacelv) > 0 then
			local pPalace = Player:getBuildData():getBuildById(e_build_ids.palace)
			if pPalace then
				if pPalace.nLv < tonumber(tLimits.palacelv) then
					bCan = false
					tTips[nTipIndex] = getConvertedStr(1,10105)
					nTipIndex = nTipIndex + 1
				end
			end
		end
		--铜
		if tonumber(tLimits.coincost) > 0 then
			if Player:getPlayerInfo().nCoin < tonumber(tLimits.coincost) then
				bCan = false
				tTips[nTipIndex] = string.format(getConvertedStr(1,10106),getConvertedStr(1, 10091))
				nTipIndex = nTipIndex + 1
				nresId = e_resdata_ids.yb
			end
		end
		--木
		if tonumber(tLimits.woodcost) > 0 then
			if Player:getPlayerInfo().nWood < tonumber(tLimits.woodcost) then
				bCan = false
				tTips[nTipIndex] = string.format(getConvertedStr(1,10106),getConvertedStr(1, 10092))
				nTipIndex = nTipIndex + 1
				nresId = e_resdata_ids.mc
			end
		end
	end
	return bCan, tTips, nresId
	
end

--通过建筑状态获取建筑操作按钮
--_nState：状态
function Build:getBuildActionBtnsByState( _nState )
	-- body
	-- if not self.tBuildActionBtns then
		self.tBuildActionBtns = {}
		--从配表中查询
		local sAction = getBuildActionBtnFromDB(self.sTid)
		if sAction then
			local tTemp = luaSplitMuilt(sAction,";","|",":")
			if tTemp and table.nums(tTemp) > 0 then
				for k, v in pairs (tTemp) do
					if type(v[2]) ~= "table" then
						self.tBuildActionBtns[v[1]] = {v[2]}
					else
						self.tBuildActionBtns[v[1]] = v[2]
					end
				end
			end
		end
	-- end
	return self.tBuildActionBtns[tostring(_nState)]
end

--获取建筑是否上锁
function Build:getIsLocked( )
	return self.bLocked
end


return Build
