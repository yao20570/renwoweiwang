-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-17 17:47:14 星期五
-- Description: 玩家基础数据管理类
-- 注意：1.Player文件只编写初始化，获取单例，释放数据逻辑代码，各个模块业务逻辑代码分块处理
-- 		 2.各个模块初始化和数据析构代码必需成对存在
-----------------------------------------------------

Player = class("Player")

require("app.utils.net.NetworkController")
require("app.layer.playerinfo.PlayerInfoController")
require("app.layer.hero.data.HeroController")
require("app.layer.fuben.FubenController")
require("app.layer.chat.data.ChatController")
require("app.layer.world.WorldController")
require("app.layer.build.BuildController")
require("app.layer.bag.BagInfoController")
require("app.layer.palace.PalaceController")
require("app.layer.technology.data.TnolyController")

require("app.layer.atelier.DlgAtelierController")
require("app.layer.task.TaskController")
require("app.layer.mail.MailController")
require("app.layer.rank.RankController")
require("app.layer.equip.EquipController")
require("app.layer.notice.NoticeController")
require("app.layer.newguide.NewGuideController")
require("app.layer.weapon.WeaponInfoController")
require("app.layer.country.CountryController")
require("app.layer.shop.ShopController")
require("app.layer.buff.BuffController")
require("app.data.activity.ActivityController")
require("app.layer.dayloginawd.DayLoginController")
require("app.layer.friends.FriendsController")
require("app.layer.wuwang.WuWangController")
require("app.layer.dailygift.DailyGiftController")
require("app.layer.triggergift.TriggerGiftController")
require("app.layer.herotravel.HeroTravelController")
require("app.layer.arena.data.ArenaController")
require("app.layer.activityb.exam.ExamController")
require("app.layer.remains.RemainsController")
require("app.layer.tlboss.TLBossController")
require("app.layer.passkillhero.PassKillHeroController")
require("app.layer.imperialwar.ImperialWarController")
require("app.layer.nationaltreasure.NationalTreasureController")
require("app.layer.warhall.data.WarHallController")
require("app.layer.newcountry.countryshop.data.CountryShopController")
require("app.layer.newcountry.countrytask.data.CountryTaskController")
require("app.layer.newcountry.newcountryhelp.data.CountryHelpController")
require("app.layer.newcountry.countrytreasure.data.CountryTreasureController")
require("app.layer.newcountry.newcountrytnoly.CountryTnolyController")

require("app.layer.newcountry.countrycity.data.CountryCityController")

--添加初始化模块
function Player:addInitKeys( sKey )
	-- body
	Player.tAllInits[sKey] = sKey
end

--移除初始化模块
function Player:removeInitKeys( sKey )
	-- body
	if Player.tAllInits[sKey] then
		Player.tAllInits[sKey] = nil
	else
		print(sKey .. "没有在Player.lua文件中执行初始化操作")
	end
end

--打印初始化相关信息
function Player:dumpInitKeys(  )
	-- body
	if Player.tAllInits and table.nums(Player.tAllInits) == 0 then
		print("所有模块都释放完整了")
	else
		for k, v in pairs (Player.tAllInits) do
			print(v .. "没有在Player.lua释放回调中执行释放操作")
		end
	end
end


-- 初始化数据，角色登陆前会调用这个接口
function Player:initPlayer()
	--初始化db
	if not Player.gamedb then --避免Player数据初始化 在数据库读取数据之前
		 -- 打开数据库
		local path = cc.FileUtils:getInstance():fullPathForFilename("data/game.db")
		Player.gamedb = openDatabase(path)
	end
	Player.pHomeLayer 					= nil 			-- 玩家主界面
	Player.pFightLayer 					= nil           -- 玩家战斗界面
	Player.pLoginLayer 					= nil           -- 玩家登录界面
	Player.pTmpMidLayer 				= nil 			-- 游戏常态存在界面

	Player.pFubenData                   = nil           -- 副本数据
	Player.heroInfos                    = nil           -- 英雄数据
	Player.activity 					= nil 			-- 活动数据
	Player.pBagData						= nil			-- 背包数据
	Player.pTaskInfo 					= nil 			-- 任务数据
	Player.pCountryData 				= nil 			-- 国家数据
	Player.shopData 					= nil 			-- 商店数据
	Player.pRankInfo 					= nil 			-- 排行数据
	Player.pFriendsData 				= nil  			-- 好友信息数据	
	Player.pArenaData 					= nil 			-- 竞技场数据
	Player.remainsData 					= nil 			-- 韬光养晦数据

	Player.isGuiding 					= false 		-- 是否属于新手引导阶段
	Player.nReconnetCount 				= 0 			-- 重连次数
	Player.nActARedNums                 = 0             -- 活动a的红点数
	Player.nActBRedNums                 = 0             -- 活动b的红点数
	Player.bRealyShowHome   			= false 		-- 是否进入到homelayer了

	--初始化一下
	Player.tAllInits = {} --用来存放初始化keys
	--初始化玩家基本数据信息
	self:addInitKeys(Player:initPlayerInfo())
	--初始化英雄数据
	self:addInitKeys(Player:initHeroInfo())
	--初始化建筑数据
	self:addInitKeys(Player:initBuildData())
	--初始化世界数据
	self:addInitKeys(Player:initWorldData())
	--初始化副本数据
	self:addInitKeys(Player:initFubenData())
	--初始化活动数据
	self:addInitKeys(Player:initActivityInfo())
	--初始化聊天数据
	self:addInitKeys(Player:initChatData())
	--初始化背包数据
	self:addInitKeys(Player:initBagInfo())
	--初始化资源数据
	self:addInitKeys(Player:initResourceData())
	--初始化科技数据
	self:addInitKeys(Player:initTnolyData())
	--初始化任务数据
	self:addInitKeys(Player:initPlayerTaskInfo())
	--初始化邮件数据
	self:addInitKeys(Player:initMailData())
	--初始化排行榜数据
	self:addInitKeys(Player:initRankInfo())
	--初始化每日抢答排行榜数据
	self:addInitKeys(Player:initExamRankInfo())
	--初始化每日抢答数据
	self:addInitKeys(Player:initDataExam())
	--初始化装备数据
	self:addInitKeys(Player:initEquipData())
	--初始化新手引导数据
	self:addInitKeys(Player:initNewGuideData())
	--初始化新手引导管理器
	self:addInitKeys(Player:initNewGuideMgr())
	--初始化国家数据
	self:addInitKeys(Player:initCountryData())
	--初始化商店数据
	self:addInitKeys(Player:initShopData())
	--初始化Buff数据
	self:addInitKeys(Player:initBuffData())
	-- 初始化公告数据
	self:addInitKeys(Player:initNoticeData())
	--初始化神兵数据
	self:addInitKeys(Player:initWeaponInfo())
	--初始化每日登录奖励数据
	self:addInitKeys(Player:initDayLoginData())
	--初始化好友信息数据
	self:addInitKeys(Player:initFriendsData())	
	--初始化竞技场数据
	self:addInitKeys(Player:initArenaData())
	--实始化触发礼包数据
	self:addInitKeys(Player:initTriggerGiftData())
	--实始化韬光养晦数据
	self:addInitKeys(Player:initRemainsData())
	--初始化限时礼包数据
	self:addInitKeys(Player:initTLBossData())
	--初始化过关斩将数据
	self:addInitKeys(Player:initPassKillHeroData())
	--初始化国家宝藏数据
	self:addInitKeys(Player:initNationalTreasureData())
	--初始化皇城战数据
	self:addInitKeys(Player:initImperWarData())
    --初始化战争大厅数据
	self:addInitKeys(Player:initWarHallData())
	--初始化国家任务数据
	self:addInitKeys(Player:initCountryTaskData())
	--初始新国家系统国家城池数据
	self:addInitKeys(Player:initCountryCityData())
	--初始新国家系统互助数据
	self:addInitKeys(Player:initCountryHelpData())
end
-- 执行一次初始化
Player:initPlayer()

-- 销毁玩家数据
function Player:destroyPlayer( )
	-- body

	--保存一下基地的缩放值
	if Player:getUIHomeLayer() and Player:getUIHomeLayer().pHomeBase then
		local fScale = Player:getUIHomeLayer().pHomeBase:getScrollBothScale() or 1
		saveLocalInfo(Player:getPlayerInfo().pid .. "_homebasescale" ,fScale)
	end



	self:releaseUILoginLayer()
	self:releaseUIFightLayer()
	self:releaseUIHomeLayer()
	self:releaseTmpMidLayer()

	--设置非新手引导阶段
	self:setIsGuiding(false)
	--重连次数修改为0
	Player.nReconnetCount = 0
	-- 活动a的红点数
	Player.nActARedNums   = 0  
	-- 活动b的红点数           
	Player.nActBRedNums   = 0             

	--释放玩家基本数据信息
	self:removeInitKeys(Player:releasePlayerInfo())
	--释放英雄数据
	self:removeInitKeys(Player:releaseHeroInfo())
	--释放玩家建筑数据
	self:removeInitKeys(Player:releaseBuildData())
	--释放世界数据
	self:removeInitKeys(Player:releaseWorldData())
	--释放副本数据
	self:removeInitKeys(Player:removeFubenData())
	--释放副本数据
	self:removeInitKeys(Player:releaseActivityInfo())
	--释放聊天数据
	self:removeInitKeys(Player:removeChatData())
	--释放背包数据
	self:removeInitKeys(Player:releaseBagInfo())
	--释放玩家的资源信息
	self:removeInitKeys(Player:releaseResourceData())
	--释放科技相关数据
	self:removeInitKeys(Player:releaseTnolyData())
	--释放任务相关数据
	self:removeInitKeys(Player:releasePlayerTaskInfo())
	--释放邮件相关数据
	self:removeInitKeys(Player:releaseMailData())
	--释放排行榜数据
	self:removeInitKeys(Player:releaseRankInfo())
	--释放每日答题排行榜数据
	self:removeInitKeys(Player:releaseExamRankInfo())
	--释放每日答题数据
	self:removeInitKeys(Player:releaseDataExam())
	--释放装备数据
	self:removeInitKeys(Player:releasEquipData())
	--释放新手引导数据
	self:removeInitKeys(Player:releaseNewGuideData())
	--释放新手引导管理器
	self:removeInitKeys(Player:releaseNewGuideMgr())
	--释放国家数据
	self:removeInitKeys(Player:releasCountryData())
	--释放商店数据
	self:removeInitKeys(Player:releaseShopData())
	--释放公告数据
	self:removeInitKeys(Player:releaseNoticeData())
	--释放神兵数据
	self:removeInitKeys(Player:releaseWeaponInfo())
	--释放buff数据
	self:removeInitKeys(Player:releaseBuffData())
	--释放每日登录奖励数据
	self:removeInitKeys(Player:releaseDayLoginData())
	--释放玩家好友数据
	self:removeInitKeys(Player:releaseFriendsData())	
	--释放玩家触发礼包数据
	self:removeInitKeys(Player:releaseTriggerGiftData())
	--释放竞技场数据
	self:removeInitKeys(Player:releaseArenaData())	
	--释放韬光养晦数据
	self:removeInitKeys(Player:releaseRemainsData())	
	--释放限时Boss数据
	self:removeInitKeys(Player:releaseTLBossData())
	--释放过关斩将数据
	self:removeInitKeys(Player:releasePassKillHeroData())
	--释放皇城战数据
	self:removeInitKeys(Player:releaseImperWarData())	
    --释放战争大厅数据
	self:removeInitKeys(Player:releaseWarHallData())
    --释放国家宝藏数据数据
	self:removeInitKeys(Player:releaseNationalTreasureData())
	--释放国家任务数据
	self:removeInitKeys(Player:releaseCountryTaskData())
	--释放新国家系统国家城池数据
	self:removeInitKeys(Player:releaseCountryCityData())
	--释放新国家系统国家互助数据
	self:removeInitKeys(Player:releaseCountryHelpData())
	--该方法最后调用
	self:dumpInitKeys()

	NEW_ROLE = false
	
	-- 执行一次初始化
	Player:initPlayer()

end

--玩家主界面赋值
function Player:initUIHomeLayer( _pHomeLayer )
	-- body
	Player.pHomeLayer = _pHomeLayer
end

--获得主界面
function Player:getUIHomeLayer(  )
	-- body
	return Player.pHomeLayer
end

--释放主界面
function Player:releaseUIHomeLayer(  )
	-- body
	Player.pHomeLayer 					= nil
end

--玩家战斗界面赋值
function Player:initUIFightLayer( _pFightLayer )
	-- body
	Player.pFightLayer = _pFightLayer
end

--获得战斗界面
function Player:getUIFightLayer(  )
	-- body
	return Player.pFightLayer
end

--释放战斗界面
function Player:releaseUIFightLayer(  )
	-- body
	Player.pFightLayer 					= nil
end

--玩家登录界面赋值
function Player:initUILoginLayer( _pLoginLayer )
	-- body
	Player.pLoginLayer = _pLoginLayer
end

--获得登录界面
function Player:getUILoginLayer(  )
	-- body
	return Player.pLoginLayer
end

--释放登录界面
function Player:releaseUILoginLayer(  )
	-- body
	Player.pLoginLayer 					= nil
end

--常态存在界面赋值
function Player:initTmpMidLayer( _pLayer )
	-- body
	Player.pTmpMidLayer = _pLayer
end

--获得常态存在界面
function Player:getTmpMidLayer(  )
	-- body
	return Player.pTmpMidLayer
end

--释放常态存在界面
function Player:releaseTmpMidLayer(  )
	-- body
	Player.pTmpMidLayer 					= nil
end

--设置当前是否属于新手引导阶段
function Player:setIsGuiding( _nEnabled )
	-- body
	Player.isGuiding = _nEnabled
end

--获得当前是否为新手引导阶段
function Player:getIsGuiding()
	return Player.isGuiding
end



return Player