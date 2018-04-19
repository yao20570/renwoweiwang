-- Author: liangzhaowei
-- Date: 2017-04-27 19:35:39
-- Description: NPC 属性
-----------------------------------------------------
local Goods = require("app.data.Goods")

--npc类型,默认为npc
--en_npc_tpye.parent
en_npc_tpye = {
	parent = 1, --默认为npc父类
	wall = 2, --城墙守卫
}

local Npc = class("Npc", Goods)

function Npc:ctor(  )
	Npc.super.ctor(self,e_type_goods.type_npc)
	self:myInit()
end



function Npc:myInit()
	self.nId           =   0 --ID   
	self.sName         =   "" --武将名称     
	self.sIcon         =   "ui/daitu.png" --武将图标     
	self.sBossImg      =   "ui/daitu.png" --bossNpc特有图标     
	self.sEffects      =   "" --特技ID        
	self.nKind         =   0 --兵种类型     
	self.nQuality      =   0 --品质        
	self.nPhalanx      =   0 --方阵数        
	self.nLevel        =   0 --等级      
	self.nAtk          =   0 --攻击    
	self.nDef          =   0 --防御    
	self.nTroops       =   0 --兵力       
	self.nHit          =   0 --命中    
	self.nDodge        =   0 --闪避      
	self.nCrit         =   0 --暴击     
	self.nTenacity     =   0 --韧性         
	self.nStrongAtk    =   0 --强攻          
	self.nStrongDef    =   0 --强防          
	self.nSiege        =   0 --攻城      
	self.nDefCity      =   0 --守城  


	--城墙守卫数据

end

-- 用配置表DB中的数据来重置基础数据
function Npc:initDatasByDB( _tData )
	if (not _tData) then
		return 
	end

	self.sTid          =    _tData.id       or self.sTid        --ID   
	self.nId           =    _tData.id        or self.nId        --ID   
	self.sName         =    _tData.name      or self.sName      --武将名称  
	if _tData.icon then
	  self.sIcon = "#".. _tData.icon ..".png"
    end   
    if _tData.img then
    	self.sImg	   =    _tData.img 				            --武将形象
    end

    if _tData.bossimg then
    	self.sBossImg	   =   "ui/hero_boss/".._tData.bossimg..".jpg" 				            --bossNpc特有图标  
    end



		               

	self.nEffects      =    _tData.effects   or self.nEffects   --特技ID        
	self.nKind         =    _tData.kind      or self.nKind      --兵种类型     
	self.nQuality      =    _tData.quality   or self.nQuality   --品质        
	self.nPhalanx      =    _tData.phalanx   or self.nPhalanx   --方阵数        
	self.nLevel        =    _tData.level     or self.nLevel     --等级      
	self.nAtk          =    _tData.atk       or self.nAtk       --攻击    
	self.nDef          =    _tData.def       or self.nDef       --防御    
	self.nTroops       =    _tData.troops    or self.nTroops    --兵力       
	self.nHit          =    _tData.hit       or self.nHit       --命中    
	self.nDodge        =    _tData.dodge     or self.nDodge     --闪避      
	self.nCrit         =    _tData.crit      or self.nCrit      --暴击     
	self.nTenacity     =    _tData.tenacity  or self.nTenacity  --韧性         
	self.nStrongAtk    =    _tData.strongAtk or self.nStrongAtk --强攻          
	self.nStrongDef    =    _tData.strongDef or self.nStrongDef --强防          
	self.nSiege        =    _tData.siege     or self.nSiege     --攻城      
	self.nDefCity      =    _tData.defCity   or self.nDefCity   --守城        
	
end

-- 根据服务器刷新属性数据
function Npc:updateData( _tData )
	if (not _tData) then
		return 
	end

end




return Npc

