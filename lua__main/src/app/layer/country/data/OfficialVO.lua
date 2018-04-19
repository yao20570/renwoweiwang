--官员
local OfficialVO = class("OfficialVO")

function OfficialVO:ctor(  )
	--body
	self:myInit()
end

function OfficialVO:myInit(  )
	-- body
	self.nOfficial  = 0
	self.nID 		= nil
	self.sName 		= nil 
	self.nLv 		= 0 
	self.nSword		= 0
	self.nArea 		= 0
end

function OfficialVO:refreshDataByService(_data )
	-- body	
	self.nID 		= 	_data.a or self.nID
	self.nOfficial 	=  	_data.j or self.nOfficial --	Integer	官职
 	self.sName 		=  	_data.n or self.sName			--String	名字
 	self.nLv 		= 	_data.lv or self.nLv 			--lv	Integer	等级
 	self.nSword 	= 	_data.s or self.nSword 		--s	Long	战斗力
 	self.nArea 		= 	_data.bi or self.nArea 		--bi	Integer	所在区域ID
end
--官员显示
function OfficialVO:getFormatStrGroup(  )
	-- body
	local tgroup = {}	
	local tofficial = getNationTransport(self.nOfficial)
	tgroup[1] = {text = tofficial.name, color = _cc.yellow}
	tgroup[2] = {text = self.sName, color = _cc.pwhite}
	tgroup[3] = {text = self.nLv, color = _cc.green}
	tgroup[4] = {text = formatCountToStr(self.nSword), color = _cc.blue}
	tgroup[5] = {text = getAreaName(self.nArea), color = _cc.pwhite}
	return tgroup
end
--将军显示
function OfficialVO:getGeneralFormatStr()
	-- body
	local tgroup = {}
	tgroup[1] = {text = self.sName, color = _cc.pwhite}
	tgroup[2] = {text = self.nLv, color = _cc.green}
	tgroup[3] = {text = formatCountToStr(self.nSword), color = _cc.blue}
	return tgroup
end

function OfficialVO:release(  )

end
return OfficialVO

