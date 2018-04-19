----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-07 10:04:30
-- Description: 新手引导控制器
-----------------------------------------------------
local NewGuideData = require("app.layer.newguide.data.NewGuideData")
local NewGuideMgr = require("app.layer.newguide.NewGuideMgr")
local GirlGuideMgr = require("app.layer.newguide.GirlGuideMgr")

--获取数据单例
function Player:getNewGuideData(  )
	if not Player.newGuideData then
		self:initNewGuideData()
	end
	return Player.newGuideData
end

--初始化数据
function Player:initNewGuideData(  )
	if not Player.newGuideData then
		Player.newGuideData = NewGuideData.new()
	end
	return "Player.newGuideData"
end

--释放邮件数据
function Player:releaseNewGuideData()
	if Player.newGuideData then
		Player.newGuideData:release()
		Player.newGuideData = nil
	end
	return "Player.newGuideData"
end


--获取新手引导管理器单例
function Player:getNewGuideMgr(  )
	if not Player.newGuideMgr then
		self:initNewGuideMgr()
	end
	return Player.newGuideMgr
end

--初始化管理器单例
function Player:initNewGuideMgr(  )
	if not Player.newGuideMgr then
		Player.newGuideMgr = NewGuideMgr.new()
	end
	return "Player.newGuideMgr"
end

--释放管理器单例
function Player:releaseNewGuideMgr()
	if Player.newGuideMgr then
		Player.newGuideMgr:release()
		Player.newGuideMgr = nil
	end
	return "Player.newGuideMgr"
end

--获取教你玩引导管理器单例
function Player:getGirlGuideMgr(  )
	if not Player.girlGuideMgr then
		self:initGirlGuideMgr()
	end
	return Player.girlGuideMgr
end

--初始化管理器单例
function Player:initGirlGuideMgr(  )
	if not Player.girlGuideMgr then
		Player.girlGuideMgr = GirlGuideMgr.new()
	end
	return "Player.girlGuideMgr"
end

--释放管理器单例
function Player:releaseGirlGuideMgr()
	if Player.girlGuideMgr then
		Player.girlGuideMgr:release()
		Player.girlGuideMgr = nil
	end
	return "Player.girlGuideMgr"
end

