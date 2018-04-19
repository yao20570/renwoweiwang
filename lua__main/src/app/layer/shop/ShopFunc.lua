----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-16 16:17:13
-- Description: 常用的商店方法
-----------------------------------------------------
local ShopFunc = {}

--获取vip可以优惠次数
--nExchange: shop_base exchange
function ShopFunc.getShopVipPrivilegeNum( nExchange ) 
	local tShopBase = getShopBaseData(nExchange)
	if not tShopBase then
		return 0
	end

	local tBuyTimes = luaSplit(tShopBase.buytimes, ";")
	local nPrivilegeBuyMax =tonumber(tBuyTimes[Player:getPlayerInfo().nVip+1]) or 0
	local nPrivilegeBought = Player:getShopData():getVipDiscountBought(tShopBase.exchange)
	local nPrivilegeBuy = math.max(nPrivilegeBuyMax - nPrivilegeBought, 0)
	return nPrivilegeBuy
end

--获取vip物品消耗数据
--nExchange: shop_base exchange
function ShopFunc.getShopVipItemCostData( nExchange )
	local tShopBase = getShopBaseData(nExchange)
	if not tShopBase then
		return nil
	end
	--拥有物品消耗次数
	local sFreeCost = tShopBase.freecost
	if sFreeCost then

		local tFreeCost = luaSplit(sFreeCost, ":")
		--替代品扣除id
		local nFreeCostId = tonumber(tFreeCost[1])
		--替代品扣除基数
		local nFreeCostNum = tonumber(tFreeCost[2])
		if nFreeCostId and nFreeCostNum then
			local tGoods2 = getGoodsByTidFromDB(nFreeCostId)
		    if tGoods2 then
		    	--可免费替代品上限
		        local nFreeCostCanBuy = math.floor(getMyGoodsCnt(nFreeCostId) / nFreeCostNum )
		        if nFreeCostCanBuy > 0 then		        	
		        	return {
		        		nFreeCostId = nFreeCostId,
		        		nFreeCostNum = nFreeCostNum,
		        		nFreeCostCanBuy = nFreeCostCanBuy,
		        	}
		        end
		    end
		end
	end
	return nil
end


--获取材料可以买的次数
--nExchange: shop_material exchange
function ShopFunc.getShopMaterialCanBuy( nExchange )
	local tShopMaterial = getShopMaterialData(nExchange)
	if not tShopMaterial then
		return 0
	end
	--可购买次数
	local tBuyTimes = luaSplit(tShopMaterial.buytimes, ";")
	local nBuyTimesIndex = Player:getPlayerInfo().nVip + 1
	if nBuyTimesIndex > #tBuyTimes then
		nBuyTimesIndex = #tBuyTimes
	end
	local nBuyMax = tonumber(tBuyTimes[nBuyTimesIndex]) or 0
	local nBought = Player:getShopData():geMaterialBuyNum(tShopMaterial.exchange)
	return math.max(nBuyMax - nBought, 0)
end

--获取材料单价
--nExchange: shop_material exchange
function ShopFunc.getShopMaterialPrice( nExchange )
	local tShopMaterial = getShopMaterialData(nExchange)
	if not tShopMaterial then
		return 0
	end

	--价格
	local nBought = Player:getShopData():geMaterialBuyNum(tShopMaterial.exchange)
	local tPrice = luaSplit(tShopMaterial.prices, ";")
	local nPrice = 0
	if #tPrice > 0 then
		local sPrice = tPrice[nBought + 1] or tPrice[#tPrice]
		nPrice = tonumber(sPrice)
	end
	if not nPrice then
		nPrice = 0
	end
	return nPrice
end


--获取道具商店单价
--nExchange: shop_base exchange
function ShopFunc.getShopItemPrice( nExchange )
	local tShopBase = getShopBaseData(nExchange)
	if not tShopBase then
		return nil
	end
	local nPrice = tShopBase.cost
	if Player:getShopData():getIsDiscountId(tShopBase.exchange) then
		nPrice = math.ceil(nPrice * tShopBase.discount)
	end
	return nPrice
end

--获取商品描述
--tData:shop_base
function ShopFunc.getShopGoodsDesc( tData )
	if not tData then
		return ""
	end
	local nVipLv = Player:getPlayerInfo().nVip
	local nIndex = nVipLv + 1
	--玩家当前VIP等级购买，每次可获得%s威望
	if tData.exchange == 11 then
		local sStr = getShopInitParam("vipPrestigeBuy")
		if sStr then
			local sStrList = luaSplit(sStr, ";")
			if nIndex > #sStrList then
				nIndex = #sStrList
			end
			local sData = sStrList[nIndex] or ""
			return string.format(tData.desc, sData)
		end
	--玩家当前VIP等级购买，募兵量提高%s
	elseif tData.exchange == 15 then
		local tVipData = getAvatarVIPByLevel(nVipLv)
		if tVipData then					
			return string.format(tData.desc, tVipData.recruitfast.."%")
		end
	--玩家当前VIP等级购买，每次可获得%s个自动建造
	elseif tData.exchange == 16 then
		local sStr = getShopInitParam("autoBuildBuy")
		if sStr then
			local sStrList = luaSplit(sStr, ";")
			if nIndex > #sStrList then
				nIndex = #sStrList
			end
			local sData = sStrList[nIndex] or ""
			return string.format(tData.desc, sData)
		end
	--玩家当前VIP等级购买，每次可获得%s个补充城防
	elseif tData.exchange == 17 then
		local sStr = getShopInitParam("cityDefBuy")
		if sStr then
			local sStrList = luaSplit(sStr, ";")
			if nIndex > #sStrList then
				nIndex = #sStrList
			end
			local sData = sStrList[nIndex] or ""
			return string.format(tData.desc, sData)
		end
	end
	return tData.desc
end


function ShopFunc.getShopGoodsCnt( nId )
	-- body
    nId = tonumber(nId)
    local  nCurrNum = 0
    local nVipLv = Player:getPlayerInfo().nVip
	local nIndex = nVipLv + 1
    if nId >= 2 and nId <= 5 then --粮草,银币,木材,镔铁
        nCurrNum = Player:getResourceData():getResCntUnitTime(nId) 
        local tminLimit = luaSplitMuilt(getShopInitParam("minLimit"), ";", ":")
        for k, v in pairs(tminLimit) do
        	local nid = tonumber(v[1] or 0)
        	local nNum = tonumber(v[2] or 0)
        	if nid == nId and nCurrNum < nNum then        		
        		nCurrNum = nNum        		        	
        		break
        	end
        end
    elseif nId == e_resdata_ids.rk then --人口
    	local tSaturat = getSaturationDataFromDB(Player:getBuildData():getBuildById(e_build_ids.palace).nLv)
    	nCurrNum = tSaturat.maxlimit or 0
    	nCurrNum = nCurrNum*0.1
    elseif nId == e_resdata_ids.ww then --威望
		local sStr = getShopInitParam("vipPrestigeBuy")
		if sStr then
			local sStrList = luaSplit(sStr, ";")
			if nIndex > #sStrList then
				nIndex = #sStrList
			end
			local sData = sStrList[nIndex] or 0
			nCurrNum = tonumber(sData)
		end
	elseif nId == e_id_item.zdjz then
		local sStr = getShopInitParam("autoBuildBuy")
		if sStr then
			local sStrList = luaSplit(sStr, ";")
			if nIndex > #sStrList then
				nIndex = #sStrList
			end
			local sData = sStrList[nIndex] or 0
			nCurrNum = tonumber(sData)
		end
	elseif nId == e_id_item.bccf then
		local sStr = getShopInitParam("cityDefBuy")
		if sStr then
			local sStrList = luaSplit(sStr, ";")
			if nIndex > #sStrList then
				nIndex = #sStrList
			end
			local sData = sStrList[nIndex] or 0
			nCurrNum = tonumber(sData)
		end	
    end
    return nCurrNum
end

--对自动建造和补充城防的特殊处理
function ShopFunc.getTipStr(nvip, nCurNum, nMaxlimit)
	-- body
	local sStr = {}
	local str = getTipsByIndex(10051)
	str = string.format(str, tostring(nvip or 0), tostring(nCurNum or 0), tostring(nMaxlimit or 0))
	local ttmp = luaSplit(str, ";")
	if ttmp then
		for k, v in pairs(ttmp) do
			local tt = luaSplit(v, ":")
			tt.color = tt[2] or _cc.pwhite
			tt.text = tt[1]	
			table.insert( sStr, tt )		 
		end
	end
	return sStr
end

--校对特殊处理物品的批量选择上限
function ShopFunc.getGoodSelectMax( _nMax, id )
	-- body
	local nMax = _nMax or 1
	if not id then
		return nMax
	end
	local AvatarVip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
	local nBagMaxNum = 0
	local itemCnt = 0
	local pitemdata = nil
	if id == e_id_item.zdjz then --自动建造
		nBagMaxNum = AvatarVip.autobulid 
		itemCnt = Player:getBuildData().nAutoUpTimes
	elseif id == e_id_item.bccf then			
		nBagMaxNum = AvatarVip.citydef
		itemCnt = Player:getBuildData().nAutoRecruit	
	else		
		return nMax
	end
	if nBagMaxNum - itemCnt <= nMax then
		if nBagMaxNum - itemCnt <= 0 then
			return 1
		end
		return nBagMaxNum - itemCnt
	else
		return nMax
	end
end

--判断是否购买对应的Vip礼包
function ShopFunc.getGoodVipGiftInfo( nId )
	-- body
	local bNeedVipGift 		= 		false--是否需要购买Vip礼包
	local bHadVipGift 		= 		false--是否已经购买对应VIP礼包
	local tStr 				= 		nil   --对应的礼包提示

	if nId then
		if nId == e_resdata_ids.bb then
			local nvip = getArmyVipLvLimit(e_id_item.bbgm)			
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then						
				bHadVipGift = true	
			else		
				tStr = getTextColorByConfigure(getTipsByIndex(10062))
			end		
			bNeedVipGift = true
		elseif nId == e_resdata_ids.qb then
			local nvip = getArmyVipLvLimit(e_id_item.qbgm)
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then
				bHadVipGift = true	
			else		
				tStr = getTextColorByConfigure(getTipsByIndex(10063))					
			end	
			bNeedVipGift = true
		elseif nId == e_resdata_ids.gb then
			local nvip = getArmyVipLvLimit(e_id_item.gbgm)
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then
				bHadVipGift = true	
			else		
				tStr = getTextColorByConfigure(getTipsByIndex(10064))				
			end	
			bNeedVipGift = true
		elseif nId == e_id_item.gfys then
			local nvip = tonumber(getBuildParam("workshopVip"))
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then
				bHadVipGift = true	
			else		
				tStr = getTextColorByConfigure(getTipsByIndex(10067))				
			end	
			bNeedVipGift = true
		elseif nId == e_id_item.kjky then
			local nvip = getArmyVipLvLimit(e_id_item.kjky)
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then
				bHadVipGift = true	
			else		
				tStr = getTextColorByConfigure(getTipsByIndex(20014))				
			end	
			bNeedVipGift = true			
		else
			bNeedVipGift = false
		end
	end 
	return bNeedVipGift, bHadVipGift, tStr
end
return ShopFunc