--国家基础数据
--新国家系统的子系统的布局位置
e_type_country_sys_pos={
	countrytnoly=1,		--国家科技
	countryshop=2,	    --国家商店
	countryhelp=3,		--国家互助
	countrytask=4,		--国家任务
	countrytreasure=5,	--国家宝藏
	countryglory=6,		--国家荣誉
	countrycity=7,		--国家城池
	countryofficial=8,	--国家爵位	
}

local KingDataVo = require("app.layer.country.data.KingDataVo")

local CountryDataVo = class("CountryDataVo")

function CountryDataVo:ctor(  )
	--body
	self:myInit()
end

function CountryDataVo:myInit(  )
	-- body
	self.sAffiche 			= 		"" --国家公告
	self.nAfficheTime 		= 		nil --公告时间(时间戳)
	self.nCLv 				= 		0 --国家等级
	self.nCExp 				= 		0 --国家经验	
	self.nIsKing 			= 		0 --我是否是国王 0:否 1：是
	self.nExploit 			= 		0 --当天已开发次数
	self.nOfficial 			= 		0 --我的官职
	self.nNobility 			= 		0 --我的爵位
	self.nRank 				= 		0 --全国排名
	self.nIsWorship			= 		0 --是否已膜拜国王 0:否 1:是
	self.nVotes 			= 		0 --进入排行榜得票数
	self.nScore 			= 		0 --城战积分
	self.nT 				= 		0 --已经投票次数
	self.nAfficheCnt 		=		0 --公告已编辑次数[国王才有该字段]
	self.tKingVo 			= 		nil --国王数据
	self.nFct 				= 		0 --官员已经使用免体力短途战次数
	--
	--当前膜拜次数
	self.nWorship 			= 		0 --当前膜拜次数
end

function CountryDataVo:refreshDataByService(_data )	
	-- dump(_data, "_data", 100)
	-- body	
	self.sAffiche 			= 		_data.n or self.sAffiche 		--国家公告
	self.nAfficheTime 		= 		_data.nt or self.nAfficheTime 	--公告时间(时间戳)
	self.nCLv 				= 		_data.lv or self.nCLv --国家等级
	--self.nCExp 				= 		_data.exp or self.nCExp --国家经验
	self.nIsKing 			= 		_data.k or self.nIsKing --我是否是国王 0:否 1：是
	--self.nExploit 			= 		_data.t or self.nExploit --当天已开发次数
	self.nOfficial 			= 		_data.j or self.nOfficial --我的官职
	self.nNobility 			= 		_data.b or self.nNobility --我的爵位
	self.nRank 				= 		_data.r or self.nRank --全国排名
	self.nIsWorship			= 		_data.w or self.nIsWorship --是否已膜拜国王 0:否 1:是
	self.nVotes 			= 		_data.vs or self.nVotes --进入排行榜的得票数
	self.nScore 			= 		_data.cso or self.nScore --城战积分
	--self.nT 				= 		_data.tt or self.nT 	--已投票次数
	self.nAfficheCnt 		=		_data.ss or self.nAfficheCnt --公告已编辑次数[国王才有该字段]
	self.nFct 				= 		_data.fct or self.nFct --官员已经使用免体力短途战次数
	if _data.kVo then		
		if table.nums(_data.kVo) > 0 then
			if not self.tKingVo then
				self.tKingVo 	= 		KingDataVo.new()			
			end
			self.tKingVo:refreshDataByService(_data.kVo)
		else
			self.tKingVo = nil
		end
	end	

	self:refreshVotedTimes(_data)
	self:refreshCountryExp(_data)
end

--国家经验刷新 
function CountryDataVo:refreshCountryExp( _data )
	-- body
	self.nCExp 		= 	_data.exp or self.nCExp
	self.nExploit 	= 	_data.t or self.nExploit --当天已开发次数
	sendMsg(ghd_country_home_menu_red_msg)	
end

--城战积分推送
function CountryDataVo:refreshCountryScore( _data )
	-- body
	self.nScore 	= 	_data.s or self.nScore
end

--当前膜拜次数
function CountryDataVo:refreshCountryWorship( _data )
	-- body
	self.nWorship = _data.t or self.nWorship
end
--刷新国家公告
function CountryDataVo:refreshCountryAffiche( _data)	
	-- body
	self.sAffiche = _data.n or self.sAffiche
	self.nAfficheTime = _data.nt or self.nAfficheTime
end

--更新国家公告编辑次数
function CountryDataVo:refreshAfficheCnt( _data )
	-- body
	self.nAfficheCnt = _data or self.nAfficheCnt
end

--更新爵位
function CountryDataVo:refreshNobility( _data )
	-- body
	self.nNobility = _data.b or self.nNobility
end

--排行榜奖励票数刷新
function CountryDataVo:refreshVotes( _data )
	-- body
	self.nVotes = _data or self.nVotes
end

--刷新已投票次数
function CountryDataVo:refreshVotedTimes( _data )
	-- body
	self.nT = _data.tt or self.nT
	--国家红点相关消息
	sendMsg(ghd_country_home_menu_red_msg)
end
--刷新我的膜拜状态
function CountryDataVo:updateMyWorship( nworship )
	-- body
	self.nIsWorship = nworship or self.nIsWorship
	sendMsg(ghd_mobai_red_msg)
end
--是否已经膜拜
function CountryDataVo:isHadWorship()
	-- body
	if self.nIsWorship == 1 then
		return true
	else
		return false
	end
end
--是否存在国王
function CountryDataVo:isHaveKing(  )
	-- body
	if self.tKingVo then
		return true
	else
		return false
	end
end

--是否当前玩家是国王
function CountryDataVo:isKing(  )
	-- body
	if self.nIsKing and self.nIsKing == 1 then
		return true
	else
		return false		
	end
end

function CountryDataVo:isOfficial(  )
	-- body
	local tofficial = getNationTransport(self.nOfficial)
	return tofficial ~= nil
end

function CountryDataVo:getIsOfficialEnough( nOfficial )
	if self.nOfficial == 0 then --不在配表中
		return false
	end
	local tofficial = getNationTransport(self.nOfficial)
	if not tofficial then
		return false
	end
	return self.nOfficial <= nOfficial --配表，越小就是越大官
end

--官员的免费短途站总次数
function CountryDataVo:getShortFightCnt(  )
	-- body
	local nCnt = 0	
	if self.nOfficial and self.nOfficial ~= 0 then
		local nOfficial = self.nOfficial			
		local tcountryprishow = getCountryPriShow()
		local tprishow = tcountryprishow[3]
		if nOfficial == e_official_ids.king then
			nCnt = tonumber(tprishow["king"] or 0)
		elseif nOfficial == e_official_ids.chancellor then
			nCnt = tonumber(tprishow["minister"] or 0)
		elseif nOfficial == e_official_ids.counsellor then
			nCnt = tonumber(tprishow["adviser"] or 0)
		elseif nOfficial == e_official_ids.general then
			nCnt = tonumber(tprishow["general"] or 0)
		end
	end
	local tofficial = getNationTransport(self.nOfficial)
	local sName = ""
	if tofficial then
		sName = tofficial.name
	end
	local nFree = nCnt - self.nFct --剩余次数
	local tShortFigheData = {
		nCnt = nCnt,
		nFct = self.nFct,
		nFree = nFree,
		sName = sName,
	}	
	if nCnt == 0 then
		tShortFigheData = nil
	end
	return tShortFigheData --总免费次数 已使用次数 官员名称
end

function CountryDataVo:release(  )

end
return CountryDataVo

