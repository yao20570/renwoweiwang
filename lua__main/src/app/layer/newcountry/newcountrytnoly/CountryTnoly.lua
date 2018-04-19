-- CountryTnoly.lua
-- Author: dengshulan
-- Date: 2018-03-30 18:35:00
-- 国家科技基础数据

local Goods = require("app.data.Goods")

local CountryTnoly = class("CountryTnoly", Goods)


function CountryTnoly:ctor()
	CountryTnoly.super.ctor(self,e_type_goods.country_tech)
	-- body
	self:myInit()
end

function CountryTnoly:myInit()
	--配表字段
	self.nId 				= 0                  --int	    科技id
	self.sName 				= ""                 --string   科技名称
	self.nStage   			= 0                  --int      科技所属阶段
	self.sLevelUp 		    = ""                 --string   等级,经验
	self.nCostType 			= nil                --int      消耗资源类型
	self.sBuffId 		    = ""                 --string   对应等级buffId
	self.nLvEffect 			= 0                  --int      该等级以上的玩家生效
	self.sDesc 				= ""                 --string   描述	
	self.sIcon              = "ui/daitu.png"     --string   图标icon
	self.nQuality           = 1    				 --int   	品质

	--后端字段
	self.nLevel             = 0    				 --int   当前等级
	self.nSection           = 0    				 --int   当前等级段位
	self.nExp            	= 0    				 --int   科技经验
	self.nRecommend         = 0    				 --int   是否推荐, 0否1是
	

	--自建字段	
	self.nMaxLevel          = 0    				 --int   满级等级
	self.tExps  			= {} 					--等级段位经验
	self.nMaxSection 		= 0 					--最大段位
end

--配表数据
function CountryTnoly:initDatasByDB( data )
	self.nId 				= data.id or self.nId						--int	  科技id
	self.sName 				= data.name or self.sName 					--string  科技名称
	self.nStage   			= data.stage or self.nStage 				--int     科技所属阶段
	self.sLevelUp 		    = data.lvlexp or self.sLevelUp				--string  等级,经验
	self.nCostType 			= data.costtype or self.nCostType			--int     消耗资源类型
	self.sBuffId 		    = data.lvlbuff or self.sBuffId				--string  对应等级buffId
	self.nLvEffect          = data.lvleffect or self.nLvEffect     	    --int 	  该等级以上的玩家生效
	self.sDesc          	= data.desc or self.sDesc     			    --string  描述
	if data.icon then
		self.sIcon          = "#"..data.icon..".png"   --str 关卡icon
	end
	self.nQuality           = data.quality or self.nQuality    			--int   品质
	
	if data.exps then
		local tExps = luaSplitMuilt2(data.exps, "|", "-", ",", ":")
		self.tExps = tExps
	end
	-- dump(self.tExps, "self.tExps ==", 100)
	
	self.nMaxLevel = table.nums(self.tExps) - 1
end

--刷新来自服务器的数据
function CountryTnoly:updateByService( data )
	self.nLevel 				= data.l or self.nLevel						--int	  当前等级
	self.nSection          		= data.s or self.nSection    				--int     当前等级段位
	self.nExp 					= data.e or self.nExp 						--int	  科技经验
	self.nRecommend 			= data.r or self.nRecommend					--int	  是否推荐
end

--获取升级需要的经验
function CountryTnoly:getNextLvNeedExp()
	local nExp = 1
	for _, v in ipairs(self.tExps) do
		if self.nLevel == tonumber(v[1][1][1]) then
			for _, data in ipairs(v[2]) do
				if self.nSection == tonumber(data[1]) then
					nExp = tonumber(data[2])
				end
			end
		end
	end
	return nExp
end

--获取当前等级最大段位
function CountryTnoly:getMaxSection()
	-- body
	local nMaxSection = 0
	for k, v in ipairs(self.tExps) do
		if tonumber(v[1][1][1]) == self.nLevel then
			nMaxSection = table.nums(v[2])
			if self.nLevel == self.nMaxLevel then
				nMaxSection = nMaxSection - 1
			end
		end
	end
	return nMaxSection
end

--科技是否满级
function CountryTnoly:getIsMaxLv()
	--满级的满阶段
	local nMaxLvSection = table.nums(self.tExps[table.nums(self.tExps)][2]) - 1
	return self.nLevel >= self.nMaxLevel and self.nSection >= nMaxLvSection
end

--通过科技等级和段位获取buff
function CountryTnoly:getBuffByLv(_nLv, _section)
	if _nLv > self.nMaxLevel then
		return
	end
	local function getBuff(_nLv, _section)
		for k, v in ipairs(self.tExps) do
			if tonumber(v[1][1][1]) == _nLv then
				for _, data in ipairs(v[2]) do
					if tonumber(data[1]) == _section then
						local nBuffId = tonumber(data[3])
						local tBuffData = getBuffDataByIdFromDB(nBuffId)
						return tBuffData
					end
				end
			end
		end
	end
	-- if _nLv == 0 then
	-- 	--取下个阶段的buff
	-- 	if _section > 0 then
	-- 		return getBuff(_nLv + 1, 0) 
	-- 	else
	-- 		return nil
	-- 	end
	-- else
	for k, v in ipairs(self.tExps) do
		if tonumber(v[1][1][1]) == _nLv then
			--取下个阶段的buff
			if _section >= table.nums(v[2]) then
				return getBuff(_nLv + 1, 0)
			else
				for _, data in ipairs(v[2]) do
					if tonumber(data[1]) == _section then
						local nBuffId = tonumber(data[3])
						local tBuffData = getBuffDataByIdFromDB(nBuffId)
						return tBuffData
					end
				end
			end
		end
	end
	-- end
end


return CountryTnoly
