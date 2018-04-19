-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-15 14:22:41 星期三
-- Description: 查表操作
-----------------------------------------------------


local PostData = require("app.layer.fuben.PostData")
local DataHero = require("app.layer.hero.data.DataHero")
local HeroAtt = require("app.layer.hero.data.HeroAtt")
local DataNpcWall = require("app.layer.wall.DataNpcWall")
local Npc = require("app.data.npc.Npc")
local ResData = require("app.data.ResData")
local Tnoly = require("app.layer.technology.data.Tnoly")
local Buff = require("app.data.Buff")
local IconData = require("app.data.IconData")
local BoxData = require("app.data.BoxData")
local TitleData = require("app.data.TitleData")
local TechData = require("app.data.TechData")

local ChapterData = require("app.layer.fuben.ChapterData")

local ItemStuffData = require("app.layer.bag.ItemStuffData")
local ItemEquipData = require("app.layer.bag.ItemEquipData")

local BTaskItemData = require("app.layer.task.BTaskItemData")
local DataChatprtTatget = require("app.layer.task.data.DataChatperTarget")
local HonorTask = require("app.layer.country.data.HonorTask")
local WeaponBData = require("app.layer.weapon.WeaponBData")

local DataOfficial = require("app.layer.palace.DataOfficial")
local DataResearcher = require("app.layer.palace.DataResearcher")
local DataSmith = require("app.layer.palace.DataSmith")
local RemainsTaskVo = require("app.layer.remains.RemainsTaskVo")

local tGlobleParam = {} -- 全局表的临时数据
-- 获取一些全局参数, 比如角色名长度
function getGlobleParam( _key )
	-- body
	if(tGlobleParam[_key]) then
		return tGlobleParam[_key]
	end
	for data in execForRows(Player.gamedb, "select * from avatar_init where key = \'" .. _key .. "\'") do
		tGlobleParam[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in avatar_init db")
	return -1
end

--获取玩家头像
local tAvatarIcon = {}
function getAvatarIcon( _key )
	if not _key then
		return
	end
	if(tAvatarIcon[_key]) then
		return tAvatarIcon[_key]
	end
	for data in execForRows(Player.gamedb, "select * from avatar_icon where id = \'" .. _key .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tAvatarIcon[_key] = data
		return tAvatarIcon[_key] 
	end
	print("cannot find \"" .. _key .. "\" in avatar_icon db")
	return nil
end
--获取所有Icon数据
local tIconDatas = nil
function getAllIconsData(  )
	-- body
	if not tIconDatas then
		tIconDatas = {}
		local tTemp = execForTable(Player.gamedb, "select * from avatar_icon;")	
		--dump(tTemp, "tTemp", 100)
		for k, v in pairs(tTemp) do
			if not tIconDatas[v.id] then
				local pIconData = IconData.new()
				pIconData:initDatasByDB(v)
				tIconDatas[v.id] = pIconData
			end
		end		
	end
	local tList = {}
	if tIconDatas and table.nums(tIconDatas) > 0 then
		for k, v in pairs(tIconDatas) do 
			table.insert(tList, copyTab(v))
		end
	end	
	return tList			
end

--获取聊天都想框
local tAvatarBoxIcon = {}
function getAvatarBoxIcon( _key )
	if not _key then
		return
	end
	if(tAvatarBoxIcon[_key]) then
		return tAvatarBoxIcon[_key]
	end
	for data in execForRows(Player.gamedb, "select * from avatar_box where id = \'" .. _key .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tAvatarBoxIcon[_key] = data
		return tAvatarBoxIcon[_key] 
	end
	print("cannot find \"" .. _key .. "\" in avatar_box db")
	return nil
end
--获取所有Icon数据
local tBoxDatas = nil
function getAllBoxsData(  )
	-- body
	if not tBoxDatas then
		tBoxDatas = {}
		local tTemp = execForTable(Player.gamedb, "select * from avatar_box;")	
		--dump(tTemp, "tTemp", 100)
		for k, v in pairs(tTemp) do
			if not tBoxDatas[v.id] and tonumber(v.show or 0) > 0 then
				local pIconData = BoxData.new()
				pIconData:initDatasByDB(v)
				tBoxDatas[v.id] = pIconData
			end
		end		
	end
	local tList = {}
	if tBoxDatas and table.nums(tBoxDatas) > 0 then
		for k, v in pairs(tBoxDatas) do 
			table.insert(tList, copyTab(v))
		end
	end	
	return tList	
end
--获取头像称号
local tAvatarTitles = {}
function getAvatarTitle( _key )
	-- body
	if not _key then
		return
	end
	if(tAvatarTitles[_key]) then
		return tAvatarTitles[_key]
	end
	for data in execForRows(Player.gamedb, "select * from avatar_title where id = \'" .. _key .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tAvatarTitles[_key] = data
		return tAvatarTitles[_key] 
	end
	print("cannot find \"" .. _key .. "\" in avatar_title db")
	return nil	
end
--获取所有称号数据
local tTitleDatas = nil
function getAllTitlesData()
	-- body	
	if not tTitleDatas then
		tTitleDatas = {}
		local tTemp = execForTable(Player.gamedb, "select * from avatar_title;")	
		--dump(tTemp, "tTemp", 100)
		for k, v in pairs(tTemp) do
			if not tTitleDatas[v.id] and tonumber(v.show or 0) > 0 then
				local pTitleData = TitleData.new()
				pTitleData:initDatasByDB(v)
				tTitleDatas[v.id] = pTitleData
			end
		end		
	end
	local tList = {}
	if tTitleDatas and table.nums(tTitleDatas) > 0 then
		for k, v in pairs(tTitleDatas) do 
			table.insert(tList, copyTab(v))
		end
	end	
	return tList
end

--系统开放表
local tOpenSystem = {}
function getOpenSystem( nId )
	if(tOpenSystem[nId]) then
		return tOpenSystem[nId]
	end
	for data in execForRows(Player.gamedb, "select * from open_system where id = \'" .. nId .. "\'") do
		tOpenSystem[nId] = data
		return tOpenSystem[nId] 
	end
	print("cannot find \"" .. nId .. "\" in open_system db")
	return nil
end


local tTipsByIndex = {} -- 提示语配表临时数据
-- 从表中获取错误信息
-- nId（int）：错误信息的状态码
function getTipsByIndex( nId )
	local sStr = getConvertedStr(1, 10000)
	if(tTipsByIndex[nId]) then
		if nId< 10000 then --提示文本不显示
			myprint("错误id为=" .. nId)
		end
		return tTipsByIndex[nId]
	end
	local tTemp = execForTable(Player.gamedb, "select * from tips_base where tip_index = \'" .. nId .. "\';")
	if nId< 10000 then --提示文本不显示
		myprint("错误id为=" .. nId)
	end
	for i, v in pairs(tTemp) do
		sStr = v.content
		tTipsByIndex[nId] = sStr
	end
	return sStr 
end


local tTipSoldierByLv = nil -- 提示语配表临时数据
-- 从表中获取错误信息
-- nId（int）：错误信息的状态码
function getTipSoldierByLv( nLv )
	if not nLv then
		return
	end
	if not tTipSoldierByLv then
		tTipSoldierByLv = {}
		local tTemp = execForTable(Player.gamedb, "select * from tips_soldier ;")	
		for k, v in pairs(tTemp) do
			tTipSoldierByLv[v.tip_index] = v
		end
	end
	local tData = {}
	for k, v in pairs(tTipSoldierByLv) do
		if v.start <= nLv then
			table.insert(tData, v.content)
		end
	end
	return tData
end

local tDisplayParam = {} -- 建筑全局表的临时数据
-- 获取一些全局参数, 比如角色名长度
function getDisplayParam( _key )
	-- body
	if(tDisplayParam[_key]) then
		return tDisplayParam[_key]
	end
	for data in execForRows(Player.gamedb, "select * from display_init where key = \'" .. _key .. "\'") do
		tDisplayParam[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in item_base db")
	return -1
end

-- 根据配表id，分段读取获得Goods数据(需要继承Goods结构)
-- sTid（int）：配表id
function getGoodsByTidFromDB( sTid )
	local pGoods = nil 
	
	if(sTid) then
		local nNum = tonumber(sTid)
		if(nNum >= 1 and nNum <= 199) then -- 资源
			pGoods = getItemResourceData(nNum)
		elseif(nNum >= 201 and nNum <= 299) then   -- 神兵
			pGoods = getBaseWeaponDataByID(nNum)
		elseif(nNum >= 1001 and nNum <= 1099) then -- 地图
		elseif(nNum >= 2001 and nNum <= 2999) then -- 装备
			pGoods = getBaseEquipDataByID(nNum)
		elseif(nNum >= 3001 and nNum <= 3999) then --科技
			pGoods = getTnolyByIdFromDB(nNum)
		elseif(nNum >= 10000 and nNum <= 10999) then -- 建筑
			--建筑由于比较特殊 不在这里获取
			-- pGoods = getBuildDataByIdFromDB(sTid)
		elseif (nNum >= 11001 and nNum <= 11999) then -- 城池
		elseif (nNum >= 12001 and nNum <= 12999) then -- 矿点
		elseif(nNum >= 13001 and nNum <= 13999) then -- 乱军
		elseif(nNum >= 20001 and nNum <= 29999) then -- 任务
		elseif(nNum >= 30001 and nNum <= 39999) then -- buff
			pGoods = getBuffDataByIdFromDB(nNum)
		elseif(nNum >= 50001 and nNum <= 70000) then -- 掉落id
		elseif(nNum >= 70001 and nNum <= 89999) then -- 怪物组
		elseif(nNum >= 700001 and nNum <= 999999) then -- 怪物
			pGoods = getNPCData(nNum)
		elseif(nNum >= 100001 and nNum <= 129999) then -- 物品
			pGoods = getBaseItemDataByID(nNum)
		elseif(nNum >= 130000 and nNum <= 139999) then --头像id
		elseif(nNum >= 140000 and nNum <= 149999) then --头像框id	
		elseif(nNum >= 200001 and nNum <= 299999) then -- 英雄
			pGoods = getHeroDataById(nNum)
		end
	end
	return pGoods 
end

--判断物品是否属于资源
--配表id
function getGoodsIsResouce( nTid )
	if(nTid >= 1 and nTid <= 199) then
		return true
	end
	return false
end

-------------------------------Buff相关--------------------------------------------------
local tGetBuffDataById = {} -- 临时数据
-- 获取buff数据
-- _nId: Buff 的id
function getBuffDataByIdFromDB( _nId)
	if not _nId then
		return
	end
	_nId = tonumber(_nId)
	local tBuffData = nil
	if (tGetBuffDataById[_nId]) then
		tBuffData = Buff.new()
		tBuffData:initDatasByDB(tGetBuffDataById[_nId])
		return tBuffData
	end
	for data in execForRows(Player.gamedb, "select * from buff_base where id = \'" .. _nId .. "\'") do
  		if (data) then
  			tBuffData = Buff.new()
  			tBuffData:initDatasByDB(data)
  			tGetBuffDataById[_nId] = data
  			break
  		end
    end
    return tBuffData
end

local tGetEffectDataById = {} -- 临时数据
-- 获取Effect数据
-- _nId: effect的id
function getEffectDataByIdFromDB( _nId)
	if not _nId then
		return
	end
	_nId = tonumber(_nId)
	if (tGetEffectDataById[_nId]) then
		return tGetEffectDataById[_nId]
	end
	local tEffectData = nil
	for data in execForRows(Player.gamedb, "select * from buff_key where id = \'" .. _nId .. "\'") do
  		if (data) then
  			tEffectData = data
  			tGetEffectDataById[_nId] = tEffectData
  			break
  		end
    end
    return tEffectData
end

-------------------------------Buff相关--------------------------------------------------

-------------------------------科技相关--------------------------------------------------
local tTnolyInitData = {}
function getTnolyInintDataFromDB(_key)
	if(tTnolyInitData[_key]) then
		return tTnolyInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from science_init where key = \'" .. _key .. "\'") do
		if _key == "artifactCrits" then
			local tStr = luaSplit(data.value,";")
			local tData = {}
			for i=1,#tStr do
				local tTempStr = luaSplit(tStr[i],":")
				tData[tonumber(tTempStr[1])] = tTempStr[2]
			end
			tTnolyInitData[_key] = tData
		else
			tTnolyInitData[_key] = data.value
		end
		return tTnolyInitData[_key]
	end
	return nil
end

--科技临时数据表
local tAllTechnologyFromDB = {} -- 建筑的临时数据
-- 获取所有的建筑
function getAllTechnologyFromDB( )
	local t = {}
	if(tAllTechnologyFromDB and table.nums(tAllTechnologyFromDB) > 0) then
		for k, v in pairs (tAllTechnologyFromDB) do
			local tnoly = Tnoly.new()
			tnoly:initDatasByDB(v)
			t[tnoly.sTid] = tnoly
		end
	else
		local tTemp = execForTable(Player.gamedb, "select * from science_base ;")
		for i, v in pairs(tTemp) do
			local tnoly = Tnoly.new()
			tnoly:initDatasByDB(v)
			t[tnoly.sTid] = tnoly
			tAllTechnologyFromDB[tnoly.sTid] = v
		end
	end
	if(not t or table.nums(t) <= 0) then
		t = nil
	end
	return t
end

--根据id获取科技
function getTnolyByIdFromDB( _nId )
	-- body
	if not _nId then
		return
	end
	local tnoly = nil
	if(tAllTechnologyFromDB and table.nums(tAllTechnologyFromDB) > 0) then
		if tAllTechnologyFromDB[_nId] then
			tnoly = Tnoly.new()
			tnoly:initDatasByDB(tAllTechnologyFromDB[_nId])
		end
	else
		--科技是无论怎么样都需要获得所以科技数据的，所以这里可以直接通过获得所有科技，然后根据id查询，其他模块需要根据id从配表中查询出来
		local tAllTnolys = getAllTechnologyFromDB()
		if tAllTnolys then
			tnoly = tAllTnolys[_nId]
		end
	end
	return tnoly
end

local tTnolyUpDataById = {} -- 临时数据
-- 获取科技升级数据
-- _nBuildId: 建筑id
function getTnolyUpDataByIdFromDB( _upId)
	if not _upId then
		return
	end
	_upId = tonumber(_upId)
	if (tTnolyUpDataById[_upId]) then
		return tTnolyUpDataById[_upId]
	end
	local tUpLv = nil
	for data in execForRows(Player.gamedb, "select * from science_lv_up where id = \'" .. _upId .. "\'") do
  		if (data) then
  			tUpLv = data
  			tTnolyUpDataById[_upId] = tUpLv
  			break
  		end
    end
    return tUpLv
end

local tResearchersData = {}
--根据Id获取研究员数据
function getResearcherDatasFromDB(  )
	-- body
	if not tResearchersData or  #tResearchersData <= 0 then
		local tmptable = execForTable(Player.gamedb, "select * from science_researcher;")
		tResearchersData = {}
		for k, v in pairs(tmptable) do
			if v then 
				table.insert(tResearchersData, v)
			end
		end
	end
	return tResearchersData
end

function getResearcherLimit(  )
	-- body
	local tTable = getResearcherDatasFromDB()
	local nlv = tonumber(tTable[1].institute)
	for k, v in pairs(tTable) do
		local curlv = tonumber(v.institute)
		if nlv > curlv then
			nlv = curlv
		end
	end
	return nlv
end

function getResearcherDataByID( _Id )
	-- body
	if not _Id then
		return nil
	end
	local tResearcher = getResearcherDatasFromDB()
	for k, v in pairs(tResearcher) do
		if v.id  == _Id then
			pData = DataResearcher.new()
			pData:refreshDataByDB(v)
			return pData
		end
	end
	return nil
end
-------------------------------科技相关--------------------------------------------------

-------------------------------建筑相关--------------------------------------------------

local tBuildParam = {} -- 建筑全局表的临时数据
-- 获取一些全局参数, 比如角色名长度
function getBuildParam( _key )
	-- body
	if(tBuildParam[_key]) then
		return tBuildParam[_key]
	end
	for data in execForRows(Player.gamedb, "select * from build_init where key = \'" .. _key .. "\'") do
		local tData = nil
		if _key == "collectionCost" or _key == "defenceCost" then
			tData = {}
			--1:60:500;2:65:500;3:70:600;4:75:600
			local tData2 = luaSplitMuilt(data.value, ";", ":")
			for i=1,#tData2 do
				local nPos = tonumber(tData2[i][1])
				local nLv = tonumber(tData2[i][2])
				local nCost = tonumber(tData2[i][3])
				tData[nPos] = {nPos = nPos, nLv = nLv, nCost = nCost}
			end
		elseif _key == "collectionFree" or _key == "defenceFree" then
			tData = {}
			--1:60;2:70;3:75;4:80
			local tData2 = luaSplitMuilt(data.value, ";", ":")
			for i=1,#tData2 do
				local nPos = tonumber(tData2[i][1])
				local nLv = tonumber(tData2[i][2])
				tData[nPos] = {nPos = nPos, nLv = nLv}
			end
		else
			tData = data.value
		end
		tBuildParam[_key] = tData
		return tData
	end
	print("cannot find \"" .. _key .. "\" in build_init db")
	return -1
end

--建筑临时数据表
local tAllBuildsFromDB = {} -- 建筑的临时数据
-- 获取所有的建筑
function getAllBuildsFromDB( )
	if(tAllBuildsFromDB and #tAllBuildsFromDB > 0) then
		return tAllBuildsFromDB
	else
		local tTemp = execForTable(Player.gamedb, "select * from build_building ;")
		for i, v in pairs(tTemp) do
			local nUse = tonumber(v.use or 0)
			if nUse == 0 then
				table.insert(tAllBuildsFromDB, v)
			end	
			--测试		
            --if v.id == 11021 then
			--	table.insert(tAllBuildsFromDB, v)
			--end	
            --if 11013 == v.id then
            --    table.remove(tAllBuildsFromDB, #tAllBuildsFromDB)
            --end
		end
	end
	return tAllBuildsFromDB
end
local tBuildTroopQueue = {}
function getTroopsVoById( _nId )
	-- body
	if not _nId then
		return nil
	end
	if(tBuildTroopQueue[_nId]) then
		return tBuildTroopQueue[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from build_queue where id = \'" .. _nId .. "\'") do
		tBuildTroopQueue[_nId] = data
		return data 
	end
	print("cannot find \"" .. _nId .. "\" in build_queue db")
	return nil	
end

--根据id获得建造的基础（配表）数据
function getBuildDatasByTid( sTid )
	-- body
	if table.nums(tAllBuildsFromDB) <= 0 then
		getAllBuildsFromDB()
	end
	local tData = nil
	for k, v in pairs (tAllBuildsFromDB) do
		if v.id == sTid then
			tData = v
			break
		end
	end
	return tData
end

-- local tBuildDataById = {} -- 临时数据
-- 获取建筑操作按钮
-- _nBuildId: 建筑id
function getBuildDataByIdFromDB( _nBuildId)
	if not _nBuildId then
		return
	end
	return getBuildDatasByTid(_nBuildId)
end

--根据资源田下标获得资源田相关数据
local tSubBDatasFromDBByCell = {}
function getSubBDatasFromDBByCell( _nCell )
	-- body
	if not _nCell then
		return
	end
	if (tSubBDatasFromDBByCell[_nCell]) then
		return tSubBDatasFromDBByCell[_nCell]
	end
	local tData = nil
	for data in execForRows(Player.gamedb, "select * from build_resource_field where location = \'" .. _nCell .. "\'") do
  		if (data) then
  			tData = data
  			tSubBDatasFromDBByCell[_nCell] = tData
  			break
  		end
    end
    return tData
end

local tBuildUpLimits = {} -- 临时数据
-- 获取建筑升级相关数据
-- _nBuildId: 建筑id
-- _nLv: 建筑等级
function getBuildUpLimitsFromDB( _nBuildId, _nLv )
	if not _nBuildId then
		return
	end
	if not _nLv then
		return
	end
	local key = _nBuildId .. "_".._nLv
	if (tBuildUpLimits[key]) then
		return tBuildUpLimits[key]
	end
	local tData = nil
	for data in execForRows(Player.gamedb, "select * from build_lv_up where buildId = \'" .. _nBuildId .. "\' and buildLv = \'" .. _nLv .. "\'") do
  		if (data) then
  			--解析cityIcon
			local cityicon = data.cityicon
			if cityicon then
				local tData = luaSplit(cityicon,";")
				for i=1,#tData do
					tData[i] = "#"..tData[i]..".png"
				end
				data.tCityicon = {
					[e_type_country.shuguo] = tData[1],
					[e_type_country.weiguo] = tData[2],
					[e_type_country.wuguo] = tData[3],
					[e_type_country.qunxiong] = tData[4],
				}
			end
			--解析mapIcon
			local mapicon = data.mapicon
			if mapicon then
				local tData = luaSplit(mapicon,";")
				for i=1,#tData do
					tData[i] = "#"..tData[i]..".png"
				end
				data.tMapicon = {
					[e_type_country.shuguo] = tData[1],
					[e_type_country.weiguo] = tData[2],
					[e_type_country.wuguo] = tData[3],
					[e_type_country.qunxiong] = tData[4],
				}
			end
  			tData = data
  			tBuildUpLimits[key] = tData
  			break
  		end
    end
    return tData
end

--获取玩家城池点图标
--nPalaceLv：皇城等级
--nCountry:国家
function getPlayerDotIcon( nPalaceLv, nCountry)
	local tData = getBuildUpLimitsFromDB(e_build_ids.palace, nPalaceLv)

	if tData then
		return tData.tMapicon[nCountry]
	end
	return nil
end

--获取玩家城池图标
--nPalaceLv：皇城等级
--nCountry:国家
function getPlayerCityIcon( nPalaceLv, nCountry)
	local tData = getBuildUpLimitsFromDB(e_build_ids.palace, nPalaceLv)
	if tData then
		return tData.tCityicon[nCountry]
	end
	return nil
end


local tAllCampTeam = {} -- 临时数据
-- 获取兵营扩充队列总个数
function getAllCampTeamFromDB( )
	if (tAllCampTeam and #tAllCampTeam > 0) then
		return tAllCampTeam
	end
	for data in execForRows(Player.gamedb, "select * from build_barracks where institute > 0") do
  		if (data) then
  			tAllCampTeam[#tAllCampTeam + 1] = data
  		end
    end
    return tAllCampTeam
end

-- 获取兵营扩充队列最大个数
function getMaxCountCampTeam(  )
	-- body
	local tDatas = getAllCampTeamFromDB()
	return table.nums(tDatas)
end

local tCampTeamByQueue = {} -- 临时数据
-- 获取扩充队列相对应数据
-- _nNum: 扩充次数
function getCampTeamByQueueFromDB( _nNum)
	if not _nNum then
		return
	end
	if (tCampTeamByQueue[_nNum]) then
		return tCampTeamByQueue[_nNum]
	end
	local tQueue = nil
	for data in execForRows(Player.gamedb, "select * from build_barracks where queue = \'" .. _nNum .. "\'") do
  		if (data) then
  			tQueue = data
  			tCampTeamByQueue[_nNum] = tQueue
  			break
  		end
    end
    return tQueue
end

local tAllRecruitCt = {} -- 临时数据
-- 获取募兵扩充总次数
function getAllRecruitCtFromDB( )
	if (tAllRecruitCt and #tAllRecruitCt > 0) then
		return tAllRecruitCt
	end
	for data in execForRows(Player.gamedb, "select * from build_barracks where coin > 0") do
  		if (data) then
  			tAllRecruitCt[#tAllRecruitCt + 1] = data
  		end
    end
    return tAllRecruitCt
end

-- 获取募兵扩充最大次数
function getMaxCountRecruit(  )
	-- body
	local tDatas = getAllRecruitCtFromDB()
	return table.nums(tDatas)
end

local tRecruitByQueue = {} -- 临时数据
-- 获取扩充队列相对应数据
-- _nNum: 扩充次数
function getRecruitByQueueFromDB( _nNum)
	if not _nNum then
		return
	end
	if (tRecruitByQueue[_nNum]) then
		return tRecruitByQueue[_nNum]
	end
	local tQueue = nil
	for data in execForRows(Player.gamedb, "select * from build_barracks where queue = \'" .. _nNum .. "\'") do
  		if (data) then
  			tQueue = data
  			tRecruitByQueue[_nNum] = tQueue
  			break
  		end
    end
    return tQueue
end

local tBuildActionBtn = {} -- 临时数据
-- 获取建筑操作按钮
-- _nBuildId: 建筑id
function getBuildActionBtnFromDB( _nBuildId)
	if not _nBuildId then
		return
	end
	if (tBuildActionBtn[_nBuildId]) then
		return tBuildActionBtn[_nBuildId]
	end
	local sAction = nil
	for data in execForRows(Player.gamedb, "select * from build_button where queue = \'" .. _nBuildId .. "\'") do
  		if (data) then
  			sAction = data.institute
  			tBuildActionBtn[_nBuildId] = sAction
  			break
  		end
    end
    return sAction
end

local tPalaceData = {} --临时数据 返回当前王宫等级下的文官信息和下一个解锁的文官数据
--获取王宫文官数据
--_Id 文官Id 
--return 文官基础数据(文官table)
function getBuildPalaceData()
	-- body
	if not tPalaceData or table.getn(tPalaceData) <= 0 then
		local ttmptable = execForTable(Player.gamedb, "select * from build_palace ;")
		for i,v in pairs(ttmptable) do
			if v then
				table.insert(tPalaceData, v)
			end				
		end
	end		
	return tPalaceData
end

function getOfficiclLimit(  )
	-- body
	local tTable = getBuildPalaceData()	
	local nlv = tonumber(tTable[1].palacelevel	)
	for k, v in pairs(tTable) do
		local curlv = tonumber(v.palacelevel)		
		if nlv > curlv then
			nlv = curlv
		end
	end
	return nlv
end

function getPalaceOfficialByID( _Id )
	-- body
	if not _Id then
		return nil
	end
	local pData = nil
	local tofficial = getBuildPalaceData()
	for k, v in pairs(tofficial) do
		if v.id == _Id then
			pData = DataOfficial.new()
			pData:refreshDataByDB(v)
			return pData
		end
	end
	return nil
end

local tBlackSmithData = {} --临时数据 返回当前王宫等级下的铁匠信息和下一个解锁的铁匠数据
--获取铁匠数据
--_Id 铁匠Id 
--return 铁匠基础数据(铁匠table)
function getBuildBlackSmith()
	-- body
	if not tBlackSmithData or table.getn(tBlackSmithData) <= 0 then
		local ttmptable = execForTable(Player.gamedb, "select * from build_blacksmith;")
		for i,v in pairs(ttmptable) do
			if v then
				table.insert(tBlackSmithData, v)
			end				
		end
	end	
	return tBlackSmithData
end

--铁匠雇用限制
function getBlackSmithLimit(  )
	-- body
	local tTable = getBuildBlackSmith()
	--dump(tTable, "tTable", 10)
	local nlv = tonumber(tTable[1].palacelevel)
	for k, v in pairs(tTable) do
		local curlv = tonumber(v.palacelevel)
		if nlv > curlv then
			nlv = curlv
		end
	end
	return nlv
end

function getBlackSmithByID( _Id )
	-- body
	if not _Id then
		return nil
	end
	local tData = getBuildBlackSmith()
	for k, v in pairs(tData) do
		if v.id == _Id then
			pData = DataSmith.new()
			pData:refreshDataByDB(v)
			return pData
		end
	end
	return nil
end

-------------------------------城墙--------------------------------------------------


--城墙临时数据
local tWallBaseData = nil
function getAllWallBaseData()
	-- body
	if not tWallBaseData then
		tWallBaseData = {}
		local ttmptable = execForTable(Player.gamedb, "select * from build_wall ;")
		for i,v in pairs(ttmptable) do
			if v then
				tWallBaseData[i] = v
			end				
		end
	end

	return tWallBaseData

end

--通过城墙等级获取数据
function getWallBaseDataByLv( _lv )
	-- body
	if not _lv then
		return
	end
	if not tWallBaseData then
		tWallBaseData = getAllWallBaseData()
	end
	return tWallBaseData[_lv]
	-- if tWallBaseData[_lv] then
	-- 	return tWallBaseData[_lv]
	-- end
	-- local data = nil
	-- for data in execForRows(Player.gamedb, "select * from build_wall where wall = \'" .. _lv .. "\'") do
	-- 	if data then
	-- 		tWallBaseData[_lv] = data
	-- 		return tWallBaseData[_lv]
	-- 	end
	-- end
end

--获取城防容量解锁条件
function getWallLvByNum(_num)
	-- body
	if not tWallBaseData then
		tWallBaseData = getAllWallBaseData()
	end
	for lv, data in pairs(tWallBaseData) do
		if data.num == _num then
			return lv
		end
	end
end

local tWallInitData = {} -- 城墙基本参数
-- 获取副本基本参数
function getWallInitParam( _key )
	-- body
	if(tWallInitData[_key]) then
		return tWallInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from build_init where key = \'" .. _key .. "\'") do
		tWallInitData[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in wall_init db")
	return -1
end


-------------------------------城墙--------------------------------------------------


-------------------------------建筑相关--------------------------------------------------


-------------------------------酒馆相关--------------------------------------------------

local tSummonInitData = {} -- 酒馆设置临时数据
-- 获取酒馆设置临时数据
function getSummonParam( _key )
	-- body
	if(tSummonInitData[_key]) then
		return tSummonInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from summon_init where key = \'" .. _key .. "\'") do
		tSummonInitData[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in summon_init db")
	return -1
end

-------------------------------酒馆相关--------------------------------------------------







-------------------------------副本------------------------------------------------------


--获取所有章节数据
local tChapterData = nil
function getAllChapterFromDB()
	
	local t = {}
	if not tChapterData then
		tChapterData = {}
		local tTemp = execForTable(Player.gamedb, "select * from dragon_chapter order by id")
		for i, v in pairs(tTemp) do
			local pData = ChapterData.new()
			pData:initDatasByDB(v)
			if(pData) then
				tChapterData[pData.nId] = v
				if not t[pData.nId] then
					t[pData.nId] = {}
				end
				t[pData.nId] = pData
			end
		end
	else
		for i, v in pairs(tChapterData) do
			local pData = ChapterData.new()
			pData:initDatasByDB(v)
			if not t[pData.nId] then
				t[pData.nId] = {}
			end
			t[pData.nId] = pData
		end
	end
	return t
end

--获取所有关卡数据
local tPostData = nil
function getAllPostFromDB()
	local t = {}
	if not tPostData then
		tPostData = {}
		local tTemp = execForTable(Player.gamedb, "select * from dragon_outposts order by id")
		for i, v in pairs(tTemp) do
			local pData = PostData.new()
			pData:initDatasByDB(v)
			pData.index = i
			v.index = i
			if(pData) then
				tPostData[pData.nId] = v
				if not t[pData.nId] then
					t[pData.nId] = {}
				end
				t[pData.nId] = pData
			end
		end
	else
		for i, v in pairs(tPostData) do
			local pData = PostData.new()
			pData:initDatasByDB(v)
			if not t[pData.nId] then
				t[pData.nId] = {}
			end
			t[pData.nId] = pData
		end
	end
	return t
end

--根据id获取关卡数据
--nId:关卡id副本
function getDragonOutPostsById( nId )
	if not nId then
		return
	end
	if not tPostData then
		getAllPostFromDB()
	end
	if tPostData then
		return tPostData[nId]
	end
	return nil
end

--是否不显示关卡
function getIsNotShowOutposts( nId )
	local tData = getDragonOutPostsById(nId)
	if tData then
		if tData.isappear == 0 then
			return true
		end
	end
	return false
end


local tFubenInitData = {} -- 副本设置的临时数据
-- 获取副本基本参数
function getFubenParam( _key )
	-- body
	if(tFubenInitData[_key]) then
		return tFubenInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from dragon_init where key = \'" .. _key .. "\'") do
		tFubenInitData[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in dragon_init db")
	return -1
end

-------------------------------副本------------------------------------------------------


-------------------------------聊天------------------------------------------------------
local tChatBaseData = {} -- 聊天类型设置的相关数据
-- 获取聊天基本参数
function getChatBaseDataByType( _nType )
	-- body
	if(tChatBaseData[_nType]) then
		return tChatBaseData[_nType]
	end
	for data in execForRows(Player.gamedb, "select * from chat_base where type = \'" .. _nType .. "\'") do
		tChatBaseData[_nType] = data
		return data 
	end
	print("cannot find \"" .. _nType .. "\" in chat_base db")
	return nil
end

local tShareNotice = {}
--获取分享内容
function getChatCommonNotice(_nId)
	if tShareNotice[_nId] then
		return tShareNotice[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from chat_common_notice where id = \'" .. _nId .. "\'") do
		tShareNotice[_nId] = data
		return data
	end
	return {}
end

local tActivityNotice = {}
--获取分享内容
function getChatActivityNotice(_nId)
	if tActivityNotice[_nId] then
		return tActivityNotice[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from chat_activity_notice where id = \'" .. _nId .. "\'") do
		tActivityNotice[_nId] = data
		return data
	end
	return {}
end

local tChatHornParam = {}
function getChatHornParam( _nId )
	-- body
	if tChatHornParam[_nId] then
		return tChatHornParam[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from chat_horn where type = \'" .. _nId .. "\'") do
		tChatHornParam[_nId] = data
		return data
	end
	return {}	
end

local tChatInitParam = {}
function getChatInitParam( _key )
	-- body
	if(tChatInitParam[_key]) then
		return tChatInitParam[_key]
	end
	for data in execForRows(Player.gamedb, "select * from chat_init where key = \'" .. _key .. "\'") do
		tChatInitParam[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in item_base db")
	return -1
end

--表情
local tChatEmoCn = nil
local nEmoCnt = nil
local tChatEmoOrder = nil
--初始化全部表情
function initChatEmoData(  )
	if not tChatEmoCn then
		tChatEmoCn = {}
		nEmoCnt = 0
		tChatEmoOrder = {}
		for k,data in pairs(execForTable(Player.gamedb, "select * from chat_emo_new")) do
			data.sImg = "#"..data.imgname
			tChatEmoCn[data.name_chi] = data
			table.insert(tChatEmoOrder, data)
			nEmoCnt = nEmoCnt + 1
		end
		table.sort(tChatEmoOrder, function(a, b)
			return a.orid < b.orid
		end)
	end
end

--根据中文获取表情
function getChatEmoDataByCn( _key )
	if not tChatEmoCn then
		initChatEmoData()
	end
	if tChatEmoCn then
		return tChatEmoCn[_key]
	end
end

--获取表情数量
function getChatEmoCnt( )
	if not nEmoCnt then
		initChatEmoData()
	end
	return nEmoCnt
end

--获取排序后的表情
function getChatEmoOrder( )
	if not tChatEmoOrder then
		initChatEmoData()
	end
	return tChatEmoOrder
end
-------------------------------聊天------------------------------------------------------


-------------------------------英雄------------------------------------------------------
---------------
local tHeroData = {} -- 英雄临时数据
-- 根据配表id读取英雄数据
-- pHero（Hero）：返回英雄数据
function getHeroDataById( sGid )
	if (not sGid) then
		return
	end
	local pHero = nil
	if(tHeroData[sGid] ~= nil) then
		pHero = DataHero.new()
  		pHero:initDatasByDB(tHeroData[sGid])
  		return pHero
	end
	-- body
	for data in execForRows(Player.gamedb, "select * from hero_base where id = \'" .. sGid .. "\'") do
  		pHero = DataHero.new()
  		pHero:initDatasByDB(data)
    	tHeroData[sGid] = data
    	break
    end
    return pHero 
end

function getHeroTableDataById(_tId)
	if tHeroData[_tId] then
		return tHeroData[_tId]
	end
	for data in execForRows(Player.gamedb, "select * from hero_base where id = \'" .. _tId .. "\'") do
    	tHeroData[_tId] = data
    	break
    end
    return tHeroData[_tId];
end

local tHeroInitData = {} -- 英雄初始化临时数据
-- 获取英雄初始化临时数据
function getHeroInitData( _key )
	-- body
	if(tHeroInitData[_key]) then
		return tHeroInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from hero_init where key = \'" .. _key .. "\'") do
		tHeroInitData[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in item_base db")
	return -1
end


local tAllHeroId = {} --获取所有品质英雄Id
function getAllHeroId()
	if (not tAllHeroId) or table.nums(tAllHeroId) <1  then
		local tTemp = execForTable(Player.gamedb, "select * from hero_base order by id")
		for i, v in pairs(tTemp) do
			table.insert(tAllHeroId, v.id)
		end
		return tAllHeroId
	else
		return tAllHeroId
	end
	print("cannot find \"" .. data .. "\" in hero_base db")
	return -1
end

local tAllHeroKeys = {}
--获取图鉴所有英雄的唯一标志
function getAllHeroKeys(  )
	-- body
	if(tAllHeroKeys and #tAllHeroKeys > 0) then
		return tAllHeroKeys
	else
		local tTemp = execForTable(Player.gamedb, "select * from hero_base ;")
		for i, v in pairs(tTemp) do
			if v.isappear == 1 then
				local tT= {}
				tT.key = v.key
				tT.category = v.category
				tAllHeroKeys[v.key] = tT
			end
		end
		return tAllHeroKeys
	end
end

local tHeroExpData = {} -- 英雄经验的临时数据
-- 根据英雄等级获取经验数据 返回的数据只是复制数据
function getHeroExpDataByLv(_lv )

	if (not _lv) then
		return
	end
	if(tHeroExpData[_lv]) then
		return copyTab(tHeroExpData[_lv])
	end
	for data in execForRows(Player.gamedb, "select * from hero_exp where level = \'" .. _lv .. "\'") do
		tHeroExpData[_lv] = data
		return copyTab(data) 
	end
	print("cannot find \"" .. _lv .. "\" in hero_exp db")
	return -1
end

local tHeroAdvanceData = {} -- 英雄进阶的临时数据
-- 根据英雄等级获取经验数据 返回的数据只是复制数据
function getHeroAdvanceDataByKind( _kind )
	if (not _kind) then
		return
	end
	if(tHeroAdvanceData[_kind]) then
		return copyTab(tHeroAdvanceData[_kind])
	end

	local tKindData =  nil
	for data in execForRows(Player.gamedb, "select * from hero_advance where kind = \'" .. _kind .. "\'") do
		if not tKindData then
			tKindData = {}
		end
		table.insert(tKindData, data)
	end
	if tKindData then
		tHeroAdvanceData[_kind] = tKindData
		return copyTab(tKindData)
	end
	print("cannot find \"" .. _kind .. "\" in hero_advance db")
	return -1
end

-------------------------------英雄------------------------------------------------------


-----------------------------------基础属性表---------------------------------------------         
local tBaseAttData = {} -- 基础属性临时数据
-- 根据配表id读取基础属性数据
-- pHeroAtt(HeroAtt)：返回英雄属性数据
function getBaseAttData( sGid )
	if (not sGid) then
		return
	end

	local pHeroAtt = nil
	if(tBaseAttData[sGid] ~= nil) then
		pHeroAtt = HeroAtt.new()
  		pHeroAtt:initDatasByDB(tBaseAttData[sGid])
  		return pHeroAtt
	end
	-- body
	for data in execForRows(Player.gamedb, "select * from attribute_base where id = \'" .. sGid .. "\'") do
  		pHeroAtt = HeroAtt.new()
  		pHeroAtt:initDatasByDB(data)
    	tBaseAttData[sGid] = data
    	break
    end


    return pHeroAtt 
end

-- 获取item_resource表
local tItemResourceData = {}
function getItemResourceData( nId )
	if not nId then
		return
	end
	local pResData = nil
	if(tItemResourceData[nId]) then
		pResData = ResData.new()
		pResData:initDatasByDB(tItemResourceData[nId])
		return pResData
	end
	for data in execForRows(Player.gamedb, "select * from item_resource where id = \'" .. nId .. "\'") do
		pResData = ResData.new()
		pResData:initDatasByDB(data)
		tItemResourceData[nId] = data
		break
	end
	if pResData == nil then
		print("cannot find \"" .. nId .. "\" in item_resource db")
	end
	return pResData
end

-----------------------------------基础属性表---------------------------------------------  


-----------------------------------NPC---------------------------------------------  


local tNpcData = {} --怪物临时数据
-- 根据怪物id读取怪物数据
-- pNpc（Npc）：返回怪物数据
-- _type 
function getNPCData( _nId,_type)
	if (not _nId) then
		return
	end

	if not _type then
		_type = en_npc_tpye.parent
	end

	local pNpc = nil
	if(tNpcData[_nId] ~= nil) then
		if _type == en_npc_tpye.parent then
			pNpc = Npc.new()
		elseif _type == en_npc_tpye.wall then
			pNpc = DataNpcWall.new()
		end
  		pNpc:initDatasByDB(tNpcData[_nId])
  		return pNpc
	end
	-- body
	for data in execForRows(Player.gamedb, "select * from npc_monster where id = \'" .. _nId .. "\'") do
		if _type == en_npc_tpye.parent then
			pNpc = Npc.new()
		elseif _type == en_npc_tpye.wall then
			pNpc = DataNpcWall.new()
		end
  		pNpc:initDatasByDB(data)
    	tNpcData[_nId] = data
    	break
    end
    return pNpc 
end

local tNpcGropData = {} --怪物组数据
-- !!!注意每次拿出的npc组数据都是一份新的数据!!!
-- 获取怪物id数据
function getNpcGropById(_id)
	if(tNpcGropData[_id]) then
		return copyTab(tNpcGropData[_id]) 
	end
	for data in execForRows(Player.gamedb, "select * from npc_group where id = \'" .. _id .. "\'") do
		local tGropStr = luaSplit(data.monsterids,":")
		if (not tGropStr) or (table.nums(tGropStr)<1) then
			print("cannot find \"" .. _id .. "\" in npc_group db")
			return -1
		end
		local tGropNpc = {}
		for k,v in pairs(tGropStr) do
			table.insert(tGropNpc,getNPCData(tonumber(v)))
		end
		tNpcGropData[_id] = tGropNpc
		return copyTab(tGropNpc)  
	end
	print("cannot find \"" .. _id .. "\" in npc_group db")
	return -1
end


-- 获取npc怪物表列表中的数据
local tNpcGropListData = {}
-- name	名称 level 等级	monsterIds 怪物组id	camp 阵营	score --分数
function getNpcGropListDataById( nId )
	if(tNpcGropListData[nId]) then
		return tNpcGropListData[nId]
	end
	for data in execForRows(Player.gamedb, "select * from npc_group where id = \'" .. nId .. "\'") do
		tNpcGropListData[nId] = data
		return data
	end
	print("cannot find \"" .. nId .. "\" in npc_group db")
	return -1
end

--获取总属性值
function getNpcGroupTotalAttr( nId, sKey )
	local nAttr = 0
	local tNpcGroup = getNpcGropListDataById(nId)
	if tNpcGroup then
		if tNpcGroup.monsterids then
			local tStr = luaSplit(tNpcGroup.monsterids, ":")
			for i=1, #tStr do
				local nMonsterId = tonumber(tStr[i])
				if nMonsterId then
					local tMonster = getNPCData(nMonsterId)
					if tMonster then
						if sKey == "troops" then
							nAttr = nAttr + tMonster.nTroops
						end
					end
				end
			end
		end
	end
	return nAttr
end

-----------------------------------NPC---------------------------------------------  


-------------------------------活动------------------------------------------------------
-----------------
local tAllActivity = nil
--获取所有的活动
function getAllActivity()
	if tAllActivity then
		return tAllActivity
	end
	tAllActivity = {}
	for k,data in pairs(execForTable(Player.gamedb, "select * from activity_template")) do
		table.insert(tAllActivity, data)
	end
	return tAllActivity
end

-- local tActivityTemplateData = {} -- 活动基本数据
-- 获取活动基本参数
-- function getActivityTemplate( _nId )
-- 	-- body 
-- 	-- if(tActivityTemplateData[_nId]) then
-- 	-- 	return tActivityTemplateData[_nId]
-- 	-- end
-- 	-- for data in execForRows(Player.gamedb, "select * from activity_template where id = \'" .. _nId .. "\'") do
-- 	-- 	tActivityTemplateData[_nId] = data
-- 	-- 	return data 
-- 	-- end
-- 	-- print("cannot find \"" .. _nId .. "\" in activity_template db")

-- 	local tAllActivity = getAllActivity()
-- 	for id, data in pairs(tAllActivity) do
-- 		if id == _nId then
-- 			return data
-- 		end
-- 	end
-- end

--通过活动id和参数版本获取活动
function getActivityByIdAndVer(_nId, _nVer)
	local tAllActivity = getAllActivity()
	for i, data in pairs(tAllActivity) do
		if data.id == _nId and data.paramver == _nVer then
			return data
		end
	end
end
-------------------------------活动------------------------------------------------------






-----------------------------------大地图相关---------------------------------------------    
--获取世界大地图init数据
local tWorldInitData = {}
function getWorldInitData( _key )
	-- body
	if(tWorldInitData[_key]) then
		return tWorldInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from world_init where key = \'" .. _key .. "\'") do
		if _key == "collectTime" then
			local tData = luaSplitMuilt(data.value, ";", ",") 
			local tData2 = {}
			for i=1,#tData do
				if #tData[i] >= 2 then
					local nkey = tonumber(tData[i][1])
					local nValue = tonumber(tData[i][2])
					if nkey and nValue then
						tData2[nkey] = nValue
					end
				end
			end
			tWorldInitData[_key] = tData2
		elseif _key == "yljConf" then
			local tData = luaSplitMuilt(data.value, ";", ":") 
			local tData2 = {}
			for i=1,#tData do
				if #tData[i] >= 2 then
					local nkey = tonumber(tData[i][1])
					local nValue = tonumber(tData[i][2])
					if nkey and nValue then
						tData2[nkey] = nValue
					end
				end
			end
			tWorldInitData[_key] = tData2
		elseif _key == "detectId" then
			local tData = luaSplit(data.value, ":")
			local nScienceId = tonumber(tData[1])
			local nLv = tonumber(tData[2])
			tWorldInitData[_key] = {nScienceId = nScienceId, nLv = nLv}
		elseif _key == "marchTimes" or _key == "Crossregionalcountdown" then
			local tData = luaSplitMuilt(data.value, ";", ":") 
			local tData2 = {}
			for i=1,#tData do
				if #tData[i] >= 2 then
					local nkey = tonumber(tData[i][1])
					local nValue = tonumber(tData[i][2])
					if nkey and nValue then
						tData2[nkey] = nValue
					end
				end
			end
			tWorldInitData[_key] = tData2
		elseif _key == "collectPaperdoubleCost" then
			--双倍征收消耗道具(城池类型-物品id:数量；物品id:数量;2-物品id:数量;物品id:数量)
			-- 1-100013:1;2-100014:1;3-100015:1;4-100016:1;5-100017:1
			local tData = luaSplitMuilt(data.value, ";", "-", ":") 
			local tData2 = {}
			for i=1,#tData do
				if #tData[i] == 2 then
					local nKind = tonumber(tData[i][1])
					local nGoodsId = tonumber(tData[i][2][1])
					local nCt = tonumber(tData[i][2][2])
					if nKind and nGoodsId and nCt then
						tData2[nKind] = {nGoodsId = nGoodsId, nCt = nCt}
					end
				end
			end
			tWorldInitData[_key] = tData2
		elseif _key == "worldHelpIcon" then  --获取世界玩法的显示等级范围
			local tData = luaSplit(data.value, ";")
			local tData2 = {}
			for i=1,#tData do
				tData2[i] = tonumber(tData[i])
			end
			tWorldInitData[_key] = tData2
		elseif _key == "worldIcon" then  --世界玩法显示图标
			tWorldInitData[_key] = data.value
		elseif _key == "firstBlood" then --首杀奖励
			local tData = luaSplitMuilt(data.value, ";", ":") 
			local tDict = {}
			for i=1,#tData do
				local nKind = tonumber(tData[i][1])
				local nDropId = tonumber(tData[i][2])
				if nKind and nDropId then
					tDict[nKind] = getDropById(nDropId)
				end
			end
			tWorldInitData[_key] = tDict
		else
			tWorldInitData[_key] = tonumber(data.value) or data.value
		end
		return tWorldInitData[_key]
	end
	print("cannot find \"" .. _key .. "\" in world_init db")
	return nil
end

-- 获取世界大地图数据
local tWorldMapData = nil
local tDecorateData = {} --以坐标点为字典
function getWorldMapData(  )
	if tWorldMapData then
		return tWorldMapData
	end
	tWorldMapData = {}
	for k,data in pairs(execForTable(Player.gamedb, "select * from world_block")) do
		--解析mapIcon
		local mapicon = data.mapicon
		if mapicon then
			local tData = luaSplit(mapicon,";")
			for i=1,#tData do
				tData[i] = "#"..tData[i]..".png"
			end
			data.tMapicon = {
				[e_type_country.shuguo] = tData[1],
				[e_type_country.weiguo] = tData[2],
				[e_type_country.wuguo] = tData[3],
				[e_type_country.qunxiong] = tData[4],
			}
		end

		-- --装饰物坐标|装饰物方向|icon #分割
		if data.position and data.adornment then
			local position = luaSplit(data.position, ",")
			local adornment = nil
			if string.find(data.adornment, "#") then
				adornment = luaSplitMuilt(data.adornment, "#", "|", ";", ",")
			else
				adornment = {}
				table.insert(adornment, luaSplitMuilt(data.adornment, "|", ";", ","))
			end
			if position and adornment then
				local nBaseX = tonumber(position[1])
				local nBaseY = tonumber(position[2])
				for i=1,#adornment do
					local tData = adornment[i]
					if type(tData[1]) == "table" and tData[2] then --恶心的配表兼容
						local nStartX = tonumber(tData[1][1][1])
						local nStartY = tonumber(tData[1][1][2])
						local nEndX = tonumber(tData[1][2][1])
						local nEndY = tonumber(tData[1][2][2])
						local sImg = "#"..tData[2]..".png"

						--地图位置
						local tMapPos = nil
						if nStartX == nEndX and nStartY == nEndY then
							local fPosX, fPosY = WorldFunc.getMapPosByDotPos(nStartX + nBaseX, nStartY + nBaseY)
							tMapPos = {x = fPosX, y = fPosY}
						else
							local fPosX, fPosY = WorldFunc.getMapPosByDotPos(nStartX + nBaseX, nStartY + nBaseY)
							local fPosX2, fPosY2 = WorldFunc.getMapPosByDotPos(nEndX + nBaseX, nEndY + nBaseY)
							tMapPos = {x = fPosX + (fPosX2 - fPosX)/2, y = fPosY + (fPosY2 - fPosY)/2}
						end

						--相关键值
						for j=nStartX + nBaseX,nEndX + nBaseX do
							for k = nStartY + nBaseY, nEndY + nBaseY do
								local sDotKey = string.format("%s_%s", j, k)
								tDecorateData[sDotKey] = {sImg = sImg, nStartX = nStartX + nBaseX, nStartY = nStartY + nBaseY, nEndX = nEndX + nBaseX, nEndY = nEndY + nBaseY, tMapPos = tMapPos}
							end
						end
					end
				end
			end
		end
		tWorldMapData[data.id] = data
	end
	return tWorldMapData
end

--获取装饰数据
function getDecorateData( sDotKey)
	if not sDotKey then
		return
	end
	return tDecorateData[sDotKey]
end

-- 获取世界大地图城池
local tWorldCityData = nil
local tWorldCityIdByDotKey = nil
function getWorldCityData(  )
	if tWorldCityData then
		return tWorldCityData
	end
	tWorldCityData = {}
	tWorldCityIdByDotKey = {}
	for k,data in pairs(execForTable(Player.gamedb, "select * from world_city")) do
		--解析cityIcon
		local cityicon = data.cityicon
		if cityicon then
			local tData = luaSplit(cityicon,";")
			for i=1,#tData do
				tData[i] = "#"..tData[i]..".png"
			end
			data.tCityicon = {
				[e_type_country.shuguo] = tData[1],
				[e_type_country.weiguo] = tData[2],
				[e_type_country.wuguo] = tData[3],
				[e_type_country.qunxiong] = tData[4],
			}
		end
		--解析mapIcon
		local mapicon = data.mapicon
		if mapicon then
			local tData = luaSplit(mapicon,";")
			for i=1,#tData do
				tData[i] = "#"..tData[i]..".png"
			end
			data.tMapicon = {
				[e_type_country.shuguo] = tData[1],
				[e_type_country.weiguo] = tData[2],
				[e_type_country.wuguo] = tData[3],
				[e_type_country.qunxiong] = tData[4],
			}
		end
		--解析coordinate
		local coordinate = data.coordinate
		if coordinate then
			if data.grid <= 1 then
				local tPos = luaSplit(coordinate,",")
				if #tPos >= 2 then
					local nDotX = tonumber(tPos[1])
					local nDotY = tonumber(tPos[2])
					data.tCoordinate = {x = nDotX, y = nDotY}
					local fPosX, fPosY = WorldFunc.getMapPosByDotPos(data.tCoordinate.x, data.tCoordinate.y)
					if fPosX then
						data.tMapPos = {x = fPosX, y = fPosY}
					else
						myprint(string.format("world_city id = %s,生成地图坐标出错",k))
					end
					data.tCoordinateCenter = data.tCoordinate
					--记录关联
					local sDotKey = string.format("%s_%s", nDotX, nDotY)
					tWorldCityIdByDotKey[sDotKey] = data.id
				end
			else
				local tPos = luaSplitMuilt(coordinate,";",",")
				if #tPos >= 2 then

					local nDotX = tonumber(tPos[1][1])
					local nDotY = tonumber(tPos[1][2])
					local nDotX2 = tonumber(tPos[2][1])
					local nDotY2 = tonumber(tPos[2][2])
					data.tCoordinate = {x = nDotX, y = nDotY, x2 = nDotX2, y2 = nDotY2}
					local fPosX, fPosY = WorldFunc.getMapPosByDotPos(nDotX, nDotY)
					local fPosX2, fPosY2 = WorldFunc.getMapPosByDotPos(nDotX2, nDotY2)
					if fPosX and fPosX2 then
						-- data.tMapPos = {x = fPosX, y = fPosY}
						data.tMapPos = {x = fPosX + (fPosX2 - fPosX)/2, y = fPosY + (fPosY2 - fPosY)/2}
					else
						myprint(string.format("world_city id = %s,生成地图坐标出错",k))
					end

					data.tCoordinateCenter = {
						x = data.tCoordinate.x + (data.tCoordinate.x2 - data.tCoordinate.x)/2,
						y = data.tCoordinate.y + (data.tCoordinate.y2 - data.tCoordinate.y)/2,
					}

					--记录关联
					local nDotXStart = nDotX
					local nDotYStart = nDotY
					for nDotXStart=nDotX,nDotX2 do
						for nDotYStart=nDotY,nDotY2 do
							local sDotKey = string.format("%s_%s", nDotXStart, nDotYStart)
							tWorldCityIdByDotKey[sDotKey] = data.id
						end
					end
				end
			end
		end
		--解析area
		local area = data.area
		if area then
			local tData = luaSplitMuilt(area,";", ",")
			local tArea = {
				xstart = tonumber(tData[1][1]),
				ystart = tonumber(tData[1][2]),
				xover = tonumber(tData[2][1]),
				yover = tonumber(tData[2][2]),
			}
			data.tArea = tArea
		end
		tWorldCityData[data.id] = data
	end
	return tWorldCityData
end

--获取世界大地图城池数据单个
function getWorldCityDataById( nCityId )
	if not tWorldCityData then
		getWorldCityData()
	end
	if tWorldCityData then
		return tWorldCityData[nCityId]
	end
	return nil
end

--获取世界大地图城池数据集
--nMapId:区域id
function getWorldCityDataByMapId( nMapId )
	if not tWorldCityData then
		getWorldCityData()
	end
	if tWorldCityData then
		local tRes = {}
		for k,v in pairs(tWorldCityData) do
			if v.map == nMapId then
				table.insert( tRes, v )
			end
		end
		return tRes
	end
	return {}
end

--根据坐标获取系统城池的数据
--nX, nY:系统城池最左边的视图点
function getWorldCityDataByPos( nX, nY )
	if not tWorldCityIdByDotKey then
		getWorldCityData()
	end
	if tWorldCityIdByDotKey then
		local sDotKey = string.format("%s_%s", nX, nY)
		local nSysCityId = tWorldCityIdByDotKey[sDotKey]
		if nSysCityId then
			return getWorldCityDataById(nSysCityId)
		end
	end
	return nil
end

-- 获取区域大地图数据
function getWorldMapDataById( nBlockId )
	if not tWorldMapData then
		getWorldMapData()
	end
	return tWorldMapData[nBlockId]
end

-- 判断城池是否是区域的中心城池
function getWorldCityIsCenter( nCityId )
	if not nCityId then
		return false
	end
	local tCityData = getWorldCityDataById(nCityId)
	if tCityData then
		local tBlockData = getWorldMapDataById(tCityData.map)
		if tBlockData then
			return tBlockData.maincity == nCityId
		end
	end
	return false
end

-- -- 获取州随机坐标
-- function getRandomDotByBlockType( nBlockType )
-- 	if not tWorldMapData then
-- 		getWorldMapData()
-- 	end

-- 	if tWorldMapData then
-- 		local tBlockDatas = {}
-- 		for k,v in pairs(tWorldMapData) do
-- 			if v.type == nBlockType then
-- 				table.insert(tBlockDatas, v)
-- 			end
-- 		end

-- 		local nIndex = math.random(1,#tBlockDatas)
-- 		local nX = math.random(tBlockDatas[nIndex].xstart, tBlockDatas[nIndex].xover)
-- 		local nY = math.random(tBlockDatas[nIndex].ystart, tBlockDatas[nIndex].yover)
-- 		return tBlockDatas[nIndex].id, nX, nY
-- 	end
-- 	return nil
-- end

-- 获取随机系统城池
--nKind 城池类型
--tOutIdDict 除外的id
function getRandomSysCityByKind( nKind, tOutIdDict)
	--可以去的区域
	local nMapId = nil
	local nMyBlockId = Player:getWorldData():getMyCityBlockId()
	local tCurrBlockData = getWorldMapDataById(nMyBlockId)
	local tMapIds = {}
	while tCurrBlockData do
		tMapIds[tCurrBlockData.id] = true
		tCurrBlockData = getWorldMapDataById(tCurrBlockData.subordinate)
	end
	--遍历城池
	--城池数据
	if not tWorldCityData then
		getWorldCityData()
	end
	if tWorldCityData then
		local tCityDatas = {}
		for k,v in pairs(tWorldCityData) do
			if v.kind == nKind and tMapIds[v.map] then
				--存在包含的目标中
				if tOutIdDict then
					if not tOutIdDict[k] then
						table.insert(tCityDatas, v)
					end
				else
					table.insert(tCityDatas, v)
				end
			end
		end
		if #tCityDatas > 0 then
			local nIndex = math.random(1,#tCityDatas)
			return tCityDatas[nIndex]
		end
	end
	return nil
end

-- 获取LvUp表
local tAvatarLvUp = {}
function getAvatarLvUpByLevel( _key )
	if _key == 0 then
		return
	end
	if(tAvatarLvUp[_key]) then
		return tAvatarLvUp[_key]
	end
	for data in execForRows(Player.gamedb, "select * from avatar_lv_up where level = \'" .. _key .. "\'") do
		tAvatarLvUp[_key] = data
		return data
	end
	print("cannot find \"" .. _key .. "\" in avatar_lv_up db")
	return nil
end

-- 获取世界地图乱军数据
local tWorldEnemyData = {}
function getWorldEnemyData( _key , bIsNoLog)
	if(tWorldEnemyData[_key]) then
		return tWorldEnemyData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from world_rebel where id = \'" .. _key .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tWorldEnemyData[_key] = data
		return data
	end
	if not bIsNoLog then
		print("cannot find \"" .. _key .. "\" in world_rebel db")
	end
	return nil
end

--根据等级获取乱军数据
function getWorldEnemyDataByLv( nLv )
	for data in execForRows(Player.gamedb, "select * from world_rebel where level = \'" .. nLv .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tWorldEnemyData[data.id] = data
		return data
	end
	return nil
end

-- 获取世界地图侦查表
local tWorldDetect = {}
function getWorldDetectData( _key )
	if(tWorldDetect[_key]) then
		return tWorldDetect[_key]
	end
	for data in execForRows(Player.gamedb, "select * from world_detect where lv = \'" .. _key .. "\'") do
		--转高级侦查为字典模式
		local tData = luaSplitMuilt(data.seniordetect, "|", ":")
		local tCostType = {}
		local tSeniorDetect = {}
		for i=1,#tData do
			local nKey = tonumber(tData[i][1])
			local nValue = tonumber(tData[i][2])
			tSeniorDetect[nKey] = nValue
			if i == 1 then --消耗类型 0:正常消耗 1:特殊消耗 ,服务端需要
				tCostType[nKey] = 1
			elseif i == 2 then
				tCostType[nKey] = 0
			end
		end
		data.tSeniorDetect = tSeniorDetect
		data.tCostType = tCostType
		tWorldDetect[_key] = data
		return data
	end
	print("cannot find \"" .. _key .. "\" in world_detect db")
	return nil
end

--获取世界地图城战
local tWorldCityFightData = {}
function getWorldCityFightData( _key )
	if(tWorldCityFightData[_key]) then
		return tWorldCityFightData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from world_city_fight where id = \'" .. _key .. "\'") do
		--转高级侦查为字典模式
		local tRule = {}
		local tData = luaSplit(data.rule, ";")
		if #tData == 1 then
			tData = luaSplitMuilt(data.rule, ":", "-")
			local nStartTime = tonumber(tData[1][1])
			local nEndTime = tonumber(tData[1][2])
			local nStayTime = tonumber(tData[2])*60
			table.insert(tRule, {nStartTime = nStartTime, nEndTime = nEndTime, nStayTime = nStayTime})
		else
			tData = luaSplitMuilt(data.rule, ";", ":", "-")
			for i=1,#tData do
				local nStartTime = tonumber(tData[i][1][1])
				local nEndTime = tonumber(tData[i][1][2])
				local nStayTime = tonumber(tData[i][2])*60
				table.insert(tRule, {nStartTime = nStartTime, nEndTime = nEndTime, nStayTime = nStayTime})
			end
		end
		data.tRule = tRule
		tWorldCityFightData[_key] = data
		return data
	end
	print("cannot find \"" .. _key .. "\" in world_city_fight db")
	return nil
end

-- 获取矿点数据
local tWorldMineData = {}
function getWorldMineData( _key )
	if not _key then
		return nil
	end
	if(tWorldMineData[_key]) then
		return tWorldMineData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from world_mine where id = \'" .. _key .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tWorldMineData[_key] = data
		return data
	end
	print("cannot find \"" .. _key .. "\" in world_mine db")
	return nil
end

--根据等级获取乱军数据
function getWorldMineDataByTypeAndLv( nType, nLv )
	for data in execForRows(Player.gamedb, "select * from world_mine where type = \'" .. nType .. "\' and level = \'" .. nLv .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tWorldMineData[data.id] = data
		return data
	end
	return nil
end

-- 获取世界地图季节数据
local tWorldSeasonData = {}
function getWorldSeasonData( _key )
	if(tWorldSeasonData[_key]) then
		return tWorldSeasonData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from world_season where days = \'" .. _key .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tWorldSeasonData[_key] = data
		return data
	end
	print("cannot find \"" .. _key .. "\" in world_season db")
	return nil
end


-- 获取都城数据
local tWorldCapitalData = {}
function getWorldCapitalData( nId )
	if(tWorldCapitalData[nId]) then
		return tWorldCapitalData[nId]
	end
	for data in execForRows(Player.gamedb, "select * from world_capital where id = \'" .. nId .. "\'") do
		tWorldCapitalData[nId] = data
		return data
	end
	print("cannot find \"" .. nId .. "\" in world_capital db")
	return nil
end

--获取都城最大等级
local nCapitalLvMax = nil
function getWorldCapitalLvMax(  )
	if nCapitalLvMax then	
  		return nCapitalLvMax
	end
	for data in execForRows(Player.gamedb, "select * from world_capital order by id desc") do		    	
		nCapitalLvMax = data.id
    	return nCapitalLvMax
    end
    nCapitalLvMax = 0
    return nCapitalLvMax
end

--获取世界目标
local tWorldTargetData = {}
function getWorldTargetData( nId )
	if(tWorldTargetData[nId]) then
		return tWorldTargetData[nId]
	end
	for data in execForRows(Player.gamedb, "select * from world_target where id = \'" .. nId .. "\'") do
		--taskDetail
		if data.taskdetail then
			local tData = luaSplit(data.taskdetail, ":") 
			data.nTargetType = tonumber(tData[1])
			data.nTargetValue = tonumber(tData[2])
		end
		--bossAward
		if data.bossaward then
			local tData = luaSplitMuilt(data.bossaward, ";", ":", "-")
			data.tBossAward = {}
			for i=1,#tData do
				local tTroops = tData[i][1]
				local nDropId = tData[i][2]
				if tTroops and nDropId then
					if #tTroops == 2 then
						local nTroopsMin = tonumber(tTroops[1])
						local nTroopsMax = tonumber(tTroops[2])
						local nDropId = tonumber(nDropId)
						if nTroopsMin and nTroopsMax and nDropId then
							local tData2 = {
								nTroopsMin = nTroopsMin,
								nTroopsMax = nTroopsMax,
								nDropId = nDropId,
							}
							table.insert(data.tBossAward, tData2)
						end
					end
				end
			end
		end
		if data.icon then
			data.sIcon = "#"..data.icon..".png"
		end
		tWorldTargetData[nId] = data
		return data
	end
	-- print("cannot find \"" .. nId .. "\" in world_target db")
	return nil
end

-----------------------------------大地图相关---------------------------------------------    

-- 获取vip表
local tAvatarVip = nil
--获取所有vip数据
function getAvatarVIPData(  )
	-- body
	if not tAvatarVip or #tAvatarVip <= 0 then
		tAvatarVip = {}
		for data in execForRows(Player.gamedb, "select * from avatar_vip") do
			tAvatarVip[data.lv] = data			
		end		
	end
	return tAvatarVip
end
--获取某一等级的vip数据
function getAvatarVIPByLevel( _key )
	if not tAvatarVip or #tAvatarVip <= 0 then
		getAvatarVIPData()		
	end
	if(tAvatarVip[_key]) then
		return tAvatarVip[_key]
	end	
	print("cannot find \"" .. _key .. "\" in avatar_vip db")
	return nil
end
--获取VIP页数
function getAvatarVIPNum(  )
	-- body
	if not tAvatarVip then
		getAvatarVIPByLevel(0)
	end
	return table.nums(tAvatarVip)
end

-- 获取vip表的礼包等级列表
local tAvatarVipLvs = nil
function getAvatarVipLvs( )
	if tAvatarVipLvs then
		return tAvatarVipLvs
	end
	tAvatarVipLvs = {}
	for data in execForRows(Player.gamedb, "select * from avatar_vip") do
		table.insert(tAvatarVipLvs, data.lv)
	end
	return tAvatarVipLvs
end
-----------------------------------背包相关---------------------------------------------         
local tBaseItemData = {} -- 基础物品临时数据
-- 根据配表id读取物品数据
function getBaseItemDataByID( _id )
	if not _id then
		return
	end
	local pItemStuffData = nil	
	if tBaseItemData[_id] then	
    	pItemStuffData = ItemStuffData.new()
		pItemStuffData:initDataByDB(tBaseItemData[_id])
  		return pItemStuffData
	end
	for data in execForRows(Player.gamedb, "select * from item_base where id = \'" .. _id .. "\'") do		    	
    	pItemStuffData = ItemStuffData.new()
		pItemStuffData:initDataByDB(data)
		tBaseItemData[_id] = data
    	break
    end
    return pItemStuffData 
end

local tItemList = {}
function getBaseItemDataByList(list, _type)
	if not list then
		return
	end
	tItemList = {}
	for i, itemres in pairs(list) do
		local pItemStuffData = getBaseItemDataByID(itemres.id)		
		if pItemStuffData then		
			pItemStuffData.nCt = itemres.c --物品数量
			if (_type == nId) or (pItemStuffData.nType == _type) then
				table.insert(tItemList, pItemStuffData)
			end

		end		
	end
	--根据配表排序
	table.sort( tItemList, function ( a, b )
		-- body
		return a.nSequence < b.nSequence
	end )
	return tItemList
end

local tBaseEquipData = {} -- 装备临时数据
-- 根据配表id读取物品数据
function getBaseEquipDataByID( _id )
	if not _id then
		return
	end
	local pItemEquipData = nil	
	if tBaseEquipData[_id] then	
    	pItemEquipData = ItemEquipData.new()
		pItemEquipData:initDataByDB(tBaseEquipData[_id])
  		return pItemEquipData
	end
	
	for data in execForRows(Player.gamedb, "select * from equip_base where id = \'" .. _id .. "\'") do		    	
    	pItemEquipData = ItemEquipData.new()
		pItemEquipData:initDataByDB(data)
		tBaseEquipData[_id] = data
    	break
    end
    return pItemEquipData 
end

--根据配表类型获取装备数据
local tEquipsByQuality = {}
function getEquipsByQuality( nQuality )
	local t = {}
	if tEquipsByQuality[nQuality] and table.nums(tEquipsByQuality[nQuality]) > 0 then
		for k, v in pairs (tEquipsByQuality[nQuality]) do
			local pItemEquipData = ItemEquipData.new()
			pItemEquipData:initDataByDB(v)
			table.insert(t, pItemEquipData)
		end
	else
		local tDatas = {}
		for data in execForRows(Player.gamedb, "select * from equip_base where quality = \'" .. nQuality .. "\'") do
			if tBaseEquipData[data.id] then
				local pItemEquipData = ItemEquipData.new()
				pItemEquipData:initDataByDB(tBaseEquipData[data.id])
				table.insert(tDatas, tBaseEquipData[data.id])
				table.insert(t, pItemEquipData)
			else
				local pItemEquipData = ItemEquipData.new()
				pItemEquipData:initDataByDB(data)
				tBaseEquipData[data.id] = data
				table.insert(tDatas, tBaseEquipData[data.id])
				table.insert(t, pItemEquipData)
			end
	    end
	    tEquipsByQuality[nQuality] = tDatas
	end
	
    if(not t or table.nums(t) <= 0) then
		t = nil
	end
    return t 
end

--获取装备最高品质
local nEquipQualityMax = nil
function getEquipQualityMax(  )
	if nEquipQualityMax then	
  		return nEquipQualityMax
	end
	for data in execForRows(Player.gamedb, "select * from equip_base order by quality desc") do		    	
		nEquipQualityMax = data.quality
    	return nEquipQualityMax
    end
    nEquipQualityMax = 0
    return nEquipQualityMax
end

--获取打造显示的装备数据
function getEquipsInSmith( nQuality )
	local tRes = {}
	local tEquipDatas = getEquipsByQuality(nQuality)
	for i=1,#tEquipDatas do
		if tEquipDatas[i].bIsShow then
			table.insert(tRes, tEquipDatas[i] )
		end
	end
	return tRes
end

--获取洗炼数据
local tEquipTrainAttr = {}
function getEquipTrainAttr( nLv )
	if not nLv then
		return
	end
	if tEquipTrainAttr[nLv] then	
  		return tEquipTrainAttr[nLv]
	end
	for data in execForRows(Player.gamedb, "select * from equip_train_attr where level = \'" .. nLv .. "\'") do		    	
		tEquipTrainAttr[nLv] = data
    	return data
    end
    print("cannot find \"" .. nLv .. "\" in equip_train_attr db")
    return nil 
end

--获取洗炼最高等级
local nEquipTrainAttrLvMax = nil
function getEquipTrainAttrLvMax(  )
	if nEquipTrainAttrLvMax then	
  		return nEquipTrainAttrLvMax
	end
	for data in execForRows(Player.gamedb, "select * from equip_train_attr order by level desc") do		    	
		nEquipTrainAttrLvMax = data.level
    	return nEquipTrainAttrLvMax
    end
    print("cannot find nEquipTrainAttrLvMax in equip_train_attr db")
    return nil 
end

local tEquipInit = {} -- 装备初始表
function getEquipInitParam( sKey )
	if(tEquipInit[sKey]) then
		return tEquipInit[sKey]
	end
	for data in execForRows(Player.gamedb, "select * from equip_init where key = \'" .. sKey .. "\'") do
		tEquipInit[sKey] = tonumber(data.value) or data.value
		return tEquipInit[sKey] 
	end
	print("cannot find \"" .. sKey .. "\" in item_base db")
	return -1
end

--获取装备的强化数据
--_nQuality: 品质
local tEquipStrengthData = nil
function getAllEquipStrengthInfo()
	-- body
	if tEquipStrengthData then	
  		return tEquipStrengthData
	end
	local tTemp = execForTable(Player.gamedb, "select * from equip_strprob;")
	if not tTemp or #tTemp <= 0 then
		print("cannot find equip_strprob db")	
	else	
		tEquipStrengthData = tTemp
	end
	return tEquipStrengthData
end

--根据装备品质获取强化数据
local tEquipStrenthDic = {}
function getEquipStrengthByQuality(_nQuality)
	-- body
	if not _nQuality then
		return
	end
	if tEquipStrenthDic[_nQuality] then
		return tEquipStrenthDic[_nQuality]
	end
	tEquipStrenthDic[_nQuality] = {}
	if not tEquipStrengthData then
		getAllEquipStrengthInfo()
	end
	local nQ = tostring(_nQuality)
	for k, v in pairs(tEquipStrengthData) do
		local nLv = tonumber(v.level)
		tEquipStrenthDic[_nQuality][nLv] = {
			attr 			= v["attr"..nQ],
			prob 			= tonumber(v["prob"..nQ]), --成功基础概率
			resources 		= v["resources"..nQ],
			stone 			= tonumber(v["stone"..nQ]) --突破石数量
		}
	end
	return tEquipStrenthDic[_nQuality]
end

--根据品质和强化等级获取强化数据
function getEquipStrengthInfo(_nQuality, _nLv)
	-- body
	if tEquipStrenthDic[_nQuality] then
		if tEquipStrenthDic[_nQuality][_nLv] then
			return tEquipStrenthDic[_nQuality][_nLv]
		end
	else
		local tDic = getEquipStrengthByQuality(_nQuality)
		return tDic[_nLv]
	end
end
-----------------------------------背包相关---------------------------------------------         

-----------------------------------国家相关---------------------------------------------
--国家全局表
local tCountryParam = {}
function getCountryParam( _key )
	-- body
	if(tCountryParam[_key]) then
		return tCountryParam[_key]
	end
	tCountryParam = {}
	for data in execForRows(Player.gamedb, "select * from country_init where key = \'" .. _key .. "\'") do
		if data and data.value then
			tCountryParam[_key] = data.value
			return tCountryParam[_key]
		end
	end
	print("cannot find \"" .. _key .. "\" in country_init db")
	return nil	
end

--获取城战积分进度数据
function getWarScoreTasksData( )
	-- body
	local tScoreData = luaSplit(getCountryParam("castleWarScoreTasks"), ";")
	local tdata = {}
	for k, v in pairs(tScoreData) do
		local ttmp = luaSplit(v, ":")
		local idx = tonumber(ttmp[1]) 
		tdata[idx] = {nScore = tonumber(ttmp[2]), nDropId = tonumber(ttmp[3])}
	end
	return tdata
end

-- 获取国家官职表
local tNationNoble = {}
function getNationNoble( nLevel )
	if(tNationNoble[nLevel]) then
		return tNationNoble[nLevel]
	end
	for data in execForRows(Player.gamedb, "select * from country_privilege where officer = \'" .. nLevel .. "\'") do
		tNationNoble[nLevel] = data
		return data
	end
	print("cannot find \"" .. nLevel .. "\" in country_privilege db")
	return nil
end

-- 获取国家召唤表
local tNationTransport = {}
function getNationTransport( nOfficer )
	if not nOfficer then
		return nil
	end
	if tNationTransport[nOfficer] then
		return tNationTransport[nOfficer]
	end
	for data in execForRows(Player.gamedb, "select * from country_privilege where officer = \'" .. nOfficer .. "\'") do
		tNationTransport[nOfficer] = data
		return data
	end
	print("cannot find \"" .. nOfficer .. "\" in country_privilege db")
	return nil
end

--获取国家荣誉任务表
local tCountryHonorTask = nil
function getCountryHonorTask( )
	-- body
	local t = {}
	if not tCountryHonorTask or # tCountryHonorTask <= 0 then
		local tTemp = execForTable(Player.gamedb, "select * from country_honor_task;")
		if not tTemp or #tTemp <= 0 then
			tCountryHonorTask = nil			
		else
			tCountryHonorTask = {}
			for i, v in pairs(tTemp) do
				local tdata = HonorTask.new()
				tdata:refreshDataByDB(v)
				tCountryHonorTask[v.id] = v
				t[v.id] = tdata
			end
		end
	else
		for k, v in pairs (tCountryHonorTask) do
			local tdata = HonorTask.new()
			tdata:refreshDataByDB(v)
			t[v.id] = tdata
		end
	end
	if(not t or #t <= 0) then
		t = nil
	end
	return t
end

--官职特权
local tCountryPriShow = nil
function getCountryPriShow(  )
	-- body
	if not tCountryPriShow then
		local tTemp = execForTable(Player.gamedb, "select * from country_prishow;")
		if not tTemp or #tTemp <= 0 then
			tCountryPriShow = nil			
			return tCountryPriShow
		end
		tCountryPriShow = {}
		for i, v in pairs(tTemp) do
			table.insert(tCountryPriShow, v)			
		end
	end
	return tCountryPriShow	
end

--国家经验表
local tCountryExp = nil
function getCountryExpFromDB(  )
	-- body
	if not tCountryExp then
		local tTemp = execForTable(Player.gamedb, "select * from country_exp;")
		if not tTemp or #tTemp <= 0 then
			tCountryExp = nil			
			return tCountryExp
		end
		tCountryExp = {}
		for i, v in pairs(tTemp) do
			tCountryExp[v.level] = v
		end
	end
	return tCountryExp	
end

--国家开发表
local tCountryDevelop = nil
function getCountryDevelop(  )
	-- body
	if not tCountryDevelop then
		local tTemp = execForTable(Player.gamedb, "select * from country_develop;")
		if not tTemp or #tTemp <= 0 then
			tCountryDevelop = nil	
			print("cannot find country_develop db")	
		else	
			tCountryDevelop = {}
			for i, v in pairs(tTemp) do
				tCountryDevelop[v.time] = v
			end
		end
	end
	return tCountryDevelop
end

--国家爵位表
local tCountryBanneret = nil
function getCountryBanneret(  )
	-- body
	if not tCountryBanneret then
		local tTemp = execForTable(Player.gamedb, "select * from country_banneret;")
		if not tTemp or #tTemp <= 0 then
			tCountryBanneret = nil	
			print("cannot find country_banneret db")	
		else	
			tCountryBanneret = {}
			for i, v in pairs(tTemp) do
				tCountryBanneret[v.level] = v
			end
		end
	end
	return tCountryBanneret	
end

function getBanneretByLv( _nLv )
	-- body
	if not _nLv then
		return nil
	end
	if not tCountryBanneret then
		getCountryBanneret( )		
	end
	return tCountryBanneret[_nLv]
end

--获取爵位
function getCountryBanneretByLv( nLv )
	if not tCountryBanneret then
		getCountryBanneret()
	end
	if tCountryBanneret then
		return tCountryBanneret[nLv]
	end
end

--国家投票表
local tCountryVote = nil
function getCountryVote(  )
	-- body
	if not tCountryVote then
		local tTemp = execForTable(Player.gamedb, "select * from country_vote;")
		if not tTemp or #tTemp <= 0 then
			tCountryVote = nil	
			print("cannot find country_vote db")	
		else	
			tCountryVote = {}
			for i, v in pairs(tTemp) do
				tCountryVote[v.time] = v.cost
			end
		end
	end
	return tCountryVote	
end

--国家日志模板表
local tLogTemplate = nil
function getCountryLogTemplates(  )
	-- body
	if not tLogTemplate then
		local tTemp = execForTable(Player.gamedb, "select * from country_journal;")
		if not tTemp or #tTemp <= 0 then
			tLogTemplate = nil	
			print("cannot find country_journal db")	
		else	
			tLogTemplate = {}
			for i, v in pairs(tTemp) do
				tLogTemplate[v.id] = v.content
			end
		end
	end
	return tLogTemplate	
end

function getCountryLogTemplate( nId )
	if not tLogTemplate then
		getCountryLogTemplates()
	end
	if tLogTemplate then
		return tLogTemplate[nId]
	end
end
-----------------------------------国家相关---------------------------------------------

---------------------------------名字表---------------------------------------------         
local tNames = {} --玩家名字库
--从name表获取一个随机名字
function getRandomName(  )
	-- body

	if table.nums(tNames) <= 0 then
		local tTemp = execForTable(Player.gamedb, "select * from avatar_name;")
		if not tTemp or #tTemp <= 0 then
			print("Failed to generate a random name")
			return nil
		end
 		for i, v in pairs(tTemp) do
			tNames[i] = v
 		end
	end
	local nlen = table.nums(tNames)	
	--math.randomseed(os.time())  	
	local nidx1 = math.random(1, nlen)	
	local namefst = tNames[nidx1].first    --序号1姓氏

	local nidx2 = math.random(1, nlen)
	local namemid = tNames[nidx2].mid  	  --序号 中间名 集合
	local nidx3 = math.random(1, nlen)
	local namelst = tNames[nidx3].last     --序号 名 集合	
	if not namemid then
		namemid = ""
	end
	if namefst and namelst then
		return	namefst..namemid..namelst
	end
	return nil
end

---------------------------------名字表---------------------------------------------         

---------------------------------作坊相关---------------------------------------------         
local tAtelierParam = {} --工坊参数表
function getAtelierParam(_key)
	-- body
	-- body
	if(tAtelierParam[_key]) then
		return tAtelierParam[_key]
	end
	for data in execForRows(Player.gamedb, "select * from build_init where key = \'" .. _key .. "\'") do
		tAtelierParam[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in build_init db")
	return -1
end

local tAtelierSaturation = {} --人口饱和度数据
--参数 _Lv 王宫等级
function getSaturationDataFromDB( _Lv )
	-- body
	if(tAtelierSaturation[_Lv]) then
		return tAtelierSaturation[_Lv]
	end
	local tdata = {}
	for data in execForRows(Player.gamedb, "select * from build_saturation where level = \'" .. _Lv .. "\'") do
		if data then
			tdata = data
			tAtelierSaturation[_Lv] = data
			return tdata
		end
	end	
	return tdata
end
--获取build_production表的数据
local tAtelierProduction = nil
--从name表获取一个随机名字
function getAtelierProductionParam( )
	-- body
	if tAtelierProduction then
		return tAtelierProduction
	else
		tAtelierProduction = {}
		local tTemp = execForTable(Player.gamedb, "select * from build_production;")
		if not tTemp or #tTemp <= 0 then
			print("读取build_production表失败")
			return nil
		end
 		for i, v in pairs(tTemp) do
			tAtelierProduction[i] = v
 		end 
 		return tAtelierProduction
	end
end
---------------------------------作坊相关---------------------------------------------         
---------------------------------公共相关---------------------------------------------

local tDropById = {} -- 掉落的配表临时数据
local tDropTempData = {} -- 等级配表的临时数据
-- 根据掉落的配表id获得掉落详细列表
function getDropById( nId )
	if not nId then return end
	local pResData = {}

	if(tDropById[nId]) then
		pResData = tDropById[nId]
	else
		--根据id获得掉落列表
		for data in execForRows(Player.gamedb, "select * from drop_drop where did = \'" .. nId .. "\'") do
	  		pResData = data
	  		tDropById[nId] = data
	    end
	end

	-- 是否在普通掉落表中查询到了
	if(pResData and table.nums(pResData) > 0) then
	    local i = 1
	    local tDropData = {}
	    while pResData["id"..i] do
	    	local nId = pResData["id"..i]
	    	local drop = getGoodsByTidFromDB(nId)
	    	if  drop then	    	
		    	if drop.nGtype == e_type_goods.type_res then
					drop.nNeedCount = pResData["num"..i]
		    	else
		    		drop.nCt = pResData["num"..i]
		    	end

		    	--掉落几率，关卡详情界面用到
		    	drop.weig = pResData["weig"..i]
		    	table.insert(tDropData, drop)
		    else
	    		--掉落组id去查询(这个时候是一个table了)
	    		drop = getDropDataByGroupId(nId)
	    		if drop and table.nums(drop) > 0 then
	    			for k, v in pairs (drop) do
		    			if v.nGtype == e_type_goods.type_res then
							v.nNeedCount = v.num
				    	else
				    		v.nCt =  v.num
				    	end
				    	v.weig = drop.weight
				    	table.insert(tDropData, v)
	    			end
	    		end
		    end
	    	i = i + 1
	    end
	    return tDropData, pResData

	else -- 查询不到，到等级掉落表中查询
		local tTempData = getDropDataForLevelById(nId)
		-- 如果从等级配表中找到的话
		if(tTempData) then
			local sNewId = nil
			if(tTempData.type == 1) then -- 指挥中心等级
				-- local pBuild = Player:getBaseBuildInfoByIdFromPlayer(e_ids_build.slb)
				-- if(pBuild and pBuild.nLv) then
				-- 	sNewId = tTempData["lv" .. pBuild.nLv]
				-- end
			else -- 玩家等级
				sNewId = tTempData["lv" .. Player.baseInfos.nLv]
			end
			if(sNewId and string.len(sNewId) > 0) then
				return getDropById(sNewId)
			end
		end
    	return nil 
	end
end

--根据掉落组ID获取掉落物品列表
function getDropDataByGroupId( nId )
	local pResData = {}
	local data = execForTable(Player.gamedb, "select * from drop_group where gid = \'" .. nId .. "\'") do
  		for k,v in pairs(data) do
  			if v and v.id then
	  			local tGood = getGoodsByTidFromDB(v.id)
		  		if tGood then
		  			tGood.num = v.num
			  		table.insert(pResData,tGood)
			  	end
			end
  		end
    end
	return pResData
end

--根据掉落Id获取掉落物品显示数据
function getDropItemsShow( nid )
	-- body
	local items = getDropById(nid)
	if not items or #items <= 0 then
		return nil
	end
	local ttemp = {}		
	for k, v in pairs(items) do			
		if not ttemp[v.sTid] then
			ttemp[v.sTid] = {item = v, min = v.nCt, max = v.nCt}			
		else
			local cnt = tonumber(v.nCt or 0)
			if cnt < ttemp[v.sTid].min then
				ttemp[v.sTid].min = cnt		
			end
			if cnt > ttemp[v.sTid].max then
				ttemp[v.sTid].max = cnt
			end
		end
	end
	local tshowitems = {}
	for k, v in pairs(ttemp) do
		table.insert(tshowitems, v)
	end
	table.sort(tshowitems, function ( a, b )
		-- body
		return a.item.sTid < b.item.sTid
	end)
	return tshowitems
end

--根据掉落ID获取等级掉落的不同分配
function getDropDataForLevelById( nId )
	local pResData = {}
	if(tDropTempData[nId]) then
		pResData = tDropTempData[nId]
	else
		--根据id获得掉落列表
		for data in execForRows(Player.gamedb, "select * from drop_level where id = \'" .. nId .. "\'") do
	  		pResData = data
	  		tDropTempData[nId] = data
	    end
	end
	return pResData
end

---------------------------------公共相关---------------------------------------------

---------------------------------任务相关---------------------------------------------
--加载任务表
local tTaskData = {}
function getTaskDatasFromDB( _id )
	-- body
	if not _id then
		return
	end
	local tdata = nil
	if tTaskData[_id] then
		tdata = BTaskItemData.new()
		tdata:initDataByDB(tTaskData[_id])
	else		
		if  _id >= 20001  and _id <= 29999 then--任务列表
			for data in execForRows(Player.gamedb, "select * from mission_mission where id = \'" .. _id .. "\'") do
				tdata = BTaskItemData.new()
				tdata:initDataByDB(data)
				tTaskData[_id] = data
				break
			end
		end
	end	
	return tdata
end
local tDailyTask = {}
function getDailyTaskBaseDataFromDB( _id )
	-- body
	if not _id then
		return
	end
	local tdata = nil
	if tDailyTask[_id] then
		tdata = BTaskItemData.new()
		tdata:initDataByDB(tDailyTask[_id])
	else		
		if _id >= 4001 and _id <= 4999 then--日常任务
			for data in execForRows(Player.gamedb, "select * from mission_daily where id = \'" .. _id .. "\'") do
				tdata = BTaskItemData.new()
				tdata:initDataByDB(data)
				tDailyTask[_id] = data
				break
			end
		end
	end	
	return tdata	
end

local tMissionParam = {} -- 任务全局表的临时数据
-- 获取一些任务全局参数
function getMissionParam( _key )
	-- body
	if(tMissionParam[_key]) then
		return tMissionParam[_key]
	end
	for data in execForRows(Player.gamedb, "select * from mission_init where key = \'" .. _key .. "\'") do
		tMissionParam[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in item_base db")
	return -1
end

local tDailyTaskParam = nil
function getDailyTaskParam(  )
	-- body
	if not tDailyTaskParam then
		tDailyTaskParam = {}
		local tParam = luaSplitMuilt(getMissionParam("dailyTask"), ";", ":")		
		for k, v in pairs(tParam) do
			local ttmp = {}
			ttmp.nScore = tonumber(v[1] or 0)
			ttmp.nDropId = tonumber(v[2] or 0)
			table.insert(tDailyTaskParam, ttmp)
		end
	end
	return tDailyTaskParam
end

local tChatperTask = {}
function getChatperTaskBaseDataFromDB( _id )
	-- body
	if not _id then
		return
	end
	local tdata = nil
	if tChatperTask[_id] then
		tdata = DataChatprtTatget.new()
		tdata:initDataByDB(tChatperTask[_id])
	else		
		for data in execForRows(Player.gamedb, "select * from plot_target where id = \'" .. _id .. "\'") do
			tdata = DataChatprtTatget.new()
			tdata:initDataByDB(data)
			tChatperTask[_id] = data
			break
		end
	end	
	return tdata	
end


local tChatpers = {}
function getChatperData( _id )
	-- body
	if not _id then
		return
	end
	if tChatpers[_id] then
 		return tChatpers[_id]
	else		
		for data in execForRows(Player.gamedb, "select * from plot_chapter where id = \'" .. _id .. "\'") do
			tChatpers[_id] = data
			return tChatpers[_id]
		end
	end	
	print("cannot find \"" .. _id .. "\" in plot_chapter db")
	return nil	
end

local tChatperDialogs = {}
function getChatperDialogData( _id )
	-- body
	if not _id then
		return
	end
	if tChatperDialogs[_id] then
 		return tChatperDialogs[_id]
	else
		tChatperDialogs[_id] = {}
		tChatperDialogs[_id].s = {}
		tChatperDialogs[_id].e = {}
		--剧情前对话
		for data in execForRows(Player.gamedb, "select * from plot_script where oid = \'" .. _id..":0" .. "\'") do
			table.insert(tChatperDialogs[_id].s, data)
		end
		--剧情后对话
		for data in execForRows(Player.gamedb, "select * from plot_script where oid = \'" .. _id..":1" .. "\'") do
			table.insert(tChatperDialogs[_id].e, data)
		end
		return tChatperDialogs[_id]
	end	
	print("cannot find \"" .. _id .. "\" in plot_script db")
	return nil	
end


---------------------------------任务相关---------------------------------------------

---------------------------------邮件相关---------------------------------------------
--获取邮件nit数据
local tMailInitData = {}
function getMailInitData( sKey )
	-- body
	if(tMailInitData[skey]) then
		return tMailInitData[skey]
	end
	for data in execForRows(Player.gamedb, "select * from mail_init where key = \'" .. sKey .. "\'") do
		local sValue = data.value
		local nValue = tonumber(sValue)
		if nValue then
			tMailInitData[sKey] = nValue
		else
			tMailInitData[sKey] = sValue
		end
		return tMailInitData[sKey]
	end
	print("cannot find \"" .. sKey .. "\" in mail_init db")
	return nil
end

-- 获取邮件报告
local tMailReports = {}
function getMailReport( nId )
	if(tMailReports[nId]) then
		return tMailReports[nId]
	end
	for data in execForRows(Player.gamedb, "select * from mail_report where id = \'" .. nId .. "\'") do
		tMailReports[nId] = data
		--图标
		if data.icon then
			data.sIcon = "#"..data.icon..".png"
		end
		if data.icon2 then
			data.sIcon2 = "#"..data.icon2..".png"
		end
		--标题
		local tTitle = luaSplit(data.title,":")
		tMailReports[nId].sTitle = tTitle[1]
		tMailReports[nId].sColor = tTitle[2]
		--描述
		if data.desc then
			-- local tDesc = luaSplit(data.desc,":")
			-- if type(tDesc) == "table" then
			-- 	tMailReports[nId].sDesc = tDesc[1]
			-- 	tMailReports[nId].sDescColor = tDesc[2]		
			-- end
			tMailReports[nId].sDesc = data.desc
		end

		return tMailReports[nId]
	end
	print("cannot find \"" .. nId .. "\" in mail_report db")
	return nil
end

-- 获取系统邮件
local tMailSystems = {}
function getMailSystem( nId )
	if(tMailSystems[nId]) then
		return tMailSystems[nId]
	end
	for data in execForRows(Player.gamedb, "select * from mail_system where id = \'" .. nId .. "\'") do
		tMailSystems[nId] = data
		return tMailSystems[nId]
	end
	print("cannot find \"" .. nId .. "\" in mail_system db")
	return nil
end

-- 获取系统邮件
local tMailActivity = {}
function getMailActivity( nId )
	if(tMailActivity[nId]) then
		return tMailActivity[nId]
	end
	for data in execForRows(Player.gamedb, "select * from mail_activity where id = \'" .. nId .. "\'") do
		tMailActivity[nId] = data
		return tMailActivity[nId]
	end
	print("cannot find \"" .. nId .. "\" in mail_activity db")
	return nil
end

--获取表格数据
function getMailDataById( nId )
	if nId >= 1 and nId < 1001 then --报告表
		return getMailReport(nId)
	elseif nId >= 1001 and nId < 2001 then --系统表
		return getMailSystem(nId)
	elseif nId >= 2001 then --公告表
		return getMailActivity(nId)
	end
	return nil
end
---------------------------------邮件相关---------------------------------------------

---------------------------------帮助相关---------------------------------------------
-- 获取帮助数据表
local tHelpData = nil
function getHelpData()
	if tHelpData and table.nums(tHelpData) > 0 then
		return tHelpData
	end
	
	local tTemp = execForTable(Player.gamedb, "select * from tips_help")
	if not tTemp or #tTemp <= 0 then
		print("读取tips_help表失败")
		return nil
	end

	tHelpData = {}

	for i, v in pairs(tTemp) do		
		if v then
			local tTempData = v
			local tInterfaceId
			if tTempData.interfaceid then
				tInterfaceId = luaSplit(tTempData.interfaceid, ":")
				tTempData.tInterfaceId = tInterfaceId
			end
			table.insert(tHelpData, tTempData)			
		end		
	end
	return tHelpData
end

-- 获取所有需要帮助按钮的窗口类型
local tHelpInterfaceId = {}
function getHelpInterfaceIdTable()
	if table.nums(tHelpInterfaceId) > 0 then
		return tHelpInterfaceId
	end
	local allHelpData = getHelpData()
	for id, help in pairs(allHelpData) do
		if help.tInterfaceId then
			table.insert(tHelpInterfaceId, tonumber(help.tInterfaceId[1]))
		end
	end
	return tHelpInterfaceId
end
-- 获取帮助系统名称
local tSystemTitle = {}
function getHelpSystemTable()
	if table.nums(tSystemTitle) > 0 then
		return tSystemTitle
	end
	local allHelpData = getHelpData()
	local tTitle = nil
	for id, help in pairs(allHelpData) do
		if help.name ~= tTitle then
			table.insert(tSystemTitle, help.name)
			tTitle = help.name
		end
	end
	return tSystemTitle
end
-- 获取帮助系统二级标签
local tHelpSecTable = {}
function getHelpSecData(sysId)
	if(tHelpSecTable[sysId]) then
		return tHelpSecTable[sysId]
	end
	local tTemp = execForTable(Player.gamedb, "select * from tips_help where system = \'" .. sysId .. "\';")
	tHelpSecTable[sysId] = tTemp
	return tHelpSecTable[sysId]
end
-- 通过id获取每一条的数据
local tPerHelpData = {}
function getHelpDataById(nId)
	if(tPerHelpData[nId]) then
		return tPerHelpData[nId]
	end
	local allHelpData = getHelpData()
	for id, help in pairs(allHelpData) do
		if help.id == nId then
			tPerHelpData[help.id] = help
			return tPerHelpData[help.id]
		end
	end
end
-- 通过窗口类型和第二个参数类型(如果有的话)获取帮助id
function getHelpIdByDlgType(dlgType, secType)
	local allHelpData = getHelpData()
	for id, help in pairs(allHelpData) do
		if help.tInterfaceId then
			if dlgType == tonumber(help.tInterfaceId[1]) then
				if secType then
					if secType == tonumber(help.tInterfaceId[2]) then
						return help.id
					end
				else
					return help.id
				end
			end
		end
	end
end


---------------------------------帮助相关---------------------------------------------
---------------------------------充值相关---------------------------------------------
-- 获取帮助系统二级标签
local tRechargeTable = nil
function getRechargeData()
	if tRechargeTable then
		return tRechargeTable
	end
	local tTemp = execForTable(Player.gamedb, "select * from avatar_recharge")
	if not tTemp or #tTemp <= 0 then
		print("读取avatar_recharge表失败")
		return nil
	end
	tRechargeTable = {}
	for k, v in pairs(tTemp) do
		table.insert(tRechargeTable, v)
	end
	table.sort( tRechargeTable, function(a, b)
		-- body
		return a.sort < b.sort
	end )
	return tRechargeTable
end
--获取充值界面显示的数据
function getRechargeDlgData(  )
	-- body
	local tDataList = {}
	if not tRechargeTable then
		getRechargeData()
	end
	for k, v in pairs(tRechargeTable) do
		local nISShow = tonumber(v.show or 0)
		if nISShow == 1 then
			table.insert(tDataList, v)
		end
	end
	return tDataList
end

--获取特价商场界面的充值数据
function getSpecialSaleDlgData()
	-- body
	local tDataList = {}
	if not tRechargeTable then
		getRechargeData()
	end
	for k, v in pairs(tRechargeTable) do
		local nType = v.type
		if nType == 3 then
			table.insert(tDataList, v)
		end
	end
	return tDataList
end

-- 获取充值档次id(ios支付时需要用)
local tRechargeIdListForIos = nil
function getRechargeIdListForIos()
	if tRechargeIdListForIos and table.nums(tRechargeIdListForIos) > 0 then
		return tRechargeIdListForIos
	end
	tRechargeIdListForIos = {}
	for k,v in pairs(getRechargeData()) do
		local sRechId = getRechProductId(v) -- 获取充值档次id
		if (string.len(sRechId or "") > 0) then
			table.insert(tRechargeIdListForIos, sRechId)
		end
	end
	return tRechargeIdListForIos
end


--获取指定相关充值
function getRechargeDataByKey( _key )
	local tDataList = {}
	if not tRechargeTable then
		getRechargeData()
	end
	for i=1,#tRechargeTable do
		if tRechargeTable[i].pid == _key then
			return tRechargeTable[i]
		end
	end
	return nil
end

---------------------------------充值相关---------------------------------------------

---------------------------------排行榜相关---------------------------------------------
--排行榜配置信息
local tRankData = {}
function getRankData( nId )
	if not nId then
		return
	end
	if tRankData[nId] then
		return tRankData[nId]
	end
	for data in execForRows(Player.gamedb, "select * from rank_rank where id = \'" .. nId .. "\'") do
		tRankData[nId] = data
		return tRankData[nId]
	end
	return nil
end
--获取排行显示的字段类型的
local tRankTypeData = {}
function getRankTypeData( idx )
	-- body
	if not idx then
		return
	end
	if tRankTypeData[idx] then
		return tRankTypeData[idx]
	end
	for data in execForRows(Player.gamedb, "select * from rank_base where key = \'" .. idx .. "\'") do
		tRankTypeData[idx] = data
		return tRankTypeData[idx]
	end
	return nil
end

--计算标题排版配置信息
local tRankPosGroup = {}
local tRankTitleGroup = {}
function getRankSetTypePos(nId)
	-- body
	if not nId then
		return
	end
	if tRankPosGroup[nId] and tRankTitleGroup[nId] then
		return tRankPosGroup[nId], tRankTitleGroup[nId]
	end

	local rankdata = getRankData( nId )
	local ttypes = luaSplit(rankdata.sort, ";")
	--dump(ttypes, "ttypes=",100)
	local ntotal = 0
	if ttypes and #ttypes > 0 then
		local ttmp = {}
		local ttmp2 = {}
		for k, v in pairs(ttypes) do
			local ttypedata = getRankTypeData(v)
			ntotal = ntotal + ttypedata.num
			table.insert(ttmp, ttypedata.title) 
			table.insert(ttmp2, ttypedata.num)
		end
		tRankTitleGroup[nId] = ttmp
		local tpos = {}
		local curpos = 0
		local ntmp = 0
		for k, v in pairs(ttmp2) do 
			table.insert(tpos, (curpos + tonumber(v)/2)/ntotal) 			
			curpos = curpos + v			
		end
		tRankPosGroup[nId] = tpos
		return tRankPosGroup[nId], tRankTitleGroup[nId]
	end 
	return nil
end

--获取排行榜相关参数
local tRankParam = {}
function getRankParam(_key)
	-- body
	if not _key then
		return
	end
	if (tRankParam[_key]) then
		return tRankParam[_key]
	end
	for data in execForRows(Player.gamedb, "select * from rank_init where key = \'" .. _key .. "\'") do
		tRankParam[_key] = data.value
		return data.value 
	end
end

---------------------------------排行榜相关---------------------------------------------

---------------------------------新手相关-----------------------------------------------
--新手引导表
--步骤id
local tGuideData = nil
local tGuideDataByTask = nil
function getGuideData( nId )
	if not nId then
		return
	end
	if not tGuideData then
		getAllGuideData( )
	end
	return tGuideData[nId]
end

--新手引导表
--任务id
function getGuideDataByTask( nTaskId )
	if not nTaskId then
		return
	end
	if not tGuideDataByTask then
		getAllGuideData( )
	end
	return tGuideDataByTask[nTaskId]
end

function getAllGuideData( )
	if tGuideData then
		return tGuideData
	end
	tGuideData = {}
	tGuideDataByTask = {}
	for data in execForRows(Player.gamedb, "select * from guide_step") do
		if data.step then
			tGuideData[data.step] = data
			if data.missionid then
				if not tGuideDataByTask[data.missionid] then
					tGuideDataByTask[data.missionid] = data
				end
			end
		end
	end
	return tGuideData
end

--获取新手对话框npc数据
local tGuideChatNpcData = {}
function getGuideChatNpcData( nId )
	if not nId then
		return
	end
	if tGuideChatNpcData[nId] then
		return tGuideChatNpcData[nId]
	end
	for data in execForRows(Player.gamedb, "select * from guide_chatnpc where id = \'" .. nId .. "\'") do
		tGuideChatNpcData[nId] = data
		if nId == 6 then
			--主公名字
			local tData = luaSplit(data.name, ";")
			local tName = {}
			tName[e_type_country.shuguo] = tData[1]
			tName[e_type_country.wuguo] = tData[2]
			tName[e_type_country.weiguo] = tData[3]
			tGuideChatNpcData[nId].tName = tName
			--主公图片
			local tData = luaSplit(data.icon, ";")
			local tIcon = {}
			tIcon[e_type_country.shuguo] = "ui/bg_guide/" .. tData[1] .. ".png"
			tIcon[e_type_country.wuguo] = "ui/bg_guide/" .. tData[2] .. ".png"
			tIcon[e_type_country.weiguo] = "ui/bg_guide/" .. tData[3] .. ".png"
			tGuideChatNpcData[nId].tIcon = tIcon
		else
			tGuideChatNpcData[nId].sIcon = "ui/bg_guide/" .. data.icon .. ".png"
		end

		return tGuideChatNpcData[nId]
	end
	print("cannot find \"" .. nId .. "\" in guide_chatnpc db")
	return nil
end

local tBuildGuideData = nil
--获取所有的建筑引导数据
function getAllBuildGuideSteps()
	-- body
	if tBuildGuideData then
		return tBuildGuideData
	end
	tBuildGuideData = {}
	for data in execForRows(Player.gamedb, "select * from guide_dialog") do
		if data.id then
			tBuildGuideData[data.id] = data
		end
	end
	return tBuildGuideData
end

--获取建筑引导对话框
function getBuildGuideDlg( nId )
	if not nId then return end
	if not tBuildGuideData then
		getAllBuildGuideSteps()
	end
	return tBuildGuideData[nId]
end

--通过dialog id获取改面板显示的第一个引导
function getBuildGuideFirstStep(nInterfaceId)
	-- body
	if not nInterfaceId then return end
	if not tBuildGuideData then
		getAllBuildGuideSteps()
	end
	for id, data in pairs(tBuildGuideData) do
		if data.dialogid == nInterfaceId then
			return tBuildGuideData[id]
		end
	end
end

-- 获取教你玩菜单数据表
local tHelpMenuData = nil
function getAllHelpMenuData()
	if tHelpMenuData then
		return tHelpMenuData
	end
	
	local tTemp = execForTable(Player.gamedb, "select * from guide_helpmenu")
	if not tTemp or #tTemp <= 0 then
		print("读取guide_helpmenu表失败")
		return nil
	end

	tHelpMenuData = {}

	for i, v in pairs(tTemp) do		
		local tTempData = v
		if tTempData and tTempData.menu1id then
			if not tHelpMenuData[tTempData.menu1id] then
				tHelpMenuData[tTempData.menu1id] = {}
			end
			if tTempData.menu2id then
				tHelpMenuData[tTempData.menu1id][tTempData.menu2id] = tTempData
			else
				tHelpMenuData[tTempData.menu1id][1] = tTempData
			end
		end
	end
	return tHelpMenuData
end

--获取单个教你玩菜单数据
--_menu1, _menu2: 一级菜单id和二级菜单id
function getAHelpMenuData(_menu1, _menu2)
	-- body
	if not tHelpMenuData then
		getAllHelpMenuData()
	end
	if tHelpMenuData[_menu1] and tHelpMenuData[_menu1][_menu2] then
		return tHelpMenuData[_menu1][_menu2]
	end
end

--教你玩所有步骤数据
local tGuildHelpSteps = nil
function getAllTeachPlaySteps()
	if tGuildHelpSteps then
		return tGuildHelpSteps
	end
	tGuildHelpSteps = {}
	for data in execForRows(Player.gamedb, "select * from guide_helpstep") do
		if data.step then
			tGuildHelpSteps[data.step] = data
		end
	end
	return tGuildHelpSteps
end

--获取教你玩步骤
--_stepId:步骤id
function getTeachPlayStep(_stepId)
	if not _stepId then
		return
	end
	if not tGuildHelpSteps then
		getAllTeachPlaySteps( )
	end
	return tGuildHelpSteps[_stepId]
end


---------------------------------新手相关-----------------------------------------------

---------------------------------提升战力相关-------------------------------------------
local tCombatUpData = nil
function getAllCombatUpData(  )
	if tCombatUpData then
		return tCombatUpData
	end
	tCombatUpData = {}
	for data in execForRows(Player.gamedb, "select * from combatup_base order by id") do
		data.sIcon = "#".. data.icon ..".png"
		tCombatUpData[data.id] = data
	end
	return tCombatUpData
end

local tCombatUpList = nil
function getAllCombatUpList(  )
	if tCombatUpList then
		return tCombatUpList
	end
	if not tCombatUpData then
		getAllCombatUpData()
	end
	tCombatUpList = {}
	for k,v in pairs(tCombatUpData) do
		table.insert(tCombatUpList, v)
	end
	--根据配表排序
	table.sort( tCombatUpList, function ( a, b )
		return a.id < b.id
	end )
	return tCombatUpList
end

--新手引导表
function getCombatUpData( nId )
	if not nId then
		return
	end
	if not tCombatUpData then
		getAllCombatUpData()
	end
	return tCombatUpData[nId]
end

---------------------------------提升战力相关-------------------------------------------


---------------------------------神兵相关--------------------------------

--获取神兵基础信息
local tAllWeaponBaseData = {}
local tAllWeapons = {}
function getAllWeaponDatas()
	-- body
	local t = {}
	if table.nums(tAllWeaponBaseData) > 0 then
		for k, v in pairs(tAllWeaponBaseData) do
			t[k] = v
		end
	else
		local tTemp = execForTable(Player.gamedb, "select * from artifact_base")
		for k, v in pairs(tTemp) do
			local weapon = WeaponBData.new()
			weapon:initDatasByDB(v)
			t[weapon.nId] = weapon
			tAllWeaponBaseData[weapon.nId] = weapon

			table.insert(tAllWeapons, weapon)
		end
	end
	if table.nums(t) <= 0 then
		t = nil
	end

	return t
end

--获取所有神兵初始表
function getAllInitWeapons()
	-- body
	return tAllWeapons
end


--获取神兵数据
function getBaseWeaponDataByID(_id)
	if not _id then
		return
	end
	local tData = getAllWeaponDatas()
	if not tData then return end
	return tData[_id]
end


--通过id获取神兵基础信息
local tWBaseData = {}
function getBaseDataById( nId )
	-- body
	if not nId then return end
	if tWBaseData[nId] then
		return tWBaseData[nId]
	end
	for _, v in pairs(tAllWeaponBaseData) do
		if v.nId == nId then
			local tcost = luaSplit(v.sBuyCosts, ":")
			local tCosts = {}
			if tcost and #tcost > 0 then
				tCosts[tcost[1]] = tonumber(tcost[2])
				v.tCosts = tCosts
			end
			tWBaseData[nId] = v
			return tWBaseData[nId]
		end
	end

end

--获取神兵等级信息
local tWeaponLvData = nil
function getWeaponLvData(nId, nLv)
	-- body
	if not nId or not nLv then return end
	if tWeaponLvData then
		if tWeaponLvData[nId] and tWeaponLvData[nId][nLv] then
			return tWeaponLvData[nId][nLv]
		end
	end
	tWeaponLvData = {}

	if not tWeaponLvData[nId] then
		tWeaponLvData[nId] = {}
		for data in execForRows(Player.gamedb, "select * from artifact_level where id = \'" .. nId .. "\' and level = \'" .. nLv .. "\'") do
			local tTempData = data
			local tAtb = luaSplit(tTempData.atb, ":")
			local tAttribute = {}
			if tAtb and #tAtb > 0 then
				tAttribute[tAtb[1]] = tonumber(tAtb[2])
				tTempData.tAttribute = tAttribute
			end
			local tcost = luaSplit(tTempData.costs, ":")
			local tCosts = {}
			if tcost and #tcost > 0 then
				tCosts[tcost[1]] = tonumber(tcost[2])
				tTempData.tCosts = tCosts
			end

			tWeaponLvData[nId][nLv] = tTempData
			return tWeaponLvData[nId][nLv]
		end
	end
	return nil
end

--获取神兵进阶信息
local tWeaponAdData = nil
function getWeaponAdData(nId, nAdLv)
	-- body
	if not nId or not nAdLv then return end
	if tWeaponAdData then
		if tWeaponAdData[nId] and tWeaponAdData[nId][nAdLv] then
			return tWeaponAdData[nId][nAdLv]
		end
	end
	tWeaponAdData = {}

	if not tWeaponAdData[nId] then
		tWeaponAdData[nId] = {}
		for data in execForRows(Player.gamedb, "select * from artifact_advance where id = \'" .. nId .. "\' and steps = \'" .. nAdLv .. "\'") do
			local tTempData = data
			local tAtb = luaSplit(tTempData.atb, ":")
			local tAttribute = {}
			if tAtb and #tAtb > 0 then
				tAttribute[tAtb[1]] = tonumber(tAtb[2])
				tTempData.tAttribute = tAttribute
			end
			if tTempData.costs then
				local tmpcost = luaSplit(tTempData.costs, ";")
				local tCosts = {}
				if tmpcost and #tmpcost > 0 then
					for k, v in pairs(tmpcost) do
						local tcost = luaSplit(v, ":")
						tCosts[tcost[1]] = tonumber(tcost[2])
					end
				end
				tTempData.tCosts = tCosts
			end

			tWeaponAdData[nId][nAdLv] = tTempData
			return tWeaponAdData[nId][nAdLv]
		end
	end
	return nil
end

--获取神兵初始化信息
local tWeaponInitData = nil
function getWeaponInitData()
	-- body
	if tWeaponInitData then
		return tWeaponInitData
	end
	tWeaponInitData = {}
	local tTemp = execForTable(Player.gamedb, "select * from artifact_init")
	if not tTemp or #tTemp <= 0 then
		print("读取artifact_base表失败")
		return nil
	end
	for _, v in pairs(tTemp) do
		tWeaponInitData[v.key] = v.value
	end
	local tmpcost = luaSplit(tWeaponInitData.makeCosts, ";")
	local tCosts = {}
	if tmpcost and #tmpcost > 0 then
		for k, v in pairs(tmpcost) do
			local tcost = luaSplit(v, ":")
			tCosts[tcost[1]] = tonumber(tcost[2])
		end
	end
	tWeaponInitData.makeCosts = tCosts
	return tWeaponInitData
end

--获取神兵初始化信息
function getWeaponInitDataByKey( sKey )
	if not tWeaponInitData then
		getWeaponInitData()
	end
	if sKey == "openLevel" then
		return tonumber(tWeaponInitData[sKey])
	end
	return tWeaponInitData[sKey]
end

---------------------------------神兵相关--------------------------------
---------------------------------商店相关--------------------------------
local tShopTreasure = {}
function getShopTreasure( nIndex )
	if tShopTreasure[nIndex] then
		return tShopTreasure[nIndex]
	end
	
	for data in execForRows(Player.gamedb, "select * from shop_treasure where \"index\" = \'" .. nIndex .. "\'") do
		local tCost = luaSplit(data.cost, ":")
		if #tCost >= 2 then
			data.nCostId = tonumber(tCost[1])
			data.nCost = tonumber(tCost[2])
		end
		tShopTreasure[nIndex] = data
		return tShopTreasure[nIndex]
	end
	print("cannot find \"" .. nIndex .. "\" in shop_treasure db")
	return nil
end

local tShopInit = {} --工坊参数表
function getShopInitParam( sKey )
	if(tShopInit[sKey]) then
		return tShopInit[sKey]
	end
	for data in execForRows(Player.gamedb, "select * from shop_init where key = \'" .. sKey .. "\'") do
		if sKey == "treBuyCost" then
			local tData = {}
			local tCost = luaSplit(data.value, ":")
			if #tCost >= 2 then
				tData.nCostId = tonumber(tCost[1])
				tData.nCost = tonumber(tCost[2])
			end
			tShopInit[sKey] = tData
		else
			tShopInit[sKey] = data.value
		end
		if sKey == "coinExchange" or sKey == "woodExchange" or sKey == "foodExchange" then
			local tmpcost = luaSplit(data.value, ";")
			local tCosts = {}
			if tmpcost and #tmpcost > 0 then
				for k, v in pairs(tmpcost) do
					local tcost = luaSplit(v, ":")
					tCosts[tcost[1]] = tonumber(tcost[2])
				end
			end
			tShopInit[sKey] = tCosts
		end
		return tShopInit[sKey] 
	end
	print("cannot find \"" .. sKey .. "\" in shop_init db")
	return nil
end

--获取全部商店数据
local tShopBaseDatas = nil
function getAllShopBaseData()
	if tShopBaseDatas then
		return tShopBaseDatas
	end
	tShopBaseDatas = {}
	for data in execForRows(Player.gamedb, "select * from shop_base") do
		tShopBaseDatas[data.exchange] = data
	end
	return tShopBaseDatas
end

--获取材料商店数据
function getShopBaseData( nExchange )
	if not tShopBaseDatas then
		getAllShopBaseData()
	end
	if tShopBaseDatas then
		return tShopBaseDatas[nExchange]
	end
	return nil
end

--获取商店数据根据商店类型
function getOpenShopBaseDataByKind( nKind )
	if not tShopBaseDatas then
		getAllShopBaseData()
	end
	local tRes = {}
	if tShopBaseDatas then
		--皇宫等级
		local nPalaceLv = 0
		local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
		if pPalacedata.nLv then
			nPalaceLv = pPalacedata.nLv
		end
		for k,v in pairs(tShopBaseDatas) do
			if v.kind == nKind and nPalaceLv >= v.palace then
				table.insert(tRes, v)
			end
		end
		--根据配表排序
		table.sort( tRes, function ( a, b )
			return a.sequence < b.sequence
		end )
	end
	return tRes
end

--获取材料商店数据
local tShopMaterialData = nil
function getAllShopMaterialData(  )
	if tShopMaterialData then
		return tShopMaterialData
	end
	tShopMaterialData = {}
	for data in execForRows(Player.gamedb, "select * from shop_material") do
		tShopMaterialData[data.exchange] = data
	end
	return tShopMaterialData
end

function getShopMaterialLimit(  )
	-- body
	local tTable = getAllShopMaterialData()
	local nLimit = 100
	for k, v in pairs(tTable) do 
		if v.palace < nLimit then
			nLimit = v.palace
		end
	end
	return nLimit
end

--获取材料商店数据
function getShopMaterialData( nExchange )
	if not tShopMaterialData then
		getAllShopMaterialData()
	end
	if tShopMaterialData then
		return tShopMaterialData[nExchange]
	end
	return nil
end

--获取材料商店数据列表
function getOpenShopMaterialData(  )
	if not tShopMaterialData then
		getAllShopMaterialData()
	end
	local tRes = {}
	if tShopMaterialData then
		--皇宫等级
		local nPalaceLv = 0
		local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
		if pPalacedata.nLv then
			nPalaceLv = pPalacedata.nLv
		end
		for k,v in pairs(tShopMaterialData) do
			if nPalaceLv >= v.palace then
				table.insert(tRes, v)
			end
		end
		--根据配表排序
		table.sort( tRes, function ( a, b )
			return a.exchange < b.exchange
		end )
	end
	return tRes
end

--根据nGoodsId获取商品数据 znftodo优化
function getShopDataById( nGoodsId )
	local nPalaceLv = 0
	local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
	if pPalacedata.nLv then
		nPalaceLv = pPalacedata.nLv
	end

	if not tShopBaseDatas then
		getAllShopBaseData()
	end
	if tShopBaseDatas then
		for k,v in pairs(tShopBaseDatas) do
			--if v.id == nGoodsId and nPalaceLv >= v.palace then
			if v.id == nGoodsId then
				return v
			end
		end
	end
	if not tShopMaterialData then
		getAllShopMaterialData()
	end
	if tShopMaterialData then
		for k,v in pairs(tShopMaterialData) do
			--if v.id == nGoodsId and nPalaceLv >= v.palace then
			if v.id == nGoodsId then
				return v
			end
		end
	end
	return nil
end

--获取兵力购买需要的vip开放等级
local tVipPrivilege = nil
function getArmyVipLvLimit( nitemID )
	-- body	
	if not tVipPrivilege then
		local ttmp = luaSplit(getGlobleParam("vipPrivilege"), ";") 	
		--dump(ttmp, "ttmp", 100)
		tVipPrivilege = {}
		if ttmp and #ttmp > 0 then
			for k, v in pairs(ttmp) do
				local tt = luaSplit(v, ",")
				tVipPrivilege[tonumber(tt[1])] = tonumber(tt[2]) 
			end
		end		
		--dump(tVipPrivilege, "tVipPrivilege", 100)
	end
	return tVipPrivilege[nitemID]
end
---------------------------------商店相关--------------------------------
---------------------------------武王讨伐相关----------------------------
--获取武王init数据
local tAwakeInitData = {}
function getAwakeInitData( _key )
	-- body
	if(tAwakeInitData[_key]) then
		return tAwakeInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from awake_init where key = \'" .. _key .. "\'") do
		--排名奖励
		if _key == "rankAward" then
			--1-1,11:5000;100015:1|2-3,11:4000;100014:1|4-10,11:4000;100014:1|11-20,11:3000;100013:1
			-- {
			-- 	1 = {
			-- 	    1 = {
			-- 	        1 = "1"
			-- 	        2 = "1"
			-- 	    }
			-- 	    2 = {
			-- 	        1 = {
			-- 	            1 = "11"
			-- 	            2 = "5000"
			-- 	        }
			-- 	        2 = {
			-- 	            1 = "100015"
			-- 	            2 = "1"
			-- 	        }
			-- 	    }
			-- 	}
			-- }
			local tData = {}
			
			local tTempData = luaSplitMuilt(data.value,"|", ",", "-", ";", ":")
			for i=1,#tTempData do
				local nRank1 = tonumber(tTempData[i][1][1])
				local nRank2 = tonumber(tTempData[i][1][2])
				local tRes = {}
				tRes.nRank1 = nRank1
				tRes.nRank2 = nRank2
				tRes.tGoodsList = {}
				local tGoodsList = tTempData[i][2]
				for j=1,#tGoodsList do
					local nGoodsId = tonumber(tGoodsList[j][1])
					local nCt = tonumber(tGoodsList[j][2])
					table.insert(tRes.tGoodsList, {nGoodsId = nGoodsId, nCt = nCt})
				end
				table.insert(tData, tRes)
			end
			tAwakeInitData[_key] = tData		
		else
			tAwakeInitData[_key] = tonumber(data.value) or data.value
		end
		return tAwakeInitData[_key]
	end
	print("cannot find \"" .. _key .. "\" in awake_init db")
	return nil
end

-- 获取世界地图魔兵数据
local tAwakeArmyData = {}
function getAwakeArmyData( _key, bIsNoLog)
	if(tAwakeArmyData[_key]) then
		return tAwakeArmyData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from awake_army where id = \'" .. _key .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		tAwakeArmyData[_key] = data
		return data
	end
	if not bIsNoLog then
		print("cannot find \"" .. _key .. "\" in awake_army db")
	end
	return nil
end

-- 获取世界地图Boss数据
local tAwakeBossData = {}
--nLv：等级
--nDiff: 难度
function getAwakeBossData( nLv, nDiff )
	nDiff = nDiff or 1
	if(tAwakeBossData[nLv]) then
		if tAwakeBossData[nLv][nDiff] then
			return tAwakeBossData[nLv][nDiff]
		end
	end
	for data in execForRows(Player.gamedb, "select * from awake_boss where level = \'" .. nLv .. "\' and difficulty = \'" .. nDiff .. "\'") do
		if not tAwakeBossData[nLv] then
			tAwakeBossData[nLv] = {}
		end
		data.sIcon = "#"..data.icon..".png"
		data.nTroops = 0
		if data.npc then
			data.nTroops = getNpcGroupTotalAttr(data.npc, "troops")
		end
		tAwakeBossData[nLv][nDiff] = data
		return data
	end
	print(string.format("cannot find nLv = %s and nDiff = %s in awake_boss db", nLv, nDiff))
	return nil
end

-- 根据id获取乱军数据或魔军数据，因为是同一个区间,(只用于邮件或分享，小心使用~~~)
function getArmyDataInTables( _key )
	local tData = getWorldEnemyData(_key, true) or getWorldGhostdomData(_key,true) --or getAwakeArmyData(_key, true) 
	if not tData then
		print("cannot find \"" .. _key .. "\" in getArmyDataInTables")
	end
	return tData
end
---------------------------------武王讨伐相关----------------------------

---------------------------------推送相关--------------------------------
local tPushTipsParam = {} -- 推送提示语全局表的临时数据
-- id：推送序号
function getPushTipsParam( _id )
	-- body
	if not _id then return end
	if(tPushTipsParam[_id]) then
		return tPushTipsParam[_id]
	end
	for data in execForRows(Player.gamedb, "select * from tips_push where id = \'" .. _id .. "\'") do
		tPushTipsParam[_id] = data
		return data
	end
	return nil
end
---------------------------------推送相关--------------------------------

--------------------------------免费宝箱相关-----------------------------
--获取免费宝箱相关参数
local tDailyGiftParam = {}
function getDailyGiftParam(_key)
	-- body
	if not _key then
		return
	end
	if (tDailyGiftParam[_key]) then
		return tDailyGiftParam[_key]
	end
	for data in execForRows(Player.gamedb, "select * from play_init where key = \'" .. _key .. "\'") do
		tDailyGiftParam[_key] = data.value
		return data.value 
	end
end

--触发礼包
local tTriGiftData = {}
function getTriGiftData( _key )
	if not _key then
		return
	end
	if (tTriGiftData[_key]) then
		return tTriGiftData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from play_tri_gift where id = \'" .. _key .. "\'") do
		tTriGiftData[_key] = data
		return data
	end
end


--新版触发礼包
local tPlayTpackData = {}
--_packId, _giftId: 礼包id和礼品id
function getTpackData(_packId, _giftId)
	-- body
	if not _packId or not _giftId then
		return
	end
	if(tPlayTpackData[_packId]) then
		if tPlayTpackData[_packId][_giftId] then
			return tPlayTpackData[_packId][_giftId]
		end
	end
	
	for data in execForRows(Player.gamedb, "select * from play_tpack where packid = \'" .. _packId .. "\' and giftid = \'" .. _giftId .. "\'") do
		if not tPlayTpackData[_packId] then
			tPlayTpackData[_packId] = {}
		end
		tPlayTpackData[_packId][_giftId] = data
		return data
	end
	return nil
end

---------------------------------免费宝箱相关--------------------------
---------------------------------活动标签相关--------------------------
--获取活动标签相关参数
local tActivityBtn = {}
function getActivityBtnData(_nId)
	-- body
	if not _nId then
		return
	end
	if (tActivityBtn[_nId]) then
		return tActivityBtn[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from display_act where id = \'" .. _nId .. "\'") do
		tActivityBtn[_nId] = data.activity
		return data.activity 
	end
end

---------------------------------活动标签相关--------------------------

---------------------------------红包系统--------------------------
--获取活动标签相关参数
local tRedPocket = {}
function getRedPocketData(_nId)
	-- body
	if not _nId then
		return nil
	end
	if (tRedPocket[_nId]) then
		return tRedPocket[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from redpacket_redpackets where id = \'" .. _nId .. "\'") do
		tRedPocket[_nId] = data
		return tRedPocket[_nId]
	end
	return nil
end
local tRedPocketConts = {}
function GetRedPocketContById(_nId )
	-- body
	if not _nId then
		return nil
	end
	if (tRedPocketConts[_nId]) then
		return tRedPocketConts[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from redpacket_init where id = \'" .. _nId .. "\'") do
		tRedPocketConts[_nId] = data.content
		return tRedPocketConts[_nId]
	end
	return nil
end


---------------------------------红包系统--------------------------

---------------------------------武将游历--------------------------
--获取武将游历相关参数
local tHeroTravelData = {}
function getHeroTravelData(_nId)
	-- body
	if not _nId then
		return
	end
	if (tHeroTravelData[_nId]) then
		return tHeroTravelData[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from play_travel where id = \'" .. _nId .. "\'") do
		tHeroTravelData[_nId] = data
		--产出物品
		local tDropStr = luaSplit(data.get,":")
		if tDropStr then
			tHeroTravelData[_nId].tDropItem={k=tDropStr[1], v=tDropStr[2]}
		end
		--消耗物品
		local tCostStr =luaSplit(data.cost,":")
		if tCostStr then
			tHeroTravelData[_nId].tCostItem={k=tCostStr[1], v=tCostStr[2]}
		end
		return tHeroTravelData[_nId]
	end
end

---------------------------------武将游历--------------------------


---------------------------------竞技场--------------------------
--获取竞技场奖励数据
local tArenaAwards = nil
function getArenaAwards( )
	-- body
	if tArenaAwards then
		return tArenaAwards
	end
	tArenaAwards = {}
	for data in execForRows(Player.gamedb, "select * from arena_award") do	
		local tAwards = {}
		local sAward = data.items or ""
		local tTmp = luaSplitMuilt(sAward, ";", ":")
		--dump(tTmp, "tTmp", 100)
		for k, v in pairs(tTmp) do
			if v[1] or v[2] then
				local tt = {}
				tt.k = tonumber(v[1])
				tt.v = tonumber(v[2])
				table.insert(tAwards, tt)
			end
		end	
		-- local tAwards = {}
		-- local tt = {}
		-- tt.k = tonumber(tTmp[1])
		-- tt.v = tonumber(tTmp[2])
		-- table.insert(tAwards, tt)
		tArenaAwards[data.id] = data
		tArenaAwards[data.id].tAwards = tAwards
	end
	return tArenaAwards	
end
--根据排名获取奖励
function getArenaAwardByRank( _nRank )
	-- body
	if not _nRank then
		return nil
	end
	if not tArenaAwards or #tArenaAwards <= 0 then
		getArenaAwards()
	end
	for k, v in pairs(tArenaAwards) do
		if _nRank >= v.startrk and _nRank <= v.endrk then
			return v.tAwards
		end
	end
end

local tArenaLuckys = nil
function getArenaLuckys( )
	-- body
	if tArenaLuckys then
		return tArenaLuckys
	end
	tArenaLuckys = {}
	for data in execForRows(Player.gamedb, "select * from arena_lucky") do	
		local tAwards = {}
		local sAward = data.items or ""
		local tTmp = luaSplitMuilt(sAward, ";", ":")
		--dump(tTmp, "tTmp", 100)
		for k, v in pairs(tTmp) do
			if v[1] or v[2] then
				local tt = {}
				tt.k = tonumber(v[1])
				tt.v = tonumber(v[2])
				table.insert(tAwards, tt)
			end
		end	
		-- local tAwards = {}
		-- local tt = {}
		-- tt.k = tonumber(tTmp[1])
		-- tt.v = tonumber(tTmp[2])
		-- table.insert(tAwards, tt)
		tArenaLuckys[data.id] = data
		tArenaLuckys[data.id].tAwards = tAwards
	end
	return tArenaLuckys	
end
--根据配置ID获取幸运奖励
function getArenaLuckyPrizeById( _nId )
	-- body
	if not _nId then
		return nil
	end
	if not tArenaLuckys or #tArenaLuckys <= 0 then
		getArenaLuckys()
	end
	if tArenaLuckys[_nId] then
		return tArenaLuckys[_nId].tAwards
	else
		return nil
	end
end
--根据排名获取幸运奖励
function getArenaLuckyPrizeByRank( _nRank )
	-- body
	if not _nRank then
		return nil
	end
	if not tArenaLuckys or #tArenaLuckys <= 0 then
		getArenaLuckys()
	end
	for k, v in pairs(tArenaLuckys) do
		if _nRank >= v.top and _nRank <= v.low then
			return v.tAwards
		end
	end
end

--获取竞技场参数
local tArenaParams = {}
function getArenaParam( _key )
	-- body
	if(tArenaParams[_key]) then
		return tArenaParams[_key]
	end
	for data in execForRows(Player.gamedb, "select * from arena_init where key = \'" .. _key .. "\'") do
		tArenaParams[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in arena_init db")
	return -1
end

--获取竞技场参数
local tArenaShopItems = nil
function getArenaShopItems(  )
	-- body
	if not tArenaShopItems then
		tArenaShopItems = {}
		for data in execForRows(Player.gamedb, "select * from arena_shop") do	
			local sItem = data.items or ""
			local tTmp = luaSplit(sItem, ":")
			local nId = tonumber(tTmp[1] or 0)
			local nCt = tonumber(tTmp[2] or 0)
			local sCost = data.cost
			local tCost = luaSplit(sCost, ":")
			local tGood = getGoodsByTidFromDB(nId)
			local nIndex = tonumber(data.idx)
			if tGood then
				tGood.nCt = nCt			
				tArenaShopItems[nIndex] = data
				tArenaShopItems[nIndex].tGood = tGood
				tArenaShopItems[nIndex].nRes = tonumber(tCost[1] or 0)
				tArenaShopItems[nIndex].nCost = tonumber(tCost[2] or 0)				
			end
		end
	end
	return tArenaShopItems	
end

-- 获取商品 _nIdx 商品次数
function getArenaShopByIdx( _nIdx )
	-- body
	if not tArenaShopItems then
		getArenaShopItems()
	end	
	return tArenaShopItems[_nIdx]
end

---------------------------------竞技场--------------------------
---------------------------------攻城掠地--------------------------
--获取攻城掠地宝箱数据
local tAttkCityBxData = {}
function getAttkCityBxData()
	-- body
	
	if (tAttkCityBxData and table.nums(tAttkCityBxData) > 0) then
		return tAttkCityBxData
	end

	for data in execForRows(Player.gamedb, "select * from invade_reward") do
		if data.id then
			tAttkCityBxData[data.id] = data
		end
	end
	return tAttkCityBxData
end
--获取攻城掠地配置数据
local tAttkCityInitData = {} 
function getAttkCityInitData(_sKey)
	-- body
	if not _sKey then
		return nil
	end
	if (tAttkCityInitData[_sKey]) then
		return tAttkCityInitData[_sKey]
	end
	for data in execForRows(Player.gamedb, "select * from invade_init where key = \'" .. _sKey .. "\'") do
		tAttkCityInitData[_sKey] = data
		return tAttkCityInitData[_sKey]
	end
	return nil
end
--获取攻城掠地任务数据
local tAttkCityTaskData = {} 
function getAttkCityTaskData()
	-- body
	if (tAttkCityTaskData and table.nums(tAttkCityTaskData) > 0) then
		return tAttkCityTaskData
	end

	for data in execForRows(Player.gamedb, "select * from invade_target") do
		local nId = tonumber(data.id)
		if nId and nId > 100 then

			if not tAttkCityTaskData[data.day] then
				tAttkCityTaskData[data.day] = {}
			end
			table.insert(tAttkCityTaskData[data.day],data)
		end
	end
	return tAttkCityTaskData
end

function getAttkCityTaskById( _nId )
	-- body
	if not _nId then
		return
	end
	local nDay =math.floor(_nId / 100)
	if table.nums(tAttkCityTaskData) == 0 then
		getAttkCityTaskData()
	end

	local tList = tAttkCityTaskData[nDay]
	if tList then
		for k,v in pairs(tList) do
			if v.id == _nId then
				return v
			end
		end
	end

end

---------------------------------攻城掠地--------------------------


---------------------------------每日抢答--------------------------
----获取每日抢答相关参数
local tExamData = nil
function getExamConfig(_sKey)
    if not tExamData then
		tExamData = {}
		local tTemp = execForTable(Player.gamedb, "select * from answer_init;")	
		--dump(tTemp, "tTemp", 100)
		for k, v in pairs(tTemp) do
            tExamData[v.key] = v.value
		end		
	end

    return tExamData[_sKey]
end

--获取每日抢答的题目
local tExamQuestion = {}
function getQuestionConfig(_nId)
	-- body
	if not _nId then
		return
	end
    if (tExamQuestion[_nId]) then
		return tExamQuestion[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from answer_question where id = \'" .. _nId .. "\'") do
		tExamQuestion[_nId] = data		
		return tExamQuestion[_nId]
	end

    return nil
end

---------------------------------每日抢答--------------------------

---------------------------------战争大厅--------------------------

--获取每日抢答的题目
local tSysActivitys = nil
function getSystemActivitys()
	
    if (tSysActivitys) then
		return tSysActivitys
	end
	local tSysActivitys = execForTable(Player.gamedb, "select * from headquarters_base order by sequence") 
	if not tSysActivitys or #tSysActivitys <= 0 then
		print("读取avatar_preview表失败")
		return nil
	end
    
    --测试
--    tSysActivitys = {}
--    tSysActivitys[1] = {sequence = 1, dlgIndex=5500, type = 1,	name = "每日答题",	show = 1,	time = "每日;12：30:77d4fd;",	open =  "-1",	openTips = "",	                    describe = ""}
--    tSysActivitys[2] = {sequence = 2, dlgIndex=3564, type = 1,	name = "竞技场"	,	show = 1,	time = "每周三;19：30:77d4fd;",	open =  "1:55",	openTips = "主公55级解锁:d72322",	describe = ""}
--    tSysActivitys[3] = {sequence = 3, dlgIndex=5018, type = 1,	name = "冥界入侵",	show = 1,	time = "",	                    open =  "2:7",	openTips = "开州后下个周三:d72322",	describe = "简介简介简介"}
--    tSysActivitys[4] = {sequence = 4, dlgIndex=2075, type = 1,	name = "魔神来袭",	show = 1,	time = "每晚;17：30:77d4fd;",	open =  "2:7",	openTips = "开服第7天:d72322",	    describe = "挑战魔神，赢取丰厚奖励"}



    return tSysActivitys
end

---------------------------------战争大厅--------------------------

---------------------------------等级预告--------------------------
local tLevelPreviewData = nil
function getLevelPreviewData()
	if tLevelPreviewData then
		return tLevelPreviewData
	end
	tLevelPreviewData = {}
	local tTemp = execForTable(Player.gamedb, "select * from avatar_preview order by id")
	if not tTemp or #tTemp <= 0 then
		print("读取avatar_preview表失败")
		return nil
	end
	for k, v in pairs(tTemp) do
		local tOpenId = luaSplit(v.openid,";")
		local tPalaceId = luaSplit(v.palaceid,";")
		v.tOpenId = tOpenId 
		v.tPalaceId = tPalaceId 
		tLevelPreviewData[v.id] = v
	end
	
	return tLevelPreviewData
end
---------------------------------等级预告--------------------------

---------------------------------韬光养晦--------------------------
local tStrongerData = nil
function getRemainsTaskDatas(  )
	-- body
	if not tStrongerData then
		tStrongerData = {}
		local tTemp = execForTable(Player.gamedb, "select * from support_task order by id")
		if not tTemp or #tTemp <= 0 then
			print("读取avatar_preview表失败")
			return nil
		end
		for k, v in pairs(tTemp) do
			local tData = RemainsTaskVo.new()
			tData:rerfeshDataByDB(v)
			tStrongerData[v.id] = tData
		end		
	end
	return tStrongerData
end

local tStrongerParam = {}
function getStrongerParam( _sKey )
	-- body
	if not _sKey then
		return nil
	end
	if (tStrongerParam[_sKey]) then
		return tStrongerParam[_sKey]
	end
	for data in execForRows(Player.gamedb, "select * from support_init where key = \'" .. _sKey .. "\'") do
		tStrongerParam[_sKey] = data.value
		return tStrongerParam[_sKey]
	end
	return nil	
end
---------------------------------韬光养晦--------------------------


---------------------------------限时Boss--------------------------
local tBossInitData = {} -- 建筑全局表的临时数据
function getBossInitData( _key )
	if(tBossInitData[_key]) then
		return tBossInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from boss_init where key = \'" .. _key .. "\'") do
		if _key == "hurtRankAwards" or _key == "fightRankAwards" then
			local tData = {}
			local tData1 = luaSplit(data.value, "|")
			for i=1,#tData1 do
				local tData2 = luaSplit(tData1[i], ",")
				local nRank = tonumber(tData2[1])
				local tData3 = luaSplitMuilt(tData2[2], ";", ":") 
				local tGoods = {}
				for j=1,#tData3 do
					local k = tonumber(tData3[j][1])
					local v = tonumber(tData3[j][2])
					table.insert(tGoods, {k = k, v = v})
				end
				table.insert(tData, {nRank = nRank, tGoods = tGoods})
			end
			tBossInitData[_key] = tData
		else
			tBossInitData[_key] = data.value
		end
		return tBossInitData[_key] 
	end
	print("cannot find \"" .. _key .. "\" in boss_init db")
	return -1
end
---------------------------------限时Boss--------------------------
---------------------------------冥界入侵--------------------------
local tWorldGhostdomData = {}
function getWorldGhostdomData(_nId)
	if not _nId then
		return
	end
	if (tWorldGhostdomData[_nId]) then
		return tWorldGhostdomData[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from ghostdom_army where id = \'" .. _nId .. "\'") do
		data.sIcon = "#"..data.icon..".png"
		data.tempLv = data.level
		data.level = data.level2
		tWorldGhostdomData[_nId] = data
		return data 
	end
end

local tGhostBossData = {} --怪物组数据
local tGhostBossDetailData = {} --boss详细数据
-- 获取怪物id数据
function getGhostBossById(_id)
	if(tGhostBossData[_id] and tGhostBossDetailData[_id]) then
		return copyTab(tGhostBossData[_id]) , copyTab(tGhostBossDetailData[_id])
	end
	for data in execForRows(Player.gamedb, "select * from ghostdom_boss where id = \'" .. _id .. "\'") do
	
		local tNpcData=getNpcGropById(tonumber(data.enemy))
		tGhostBossData[_id] = tNpcData
		data.sIcon = "#" .. data.icon ..".png"
		tGhostBossDetailData[_id] = data
		return copyTab(tNpcData) ,copyTab(data)  
	end
	print("cannot find \"" .. _id .. "\" in ghost_boss db")
	return -1
end

--获取冥界init数据
local tGhostInitData = {}
function getGhostInitData( _key )
	-- body
	if not _key then
		return
	end
	if(tGhostInitData[_key]) then
		return tGhostInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from ghostdom_init where key = \'" .. _key .. "\'") do
		if _key == "changedAttrs" then
			
		else
			tWorldInitData[_key] = tonumber(data.value) or data.value
		end
		return tWorldInitData[_key]
	end
	print("cannot find \"" .. _key .. "\" in world_init db")
	return nil
end
local tMingjieAttrData = {}
function getMingjieAttrDataById(_nId)
	
	if not _nId then
		return
	end
	if tMingjieAttrData[_nId] then
		return tMingjieAttrData[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from ghostdom_attr where \"index\" = \'" .. _nId .. "\'") do
		data.sIcon = "#"..data.icon ..".png"
		tMingjieAttrData[_nId] = data

		return tMingjieAttrData[_nId]
	end
	print("cannot find \"" .. _nId .. "\" in ghostdom_attr db")
	return -1
end

---------------------------------冥界入侵--------------------------

---------------------------------过关斩将相关--------------------------------
--国家全局表
local tExpediteParam = {}
function getExpediteParam( _key )
	-- body
	if(tExpediteParam[_key]) then
		return tExpediteParam[_key]
	end
	tExpediteParam = {}
	for data in execForRows(Player.gamedb, "select * from expedite_init where key = \'" .. _key .. "\'") do
		if data and data.value then
			tExpediteParam[_key] = data.value
			return tExpediteParam[_key]
		end
	end
	print("cannot find \"" .. _key .. "\" in expedite_init db")
	return nil	
end

--获取过关斩将商店数据
local tExpediteShopItems = nil
function getExpediteShopItems()
	-- body
	if not tExpediteShopItems then
		tExpediteShopItems = {}
		for data in execForRows(Player.gamedb, "select * from expedite_goods") do	
			local nIndex = tonumber(data.index)
			local nId = data.id
			local nCt = data.num
			local nCost = data.battlescore
			local tGood = getGoodsByTidFromDB(nId)
			if tGood then
				tGood.nCt = nCt			
				tExpediteShopItems[nIndex] = data
				tExpediteShopItems[nIndex].tGood = tGood
				tExpediteShopItems[nIndex].nRes = e_resdata_ids.killheroexp
				tExpediteShopItems[nIndex].nCost = nCost				
				tExpediteShopItems[nIndex].nIndex = nIndex				
			end
		end
	end
	return tExpediteShopItems	
end

-- 获取商品 _nIdx 商品
function getExpediteShopItemByIdx( _nIdx )
	-- body
	if not tExpediteShopItems then
		getExpediteShopItems()
	end	
	return tExpediteShopItems[_nIdx]
end

-- 获取过关斩将通关文字
function getExpeditePassTalk(_key)
	local key = _key or 1
	for data in execForRows(Player.gamedb, "select * from expedite_chat  where id = \'" .. key .. "\'") do
		if data and data.word then
			return data.word
		end
	end
	return nil
end


---------------------------------过关斩将相关--------------------------------
---------------------------------限时Boss--------------------------

---------------------------------决战皇城--------------------------
local tEpangWarInitData = {} -- 决战皇城数据
function getEpangWarInitData( _key )
	-- body
	if(tEpangWarInitData[_key]) then
		return tEpangWarInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from epangWar_init where key = \'" .. _key .. "\'") do
		if _key == "perAward" then
			-- 1-1,20:5000|2-2,20:4200|3-3,20:3600|4-4,20:3500|5-5,20:3400|6-6,20:3300|7-7,20:3200|8-8,20:3100|9-9,20:3000|10-10,20:2900|11-11,20:2850|12-12,20:2800|13-13,20:2750|14-14,20:2700|15-15,20:2650|16-16,20:2600|17-17,20:2550|18-18,20:2500|19-19,20:2450|20-20,20:2400|21-30,20:2100|31-50,20:1800|51-100,20:1500
			local tData = {}
			local tData2 = luaSplitMuilt(data.value, "|", ",")
			for i=1,#tData2 do
				local sRank = tData2[i][1]
				local sGoods = tData2[i][2]
				if sRank and sGoods then
					local tRank2 = luaSplit(sRank, "-")
					local nRank1 = tonumber(tRank2[1])
					local nRank2 = tonumber(tRank2[2])
					local tGoods = {}
					local tGoods2 = luaSplit(sGoods, ";")
					for j=1,#tGoods2 do
						local tGoods3 = luaSplit(tGoods2[j], ":")
						if type(tGoods3) == "table" then
							local k = tonumber(tGoods3[1])
							local v = tonumber(tGoods3[2])
							if k and v then
								table.insert(tGoods, {k = k, v = v})
							end
						end
					end
					if nRank1 and nRank2 and tGoods then
						table.insert(tData, {nRank1 = nRank1, nRank2 = nRank2, tGoods = tGoods})
					end 
				end
			end
			tEpangWarInitData[_key] = tData
		elseif _key == "levelReward" then
			-- 1,75,563,100067:1;100068:1|2,180,1530,100067:1;100068:1|3,330,3135,100067:1;100068:1|4,525,5775,100067:1;100068:1|5,765,9180,100067:1;100068:1|6,1050,14175,100067:1;100068:1
			local tData = {}
			local tData2 = luaSplitMuilt(data.value, "|", ",")
			for i=1,#tData2 do
				local nStage = tonumber(tData2[i][1])
				local nScore = tonumber(tData2[i][2])
				local nCScore = tonumber(tData2[i][3])
				local sGoods = tData2[i][4]
				if nStage and nScore and nCScore and sGoods then
					local tRank2 = luaSplit(sRank, "-")
					local tGoods = {}
					local tGoods2 = luaSplit(sGoods, ";")
					for j=1,#tGoods2 do
						local tGoods3 = luaSplit(tGoods2[j], ":")
						if type(tGoods3) == "table" then
							local k = tonumber(tGoods3[1])
							local v = tonumber(tGoods3[2])
							if k and v then
								table.insert(tGoods, {k = k, v = v})
							end
						end
					end
					table.insert(tData, {nStage = nStage, nScore = nScore, nCScore = nCScore, tGoods = tGoods})
				end
			end
			tEpangWarInitData[_key] = tData
		else
			tEpangWarInitData[_key] = data.value
		end
		return tEpangWarInitData[_key] 
	end
	print("cannot find \"" .. _key .. "\" in epangWar_init db")
	return -1
end


--获取所有皇城战科技数据
local tTechDatas = nil
function getAllTechData(  )
	if not tTechDatas then
		tTechDatas = {}
		local tTemp = execForTable(Player.gamedb, "select * from epangWar_tech;")	
		for k, v in pairs(tTemp) do
			if not tTechDatas[v.id] then
				local pTechData = TechData.new()
				pTechData:initDatasByDB(v)
				tTechDatas[v.id] = pTechData
			end
		end		
	end
	return tTechDatas
end

function getTechDataById( nId )
	if not tTechDatas then
		getAllTechData()
	end
	if tTechDatas then
		return tTechDatas[nId]
	end
	return nil
end

--获取所有皇城秘库数据
local tRoyalShopDatas = nil
function getAllRoyalShopData(  )
	if not tRoyalShopDatas then
		tRoyalShopDatas = {}
		local tTemp = execForTable(Player.gamedb, "select * from epangWar_shop;")	
		for k, v in pairs(tTemp) do
			tRoyalShopDatas[v.id] = v
		end		
	end
	return tRoyalShopDatas
end

---------------------------------决战皇城--------------------------

---------------------------------纣王试炼-------------------------
local tKingZhouInitData = {} -- 决战皇城数据
function getKingZhouInitData( _key )
	-- body
	if (tKingZhouInitData[_key]) then
		return tKingZhouInitData[_key]
	end
	for data in execForRows(Player.gamedb, "select * from kingzhou_init where key = \'" .. _key .. "\'") do
		tKingZhouInitData[_key] = data.value
		return data.value 
	end
	print("cannot find \"" .. _key .. "\" in epangWar_init db")
	return -1
end

-----------------------------------------------------------------