----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-09-02 10:33:36 
-- Description: 英雄属性的label
-----------------------------------------------------

local HeroInfoLabel = class("HeroInfoLabel", function ( )
	return MUI.MLabel.new({text="", color=getC3B(_cc.pwhite), size=20})
end)

function HeroInfoLabel:ctor( _type )
	self.nType = _type or 1 -- 1是带附加属性的，2是不带附加属性
	self:setAnchorPoint(0, 0.5)
end

--设置数据 
-- _tData(table): 当前数据
-- _nHold(int): 1为 基础值(还显示额外属性) 2,为全部值  3基础值,不显示额外属性
function HeroInfoLabel:setCurData( _tData,_nHold )
	if not _tData then
		return
	end
	local tStr = {}
	-- 增加属性名称
	tStr[#tStr+1] = {text=_tData.sName or "", color=_cc.pwhite}

	local sValue = ""
	local nHold = _nHold or 1
	if nHold == 1 or nHold == 3 then
		sValue = " " .. (tostring(_tData.nVal) or "")
	elseif nHold == 2 then
		sValue = " " .. (tostring(_tData:getTotalVal()) or "")
	end
	-- 增加属性值
	tStr[#tStr+1] = {text=sValue, color=_cc.blue}

	if self.nType ==1 and  nHold ~= 3  then
		--额外属性
		if _tData.nEx and _tData.nEx > 0 then
			local sEx = " " .. "+".. _tData.nEx
			-- 增加附加值
			tStr[#tStr+1] = {text=sEx, color=_cc.green}
		end
	end
	-- 设置最终文字
	self:setString(tStr)
end

--设置数据
--属性名，属性，额外属性
function HeroInfoLabel:setCurDataEx( sAttrName, nAttr, nAttrEx )
	local tStr = {}
	table.insert(tStr, {text= tostring(sAttrName), color=_cc.pwhite})
	if nAttr then
		table.insert(tStr, {text= " " .. tostring(nAttr), color=_cc.blue})
	end
	if nAttrEx and nAttrEx > 0 then
		table.insert(tStr, {text= " +" .. tostring(nAttrEx), color=_cc.green})
	end
	-- 设置最终文字
	self:setString(tStr)
end

return HeroInfoLabel