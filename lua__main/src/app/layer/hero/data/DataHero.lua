--
-- Author: liangzhaowei
-- Date: 2017-04-21 10:29:04
-- 英雄基础数据

local Goods = require("app.data.Goods")


local DataHero = class("DataHero", Goods)

--兵种类型
--en_soldier_type.sowar
en_soldier_type = {
	infantry =1, --步将
	sowar    =2, --骑将
	archer   =3, --弓将
}

e_hero_team_type = {
	normal = 1, --上阵武将
	collect = 2, --采集
	walldef = 3, --城防
	selfchoose = 4, --自选
	arena = 5,
}

--星魂状态
e_hero_soul_state = {
	opened = 1,  --已解锁或当前是需要突破状态
	actived = 2  --已激活或当前是需要激活状态
}

function DataHero:ctor(  )
	DataHero.super.ctor(self,e_type_goods.type_hero)
	self:myInit()
end

function DataHero:myInit(  )

	--配表属性
	self.nKey	                 =  0  --    武将唯一标识	    
	self.sName	                 =  "" --    武将名称	    
	self.sIcon	                 =  "ui/daitu.png" --    头像	        
	self.sImg	                 =  "ui/daitu.png" --    武将形象	        
	self.nType	                 =  0  --    物品类型	    
	self.nQuality	             =  0  --    品质	            
	self.nKind	                 =  0  --    兵种	   
	self.nStar	                 =  0  --    星级	   
	self.nBaseTalentSum	         =  0  --    初始总资质	    
	self.nBaseTalentAtk	         =  0  --    基础攻资质	    
	self.nBaseTalentDef	         =  0  --    基础防资质	    
	self.nBaseTalentTrp	         =  0  --    基础兵资质	    
	self.nInitTrainTalentAtk	 =  0  --    初始培养攻资质	    
	self.nInitTrainTalentDef	 =  0  --    初始培养防资质	    
	self.nInitTrainTalentTrp	 =  0  --    初始培养兵资质	    
	self.nTalentLimitSum	     =  0  --    资质上限	        
	self.nTalentLimitAtk	     =  0  --    攻上限	            
	self.nTalentLimitDef	     =  0  --    防上限	            
	self.nTalentLimitTrp	     =  0  --    兵上限	            
	self.sInitAttrs	             =  "" --    初始属性	    
	self.sDes                    =  "" --    武将描述  
	self.nIsAppear               =  "" --    是否显示 (只对将军府的显示列表做限制)  
	self.sAppear               	 =  "" --    武将的对话
	self.nCategory 				 =  0  -- 	 武将类别(几星)
	self.tSoulActAttrs 			 = {}  --星魂属性
	self.tSoulBreakAttrs 		 = {}  --星魂突破属性

	--服务器数据
	self.nId                     =  0 --英雄ID
	self.nT                      =  0 --Integer	英雄模板Id
	self.nLv                     =  1 --英雄等级
	self.nE                      =  0 --当前经验
	self.nTa                     =  0 --攻资质
	self.nTd                     =  0 --防资质
	self.nTr                     =  0 --兵资质
	self.nP                      =  0 --上阵位置
	self.nCp                     =  0 --采集队列位置
	self.nDp                     =  0 --城防队列位置
	self.nS 					 =  0 --耐力值
	self.nLt                     =  0 --统领兵力数
	self.nW                      =  0 --武将出征中? 0否 1是
	self.tAa                     =  {}--武将附加属性(其他系统加成)          
	self.nPh                     =  1 --Integer		武将方阵数
	self.nAp    				 =	0 --武将进阶进度条
	self.nIg					 =  0 --武将是否神级进阶 0否 1是
	self.nBlood					 =  nil --武将血量(过关斩将用)
	self.tSoulList				 =  {} --武将星魂列表
	self.tSoulDic				 =  {} --武将星魂字典
	self.tSoulBreakList			 =  {} --武将星魂突破列表
	self.tSoulBreakDic 			 =  {} --武将星魂突破字典
	--自定义数据
	self.tAttList                = {}  --    基础属性列表
	self.tAttDict                = {}  --    属性字典
	self.nHave                   = 0 -- 拥有状态 0为 没有拥有 1为已拥有
	self.tSoulStar 				 = {nSolidNum = 0, nHollowNum = 0} --星魂星星个数表(实心和空心个数)

	self.nNailiFillCd            = 0
end

-- 用配置表DB中的数据来重置基础数据
function DataHero:initDatasByDB( _tData )
	if (not _tData) then
		return 
	end
	-- self.nId	                =          _tData.id	              or  self.nId	                  --   武将id	
	-- self.sTid    =  self.nId --goods通用id
	self.nKey	                =          _tData.key	              or  self.nKey	                  --    武将唯一(相同武将)标识	               
	self.sName	                =          _tData.name	              or  self.sName	              --    武将名称	                   
	if _tData.icon then
		self.sIcon	            =          "#".._tData.icon..".png"
	end
	self.sImg	                =          _tData.img 				                  --    武将形象	               
	self.nType	                =          _tData.type	              or  self.nType	
	self.nStar	                =          _tData.star	              or  self.nStar                  --    星级	                   
	self.nQuality	            =          _tData.quality	          or  self.nQuality	              --    品质	                   
	self.nKind	                =          _tData.kind	              or  self.nKind	                  --    兵种	                   
	self.nBaseTalentSum	        =          _tData.basetalentsum	      or  self.nBaseTalentSum	          --    初始总资质	                           
	self.nBaseTalentAtk	        =          _tData.basetalentatk	      or  self.nBaseTalentAtk	          --    基础攻资质	                           
	self.nBaseTalentDef	        =          _tData.basetalentdef	      or  self.nBaseTalentDef	          --    基础防资质	                           
	self.nBaseTalentTrp	        =          _tData.basetalenttrp	      or  self.nBaseTalentTrp	          --    基础兵资质	                           
	self.nInitTrainTalentAtk    =          _tData.inittraintalentatk  or  self.nInitTrainTalentAtk	   --    初始培养攻资质	                               
	self.nInitTrainTalentDef    =          _tData.inittraintalentdef  or  self.nInitTrainTalentDef	   --    初始培养防资质	                               
	self.nInitTrainTalentTrp    =          _tData.inittraintalenttrp  or  self.nInitTrainTalentTrp	   --    初始培养兵资质	                               
	self.nTalentLimitSum	    =          _tData.talentlimitsum	  or  self.nTalentLimitSum	      --    资质上限	                           
	self.nTalentLimitAtk	    =          _tData.talentlimitatk	  or  self.nTalentLimitAtk	      --    攻上限	                           
	self.nTalentLimitDef	    =          _tData.talentlimitdef	  or  self.nTalentLimitDef	      --    防上限	                           
	self.nTalentLimitTrp	    =          _tData.talentlimittrp	  or  self.nTalentLimitTrp	      --    兵上限	  	                        
	self.nIsAppear	            =          _tData.isappear	          or  self.nIsAppear    	      --    是否显示 (只对将军府的显示列表做限制)   
	self.sAppear				= 		   _tData.appear 			  or  self.sAppear 					--武将对话                         
	-- self.sInitAttrs	            =          _tData.initattrs	          or  self.sInitAttrs	              --    初始属性	                       
	self.sDes                   =          _tData.desc                or  self.sDes                     --    武将描述               
	self.sCut                   =          _tData.cut                 or  self.sCut
	self.nCategory 				=		   _tData.category 		 	  or  self.nCategory			    --武将类别
	self.tSoulActAttrs 			=	self:getSoulActAttrs(_tData.soulactattrs) or  self.tSoulActAttrs	--星魂属性
	self.tSoulBreakAttrs		=	self:getSoulBreakAttrs(_tData.soulbreakattrs) or self.tSoulBreakAttrs	--星魂突破属性

	if self.nTa == 0 then
		self.nTa     				=  		   self.nBaseTalentAtk + self.nInitTrainTalentAtk 			--攻资质				
	end
	if self.nTd == 0 then
		self.nTd     				=  		   self.nBaseTalentDef + self.nInitTrainTalentDef 			--防资质
	end
	if self.nTr == 0 then
		self.nTr     				=  		   self.nBaseTalentTrp + self.nInitTrainTalentTrp 			--兵资质
	end

	--初始化基础属性
	if _tData.initattrs then
		self:initAttBaseValues(_tData.initattrs)
	end
end
	
-- 根据模板重新赋值	
function DataHero:refreshBaseDataByT(_tId)
	if not _tId then
		return
	end

	local tData = getHeroTableDataById(_tId)
	if not tData then
		return
	end
 	self:initDatasByDB(tData)
end

-- 刷新英雄数据
function DataHero:refreshDatasByService( _tData )
	if (not _tData) then
		return 
	end
	self.nId    			 =  _tData.h   or    self.nId  --Integer	英雄ID
	self.sTid   			 =  self.nId
	self.nLv    			 =  _tData.l    or    self.nLv  --Integer	英雄等级
	self.nE     			 =  _tData.e    or    self.nE  --Long	当前经验
	self.nTa    			 =  _tData.ta   or    self.nTa   --Integer	攻资质
	self.nTd    			 =  _tData.td   or    self.nTd   --Integer	防资质
	self.nTr    			 =  _tData.tr   or    self.nTr   --Integer	兵资质
	self.nP     			 =  _tData.p    or    self.nP  	--Integer	上阵位置
	self.nCp    			 =  _tData.cp   or    self.nCp 	--采集队列位置
	self.nDp    			 =  _tData.dp   or    self.nDp 	--城防队列位置
	self.nS 				 =  _tData.s    or    self.nS 	--耐力值
	self.nSc    			 =  _tData.sc   or    self.nSc  --Integer	战斗力
	self.nLt    			 =  _tData.lt   or    self.nLt   --Integer	统领兵力数
	self.nW     			 =  _tData.w    or    self.nW  --Integer	武将出征中? 0否 1是
	self.nPh    			 =  _tData.ph   or    self.nPh  --Integer	武将方阵数
	self.nAp    			 =  _tData.ap   or    self.nAp  --Integer   武将进阶进度条
	self.tAa    			 =  _tData.aa   or    self.tAa   --AttributesVo	武将附加属性(其他系统加成)
	self.nIg				 =  _tData.ig   or    self.nIg   --武将是否神级进阶 0否 1是
	self.tSoulList			 =  _tData.sl   or    self.tSoulList  		--武将星魂列表
	self.tSoulBreakList		 =  _tData.sb   or    self.tSoulBreakList   --武将星魂突破列表
	self.nBlood				 =  _tData.bloor or   self.nBlood 			--武将血量/兵力(过关斩将用)

	if _tData.sl then
		--排序: 阶段>格子(按从小到大排序)
		table.sort(self.tSoulList, function(a, b)
			if a.st == b.st then
				return a.pos < b.pos
			else
				return a.st < b.st
			end
		end)
		self.tSoulDic = {}
		for k, v in pairs(self.tSoulList) do
			if not self.tSoulDic[v.st] then
				self.tSoulDic[v.st] = {}
			end
			self.tSoulDic[v.st][v.pos] = v.zt --状态(1:已解锁, 2:已激活)
		end
	end

	if _tData.sb then
		table.sort(self.tSoulBreakList, function(a, b)
			return a.k < b.k
		end)
		self.tSoulBreakDic = {}
		for k, v in pairs(self.tSoulBreakList) do
			self.tSoulBreakDic[v.k] = v.v --状态(1:可突破, 2:已突破)
		end
	end
	--刷新星魂星星个数
	self:refreshSoulStarNum()

	if _tData.t == 0 then
		self.nT      =  _tData.t   or    self.nT  --Integer	英雄模板Id
	else 
		if _tData.t then
			if self.nT ~= _tData.t then
				self.nT = _tData.t
				self:refreshBaseDataByT(self.nT)
			end
		end
	end
	if _tData.ab then
		--刷新武将基础属性信息 
		self.tAb = _tData.ab --AttributesVo	武将基础属性
		self:refreshAttInfo(_tData.ab.ats)
	end

	if _tData.aa then 
		self.tAa = _tData.aa
		self:refreshAttInfoEx(_tData.aa.ats) --刷新武将的额外属性
	end
	if _tData.sa then
		self.tSa = _tData.sa
		self:refreshAttInfoSoul(_tData.sa.ats) --刷新星魂增加的属性
	end
	-- dump(_tData,"英雄数据",30)
end

-- 初始化属性值
-- DataHero: 基础属性值
function DataHero:initAttBaseValues( _sBaseAtt )
	if (not _sBaseAtt) then
		return 
	end	
	--100:100;101:50;102:1;103:1;104:1;105:0.5;106:150;107:100;108:50;109:100;110:50
	-- 初始化基础属性值
	self.tAttList = {}
	local tAtts = luaSplit(_sBaseAtt, ";")
	local nIndex = 1
	for k,v in pairs(tAtts or {}) do
		local tAttValues = luaSplit(v or "", ":")
		if (tAttValues and table.nums(tAttValues) >= 2) then
			local pAtt = getBaseAttData(tAttValues[1])
			if (pAtt) then								
				pAtt:refreshDbBalFromDB(tonumber(tAttValues[2]))
				self.tAttList[nIndex] = pAtt
				nIndex = nIndex + 1
			end
		end
	end	
	table.sort(self.tAttList, function ( a, b )
		return a.nId < b.nId
	end)
	self:initAttrDict()
end

--初始化属性字典
function DataHero:initAttrDict( )
	--字典，提高效率
	self.tAttDict = nil
	self.tAttDict = {}
	for i=1,#self.tAttList do
		local nId = self.tAttList[i].nId
		self.tAttDict[nId] = self.tAttList[i]
	end
end

--刷新武将属性值
function DataHero:refreshAttInfo(_tData)
	if (not _tData) or (table.nums(_tData)<1)  then
		return
	end
	for k,v in pairs(self.tAttList) do
		v:setVal(0)
		for x,y in pairs(_tData) do
			if y.k == v.nId then
				v:refreshDatasByService(y)
			end
		end
	end
end

--刷新武将的额外属性
function DataHero:refreshAttInfoEx(_tData)
	if (not _tData) then
		return
	end

	--因为服务端过来的数据,每次下发都需要把额外属性都清理掉
	-- if table.nums(_tData)== 0 then
		local tData = {}
		tData.v = 0
		for k,v in pairs(self.tAttList) do
			v:refreshExData(tData)

			-- for x,y in pairs(_tData) do
			-- 	v:refreshExData(0)
			-- end
		end
	-- else
		
		-- for k,v in pairs(self.tAttList) do
		-- 	for x,y in pairs(_tData) do
		-- 		if y.k == v.nId then
		-- 			v:refreshExData(y)
		-- 		end
		-- 	end
		-- end

		--新加入的属性表
		local tNewAttr = {}
		--刷新值
		for k, tServerData in pairs(_tData) do
			local nId = tServerData.k
			local tHeroAttr = self.tAttDict[nId]
			if tHeroAttr then
				tHeroAttr:refreshExData(tServerData)
			else
				table.insert(tNewAttr, tServerData)
			end
		end
		--添加加入的属性值，并排序, 并重置属性字典
		if #tNewAttr > 0 then
			for i=1, #tNewAttr do
				local tServerData = tNewAttr[i]
				local nId = tServerData.k
				local nValue = tServerData.v
				local pAtt = getBaseAttData(nId)
				if (pAtt) then								
					pAtt:refreshDbBalFromDB(0)
					pAtt:refreshExData(tServerData)
					table.insert(self.tAttList, pAtt)
				end
			end
			--
			table.sort(self.tAttList, function ( a, b )
				return a.nId < b.nId
			end)
			self:initAttrDict()
		end

	-- end

	------


end


--获得武将现在的总资质 攻 + 防 + 兵
function DataHero:getNowTotalTalent()
	local nTotal = 0

	nTotal = self.nTa + self.nTd + self.nTr
	if nTotal< self.nBaseTalentSum then
		nTotal = self.nBaseTalentSum
	end
	return nTotal
end

--获得武将基础总资质 基础 攻 + 防 + 兵
function DataHero:getBaseTotalTalent()
	local nTotal = 0

	nTotal = self.nBaseTalentAtk + self.nBaseTalentDef + self.nBaseTalentTrp

	return nTotal
end

--获得武将所有基础资质
function DataHero:getTotalBaseTalent()
	local nTalent = 0
	nTalent = nTalent + self.nBaseTalentAtk
	nTalent = nTalent + self.nBaseTalentDef
	nTalent = nTalent + self.nBaseTalentTrp
	nTalent = nTalent + self.nInitTrainTalentAtk
	nTalent = nTalent + self.nInitTrainTalentDef
	nTalent = nTalent + self.nInitTrainTalentTrp
	return  nTalent
end

--获得基础攻和基础培养攻之和
function DataHero:getBTTalentAtk()
	return self.nBaseTalentAtk + self.nInitTrainTalentAtk
end

--获得基础防和基础培养防之和
function DataHero:getBTTalentDef()
	return self.nBaseTalentDef + self.nInitTrainTalentDef
end

--获得基础兵和基础培养兵之和
function DataHero:getBTTalentTrp()
	return self.nBaseTalentTrp + self.nInitTrainTalentTrp
end

--获取额外资质
function DataHero:getExTotalTalent()
	local nTotal = 0

	--总资质 减去 基础总资质
	nTotal = self:getNowTotalTalent() -self:getBaseTotalTalent()
	if nTotal < 0 then
		nTotal = 0
	end

	return nTotal
end

--获取额外攻资质
function DataHero:getExAtkTalent()
	if self.nTa > 0 then
		return self.nTa - self:getBTTalentAtk()
	end
	return 0
end

--获取额外防资质
function DataHero:getExDefTalent()
	if self.nTd > 0 then
		return self.nTd - self:getBTTalentDef()
	end
	return 0
end

--获取额外兵资质
function DataHero:getExTrpTalent()
	if self.nTr > 0 then
		return self.nTr - self:getBTTalentTrp()
	end
	return 0
end

--根据获取当前等级所有经验的总和
function DataHero:getLastLvAllExp(_nLv)
	local nExp = 1
	local nGetLv = _nLv - 1
	if nGetLv <= 0 then
		return 1
	end
	for i=1,nGetLv do
		local nEp = self:getLvExpByLv(i) 
		nExp = nExp + nEp
	end	
	return nExp
end

--根据等级获得升级所需要的经验
function DataHero:getLvExpByLv(_nLv)
	-- body
	local nExp = 0
	local tExpList = getHeroExpDataByLv(_nLv) --获取当前等级的经验
	if self.nQuality == 1 then
		nExp =  tExpList.exp1
	elseif self.nQuality == 2 then
		nExp =  tExpList.exp2
	elseif self.nQuality == 3 then
		nExp =  tExpList.exp3
	elseif self.nQuality == 4 then
		nExp =  tExpList.exp4
	elseif self.nQuality == 5 then
		nExp =  tExpList.exp5
	elseif self.nQuality == 6 then
		nExp =  tExpList.exp6
	elseif self.nQuality == 7 then
		nExp =  tExpList.exp7
	end
	nExp  = tonumber(nExp)
	return nExp 
end

--获取当前总的属性值  _nPropertyType 属性id
function DataHero:getProperty( _nPropertyType )
	local nProperty = 0
	local tData = self.tAttDict[_nPropertyType]
	if tData then
		nProperty = tData:getTotalVal()
	end
	return nProperty
end


--获得当前最大兵力(不用这个，用getTroopsMax)
function DataHero:getMaxBingLi()
	-- local nProperty = 0
	-- for k,v in pairs(self.tAttList) do
	-- 	if v.nId ==e_id_hero_att.bingli  then
	-- 		nProperty = v:getTotalVal()
	-- 	end
	-- end
	-- return nProperty
	return self:getTroopsMax()
end

--根据属性id获取属性结构体
function DataHero:getPropertyById(_nId)
	local tPro = {}
	for k,v in pairs(self.tAttList) do
		if v.nId ==_nId  then
			tPro = v
			break
		end
	end
	return tPro
end

--升级红点
function DataHero:getUpDateRedNums()
	local nRedNums = 0 --红点个数
	local nNums = 0 --经验丹个数
	local bEnough = false --是否达到升级红点条件

	for i=1,3 do
		nNums = nNums + getMyGoodsCnt(e_id_item.expItemS-1+i) --拥有该物品的个数
	end

	if self.nLv < Player:getPlayerInfo().nLv then
		if nNums > 0 then
			bEnough = true
		end
	end

	if bEnough then
		nRedNums = 1
	else
		nRedNums = 0
	end

	return nRedNums
end

--获取英雄兵种图片 nType (2为较大的类型,3是纯白的标志)
function DataHero:getHeroKindImg(_nType)
	-- body
	local strImg = "ui/daitu"
	local nType = _nType  or 1

		--显示兵种
	if self.nKind == en_soldier_type.infantry then --部将
		if nType == 1 then
			strImg = "#v1_img_bujiang02.png"
		elseif nType == 2 then
			strImg = "#v1_img_bujiang02b.png"
		elseif nType == 3 then
			strImg = "#v2_img_bu.png"
		end

	elseif self.nKind == en_soldier_type.sowar then --骑将
		if nType == 1 then
			strImg = "#v1_img_qibing02b.png"
		elseif nType == 2 then
			strImg = "#v1_img_qibing02bb.png"
		elseif nType == 3 then
			strImg = "#v2_img_qi.png"
		end		
	elseif self.nKind == en_soldier_type.archer then --弓将
		if nType == 1 then
			strImg = "#v1_img_gongjiang02.png"
		elseif nType == 2 then
			strImg = "#v1_img_gongjiang02b.png"
		elseif nType == 3 then
			strImg = "#v2_img_gong.png"
		end			
	end

	return strImg
end

--获取英雄兵种类型名称
function DataHero:getHeroTypeName()
	local sTypeName = "" --显示兵种
	if self.nKind == en_soldier_type.infantry then --部将
		sTypeName= getConvertedStr(5, 10266)
	elseif self.nKind == en_soldier_type.sowar then --骑将
		sTypeName= getConvertedStr(5, 10267)
	elseif self.nKind == en_soldier_type.archer then --弓将
		sTypeName= getConvertedStr(5, 10268)		
	end
	return sTypeName
end

--获取英雄品质颜色文字
function DataHero:getHeroQualityText()
	local str = ""
	str= getConvertedStr(5, 10269+self.nQuality -1)
	return str 
end

--根据当前等级获得对应的基础属性值(仅作升级提示用显示,以后端为准) (裸属性)
function DataHero:getBasePropertyByAndLv(_nType,_nLv)
	local nType = _nType +0
	local nLv = _nLv + 0
	local nValue = 0
	--星魂增加的基础属性值(攻击防御和兵力)
	local nAtkAdd, nDefAdd, nBingliAdd = self:getAttInfoSoulAdd()
	--获取星魂突破增加的属性比(攻击防御和兵力)
	local fAtkAdd, fDefAdd, fBingliAdd = self:getAttSoulAddPer()
	if nType == e_id_hero_att.gongji  then
		if nLv > 100 then
			nLv = 100
		end
		nValue = self:getPropertyById(e_id_hero_att.gongji).nDbBal + 
		math.floor(self.nTa*nLv*tonumber(getHeroInitData("atkRatio")))

		nValue = (nValue + nAtkAdd) * (1 + fAtkAdd)
	elseif nType == e_id_hero_att.fangyu then
		if nLv > 100 then
			nLv = 100
		end
		nValue = self:getPropertyById(e_id_hero_att.fangyu).nDbBal +
		math.floor(self.nTd*nLv*tonumber(getHeroInitData("defRatio")))

		nValue = (nValue + nDefAdd) * (1 + fDefAdd)
	elseif nType == e_id_hero_att.bingli then
		if nLv > 100 then
			local nAdd = 0
			if self.nIg == 1 then
				nAdd = tonumber(getHeroInitData("godTrpAdd"))
			else
				nAdd = tonumber(getHeroInitData("trpAdd"))
			end
			if not nAdd then
				nAdd = 0
			end

		   nValue = self:getPropertyById(e_id_hero_att.bingli).nDbBal + 
		   math.floor(self.nTr*100*tonumber(getHeroInitData("trpRatio")))
		   nValue = nValue + (nLv - 100)*nAdd
		else
		   nValue = self:getPropertyById(e_id_hero_att.bingli).nDbBal  +
		   math.floor(self.nTr*nLv*tonumber(getHeroInitData("trpRatio")))
		end

		nValue = (nValue + nBingliAdd) * (1 + fBingliAdd)
	end

	return nValue
end

--英雄等级是否满足进阶
function DataHero:getAdvanceCondition()
	--主公开启条件
	local nLv = tonumber(getHeroInitData("openAdvanceLv"))
	local nLvFit = true	 --主公等级条件是否满足
	if nLv > Player:getPlayerInfo().nLv then
		nLvFit = false
	end
	--武将开启
	local nHeroLv = nil
	local nHeroLvFit = true	--条件武将等级是否满足
	local nAdvanceLv = nil
	local tInfo = nil
	local t = luaSplit(getHeroInitData("AdvLvLimit"), ";")
	--蓝色
 	if self.nQuality == 3 then
 		tInfo = luaSplit(t[1], ":")
	--紫色
	elseif self.nQuality == 4 then
		tInfo = luaSplit(t[2], ":")
	--橙色
	elseif self.nQuality == 5 then
		tInfo = luaSplit(t[3], ":")
	--红色
	elseif self.nQuality == 6 then
		nHeroLv = tonumber(getHeroInitData("godAdvLv"))
		tInfo = {4, nHeroLv}
	end
	if tInfo then
		nHeroLv = tInfo[2]
		nAdvanceLv = tInfo[1]
	end
	if not nHeroLv then
		return false
	end
	if tonumber(nHeroLv) > self.nLv then
		nHeroLvFit = false
	end
	return {nLv, nLvFit}, {nHeroLv, nHeroLvFit, nAdvanceLv}
end

--
function DataHero:advanceRedNum()
	if self.nAp > 0 then
		return true
	end
	if self:canAdvance() then
		local bHavedShow = getLocalInfo(string.format("%s_%s_advanceRN",self.nQuality, self.nId), "true")
		--还没展示过红点
		if bHavedShow == "true" then
			return true
		else
			return false
		end
	else
		return false
	end
end

function DataHero:recordAdvanceRedNum()
	local bHavedShow = getLocalInfo(string.format("%s_%s_advanceRN",self.nQuality, self.nId), "true")
	--只有红点展示过才会置为不显示了
	if bHavedShow == "true" and  self:advanceRedNum() then
		saveLocalInfo(string.format("%s_%s_advanceRN",self.nQuality, self.nId), "false") 
		sendMsg(ghd_advance_hero_rednum_update_msg,{})
	end
end

--是否满足所有进阶条件
function DataHero:canAdvance()
	local nLvFit, nHeroLvFit = self:getAdvanceCondition()
	
	if not nLvFit then
		return false
	end

	if not nLvFit[2] or not nHeroLvFit[2] then
		return false
	end

	--品质是否满足
	if (self.nQuality > 2 and self.nQuality < 6) 
			or (self.nQuality == 6 and self.nIg == 0) then
		--神级进阶
		if self.nQuality == 6 then
			local tEquipVos = Player:getEquipData():getEquipVosByKindInHero(self.nId)
			if #tEquipVos == 0 then
				return false
			end
			for i=1, #tEquipVos do
				local tEquipVo = tEquipVos[i]
				if tEquipVo then
					--是否是4星装备
					if tEquipVo:getSolidStarNum() < 4 then
						return false
					end
					--装备是否拥有对应的属性
					if i <= 2 then
						nAttr = e_id_hero_att.gongji
					elseif i <= 4 then
						nAttr = e_id_hero_att.fangyu
					elseif i <= 6 then
						nAttr = e_id_hero_att.bingli
					end
					if not tEquipVo.tTrainAtbVos[1] 
							or tEquipVo.tTrainAtbVos[1].nAttrId ~= nAttr then
						return false
					end
				else
					return false
				end
			end
			return true
		else
			local nGoodsId = tonumber(getHeroInitData("transId"))
			local nCt = getMyGoodsCnt(nGoodsId)
			local nNeed = self.getAdvanceNeed()
			if nNeed > nCt then
				return false
			else
				return true
			end
		end
	else
		return false
	end
end	

function DataHero:getFrameByQuality()
	local path = "#v2_img_gauqkapaibai.png"
	if self.nQuality == 1 then
		path = "#v2_img_gauqkapaibai.png"

	elseif self.nQuality == 2 then
		path = "#v2_img_gauqkapailv.png"

	elseif self.nQuality == 3 then
		path = "#v2_img_gauqkapailan.png"

	elseif self.nQuality == 4 then
		path = "#v2_img_gauqkapaizi.png"

	elseif self.nQuality == 5 then
		path = "#v2_img_gauqkapaicheng.png"

	elseif self.nQuality == 6 then
		path = "#v2_img_gauqkapaihong.png"

	end
	return path
end

--英雄截图信息
function DataHero:getCutInfo()
	if self.sCut then
		local tInfo = luaSplit(self.sCut, ";")
		local tPos = luaSplit(tInfo[1], ",")
		return {tonumber(tPos[1]), tonumber(tPos[2]), tonumber(tInfo[2])}
	else
		return nil
	end
end

function DataHero:getAdvanceNeed()
	return tonumber(luaSplit(getHeroInitData("advOneCosts"), ":")[2])
end

--获取武将进阶进度
function DataHero:getAp()
	return self.nAp
end

--获取武将进阶进度最大值
function DataHero:getApMax()
	local totalInfo = luaSplit(getHeroInitData("advTotalCosts"), ";")
	--蓝突破
	if self.nQuality == 3 then
		return luaSplit(totalInfo[1],":")[2]
	elseif self.nQuality == 4 then
		return luaSplit(totalInfo[2],":")[2]
	elseif self.nQuality == 5 then
		return luaSplit(totalInfo[3],":")[2]
	end
	return 0
end

--获取武将进阶进度百分比
function DataHero:getAdvanceProgress()
	if self.nQuality == 6 then
		return 100
	end
	local max = self:getApMax()
	return self.nAp/max*100
end

--获取总攻击力(攻击（100） + 攻击力百分比（501）)
function DataHero:getAtkMax( )
	-- local nProperty100 = 0
	-- local tData = self.tAttDict[e_id_hero_att.gongji]
	-- if tData then
	-- 	nProperty100 = tData:getTotalVal()
	-- end
	-- local nProperty500 = 0
	-- local tData = self.tAttDict[e_id_hero_att.gongjiper]
	-- if tData then
	-- 	nProperty500 = tData:getTotalVal()
	-- end
	-- return math.floor(nProperty100 * ( 1 + nProperty500))
	return self:getProperty(e_id_hero_att.gongji)
end

--获取攻击力luo
function DataHero:getAtkLuo( )
	return math.floor(self:getBasePropertyByAndLv(e_id_hero_att.gongji, self.nLv))
end

--获取总防御力(防御（101） + 防御百分比（501）)
function DataHero:getDefMax( )
	-- local nProperty101 = 0
	-- local tData = self.tAttDict[e_id_hero_att.fangyu]
	-- if tData then
	-- 	nProperty101 = tData:getTotalVal()
	-- end
	-- local nProperty501 = 0
	-- local tData = self.tAttDict[e_id_hero_att.fangyuper]
	-- if tData then
	-- 	nProperty501 = tData:getTotalVal()
	-- end
	-- return math.floor(nProperty101 * ( 1 + nProperty501))
	return self:getProperty(e_id_hero_att.fangyu)
end

--获取防御力luo
function DataHero:getDefLuo( )
	return math.floor(self:getBasePropertyByAndLv(e_id_hero_att.fangyu, self.nLv))
end

--获取总兵力(兵力 (102) + 兵力百分比( 502)) --带buff属性
function DataHero:getTroopsMax( )
	-- local nProperty102 = 0
	-- local tData = self.tAttDict[e_id_hero_att.bingli]
	-- if tData then
	-- 	nProperty102 = tData:getTotalVal()
	-- end
	-- local nProperty502 = 0
	-- local tData = self.tAttDict[e_id_hero_att.bingliper]
	-- if tData then
	-- 	nProperty502 = tData:getTotalVal()
	-- end
	-- return math.floor(nProperty102 * ( 1 + nProperty502))
	return self:getProperty(e_id_hero_att.bingli)
end

--获取兵力luo
function DataHero:getTroopsLuo( )
	return math.floor(self:getBasePropertyByAndLv(e_id_hero_att.bingli, self.nLv))
end


--获取城防耐力值
function DataHero:getWalldefStamina( )
	return self.nS
end

--获取城防耐力值的倒计时
function DataHero:getWalldefStaminaCd( )
	--1分钟cd时间
	local nNailiFillCd = 0
	local pBChiefData = Player:getBuildData():getBuildById(e_build_ids.tcf)
    if pBChiefData then
        nNailiFillCd = pBChiefData:getNailiFillCd()
    end
    -- print("nNailiFillCd==========",nNailiFillCd)
    --最大值
	local nTroopsMax = self:getProperty(e_id_hero_att.bingli)
	local nCurrTroops = self:getWalldefStamina()
	local nSubTroops = math.max(nTroopsMax - nCurrTroops, 0)
	local nNeedCd = 0
	local nRecover = tonumber(getBuildParam("recover")) or 1
	local nNeedCd = math.floor(nSubTroops/nRecover) * 60
	return nNeedCd + nNailiFillCd
end

--获取城防耐力值发花
function DataHero:getWalldefRecoverCost( )
	local nTroopsMax = self:getProperty(e_id_hero_att.bingli)
	local nCurrTroops = self:getWalldefStamina()
	return math.ceil(math.ceil((nTroopsMax - nCurrTroops)/ tonumber(getBuildParam("recover"))) * tonumber(getBuildParam("recoverCost")))
end

--获取是不是采集队列
function DataHero:getIsCollectQueue(  )
	return self.nCp and self.nCp > 0 
end

--获取是不是城防队列
function DataHero:getIsDefenceQueue(  )
	return self.nDp and self.nDp > 0 
end

------------------------------------------武将星魂---------------------------------------

--武将星魂是否可激活或可突破
function DataHero:getSoulIsCanActivateOrBreak()
	--是否满星魂(是否突破所有星魂阶段)
	local bIsFull = self:isFullStage()
	if bIsFull then
		return false
	end
	local n = table.nums(self.tSoulList)
	local tStageData = self.tSoulList[n]
	if tStageData == nil then
		return false
	end
	local nActionType = 1
	local nMaxStage = table.nums(self.tSoulBreakAttrs)
	if n%10 == 1 or n/10 == nMaxStage then
		local tData = self.tSoulList[n-1]
		if tData and self.tSoulBreakDic[tData.st] == e_hero_soul_state.opened then
			tStageData = self.tSoulList[n-1]
			nActionType = 2
		end
	end
	local nStage = tStageData.st
	--获取星魂消耗
	local tAdvCost = self:getSoulCost(nStage)

	local bCanAdv = false
	if nActionType == 1 then
		local nCostId = tonumber(tAdvCost.tActivateCost[1])
		--当前拥有
		local nHasNum = getMyGoodsCnt(nCostId)
		--需要消耗
		local nNeedCostNum = tonumber(tAdvCost.tActivateCost[2])
		if nHasNum >= nNeedCostNum then
			bCanAdv = true
		end
		return bCanAdv
	elseif nActionType == 2 then --突破
		local nCostId = tonumber(tAdvCost.tBreakCost[1])
		--当前拥有
		local nHasNum = getMyGoodsCnt(nCostId)
		--需要消耗
		local nNeedCostNum = tonumber(tAdvCost.tBreakCost[2])
		if nHasNum >= nNeedCostNum then
			bCanAdv = true
		end
		if not bCanAdv then
			return false
		end
		--武将当前等级
		local nCurHeroLv = self.nLv
		--武将需求等级
		local nNeedHeroLv = tAdvCost.nNeedHeroLv
		if nCurHeroLv >= nNeedHeroLv then
			bCanAdv = true
		else
			bCanAdv = false
		end
	end

	return bCanAdv
end

--刷新星魂增加的属性(攻击、防御和兵力的增加值)
function DataHero:refreshAttInfoSoul(_tData)
	local nAtkAdd, nDefAdd, nBingliAdd = 0, 0, 0
	for k, v in pairs(_tData) do
		if v.k == e_id_hero_att.gongji then
			nAtkAdd = v.v
		elseif v.k == e_id_hero_att.fangyu then
			nDefAdd = v.v
		elseif v.k == e_id_hero_att.bingli then
			nBingliAdd = v.v
		end
	end
	self.nAtkAdd = nAtkAdd
	self.nDefAdd = nDefAdd
	self.nBingliAdd = nBingliAdd
end

--返回星魂增加的攻击、防御和兵力的增加值
function DataHero:getAttInfoSoulAdd()
	if self.nAtkAdd and self.nDefAdd and self.nBingliAdd then
		return self.nAtkAdd, self.nDefAdd, self.nBingliAdd
	else
		return 0, 0, 0
	end
end

--获取星魂突破增加的属性比(攻击防御和兵力)
function DataHero:getAttSoulAddPer()
	local fAtkAdd, fDefAdd, fBingliAdd = 0, 0, 0
	local nStage = 0
	for k, v in pairs(self.tSoulBreakList) do
		if v.v == e_hero_soul_state.actived then
			nStage = v.k
		end
	end
	if nStage > 0 then
		for k, v in pairs(self.tSoulBreakAttrs) do
			if k > nStage then
				break
			end
			if type(v[1]) == "table" then
				for i, j in pairs(v) do
					if tonumber(j[1]) == e_id_hero_att.gongji then
						fAtkAdd = fAtkAdd + tonumber(j[2])
					elseif tonumber(j[1]) == e_id_hero_att.fangyu then
						fDefAdd = fDefAdd + tonumber(j[2])
					elseif tonumber(j[1]) == e_id_hero_att.bingli then
						fBingliAdd = fBingliAdd + tonumber(j[2])
					end
				end
			else
				if tonumber(v[1]) == e_id_hero_att.gongji then
					fAtkAdd = fAtkAdd + tonumber(v[2])
				elseif tonumber(v[1]) == e_id_hero_att.fangyu then
					fDefAdd = fDefAdd + tonumber(v[2])
				elseif tonumber(v[1]) == e_id_hero_att.bingli then
					fBingliAdd = fBingliAdd + tonumber(v[2])
				end
			end
		end
	end
	return fAtkAdd, fDefAdd, fBingliAdd
end

--根据武将突破阶段获取星魂消耗
--_stage:阶段
function DataHero:getSoulCost(_stage)
	local tResult = {}
	local sSoulAdv = getHeroInitData("soulAdv")
	local tSoulAdv = luaSplitMuilt(sSoulAdv, "|", ",")
	tResult.nStage = tonumber(tSoulAdv[_stage][1])
	tResult.nNeedSoulNum = tonumber(tSoulAdv[_stage][2])
	tResult.nNeedHeroLv = tonumber(tSoulAdv[_stage][3])
	tResult.tBreakCost = luaSplit(tSoulAdv[_stage][4], ":")
	tResult.tActivateCost = luaSplit(tSoulAdv[_stage][5], ":")
	return tResult
end

--是否已突破所有星魂阶段(满级星魂)
function DataHero:isFullStage()
	--当前突破阶段
	local nCurStage = table.nums(self.tSoulBreakList)
	local nMaxStage = table.nums(self.tSoulBreakAttrs)
	if nCurStage >= nMaxStage and self.tSoulBreakDic[nCurStage] == e_hero_soul_state.actived then
		return true
	end
	return false
end

--刷新星魂星星个数
function DataHero:refreshSoulStarNum()
	--实心和空心个数(突破阶段数为实心个数, 阶段已激活但未突破为空心)
	local nSolidNum, nHollowNum = 0, 0
	for k, v in pairs(self.tSoulBreakList) do
		if v.v == e_hero_soul_state.actived then
			nSolidNum = nSolidNum + 1
		end
	end
	self.tSoulStar.nSolidNum = nSolidNum
	if self.tSoulDic[nSolidNum+1] then
		for k, v in pairs(self.tSoulDic[nSolidNum+1]) do
			if v == e_hero_soul_state.actived then
				nHollowNum = nHollowNum + 1
				break
			end
		end
	end
	self.tSoulStar.nHollowNum = nHollowNum
end

--解析星魂属性
function DataHero:getSoulActAttrs(_str)
	local tResult = {}
	local tParam = luaSplitMuilt(_str, "|", ";", ",", ":")
	for stage = 1, table.nums(tParam) do
		tResult[stage] = {}
		for j = 1, table.nums(tParam[stage]) do
			local pos = tonumber(tParam[stage][j][1])
			tResult[stage][pos] = tParam[stage][j][2]
		end
	end
	return tResult
end

--解析星魂突破属性
function DataHero:getSoulBreakAttrs(_str)
	local tResult = {}
	local tParam = luaSplitMuilt(_str, "|", ",", ";", ":")
	for i = 1, table.nums(tParam) do
		local stage = tonumber(tParam[i][1])
		tResult[stage] = tParam[i][2]
	end
	return tResult
end
--获取基础战力值
function DataHero:getBaseSc( )
	-- body	
	local nPower = 0	
	for k, v in pairs(self.tAttList) do
		if v.nId == e_id_hero_att.gongji then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreAtk"))
		elseif v.nId == e_id_hero_att.fangyu then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreDef"))
		elseif v.nId == e_id_hero_att.bingli then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreTrp"))
		elseif v.nId == e_id_hero_att.mingzhong then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreHit"))
		elseif v.nId == e_id_hero_att.shanbi then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreDod"))
		elseif v.nId == e_id_hero_att.baoji then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreCri"))
		elseif v.nId == e_id_hero_att.jianyi then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreTou"))
		elseif v.nId == e_id_hero_att.qianggong then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreSatk"))
		elseif v.nId == e_id_hero_att.qiangfang then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreSdef"))
		elseif v.nId == e_id_hero_att.gongcheng then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreSiege"))
		elseif v.nId == e_id_hero_att.shoucheng then
			nPower = nPower + v:getBaseVal() * tonumber(getGlobleParam("scoreDefCt"))
		end
	end	
	return nPower	
end

return DataHero