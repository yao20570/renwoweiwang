--
-- Author: liangzhaowei
-- Date: 2017-04-12 15:41:16
-- 副本 章节关卡数据

local PostData = class("PostData")

--部队类型
--en_army_type.fuben
en_army_type = {
	fuben = 1, --副本部队
	worldboss = 2, --世界Boss
	killherofight = 3, --过关斩将
}

--显示部队状态
en_army_state = {
	online = 1, --上阵中
	free   = 2, --空闲位置
	lock   = 3, --上锁位置
}

en_post_type = {
	normal 			= 0, --普通关
	gethero 		= 1, --抽将关
	fragment 		= 2, --神器碎片关
	resource 		= 3, --补给关
	equip 			= 4, --装备关
	resdrawing 		= 5, --资源田图纸关
}

function PostData:ctor()
	-- body
	self:myInit()
end

function PostData:myInit()
	--来自后端字段
	self.nId	=nil	-- 关卡id
	self.nP	    =0	-- 是否通关 0否 1是
	self.nS	    =0  	-- 通关星级
	self.nLh	=nil	-- 抽到的英雄
	self.nBh	=nil	-- 购买的英雄
	self.nF	    =0	-- 获得的国器碎片数量
	self.nRf	=nil	-- 军资补给次数
	self.nRb	=nil	-- 军资购买次数
	self.nCd	=nil  -- 军次购买入口消失CD
	self.nWd	=nil	-- 购买的装备图纸量
	self.nRd	=nil	-- 获得的资源图纸数量

	--配表字段
	self.nIndex 			= 0      --int   关卡序号 1-6
	self.nId 				= 0      --int	关卡唯一编号
	self.sName 				= ""      --string 关卡名称
	self.nType   			= 0      --int   关卡类型
	self.nChapterid 		= 0      --int 所属章节Id
	self.nPrevious 			= 0      --int 上一关卡
	self.nNext 				= 0      --int 下一关卡
	self.nExtra             = 0      --int 额外开启关卡
	self.sIcon              = "ui/daitu.png"      --str 关卡icon
	self.sTempIcon          = nil                 --str 气泡icon字段
	self.sRealBIcon         = "ui/daitu.png"      --str 真正要显示的气泡icon
	self.sBubbleType        = nil    --int 气泡类型, 1指图片, 2指武将id
	self.nOpenlv 			= 0      --int 开放等级
	self.nMonsters 			= 0      --int 守关怪物组
	self.nCost   			= 0 	 --int 胜利体力消耗
	self.nFirstexp   		= 0	     --int 首次经验
	self.nNormalExp   		= 0	     --int 正常经验
	self.nPower 			= 0      --int 推荐战力	
	self.sLotteryHero 		= nil    --str 抽将 内容	
	self.nNormaldrop 		= 0      --int 关卡掉落组
	self.nCanRepeat 		= 0      --int 是否可重复挑战
	self.nCanSweep 		    = 0      --int 是否可扫荡
	self.nCloseStar 		= 0      --int 是否结算星级
	self.nFragmentmax 		= 0      --int 碎片上限
	self.nDrawingNum 		= 0      --int 图纸数量
	self.weaponPaperCost    = 0  	--int 装备图纸价格
	self.nFeedTime          = 0  	--int 军资补给最大次数
	self.sFeedBuyCost 	    = ""      --int 军资购买花费
	self.nOpenResourceField = 0  	--int 开启的资源田
	self.sTarget            = ""    -- 目标 (国器id/)
	self.nCount 			= 0 	--int 第几关

	--自己添加
	self.nIndex 				= nil   --index 关卡序号
	
	self.bOpen                  = false --关卡是否开启	
end


function PostData:updateData( data )
	-- dump(data,"更新关卡数据：",20)
	self.nId	=     data.id   or   self.nId    	-- 关卡id
	self.nP	    =     data.p   or    self.nP	   	-- 是否通关 0否 1是
	self.nS	    =     data.s   or    self.nS	   	-- 通关星级
	self.nLh	=     data.lh   or   self.nLh    	-- 抽到的英雄
	self.nBh	=     data.bh   or   self.nBh    	-- 购买的英雄
	self.nF	    =     data.f   or    self.nF	   	-- 获得的国器碎片数量
	self.nRf	=     data.rf   or   self.nRf    	-- 军资补给次数
	self.nRb	=     data.rb   or   self.nRb    	-- 军资购买次数
	self.nCd	=     data.cd   or   self.nCd       -- 军次购买入口消失CD
	if data.cd then
		self.nLastBuyCd = getSystemTime(true)
	end
	self.nWd	=     data.wd   or   self.nWd    	-- 购买的装备图纸量
	self.nRd	=     data.rd   or   self.nRd    	-- 获得的资源图纸数量
	self.bOpen  =     true    --刷新服务端数据就说明已经开启
	self.sIcon  = self:getRealIcon() or self.sIcon

	self:closeSpLv() --根据实际情况关闭特殊关卡
end

function PostData:getBuyResCd()
	local nCd = -1
	if self.nCd then
		nCd = self.nCd - (getSystemTime(true)- self.nLastBuyCd)
		if nCd < 0 then
			nCd = 0
			self.nCd = nil
		end
	end
	return nCd
end

function PostData:initDatasByDB( data )
	self.nIndex 			= data.index or self.nIndex 				--int   关卡序号 1-6
	self.nId 				= data.id or self.nId						--int	关卡唯一编号
	self.sName 				= data.name or self.sName 					--string 关卡名称
	self.nType   			= data.type or self.nType 				    --int   关卡类型
	self.nChapterid 		= data.chapterid or self.nChapterid			--int 所属章节Id
	self.nPrevious 			= data.previous or self.nPrevious			--int 上一关卡
	self.nNext 				= data.next or self.nNext					--int 下一关卡
	self.nExtra             = data.extra or self.nExtra                 --int 额外开启关卡

	self.sBubbleType        = data.bubbletype                           --int 气泡类型,其他指图片, 2指武将id
	if data.icon then
		-- self.sIcon          = "#"..data.icon..".png"   --str 关卡icon
		self.sTempIcon          = data.icon  --str 关卡icon
	end
	-- if data.bubbleicon then
	-- 	self.sBubbleicon    = data.bubbleicon  --str 关卡icon
	-- end
	self.sIcon              = self:getRealIcon() or self.sIcon

	self.nOpenlv 			= data.openlv or self.nOpenlv				--int 开放等级
	self.nMonsters 			= data.monsters or self.nMonsters			--int 守关怪物组
	self.nCost   			= data.cost or self.nCost			        --int 胜利体力消耗

	self.nFirstexp   		= data.firstexp or self.nFirstexp			--int 首次经验
	self.nNormalExp   		= data.normalexp or self.nNormalExp			--int 正常经验
	self.nPower 			= data.power or self.nPower					--int 推荐战力	
	self.sLotteryHero 	    = data.lotteryhero or self.sLotteryHero		--str 抽将
	self.nNormaldrop 		= data.normaldrop or self.nNormaldrop		--int 关卡掉落组
	self.nCanRepeat 		= data.canrepeat or self.nCanRepeat 		--int 是否可重复挑战
	self.nCanSweep 		    = data.cansweep or self.nCanSweep		    --int 是否可扫荡
	self.nCloseStar 		= data.closeStar or self.nCloseStar  		--int 是否结算星级
	self.nFragmentmax 		= data.fragmentmax or self.nFragmentmax		--int 碎片上限
	self.nDrawingNum 		= data.drawingnum or self.nDrawingNum		--int 图纸数量
	self.nWeaponPaperCost   = tonumber(data.weaponpapercost)  or self.weaponPaperCost		--int 装备图纸价格
	self.nFeedTime          = data.feedtime or self.nFeedTime		    --int 军资补给最大次数
	self.sFeedBuyCost 	    = data.feedbuycost or self.sFeedBuyCost		--string 军资购买花费
	self.nOpenResourceField = data.openresourcefield or self.nOpenResourceField		--int 开启的资源田
	self.sTarget            = data.target            or self.sTarget    -- string 目标 (国器id/)
	self.nCount 			= data.count or self.nCount 				--int 第几关
end

--获取气泡图片
function PostData:getRealIcon()
	-- body
	local sIcon
	if self.sBubbleType == 2 then     -- 武将id(多个武将的话取品质最高的并且没有被招募过的)
		local tHeroId = luaSplit(self.sTempIcon,";")
		if table.nums(tHeroId) > 1 then
			local tShowHero = {}       -- 这里放未被招募或购买的武将
			for k, id in pairs(tHeroId) do
				if tonumber(id) ~= self.nLh then
					local tHeroData = getHeroDataById(tonumber(id))
					table.insert(tShowHero, tHeroData)
				end
			end
			--按品质高低排序
			table.sort(tShowHero, function(a, b)
				-- body
				return a.nQuality > b.nQuality
			end)
			sIcon = tShowHero[1].sIcon
		else
			local tHeroData = getHeroDataById(tonumber(tHeroId[1]))
			sIcon = tHeroData.sIcon
		end
	else
		sIcon = "#"..self.sTempIcon..".png"
	end
	return sIcon
end

--获取产出英雄列表
function PostData:getSpLvHeroList()
	local tListHero = {}
	if self.sLotteryHero then
		local tStrHero = luaSplit(self.sLotteryHero, ";")
		for k,v in pairs(tStrHero) do
			local tHero = luaSplit(v, ",")
			if table.nums(tHero)>= 2 then
				local tData = {}
				tData.nId = tonumber(tHero[1]) 
				tData.nCost = tonumber(tHero[2])
				table.insert(tListHero, tData)
			end
		end
	end
	return tListHero
end

--获取军资购买价格
function PostData:getFeedBuyCost()
	local tCost = {}
	if self.sFeedBuyCost then
		local tCoststr = luaSplit(self.sFeedBuyCost, ",")
		if tCoststr and table.nums(tCoststr)> 0 then
			for k,v in pairs(tCoststr) do
				table.insert(tCost,tonumber(v))
			end
		end
	end
	return tCost
end

--根据特殊情况关闭特殊关卡
function PostData:closeSpLv()
	--武将产出关卡
	if self.nLh and self.nBh then
		local nTnums = table.nums(self:getSpLvHeroList())
		if nTnums and (nTnums == 1) then
			if ((self.nLh > 0) or (self.nBh > 0)) then
				self.bOpen = false
			end
		else
			if ((self.nLh > 0) and (self.nBh > 0)) then
				self.bOpen = false
			end
		end
	end

	--资源田图纸关闭
	if self.nRd then
		--资源田格子下标
		local nResCell = self:getResCellIdx(self.sTarget)
		local tSuburb = Player:getBuildData():getSuburbByCell(nResCell)
		--资源田激活后入口消失
		if self:isResourceMax() and tSuburb.bActivated == true then
			self.bOpen = false
		end
	end

	--军资购买关卡
	if self.nType == en_post_type.resource then
		if (self.nRf >= self.nFeedTime) and self:getBuyResCd() <= 0 then
			self.bOpen = false
		end

		if self.nRb then
			--购买次数大于上限
			if self.nRb >= table.nums(self:getFeedBuyCost()) then
				if self.nRf >= self.nFeedTime then
					self.bOpen = false
				end
			end
		end
	end

	--国器关
	if self.nType == en_post_type.fragment then
		--已经打造了该碎片对应的神兵后才关闭入口
		local sWpTid = tonumber(self.sTarget) --神兵id
		local tWeapon = Player:getWeaponInfo():getWeaponInfoById(sWpTid)
		if self:isWpFragmentsMax() and tWeapon.nWeaponId then
			self.bOpen = false
		end
	end


	--装备关 --获得过装备图纸就关闭着特殊关卡入口 老汤说写死,要改直接打他(by 阿良)
	if self.nType == en_post_type.equip then
		if self.nWd and self.nWd > 0 then
			self.bOpen = false
		end
	end


end

--获取图纸关卡对应的资源田格子下标
function PostData:getResCellIdx(_target)
	if not _target then return nil end
	local tStr = luaSplit(_target, ":")
	--资源田格子下标
	local nResCell = tonumber(tStr[2])
	return nResCell
end

--资源田图纸是否已满
function PostData:isResourceMax()
	-- body
	if self.nRd and self.nRd >= self.nFragmentmax then
		return true
	end
	return false
end

--碎片是否已满
function PostData:isWpFragmentsMax()
	-- body
	if self.nF and self.nF >= self.nFragmentmax then
		return true
	end
	return false
end

return PostData