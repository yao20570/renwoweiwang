--
-- Author: liangzhaowei
-- Date: 2017-04-12 18:23:34
-- 副本数据

local Goods = require("app.data.Goods")


local DataFunbenData = class("DataFunbenData", Goods)


function DataFunbenData:ctor()
	DataFunbenData.super.ctor(self,e_type_goods.type_fuben)
	self:myInit()
	self:initDatasByDB()
	self.nLastFubenChapter = nil --上次打开的副本章节
end

-- 初始化成员变量
function DataFunbenData:myInit()

	self.tAllChapter = {} --所有章节数据
	self.tAllPost    = {} --所有关卡数据

	-- self.tChpaters = {} --服务器的章节信息
	-- self.tOutposts = {} --服务器的关卡信息

	-- self.tOpenChpaters = {} --开启的章节信息

	self.nPreOpenChapter = nil --上次已开启的章节
end

--设置上次打开的副本章节
function DataFunbenData:setLastEnterChapter(_nId)
	-- body
	self.nLastFubenChapter = _nId
end

function DataFunbenData:getLastEnterChapter()
	-- body
	return self.nLastFubenChapter
end

-- 刷新来自服务器的数据
function DataFunbenData:refreshDatasByService( _tData )
	if not _tData then
		return
	end
	-- dump(_tData,"_tData",30)

	-- self.tChpaters =  _tData.chpaters or self.tChpaters --所有章节信息

	--新开启的关卡
	self:setNewPostOpen(_tData.openOps)
	if _tData.openOps then
		for _, postid in pairs(_tData.openOps) do
			--关卡数据
			local tPost = self:getLevelById(postid)
			--如果开启了神器碎片关卡请求一下神器数据
			if tPost.nType == en_post_type.fragment then
				SocketManager:sendMsg("loadAllWeaponData", {})
			end
		end
	end

	if _tData.chapters then
		self:refreshChpaters(_tData.chapters) --刷新章节信息
	end


	if _tData.outposts then
		--删掉不开启特殊关卡
		for i=#_tData.outposts,1, -1 do
			if getIsNotShowOutposts(_tData.outposts[i].id) then
				table.remove(_tData.outposts, i)
			end
		end

		self:refreshOutposts(_tData.outposts) --刷新关卡信息
	end

	--特殊关卡
	if _tData.op then
		self:refreshConscribeData(_tData.op) --刷新关卡信息
	end

	if _tData.o then
		self:refreshConscribeData(_tData.o)  --刷新关卡信息
	end

	self.tOutposts = _tData.outposts  or  self.tOutposts --关卡信息

	sendMsg(gud_refresh_fuben) --通知刷新界面
	
	
end

-- 用配置表DB中的数据来重置基础数据
function DataFunbenData:initDatasByDB()
	self.tAllChapter= getAllChapterFromDB() --所有章节数据
	self.tAllPost = getAllPostFromDB()--所有关卡数据

	
	--关联章节与关卡数据
	for k,v in pairs(self.tAllChapter) do
		local tPost = {}
		for x,y in pairs(self.tAllPost) do
			if y.nChapterid == v.nId then
				table.insert(tPost,y)
			end
		end
		v.tPost = tPost --章节所有关卡

		--根据关卡唯一id重新排序
		table.sort(v.tPost, function (a,b)
			return a.nId < b.nId
		end )

	end
end

function DataFunbenData:getAllChapter()
	-- body
	return self.tAllChapter
end

function DataFunbenData:getAllPost()
	-- body
	return self.tAllPost
end

--刷新开启章节的信息
function DataFunbenData:refreshChpaters(_data)
	if not _data then
		return
	end

	--删掉不开启特殊关卡
	for k,v in pairs(_data) do
		if v.so then
			for i=#v.so,1, -1 do
				if getIsNotShowOutposts(v.so[i].id) then
					table.remove(v.so, i)
				end
			end
		end
		if v.co then
			for i=#v.co,1, -1 do
				if getIsNotShowOutposts(v.co[i]) then
					table.remove(v.co, i)
				end
			end
		end
	end

	--刷新开启章节数据
	-- self.tOpenChpaters = {}
	local nOpened = #_data
	if nOpened > 0 then
		for k,v in pairs(_data) do
			for x,y in pairs(self.tAllChapter) do
				if v.id == y.nId  then --开启判断
					y:updateData(v)
					y.bOpen = true --如果有服务端数据就说明此章节已经开启
				end
			end

		end

	end

	local tOpenedChpter = self:getOpenChpater()
	local nOpenedNum = #tOpenedChpter

	--是否有新的章节开启
	if self.nPreOpenChapter and nOpenedNum > self.nPreOpenChapter then
		--通知界面显示特效
		sendMsg(gud_refresh_fuben_arrowtx)
	end
	self.nPreOpenChapter = nOpenedNum


end

--刷新关卡信息
function DataFunbenData:refreshOutposts(_data)
	for k,v in pairs(_data) do
		local tPosts = self:getLevelById(v.id)
		if tPosts.updateData then
			tPosts:updateData(v)
		end
	end
end

--刷新单个关卡信息
function DataFunbenData:refreshConscribeData(_data)
	local tPosts = self:getLevelById(_data.id)
	if tPosts.updateData and _data then
		tPosts:updateData(_data)
	end
end

--保存新关卡开启列表
function DataFunbenData:setNewPostOpen(_tData)
	--删掉不开启特殊关卡
	if _tData then
		for i=#_tData,1, -1 do
			if getIsNotShowOutposts(_tData[i]) then
				table.remove(_tData, i)
			end
		end
	end
	-- body
	self.tOpenPost = _tData
end

--获取新关卡开启列表
function DataFunbenData:getNewPostOpen()
	-- body
	return self.tOpenPost
end

--保存当前挑战的关卡id和英雄列表
function DataFunbenData:saveChanllengeId(_id, _hsids)
	self.nChallengeId = _id
	self.tHeroIdList = _hsids or {}
end

--获取所挑战的关卡id
function DataFunbenData:getChanllengeId()
	return self.nChallengeId, self.tHeroIdList
end

--保存挑战类型(挑战为1, 扫荡为2)
function DataFunbenData:saveChanllengeType(_type)
	self.nChallengeType = _type
end

--获取挑战类型
function DataFunbenData:getChanllengeType()
	return self.nChallengeType or 1
end


--获取开启章节 _data 章节数据
function DataFunbenData:getIsOpenChpater(_data)
	local bOpen = true
	--逻辑暂时未实现
	bOpen = _data.bOpen

	return bOpen
end

--获取开启章节队列数据
function DataFunbenData:getOpenChpater()
	local tOpenChpaters = {}
	for k,v in pairs(self.tAllChapter) do
		if self:getIsOpenChpater(v) then
			table.insert(tOpenChpaters,v)
		end
	end
	return tOpenChpaters
end

--获取需要显示的章节数据(包括所有已开启的章节数据和一个未开启的章节)
function DataFunbenData:getShowChapter()
	-- body
	local tShowChpaters = {}
	for k,v in pairs(self.tAllChapter) do
		if self:getIsOpenChpater(v) then
			table.insert(tShowChpaters,v)
		else
			table.insert(tShowChpaters,v)
			break
		end
	end
	return tShowChpaters
end

--获取开启的章节的最大章节
function DataFunbenData:getNearestOpenChapter()
	-- body
	return table.nums(self:getOpenChpater())
end

-- 获取整个章节的普通关卡的列表by章节id
function DataFunbenData:getNormalLevelBySectionId(_id)
	-- body
	local tNormalLevel = {}
	for k,v in pairs(self.tAllPost) do
		if (v.nChapterid == _id) and (v.nType == 0) then
			table.insert(tNormalLevel, v)
		end
	end
	--根据关卡唯一id重新排序
	table.sort( tNormalLevel, function (a,b)
		return a.nId < b.nId
	end )

	return tNormalLevel
end

-- 获取整个章节的特殊关卡的列表by章节id(已开启的)
function DataFunbenData:getSpecialLevelBySectionId(_id)
	-- body
	local tSpecialLevel = {}
	for k,v in pairs(self.tAllPost) do
		if (v.nChapterid == _id) and (v.nType ~= 0) and (v.bOpen) then
			table.insert(tSpecialLevel, v)
		end
	end
	--根据关卡唯一id重新排序
	table.sort( tSpecialLevel, function (a,b)
		return a.nId < b.nId
	end )

	return tSpecialLevel
end


--获取章节by唯一id
function DataFunbenData:getSectionById(_id)
	local tSection = {}
	for k,v in pairs(self.tAllChapter) do
		if _id == v.nId then
           tSection = v
		end
	end
	return tSection
end

--获取关卡by唯一 _id
function DataFunbenData:getLevelById(_id)
	local tLevel = {}
	for k,v in pairs(self.tAllPost) do
		if v.nId == _id then
           tLevel = v
           break
		end
	end
	return tLevel
end

--获得上一个章节的数据 _tData 当前关卡数据
function DataFunbenData:getLastSectionData(_tData)
	local tSectionData = nil
	if not _tData then
		return
	end
	local tOpenSectionData = self:getOpenChpater()
	for k,v in pairs(tOpenSectionData) do
		if v.nId ==  _tData.nPrevious then -- 上一章节id
			tSectionData = v
		end
	end
	return tSectionData
end

--获得下一个章节的数据
function DataFunbenData:getNextSectionData(_tData)
	local tSectionData = nil
	if not _tData then
		return
	end	
	local tOpenSectionData = self:getOpenChpater()
	for k,v in pairs(tOpenSectionData) do
		if v.nId ==  _tData.nNext then -- 下章节id
			tSectionData = v
		end
	end
	return tSectionData
end

--获取章节是否有已开启的补给关
--_nId:章节id
function DataFunbenData:getHasOpenedSupply(_nId)
	-- body
	local tSection = self:getSectionById(_nId)
	for k, v in pairs(tSection.tPost) do
		--nType为0是普通关, 其他为额外关卡
		if v.nType ~= 0 and v.bOpen then
			return true
		end
	end
	return false
end

--获取特殊关卡是由哪个关卡解锁的
--_nId:关卡id
function DataFunbenData:getLockMyData(_nId)
	-- body
	local tMyData = self:getLevelById(_nId)
	--通过自己所属章节id找到该章节所有数据
	local tSectionData = self:getSectionById(tMyData.nChapterid)
	for k, v in pairs(tSectionData.tPost) do
		if v.nExtra == _nId then
			return v
		end
	end

end

--获取点击未解锁章节的提示
--_id:章节唯一id
function DataFunbenData:getLockedTip(_id, _nOpLv)
	--默认通关上个章节解锁
	local str = getConvertedStr(7, 10139)
	local tSection = self:getSectionById(_id)
	if tSection.nX >= tSection.nY then
		str = string.format(getTipsByIndex(10077), _nOpLv)
	end
	return str
end

return DataFunbenData