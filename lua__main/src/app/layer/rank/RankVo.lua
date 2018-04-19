local RankVo = class("RankVo")

function RankVo:ctor( _ntype )
	self:myInit(_ntype)
end

function RankVo:myInit( _ntype )
	-- body
	self.tRankList 	= {}	 	--排行数据
	self.nRankType 	= _ntype    --排行榜类型
	self.nCurrPage 	= 0      	--当前页数
	self.nAllPage  	= 0			--全部页数
	self.nMyRank 	= 0  		--当前玩家的当前排名
end

function RankVo:refreshDatasByService( tData )
	-- body
	self.nRankType 			= 		tData.tp or self.nRankType	
	self.nCurrPage 			= 		tData.currPage or self.nCurrPage
	self.nAllPage 			= 		tData.allPage or self.nAllPage
	self.nMyRank 			=       tData.nx or self.nMyRank

	if tData.as and table.nums(tData.as) > 0 then
		for k, v in pairs(tData.as) do			
			self.tRankList[v.x] = self:getRankDataByRankType(v, tData.tp)
			if (self.nRankType == e_rank_type.cityfight --特殊处理
				or self.nRankType == e_rank_type.countryfight 
				or self.nRankType == e_rank_type.country_science) 
				and self.nCurrPage == 1 then			
				self.tRankList[v.x]["ps"] = getRankVoteNum(self.nRankType, v.x)
			end
		end
	end	
end
--根据配表转换数据
function RankVo:getRankDataByRankType(_data, _nRankType)
	-- body
	local tdata = {}
	tdata["i"] = _data.i
	if _data.p then
		tdata["p"] 					= 		_data.p..".png"
	else 
		tdata["p"]					= 		"ui/daitu.png"
	end
	local rankdata = getRankData(self.nRankType)
	local ttypes = luaSplit(rankdata.sort, ";")
	for k, v in pairs(ttypes) do	
		tdata[v] = _data[v]
	end
	return tdata
end
return RankVo