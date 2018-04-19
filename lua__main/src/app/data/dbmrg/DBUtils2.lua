-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-29 21:14:41 星期四
-- Description: 查表操作(第二个表)
-----------------------------------------------------
---------------------------新国家系统相关-----------------------
local CountryTnoly = require("app.layer.newcountry.newcountrytnoly.CountryTnoly")



-- 获取国家科技数据表
local tCountryTnoly = nil
function getCountryTnolyData()
	if tCountryTnoly and table.nums(tCountryTnoly) > 0 then
		return tCountryTnoly
	end

	tCountryTnoly = {}
	for data in execForRows(Player.gamedb, "select * from country_science") do
		local tnoly = CountryTnoly.new()
		tnoly:initDatasByDB(data)
		tCountryTnoly[tnoly.nId] = tnoly
	end

	return tCountryTnoly
end

--根据科技id获取国家科技数据
function getCountryTnoly( _id )
	if not _id then
		return
	end
	if tCountryTnoly == nil then
		getCountryTnolyData()
	end
	return tCountryTnoly[_id]
end

--根据所属阶段获取科技表
function getCountryTnolysByStage(_stage)
	-- body
	if not _stage then
		return {}
	end
	local tTmpList = {}
	if tCountryTnoly == nil then
		getCountryTnolyData()
	end
	for k, v in pairs(tCountryTnoly) do
		if v.nStage == _stage then
			table.insert(tTmpList, v)
		end
	end
	table.sort(tTmpList, function(a, b)
		return a.nId < b.nId
	end)
	return tTmpList
end

--国家任务
local tCountryTask = nil
function getCountryTasks()
	if tCountryTask and table.nums(tCountryTask) > 0 then
		return tCountryTask
	end
	tCountryTask = {}
	for data in execForRows(Player.gamedb, "select * from country_task") do
		if data then
			tCountryTask[data.id] = data
		end		
	end
	return tCountryTask
end
--国家任务ID获取国家任务
function getCountryTaskById(  _nId )
	-- body
	if not _nId then
		return nil
	end
	if not tCountryTask then
		getCountryTasks()		
	end
	return tCountryTask[_nId]
end

--国家商店
local tCountryShopData = {}
function getCountryShopDataById(_nId )
	-- body
	if (tCountryShopData[_nId]) then
		return tCountryShopData[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from country_shop where id = \'" .. _nId .. "\'") do
		local tTempData = luaSplit(data.shopnum, ":")
		local tItemData = {}
		if tTempData and #tTempData >= 2 then
			tItemData.k= tTempData[1]
			tItemData.v= tonumber(tTempData[2])
		end
		data.tItemData=tItemData
		tCountryShopData[_nId] = data
		return data 
	end
	print("cannot find \"" .. _nId .. "\" in country_shop db")
	return nil
end

--国家宝藏
local tCountryTreasureData = {}
function getCountryTreasureDataById(_nId )
	-- body
	if (tCountryTreasureData[_nId]) then
		return tCountryTreasureData[_nId]
	end
	for data in execForRows(Player.gamedb, "select * from country_treasure where id = \'" .. _nId .. "\'") do
		tCountryShopData[_nId] = data
		return data 
	end
	print("cannot find \"" .. _nId .. "\" in country_treasure db")
	return nil
end
---------------------------新国家系统相关---------------------------