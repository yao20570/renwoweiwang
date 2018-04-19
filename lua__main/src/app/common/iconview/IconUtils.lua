-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-19 15:37:43 星期三
-- Description: icon控制类
-----------------------------------------------------
--武将icon类型
TypeIconHero = {
    NORMAL          =       1,          --普通类型
    NULL            =       2,          --空层类型
    ADD            	=       3,          --加号类型
    LOCK            =       4,          --锁住类型   
}
--武将icon大小
TypeIconHeroSize = {
	L 				= 		100, 		-- 108*108
	M 				= 		200, 		-- 108*108*0.8
	XL 				= 		300, 		-- 108*108*1.1
}
---------------------------------------------------------
--物品icon类型
TypeIconGoods = {
	NORMAL 			= 		1, 			--普通类型
	HADMORE 		= 		2, 			--带底部文字
}
--物品icon大小
TypeIconGoodsSize = {
	L 				= 		100, 		-- 108*108
	M 				= 		200, 		-- 108*108*0.8
}
--展示类型
type_icongoods_show = {
	item 			= 		1, 			-- 物品
	hero 			= 		2, 			-- 英雄武将
	tnolyTree 		= 		3, 			-- 科技树
	header 			= 		4, 			-- 玩家头像
	chatPlayer      =       5,          -- 聊天头像
	itemnum			= 		6, 			-- 物品带数量
	box				= 		7, 			-- 头像框
	tech            =       8,          -- 皇城战的科技
}
---------------------------------------------------------
--装备icon类型
TypeIconEquip = {
    NORMAL          =       1,          --普通类型
    ADD            	=       2,          --加号类型
}
--装备icon大小
TypeIconEquipSize = {
	L 				= 		100, 		-- 108*108
	M 				= 		200, 		-- 108*108*0.8
}
---------------------------------------------------------
--icon原始大小
__nItemWidth = 96
__nItemHeight = 96
---------------------------------------------------------


local IconHero = require("app.common.iconview.IconHero")
local IconGoods = require("app.common.iconview.IconGoods")
local IconEquip = require("app.common.iconview.IconEquip")


-- 根据类型获得iconGoods
-- _pParent：父层layer
-- _nType：类型（TypeIconGoods）
-- _nShowType：展示类型（type_icongoods_show）
-- _tData：需要显示的数据，类型为继承Goods
-- _nScale：大小类型(TypeIconGoodsSize,其他比例直接传缩放值)
function getIconGoodsByType( _pParent, _nType, _nShowType, _tData, _nScale)
    -- body
    if not _nType then
    	print("物品icon类型不能为nil")
    	return
    end
    _nScale = _nScale or TypeIconGoodsSize.L
    local pIconGoods = nil
    if _pParent then
        local sName = "p_icon_goods_name"
        pIconGoods = _pParent:findViewByName(sName)
        if not pIconGoods then
            pIconGoods = IconGoods.new(_nType,_nShowType)            
            pIconGoods:setName(sName)
            _pParent:addView(pIconGoods)
        end
        --设置值
        pIconGoods:setCurData(_tData)
        --设置大小
        if _nScale == TypeIconGoodsSize.M then --缩放值0.8
        	_nScale = 0.8
        elseif _nScale == TypeIconGoodsSize.L then -- 缩放值1
        	_nScale = 1
        end
        pIconGoods:setIconScale(_nScale)
    end
    return pIconGoods
end


-- 根据类型获得iconEquip
-- _pParent：父层layer
-- _nType：类型（TypeIconEquip）
-- _nEquipType: 装备种类(e_type_equip)
-- _tData：需要显示的数据，类型为继承Goods
-- _nScale：大小类型(TypeIconEquipSize,其他比例直接传缩放值)
function getIconEquipByType( _pParent, _nType, _nEquipType, _tData, _nScale,_nAddImgType)
    -- body
    if not _nType then
    	print("装备icon类型不能为nil")
    	return
    end
    _nScale = _nScale or TypeIconEquipSize.L
    local pIconEquip = nil
    if _pParent then
        local sName = "p_icon_equip_name"
        pIconEquip = _pParent:findViewByName(sName)
        if not pIconEquip then
            pIconEquip = IconEquip.new(_nType, _nEquipType, _nAddImgType)
            pIconEquip:setName(sName)
            _pParent:addView(pIconEquip)
        end
        -- --设置值
        pIconEquip:setCurData(_tData)
        -- --设置大小
        if _nScale == TypeIconEquipSize.M then --缩放值0.8
        	_nScale = 0.8
        elseif _nScale == TypeIconEquipSize.L then -- 缩放值1
        	_nScale = 1
        end
        pIconEquip:setScale(_nScale)
    end
    return pIconEquip
end

-- 根据类型获得iconHero
-- _pParent：父层layer
-- _nType：类型（TypeIconHero）
-- _tData：需要显示的数据，类型为继承Goods
-- _nScale：大小类型(TypeIconHeroSize,其他比例直接传缩放值)
function getIconHeroByType( _pParent, _nType, _tData, _nScale)
    -- body
    if not _nType then
    	print("武将icon类型不能为nil")
    	return
    end
    _nScale = _nScale or TypeIconHeroSize.L
    local pIconHero = nil
    if _pParent then
        local sName = "p_icon_hero_name"
        pIconHero = _pParent:findViewByName(sName)
        if not pIconHero then
            pIconHero = IconHero.new(_nType)
            pIconHero:setName(sName)
            _pParent:addView(pIconHero)
        end
        --设置值
        pIconHero:setIconHeroType(_nType)
        if _nType == TypeIconHero.NORMAL or _nType == TypeIconHero.LOCK then
        	pIconHero:setCurData(_tData)
        end
        --设置大小
        if _nScale == TypeIconHeroSize.M then --缩放值0.8
        	_nScale = 0.8
        elseif _nScale == TypeIconHeroSize.L then -- 缩放值1
        	_nScale = 1
        elseif _nScale == TypeIconHeroSize.XL then
        	_nScale = 1.1
        end
        pIconHero:setScale(_nScale)
        if _nScale > 1 then --放大了比例，需要重新计算大小和位置
        	--计算中心点位置
        	local fCenterX = _pParent:getPositionX() + _pParent:getWidth() / 2
        	local fCenterY = _pParent:getPositionY() + _pParent:getHeight() / 2
        	--计算放大后的大小
        	local nCurW = pIconHero:getWidth() * _nScale
        	local nCurH = pIconHero:getHeight() * _nScale
        	--重置位置
        	_pParent:setLayoutSize(nCurW,nCurH)
        	_pParent:setPosition(fCenterX - _pParent:getWidth() / 2,
        	    fCenterY - _pParent:getHeight() / 2)
        	pIconHero:setPosition((nCurW - pIconHero:getWidth()) / 2,(nCurH - pIconHero:getHeight()) / 2)
        end
    end
    return pIconHero
end

-- 刷新所有的icon显示（列表）
-- _pParentView(SViewGroup)：父控件，用来存在所需资源的控件
-- _tData(table)：物品的数据结构，类型为继承Goods
-- _nColCount(int): 每一行需要展示的个数 
-- _nType：类型（TypeIconGoods）
-- _nShowType：展示类型（type_icongoods_show）
-- _nScale：大小类型(TypeIconGoodsSize,其他比例直接传缩放值)
-- _nAlignType(int): 1是左对齐，2是中间对齐，3是右对齐（暂时不做处理）
function refreshAllIcons( _pParentView, _tData, _nColCount, _nType, _nShowType,  _nScale, _nAlignType)
	-- body
	if not _pParentView then
		print("_pParentView不能为nil")
		return
	end
	if not _nType then
		print("物品icon类型不能为nil")
		return
	end

    --设置大小
	_nScale = _nScale or TypeIconGoodsSize.L
    if _nScale == TypeIconHeroSize.M then --缩放值0.8
    	_nScale = 0.8
    elseif _nScale == TypeIconHeroSize.L then -- 缩放值1
    	_nScale = 1
    elseif _nScale == TypeIconHeroSize.XL then
    	_nScale = 1.1
    end

	local tIconGoods = {} --存放每个icongoods
	local nCol = _nColCount
	local nAlignType = _nAlignType or 2

	local nSizeParent = _pParentView:getContentSize()
	local nWidthParent = nSizeParent.width --父控件的宽
	local nHeightParent = nSizeParent.height --父控件的高


	local nCtData = table.nums(_tData) --获得数据的总个数
	if nCtData ~= _nColCount and _nAlignType == 2 then
		nCol = nCtData
	    print("数据的个数比每一行要展示的数据多，有可能显示不全哦！")
	end


	--计算每个iconbase可以拥有的宽，高
	local nNeedWidth = math.ceil(nWidthParent / nCol)
	--计算实际上每个icon的宽度
	local nCurIconWidth = 108 * _nScale
	if nNeedWidth < nCurIconWidth then
		print("父容器宽度不够,父层提供的宽度=" .. nNeedWidth ..",icon需要的宽度=" .. nCurIconWidth)
		nNeedWidth = nCurIconWidth
		--这个时候需要重新计算个数
		nCol =  math.floor(nWidthParent / nNeedWidth)
		print("父层不能够把所有的数据都显示出来")
	end

	local nCurIconIndex = 1 --当前iconGoods的标志
	local nMax = nCol --最多显示多少个icon
	for k , v in pairs(_tData) do
	    if nCurIconIndex > nMax then --如果下标已经超过最大的个数 不再往下处理
	        break
	    end
	    local pCurIcon = _pParentView:findViewByName("list_icon_good_index_" .. nCurIconIndex)
	    if not pCurIcon then
	        pCurIcon = IconGoods.new(_nType,_nShowType)
	        pCurIcon:setName("list_icon_good_index_" .. nCurIconIndex)
	        _pParentView:addView(pCurIcon)
	    end

	    local nX = 0 --坐标
	    if nAlignType == 2 then --居中显示
	        nX = (nCurIconIndex - 1) * nNeedWidth + nNeedWidth / 2 - nCurIconWidth / 2
	    elseif nAlignType == 1 then --左对齐
	        nX = (nCurIconIndex - 1) * nNeedWidth
	    end
	    pCurIcon:setPositionX(nX)

	    --设置缩放值
	    if _nScale == TypeIconGoodsSize.M then --缩放值0.8
	    	_nScale = 0.8
	    elseif _nScale == TypeIconGoodsSize.L then -- 缩放值1
	    	_nScale = 1
	    end
	    pCurIcon:setIconScale(_nScale)
	    
	    pCurIcon:setCurData(v)
	    pCurIcon:setVisible(true)
	    table.insert(tIconGoods, pCurIcon)
	    nCurIconIndex = nCurIconIndex + 1
	end

	-- 把不需要的隐藏起来
	for i = nCurIconIndex, nMax, 1 do
	    local pIconBase = _pParentView:findViewByName("list_icon_good_index_" .. i)
	    if(pIconBase) then
	        pIconBase:setVisible(false)
	    end
	end

	if tIconGoods and table.nums(tIconGoods)>0 then
		return tIconGoods
	end
end

--根据品质设置背景框（物品，武将）
--_pLayer：背景层控件
--(灰绿蓝紫橙红金)
--_nQuality：品质
function setBgQuality( _pLayer, _nQuality, _bTx )
	-- body
	_nQuality = _nQuality or 1
	local sBgName = "#v1_img_touxiangkuanghui.png"
	if _nQuality == 1 then
		sBgName = "#v1_img_touxiangkuanghui.png"
	elseif _nQuality == 2 then
		sBgName = "#v1_img_touxiangkuanglv.png"
	elseif _nQuality == 3 then
		sBgName = "#v1_img_touxiangkuanglan.png"
	elseif _nQuality == 4 then
		sBgName = "#v1_img_touxiangkuangzi.png"
	elseif _nQuality == 5 then
		sBgName = "#v1_img_touxiangkuangcheng.png"
	elseif _nQuality == 6 then
		sBgName = "#v1_img_touxiangkuanghong.png"
	elseif _nQuality == 100 then
		sBgName = "#v2_img_kapaiygwc.png"
	end
	_pLayer:setBackgroundImage(sBgName)

	if _bTx == nil then
		_bTx = false
	end

	if _bTx and _nQuality >= 5 and _nQuality < 100 then
		--品质框特效
		addBgQualityTx(_pLayer)
		-- local pArm = _pLayer:getChildByTag(1008611)
		-- if _nQuality >= 5 then
		-- 	if tolua.isnull(pArm) then
		-- 		pArm = MArmatureUtils:createMArmature(
		-- 			tNormalCusArmDatas["26"], 
		-- 			_pLayer, 
		-- 			10, 
		-- 			cc.p(_pLayer:getWidth() / 2,_pLayer:getHeight() / 2),
		-- 		    function ( _pArm )

		-- 		    end, Scene_arm_type.normal)
		-- 		pArm:setTag(1008611)
		-- 		pArm:play(-1)
		-- 	end
		-- else
		-- 	if not tolua.isnull(pArm) then
		-- 		pArm:removeSelf()
		-- 		pArm = nil
		-- 	end
		-- end
	else
		removeBgQualityTx(_pLayer)
	end
	
end
--添加品质框特效
function addBgQualityTx( _pLayer, _nQuality)
	-- body
	--品质框特效
	local pArm = _pLayer:getChildByTag(1008611)
	-- if _nQuality >= 5 then
		if tolua.isnull(pArm) then
			pArm = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["26"], 
				_pLayer, 
				10, 
				cc.p(_pLayer:getWidth() / 2,_pLayer:getHeight() / 2),
			    function ( _pArm )

			    end, Scene_arm_type.normal)
			pArm:setTag(1008611)
			pArm:play(-1)
		end
	-- else
	-- 	if not tolua.isnull(pArm) then
	-- 		pArm:removeSelf()
	-- 		pArm = nil
	-- 	end
	-- end	
end

--移除品质框特效
function removeBgQualityTx( _pLayer )
	-- body
	local pArm = _pLayer:getChildByTag(1008611)
	if not tolua.isnull(pArm) then
		pArm:removeSelf()
		pArm = nil
	end
end

--根据品质设置背景框（装备）
--_pLayer：背景层控件
--(灰绿蓝紫橙红金)
--_nQuality：品质
function setEquipBgQuality( _pLayer, _nQuality )
	-- body
	local sBgName = "#v2_btn_zhuangbeihui.png"
	if _nQuality == 1 then
		sBgName = "#v2_btn_zhuangbeihui.png"
	elseif _nQuality == 2 then
		sBgName = "#v2_btn_zhuangbeilv.png"
	elseif _nQuality == 3 then
		sBgName = "#v2_btn_zhuangbeilan.png"
	elseif _nQuality == 4 then
		sBgName = "#v2_btn_zhuangbeizi.png"
	elseif _nQuality == 5 then
		sBgName = "#v2_btn_zhuangbeicheng.png"
	elseif _nQuality == 6 then
		sBgName = "#v2_btn_zhuangbeihong.png"
	end
	_pLayer:setBackgroundImage(sBgName)
end

--设置装备剪影背景
function getEquipBgShadowPath(_nEquipType)
	-- body
	local sBgName = "#v1_btn_zhuangbeikongge.png"
	if _nEquipType == e_type_equip.weapon then
		sBgName = "#v2_btn_ZBqiang.png"
	elseif _nEquipType == e_type_equip.horse then
		sBgName = "#v2_btn_ZBjian.png"
	elseif _nEquipType == e_type_equip.clothes then
		sBgName = "#v2_btn_ZBjia.png"
	elseif _nEquipType == e_type_equip.helmet then
		sBgName = "#v2_btn_ZBkui.png"
	elseif _nEquipType == e_type_equip.yin then
		sBgName = "#v2_btn_ZBshu.png"
	elseif _nEquipType == e_type_equip.fu then
		sBgName = "#v2_btn_ZByin.png"
	end
	return sBgName
end

--设置星星层
--_pLayer:要展示星星的层
--_nAll：总星星数
--_nCur：当前星星数
--_tDarkLight:暗亮列表(可以不传) {true,false,true,false}, true表示光，false表示暗
function showStarLayer( _pLayer, _nAll, _nCur, _tDarkLight)
	-- body
	if (not _nAll or _nAll <= 0) and _pLayer then
		_pLayer:setVisible(false)
	else
		_pLayer:setVisible(true)
	end

	--先隐藏全部
	if _pLayer.__stars then
		for i = 1, #_pLayer.__stars do --znf
			local pStar = _pLayer.__stars[i]
			if not tolua.isnull(pStar) then
				pStar:setVisible(false)
			end
		end
	end

	-- body
	if not _pLayer.__stars then
		_pLayer.__stars = {}
	end

	local nW = _pLayer:getWidth() / 4

	for i = 1, _nAll do
		local pStar = _pLayer:findViewByName("star_index_" .. i)
		if not pStar then
			pStar = MUI.MImage.new("#v1_img_stara2.png")
			pStar:setName("star_index_" .. i)
			_pLayer:addView(pStar)
			table.insert(_pLayer.__stars, pStar)
		end
		local x = (i - 1) * nW + nW / 2
		if _nAll == 1 then
			x = (i + 1) *nW
		elseif _nAll == 2 then
			x = i * nW + nW / 2
		elseif _nAll == 3 then
			x = i * nW
		end
		pStar:setPosition(x, _pLayer:getHeight() / 2)
		pStar:setVisible(true)
		local bIsLight = i <= _nCur
		if _tDarkLight then
			if _tDarkLight[i] ~= nil then
				if _tDarkLight[i] then
					bIsLight = true
				else
					bIsLight = false
				end
			end
		end
		if bIsLight then
			pStar:setCurrentImage("#v1_img_stara2.png")
		else
			pStar:setCurrentImage("#v1_img_stara2b.png")
		end
	end
end

--设置装备星星层
--_pLayer:要展示星星的层
--_nAll：总星星数
--_nCur：当前星星数
--_tDarkLight:暗亮列表(可以不传) {true,false,true,false}, true表示光，false表示暗
function showEquipStarLayer( _pLayer, _nAll, _nCur, _tDarkLight)
	--先隐藏全部
	if _pLayer.__stars then
		for i = 1, #_pLayer.__stars do --znf
			local pStar = _pLayer.__stars[i]
			if not tolua.isnull(pStar) then
				pStar:setVisible(false)
			end
		end
	end

	-- body
	if not _pLayer.__stars then
		_pLayer.__stars = {}
	end
	local nW = _pLayer:getWidth() / _nAll
	for i = 1, _nAll do
		local pStar = _pLayer:findViewByName("star_index_" .. i)
		if not pStar then
			pStar = MUI.MImage.new("#v2_img_wj_star.png")
			pStar:setName("star_index_" .. i)
			_pLayer:addView(pStar)
			table.insert(_pLayer.__stars, pStar)
		end
		local x = (i - 1) * nW + nW / 2
		local y
		if _nAll == 4 then
			if i == 1 then
				y = _pLayer:getHeight() / 2
				x = x + 3
			elseif i == 4 then
				y = _pLayer:getHeight() / 2
				x = x - 3
			else
				y = 6
			end
		elseif _nAll == 3 then
			if i == 1 then
				y = _pLayer:getHeight() / 2
				x = x + 6
			elseif i == 3 then
				y = _pLayer:getHeight() / 2
				x = x - 6
			else
				y = 6
			end
		elseif _nAll == 2 then
			if i == 1 then
				y = _pLayer:getHeight() / 2 - 8
				x = x + 8
			elseif i == 2 then
				y = _pLayer:getHeight() / 2 - 8
				x = x - 8
			end
		elseif _nAll == 1 then
			if i == 1 then
				y = 5				
			end
		end
		pStar:setPosition(x, y)
		pStar:setVisible(true)
		local bIsLight = i <= _nCur
		if _tDarkLight then
			if _tDarkLight[i] ~= nil then
				if _tDarkLight[i] then
					bIsLight = true
				else
					bIsLight = false
				end
			end
		end

		if bIsLight then
			pStar:setCurrentImage("#v2_img_wj_star.png")
		else
			pStar:setCurrentImage("#v2_img_wj_starb.png")
		end
	end
end
