-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-22 11:14:23 星期一
-- Description: 排行榜信息
-----------------------------------------------------

local RankVo = require("app.layer.rank.RankVo")

local RankInfo = class("RankInfo")

function RankInfo:ctor(  )
	self:myInit()
end


-- as	List<ScoreRankMsg>	战力排行榜
-- tp	Integer	排行榜类型
-- currPage	Integer	当前页数
-- allPage	Integer	全部页数
-- nx	Integer	当前排名

function RankInfo:myInit(  )
	-- body
	--基础信息
	self.tRankList 	= {}	 	--排行数据
	self.nRankType 	= 0      	--排行榜类型
	self.nCurrPage 	= 0      	--当前页数
	self.nAllPage  	= 0			--全部页数
	self.nMyRank 	= 0  		--当前玩家的当前排名
	--	
	self.tMyInfo = nil
	--
	self.nWorldRank = nil         --战力提升途径显示的世界战力排行
	self.nCountryRank = nil       --战力提升途径显示的国内战力排行
	self.nReqMyRankInfoCd = 0     --5分钟进行一次请求战力提升途径显示的世界国内战力

	--排行榜数据
	self.tRankData = {}
	self.tRankData[e_rank_type.cityfight] = nil
	self.tRankData[e_rank_type.countryfight] = nil
	self.tRankData[e_rank_type.country_science] = nil
end

-- 根据服务端信息调整数据
function RankInfo:refreshDatasByService(tData)
	--基础信息
	--切换排行类型
	-- dump(tData, "rankinfo=", 100)
	if tData.tp and self.nRankType and self.nRankType ~= tData.tp then
		self.tRankList 	= {}	 	--排行数据
	end
	self.nRankType 			= 		tData.tp or self.nRankType

	self.nCurrPage 			= 		tData.currPage or self.nCurrPage
	self.nAllPage 			= 		tData.allPage or self.nAllPage	
	if tData.me then
		self.tMyInfo = 	self:getRankDataByRankType(tData.me, tData.tp)
		self.nMyRank =  self.tMyInfo.x
	else
		self.tMyInfo = self.tMyInfo
		self.nMyRank = 0
	end
	if tData.as and table.nums(tData.as) > 0 then
		for k, v in pairs(tData.as) do			
			self.tRankList[v.x] = self:getRankDataByRankType(v, tData.tp)			
		end
	end
	--如果获取城战国战，国家建设排行榜的第一页数据
	if ( self.nRankType == e_rank_type.cityfight 
		or self.nRankType == e_rank_type.countryfight 
		or self.nRankType == e_rank_type.country_science ) 
		and self.nCurrPage == 1 then
		if not self.tRankData[self.nRankType] then
 			self.tRankData[self.nRankType] = {}
		end
		for i = 1, 5 do
			if self.tRankList[i] then
				self.tRankData[self.nRankType][i] = copyTab(self.tRankList[i])
				self.tRankData[self.nRankType][i]["ps"] = getRankVoteNum(self.nRankType, i)								
			end
		end
	end
	--dump(tData, "排行数据", 10)
end

--获取排行数据
--return table
function RankInfo:getRankDataList()
	-- body
	if not self.tRankList and table.nums(self.tRankList) <= 0 then
		self.tRankList = {}
	end
	return self.tRankList
end
--根据类型排行类型获取数据
function RankInfo:getRankDatasByRankType(_nRankType)
	-- body
	return self.tRankData[_nRankType]
end

--判断当前是否可以请求下一页数据 --排行榜页面使用
function RankInfo:isCanAskForNextPag( ntype )	
	-- body
	if not ntype then
		return true
	end
	if self.nCurrPage == self.nAllPage and table.nums(self.tRankList) > 0 and self.nRankType == ntype then
		return false
	else
		return true
	end
end

function RankInfo:getRankDataByRankType(_data, _nRankType)
	-- body
	local tdata = {}
	tdata["i"] = _data.i 	--常用字段玩家ID
	tdata["hz"] = _data.hz 	--常用字段历史最高排名
	tdata["p"] = _data.p
	tdata["box"] = _data.box
	tdata["tit"] = _data.tit
	-- if _data.p then			--常用字段玩家头像
	-- 	tdata["p"] 					= 		getPlayerIconStr(_data.p)
	-- else 
	-- 	tdata["p"]					= 		"#i130000_tx.png"
	-- end

	local rankdata = getRankData(_nRankType)
	local ttypes = luaSplit(rankdata.sort, ";")
	for k, v in pairs(ttypes) do	
		tdata[v] = _data[v]
	end
	return tdata
end

--
function RankInfo:getRankVoByType( _ntype )
	-- body
	if not _ntype then
		return nil
	end
	if not self.tRankData[_ntype] then
		self.tRankData[_ntype] = RankVo.new(_ntype)
	end
	return self.tRankData[_ntype]
end

--[8454]查看玩家个人排行榜信息
function RankInfo:setMyRankInfo( tData )
	local nWorldRank = tData.wr --Integer	世界排行(-1:未入榜)
	if nWorldRank then
		self.nWorldRank = nWorldRank
	end
	local nCountryRank = tData.nr --	Integer	国内排行 (-1:未入榜)
	if nCountryRank then
		self.nCountryRank = nCountryRank
	end
	self.nReqMyRankInfoCd = getSystemTime()
end
function RankInfo:getWorldRank( )
	return self.nWorldRank
end

function RankInfo:getCountryRank( )
	return self.nCountryRank
end
--获取
function RankInfo:getIsNeedReqMyRankInfo()
	if self.nReqMyRankInfoCd then
		local nLeftTime = getSystemTime() - self.nReqMyRankInfoCd
		if nLeftTime >= (5 * 60) then
			return true
		end
	end
	return false
end
--
--清理公共排行数据
function RankInfo:clearRankInfo( )
	-- body
	--dump(self, "rankinfo=", 10)
	self.tRankList 	= {}	 	--排行数据
	self.nRankType 	= 0      	--排行榜类型
	self.nCurrPage 	= 0      	--当前页数
	self.nAllPage  	= 0			--全部页数
	self.nMyRank 	= 0  		--当前玩家的当前排名
	--排行榜数据
	self.tRankData = {}
	self.tRankData[e_rank_type.cityfight] = nil
	self.tRankData[e_rank_type.countryfight] = nil
	self.tRankData[e_rank_type.country_science] = nil	
end

--获取我的排行数据
function RankInfo:getMyRankInfo(  )
	-- body
	return self.tMyInfo
end
return RankInfo