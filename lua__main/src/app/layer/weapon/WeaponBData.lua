-- WeaponBData.lua
-- Author: dengshulan
-- Date: 2017-06-24 19:50:00
-- 神兵基础数据

local Goods = require("app.data.Goods")

local WeaponBData = class("WeaponBData", Goods)


function WeaponBData:ctor()
	WeaponBData.super.ctor(self,e_type_goods.type_weapon)
	-- body
	self:myInit()
end

function WeaponBData:myInit()
	--配表字段
	self.nId 				= 0                  --int	    神兵id
	self.sName 				= ""                 --string   神兵名称
	self.nMakeLv   			= 0                  --int      打造所需等级
	self.sBuyCosts 		    = ""                 --string   购买碎片花费
	self.nNeedFra 			= 0                  --int      打造所需碎片数量
	self.nQuality 		    = 0                  --int      神兵品质
	self.sIcon              = "ui/daitu.png"     --string   神兵icon
	self.sFraIcon           = "ui/daitu.png"     --string   碎片icon
	self.nOpenFb 			= 0                  --int      通关副本关卡id
	self.nJumpFb 			= 0                  --int      跳转副本章节id	
	self.sFragDesc          = nil                --string   碎片描述	

	--后端字段
	self.nWeaponId          = nil                --int      神兵id
	self.nWeaponLv          = 0                  --int      神兵等级   
	self.nProgress          = nil                --int      神兵升级进度     
	self.nCritical          = nil                --int      神兵升级暴击 
	self.nAdvanceLv         = nil                --int      神兵阶数    
	self.nAdvanceCnt        = nil                --int      神兵进阶段位数    
	self.nBuildCD           = nil                --int      神兵打造CD   
	self.nAdvanceCD         = nil                --int      神兵进阶CD    
	self.nExtraBj           = nil                --int      神兵额外暴击[没有额外暴击,这个字段不会下发]    
	self.nExtraCD           = nil                --int      神兵额外暴击生效CD[没有额外暴击,这个字段不会下发]    	

	--自建字段	
	self.nBuildLastLoadTime = nil
	self.nAdvLastLoadTime   = nil
	self.nExtraBjLastLoad   = nil
	self.nPreLv             = 1                  --int      神兵上次等级
	self.nPreAdLv	        = 0                  --int      神兵上次阶数
	self.nPreCritical	    = 1                  --int      神兵上次暴击    									
end

--刷新来自服务器的数据
function WeaponBData:refreshDatasByService( data )
	self.nWeaponId          = data.i    or self.nWeaponId           --Integer  神兵id
	self.nWeaponLv          = data.l    or self.nWeaponLv           --Integer  神兵等级
	self.nProgress          = data.p    or self.nProgress           --Integer  神兵升级进度
	self.nCritical          = data.c    or self.nCritical           --Integer  神兵升级暴击
	self.nAdvanceLv         = data.s    or self.nAdvanceLv          --Integer  神兵阶数
	self.nAdvanceCnt        = data.e    or self.nAdvanceCnt         --Integer  神兵进阶段位数
	self.nBuildCD           = data.mcd                              --Long     神兵打造CD
	self.nAdvanceCD         = data.acd                              --Long     神兵进阶CD
	self.nExtraBj           = data.ec                               --Integer  神兵额外暴击[没有额外暴击,这个字段不会下发]
	self.nExtraCD           = data.ecd                              --Long     神兵额外暴击生效CD[没有额外暴击,这个字段不会下发]

	if data.mcd and data.mcd > 0 then
		self.nBuildLastLoadTime = getSystemTime()  --最后加载时间
	end
	if data.acd and data.acd > 0 then
		self.nAdvLastLoadTime = getSystemTime()    --最后加载时间
	end
	if data.ecd and data.ecd > 0 then
		self.nExtraBjLastLoad = getSystemTime()
	end
end

--记录上次的数据
function WeaponBData:setPreData(_nLv, _nAd, _nCri)
	-- body
	self.nPreLv = _nLv
	self.nPreAdLv = _nAd
	self.nPreCritical = _nCri
end

--配表数据
function WeaponBData:initDatasByDB( data )
	self.nId 				= data.id or self.nId						--int	  神兵id
	self.sName 				= data.name or self.sName 					--string  神兵名称
	self.nMakeLv   			= data.makelv or self.nMakeLv 				--int     打造所需等级
	self.sBuyCosts 		    = data.buycosts or self.sBuyCosts			--string  购买碎片花费
	self.nNeedFra 			= data.fragments or self.nNeedFra			--int     打造所需碎片数量
	self.nQuality 		    = data.quality or self.nQuality				--int     神兵品质
	self.sIcon              = data.icon or self.sIcon                   --string  神兵icon
	self.sFraIcon           = data.fragment or self.sFraIcon            --string  碎片icon
	self.sFragDesc          = data.fragdesc or self.sFragDesc           --string  碎片描述
    self.nOpenFb            = data.open or self.nOpenFb                 --int     通关副本关卡id
    self.nJumpFb            = data.jump or self.nJumpFb                 --int     跳转副本章节id   

	if data.icon then
		self.sIcon          = "ui/weapon/"..data.icon..".png"   --str 关卡icon
	end
	if data.fragment then
		self.sFraIcon       = "#"..data.fragment..".png"  --str 关卡icon
	end

end




return WeaponBData
