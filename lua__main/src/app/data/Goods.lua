-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-27 16:52:02 星期一
-- Description: 通用数据类
-----------------------------------------------------

e_type_goods = { 			-- 类型
	type_item 		= 	1, 			-- 物品
	type_fuben		= 	2, 			-- 副本
	type_hero 		=   3, 			-- 武将
	type_equip 		= 	4, 			-- 装备
	type_npc        =   5,          -- 怪物
	type_build 		= 	6, 			-- 建筑
	type_hero_att   =   7,          -- 英雄属性
	type_tnoly      =   8,          -- 科技
	type_buff       =   9,          -- buff
	type_resdata    =   10,         -- 资源
	type_head 		= 	11, 		-- 头像
  	type_activity   =   12,         -- 活动
  	type_weapon     =   13,         -- 神兵  	
  	type_official   =   14,         -- 文官  	
  	type_researcher =   15,         -- 研究员
	type_smith 		=   16,         -- 铁匠
	type_task 		= 	17,			-- 任务
	type_daily 		= 	18,			-- 每日目标
	type_country_task = 19, 		-- 国家限时任务
	type_icon 		= 	20, 		-- 头像
	type_box 		= 	21, 		-- 头像框
	type_chatper 	= 	22, 		-- 剧情章节
	type_chatper_t  = 	23,			-- 剧情子章节
	type_title 		= 	24, 		-- 玩家称号
	type_tech       =   25,         -- 皇城战科技
	country_tech    =   26,         -- 国家科技
}


local Goods = class("Goods")

function Goods:ctor( eType )
	self:baseInit()
	-- 重置数据类型
	self.nGtype = eType or e_type_goods.type_item
end

-- 初始化成员变量
function Goods:baseInit()
	self.sName 		= nil   -- 名字（string）
	self.sDes 		= nil   -- 描述语（string）
	self.sTid 		= 0     -- 配表id（int）
	self.sPid 		= nil   -- 玩家身上对应id（string）
	self.nLv 		= 0     -- 当前等级(int)
	self.nCt 		= 0     -- 当前数量(int)
	self.nGtype 	= e_type_goods.type_item -- 数据类型，默认是物品类型(enum)
	self.sIcon 		= nil   -- 对应的icon资源(string)
	self.nQuality 	= 0     -- 品质（int）
end

-- 强制写的引用
function Goods:retain(  )
	-- 不执行任何操作
end

-- 强制写的释放
function Goods:release(  )
	-- 不执行任何操作
end

--获取当前数量
function Goods:getCnt(  )
	return self.nCt
end

function Goods:getSmallIcon(  )
    return "ui/daitu.png"
end

return Goods