--候选人数据
local CandidateVO = class("CandidateVO")


function CandidateVO:ctor(  )
	--body
	self:myInit()
end

function CandidateVO:myInit(  )
	-- body
	self.nID  		= 		nil
	self.sName 		= 		nil 
	self.nLv 		= 		0 
	self.nSword		= 		0
	self.nVotes		= 		0
end

function CandidateVO:refreshDataByService( _data )
	-- body	
	self.nID 		=  	_data.a or self.nID 		--	Long	角色ID
 	self.sName 		=  	_data.n or self.sName		--	String	名字
 	self.nLv 		= 	_data.lv or self.nLv 		--	Integer	等级
 	self.nSword 	= 	_data.s or self.nSword 		-- 	Long	战斗力
 	self.nVotes 	= 	_data.v or self.nVotes 		--  Integer	得票数
end

--候选官员显示
function CandidateVO:getFormatStrGroup(  )
	-- body
	local tgroup = {}	
	local tofficial = getNationTransport(self.nOfficial)
	tgroup[1] = {text = self.sName, color = _cc.pwhite}
	tgroup[2] = {text = self.nLv, color = _cc.green}
	tgroup[3] = {text = formatCountToStr(self.nSword), color = _cc.blue}
	tgroup[4] = {text = self.nVotes, color = _cc.pwhite}
	return tgroup
end

--候选将军显示
function CandidateVO:getGeneralFormatStr()
	-- body
	local tgroup = {}
	tgroup[1] = {text = self.sName, color = _cc.pwhite}
	tgroup[2] = {text = self.nLv, color = _cc.green}
	tgroup[3] = {text = formatCountToStr(self.nSword), color = _cc.blue}
	return tgroup
end

function CandidateVO:release(  )

end
return CandidateVO

