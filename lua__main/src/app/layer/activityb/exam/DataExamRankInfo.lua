-----------------------------------------------------
-- author: wenzongyao
-- updatetime:  2018-01-27 16:14:23 星期六
-- Description: 每日抢答排行榜信息,继承DataExamRankInfo,因为每日排行可以有相同的排名...忧伤...
-----------------------------------------------------

local RankInfo = require("app.layer.rank.RankInfo")

local DataExamRankInfo = class("DataExamRankInfo", RankInfo)

function DataExamRankInfo:ctor(  )
    DataExamRankInfo.super.ctor(self)
    	
end


-- as	List<ScoreRankMsg>	战力排行榜
-- tp	Integer	排行榜类型
-- currPage	Integer	当前页数
-- allPage	Integer	全部页数
-- nx	Integer	当前排名

function DataExamRankInfo:myInit(  )
	-- body
	--基础信息
	self.tRankList 	= {}	 	--排行数据
	self.nRankType 	= 0      	--排行榜类型
	self.nCurrPage 	= 0      	--当前页数
	self.nAllPage  	= 0			--全部页数
	self.nMyRank 	= 0  		--当前玩家的当前排名
	--	
	self.tMyInfo = nil

end

-- 根据服务端信息调整数据
function DataExamRankInfo:refreshDatasByService(tData)

	-- dump(tData, "DataExamRankInfo=", 100)
	if tData.tp ~= e_rank_type.exam then    
        return
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

    -- 和其它排行榜不一样的地方是，可以有相同的排名...所以用数组
    self.tRankList = {}
	if tData.as then
		for k, v in pairs(tData.as) do			
			table.insert(self.tRankList, self:getRankDataByRankType(v, tData.tp))			
		end
	end
	
end

function DataExamRankInfo:getMyInfo()
    return self.tMyInfo
end

return DataExamRankInfo