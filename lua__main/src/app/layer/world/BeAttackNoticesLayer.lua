----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-26 14:02:04
-- Description: 被攻击层提示
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemCityBeAttack = require("app.layer.world.ItemCityBeAttack")

local BeAttackNoticesLayer = class("BeAttackNoticesLayer",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
    return pView
end)

--pHomeTaskLayer: 世界任务层
function BeAttackNoticesLayer:ctor()
	self:onParseViewCallback()
end

--解析界面回调
function BeAttackNoticesLayer:onParseViewCallback(  )
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("BeAttackNoticesLayer",handler(self, self.onBeAttackNoticesLayerDestroy))
end

-- 析构方法
function BeAttackNoticesLayer:onBeAttackNoticesLayerDestroy(  )
    self:onPause()
end

function BeAttackNoticesLayer:regMsgs(  )
	regMsg(self, gud_world_my_city_be_attack_msg, handler(self, self.onMyCityBeAttack)) 

	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.onMyCityBeAttack))
end

function BeAttackNoticesLayer:unregMsgs(  )
	unregMsg(self, gud_world_my_city_be_attack_msg) 	

	unregMsg(self, gud_world_my_city_pos_change_msg) 	
end

function BeAttackNoticesLayer:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateViews))
	self:updateViews()
end

function BeAttackNoticesLayer:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function BeAttackNoticesLayer:setupViews(  )
	self.pNotice = ItemCityBeAttack.new()
	self:addView(self.pNotice)
	self:setContentSize(self.pNotice:getContentSize())
	--是否在动作中
	self.bIsFade = false
end

function BeAttackNoticesLayer:updateViews(  )
	--遍历找出最短cd打我消息和最短cd救我消息的列表
	local tShortCdHitNotice = nil
	local tCityWarNotices = Player:getWorldData():getCityWarNotices()
	for i=1,#tCityWarNotices do
		local tNotice = tCityWarNotices[i]
		if tNotice:getCd() > 0 and tNotice:checkTargetIsMe() then --只显示cd大于0的
			if tNotice.nType == e_type_citywar_act.hit then  --最短cd打我消息
				if tShortCdHitNotice then
					if tShortCdHitNotice:getCd() < tNotice:getCd() then
						tShortCdHitNotice = tNotice
					end 
				else
					tShortCdHitNotice = tNotice
				end
			end
		end
	end
	if tShortCdHitNotice then
		self:setVisible(true)
		self.pNotice:setData(tShortCdHitNotice)
	else
		self:setVisible(false)
		unregUpdateControl(self)
		sendMsg(gud_be_attack_notices_height_refresh)
	end
end

--我的城市受到攻击
function BeAttackNoticesLayer:onMyCityBeAttack(  )
	regUpdateControl(self, handler(self, self.updateViews))
	self:updateViews()
	sendMsg(gud_be_attack_notices_height_refresh)
end

--设置世界左边对联
--pWorldLeft：世界左边部分
function BeAttackNoticesLayer:setWorldLeft( pWorldLeft )
	self.pWorldLeft = pWorldLeft
	self.fWorldLeftOriginY = self.pHomeTaskLayer:getContentSize().height + 28
	self:updateViews()
end


return BeAttackNoticesLayer