local GhostWarVO = class("GhostWarVO")
function GhostWarVO:ctor( tData )
	self:update(tData)
end

function GhostWarVO:update( tData )
	-- dump(tData,"ghostwarvo")
	self.nType = e_type_task.ghostdom
	self.sGid = tData.gid
	self.nSeq=tData.seq or self.nSeq	--Integer 第几波 
	self.nNpcId = tData.npc or self.nNpcId-- Integer 进攻的NPC_ID 
	self.nDefTroops = tData.dt or self.nDefTroops 	-- Integer 防守方兵力 
	self.nSupport = tData.st or self.nSupport 	-- Integer 已求援次数 
	self.nWcd = tData.wcd or self.nWcd  -- Long 开战倒计时 /秒
	self.nTargetX = tData.tx --Integer 目标X
	self.nTargetY = tData.ty --
	self.sDefHeadId = tData.di -- String 防守者像id
	self.sDefBox = tData.db -- String 防守者头像边框

	self.nBossLv = 0
	self.nMaxHelp = tData.sosTimes

	self.bCanSupport = tData.sp == 1 -- Integer 能否求援 0 不能 1 能
	if tData.wcd then 
		self.nCdSystemTime = getSystemTime()
	end
	self.sSenderName = ""

	self.nCdMax = tData.tt or self.nCdMax --Integer		城战总倒计时/秒


	self.tNpcData ,self.tNpcDetailData= getGhostBossById(self.nNpcId)

	self:setSenderNameLv()

	self.nAtkTroops = 0
	self:setAtkTroops()
end

function GhostWarVO:getCd( )
	if self.nWcd and self.nWcd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nWcd - (fCurTime - self.nCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end
function GhostWarVO:getCdMax()
	return self.nCdMax or 0
end
function GhostWarVO:setSenderNameLv(  )
	-- body
	local tData = self.tNpcData[#self.tNpcData]
	self.sSenderName = tData.sName
	self.nBossLv = tData.nLevel
end

function GhostWarVO:setAtkTroops()
	-- if self.tNpcDetailData then
	-- 	local tData = getNpcGropListDataById(self.tNpcDetailData.enemy)
	-- 	if tData then
	-- 		self.nAtkTroops=tData.score
	-- 	end
	-- end
	self.nAtkTroops = 0
	for k,v in pairs(self.tNpcData) do
		self.nAtkTroops=self.nAtkTroops + v.nTroops
	end
end

function GhostWarVO:checkTargetIsMe( )
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	return self.nTargetX == nX and self.nTargetY == nY
end


function GhostWarVO:getSenderHead(  )
	return self.sSenderHeadId
end

function GhostWarVO:getSenderBox(  )
	return self.sSenderBox
end

function GhostWarVO:getDeferHead(  )
	return self.sDefHeadId
end

function GhostWarVO:getDeferBox(  )
	return self.sDefBox
end

return GhostWarVO