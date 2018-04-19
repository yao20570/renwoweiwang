-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-23 18:09:02 星期四
-- Description: 战斗工具类
-----------------------------------------------------

__nMoveSpeed         = 			120 			 --移动速度

__nShowFightTime 	 = 			1.0 			 --回合表现的时间（单位：秒 s）

__fSScale 			 = 			0.66 			 --战斗层初始缩放比例
__fEScale 			 = 			1.08 			 --战斗层最终缩放比例

__nLimitBottom 		 = 			-300 			 --下方需要展示士兵的临界值
__nLimitTop 		 =			1000 			 --上方需要展示士兵的临界值

__showFightLayer 	 = 			nil 			 --展示战斗表现的层
__nFightLayerTopH 	 = 			nil 			 --战斗界面顶层高度

__fightCenterX 		 = 			display.width / 2  --战斗表现层中点X的坐标
__fightCenterY 		 = 			display.height / 2 --战斗表现层中点Y的坐标

__isFightOver 		 = 			false 			 --是否战斗结束	

e_matrix_side = {  -- 方阵方位
	center = 1,    -- 中间
	right  = 2,    -- 右边
	left   = 3,    -- 左边
}

e_delay_time_hero = { --武将进场延迟时间
	normal = 1.3, 	--普通延迟
}

e_matrix_formation = { --方阵阵型类型（优先级：弧形＞斜线＞方阵）
	normal 		= 0, 	--默认（武将，不需要变阵）
	fangzhen   	= 1, 	--方阵
	xiexian 	= 2, 	--斜线
	gongxing 	= 3, 	--弓型
}

-- 战斗前预加载的战斗动画图片
tPreLoadFightImg = {}
tPreLoadFightImg[1]     = {"tx/fight/p1_fight_wj_circle"    , 1}
tPreLoadFightImg[2]     = {"tx/fight/p2_fight_bb_s"         , 2}
tPreLoadFightImg[3]     = {"tx/fight/p2_fight_bb_x"         , 2}
tPreLoadFightImg[4]     = {"tx/fight/p2_fight_gb_s"         , 2}
tPreLoadFightImg[5]     = {"tx/fight/p2_fight_gb_x"         , 2}
tPreLoadFightImg[6]     = {"tx/fight/p2_fight_qb_s"         , 2}
tPreLoadFightImg[7]     = {"tx/fight/p2_fight_qb_x"         , 2}
tPreLoadFightImg[8]     = {"tx/fight/p2_fight_wj_s"         , 2}
tPreLoadFightImg[9]     = {"tx/fight/p2_fight_wj_x"         , 2}
tPreLoadFightImg[10]    = {"tx/fight/p2_fight_hurt"         , 2}
tPreLoadFightImg[11]    = {"tx/fight/p1_fight_square"       , 1}
tPreLoadFightImg[12]    = {"tx/fight/p2_fight_hurt"         , 2}
tPreLoadFightImg[13]    = {"tx/fight/p1_fight_skill_qj_001" , 1}
tPreLoadFightImg[14]    = {"tx/fight/p1_fight_skill_gj_001" , 1}
tPreLoadFightImg[15]    = {"tx/fight/p1_fight_skill_bj_001" , 1}
tPreLoadFightImg[16]    = {"tx/world/p1_fight_skill_sep"    , 1}
tPreLoadFightImg[17]    = {"tx/fight/p1_fight_death"        , 1}

--tPreLoadFightTx = {}
--tPreLoadFightTx[1] = {"tx/fight/p1_fight_wj_circle"        ,1}
--tPreLoadFightTx[2] = {"tx/fight/p1_fight_square"           ,1}
--tPreLoadFightTx[3] = {"tx/fight/p2_fight_hurt"             ,2}
--tPreLoadFightTx[4] = {"tx/fight/p1_fight_skill_qj_001"     ,1}
--tPreLoadFightTx[5] = {"tx/fight/p1_fight_skill_gj_001"     ,1}
--tPreLoadFightTx[6] = {"tx/fight/p1_fight_skill_bj_001"     ,1}
--tPreLoadFightTx[7] = {"tx/world/p1_fight_skill_sep"        ,1}
--tPreLoadFightTx[8] = {"tx/fight/p1_fight_death"            ,1}



--根据士兵信息获得方阵类型(默认阵型)
--_sSid：士兵id
function __getDefaultMatrixFmt( _sSid )
	-- body
	if not _sSid then
		print("__getMatrixFmt：_sSid is nil")
		return
	end
	local sSid = tonumber(_sSid)
	local nFmtType = e_matrix_formation.fangzhen
	if sSid == 30001 then        
		nFmtType = e_matrix_formation.fangzhen
	elseif sSid == 30002 then
		nFmtType = e_matrix_formation.fangzhen
	elseif sSid == 30003 then
		nFmtType = e_matrix_formation.gongxing
	elseif sSid == 30004 then
		nFmtType = e_matrix_formation.gongxing
	elseif sSid == 30005 then
		nFmtType = e_matrix_formation.xiexian
	elseif sSid == 30006 then
		nFmtType = e_matrix_formation.xiexian
	end
	return nFmtType
end

--根据双方默认阵型获得当前需要展示的阵型
function __getCurShowMatrixFmt( _aFmt, _bFmt )
	-- body
	if not _aFmt or not _bFmt then
		print("_aFmt or _bFmt is nil")
		return
	end
	if _aFmt >= _bFmt then
		return _aFmt
	else
		return _bFmt
	end
end

-- 移动到某一个位置
function __moveToPos( _pView, _tPos, _handler )

	if not _pView or not _tPos or not _handler then
		print("__moveToPos is nil")
		return
	end
	--计算距离
	local nDis =  math.sqrt((_tPos.x - _pView:getPositionX())
							* (_tPos.x - _pView:getPositionX()) 
							+ (_tPos.y - _pView:getPositionY()) 
							* (_tPos.y - _pView:getPositionY()))
	if nDis <= 0 then
		return false
	end
	--计算时间
	local tTime = nDis / __nMoveSpeed
	--移动
	local actionMoveTo = cc.MoveTo:create(tTime, _tPos)
	--回调
	local fCallback = cc.CallFunc:create(_handler)
	local actions = cc.Sequence:create(actionMoveTo,fCallback)
	_pView:runAction(actions)
	return true
end

-- 移动到某一个位置
function __moveByPos( _pView, _tPos, _handler )

	if not _pView or not _tPos or not _handler then
		print("__moveByPos is nil")
		return
	end
	--计算距离
	local nDis =  math.sqrt((_tPos.x) * (_tPos.x) + (_tPos.y) * (_tPos.y))
	--计算时间
	local tTime = nDis / __nMoveSpeed
	--移动
	local actionMoveBy = cc.MoveBy:create(tTime, _tPos)
	--回调
	local fCallback = cc.CallFunc:create(_handler)
	local actions = cc.Sequence:create(actionMoveBy,fCallback)
	_pView:runAction(actions)
end


-- 展示武将底部圈圈的转动
--_nDir:方向 1：下方 2：上方
function __getCircleArm( _nDir )
	local sPathCircle = "ui/bg_fight/sg_zd_jdx_ls_001.png"
	if _nDir == 2 then
		sPathCircle = "ui/bg_fight/sg_zd_jdx_hs_001.png"
	end
    local pImgCircle = MUI.MImage.new(sPathCircle)
	local pLayer = MUI.MLayer.new()
    pLayer:setLayoutSize(pImgCircle:getLayoutSize())
    pLayer:addView(pImgCircle)
    centerInView(pLayer,pImgCircle)
    pLayer:setScaleY(0.5)
   	pImgCircle:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
    pImgCircle:runAction(cc.RepeatForever:create(
        cc.RotateBy:create(2.5, 360)))
    return pLayer
end

--获得转换为战斗层后的最终坐标
--_pCurLayer：当前控件层
function __convertToGetRstPos (_pCurLayer)

	local tCurLayerPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(
		_pCurLayer:convertToWorldSpace(cc.p(0, 0)))
	--战斗表现层相对于rootlayer的坐标
	local tFightLayerPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(
		__showFightLayer:convertToWorldSpace(cc.p(0, 0)))

	--计算坐标转化后士兵在fightlayer的位置
	local tRstPos = cc.p((tCurLayerPos.x - tFightLayerPos.x) / __fSScale, 
			(tCurLayerPos.y - tFightLayerPos.y) / __fSScale )

	return tRstPos
end

--获得用来战斗的武将数据
function __getHeroInfoForFightById( _hid )
	-- body
	local tHeroInfo = getGoodsByTidFromDB(_hid)
	if tHeroInfo then
		if tHeroInfo.nGtype ~= e_type_goods.type_hero and tHeroInfo.nGtype ~= e_type_goods.type_npc then
			tHeroInfo = nil
		end
	end
	return tHeroInfo
end

--获得小兵标志字符串
--_nDir：方向1,2
--_nKind：兵种类型
function __getSoldierKey( _nDir, _nKind )
	-- body
	local sKey = 30003
	if _nDir == 1 then --下方
		if _nKind == en_soldier_type.infantry then --步兵
			sKey = 30001
		elseif _nKind == en_soldier_type.sowar then --骑兵
			sKey = 30005
		elseif _nKind == en_soldier_type.archer then --弓兵
			sKey = 30003
		end
	elseif _nDir == 2 then --上方
		if _nKind == en_soldier_type.infantry then --步兵
			sKey = 30002
		elseif _nKind == en_soldier_type.sowar then --骑兵
			sKey = 30006
		elseif _nKind == en_soldier_type.archer then --弓兵
			sKey = 30004
		end
	end
	return sKey
end

--获得动作随机数
--_nMode：1：武将   2：士兵
--_nType：1：待命 	3：攻击   4：死亡
--return 1：表示普通 2：表示重击
function __getRandomForArmByType( _nMode, _nType )
	-- body
	local nArmType = 1
	local nRandom = math.random(1, 10)
	if _nMode == 1 then --武将
		if _nType == e_type_fight_action.stand then --待命
			if nRandom <= 9 then
				nArmType = 1
			else
				nArmType = 2
			end
		elseif _nType == e_type_fight_action.run then --跑步
			nArmType = 1
		elseif _nType == e_type_fight_action.attack then --攻击
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		elseif _nType == e_type_fight_action.death then --死亡
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		end
	elseif _nMode == 2 then --士兵
		if _nType == e_type_fight_action.stand then --待命
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		elseif _nType == e_type_fight_action.run then --跑步
			nArmType = 1
		elseif _nType == e_type_fight_action.attack then --攻击
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		elseif _nType == e_type_fight_action.death then --死亡
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		end
	end
	
	return nArmType
end

local FIGHT_TEXTURE = nil --存放纹理列表
local nFightPlistHandler = nil --释放纹理线程

--预加载战斗纹理(根据战报-->战斗双方武将类型和士兵类型)
function addFightTexture( _tReport, _handler )
	-- body
	doStopRemovingFightArmature()
	if FIGHT_TEXTURE and table.nums(FIGHT_TEXTURE) > 0 then
		FIGHT_TEXTURE = nil
	end
	if _tReport then
		FIGHT_TEXTURE = {}
		if _tReport.ous and table.nums(_tReport.ous) > 0 then --下方
			for k, v in pairs (_tReport.ous) do
				local tHeroInfo = getGoodsByTidFromDB(v.hid)
				if tHeroInfo then
					if tHeroInfo.nKind == 1 then --步兵
						if FIGHT_TEXTURE["p1_fight_bb_x_001"] == nil then
							FIGHT_TEXTURE["p1_fight_bb_x_001"] = "tx/fight/p1_fight_bb_x_001"
						end
					elseif tHeroInfo.nKind == 2 then --骑兵
						if FIGHT_TEXTURE["p1_fight_qb_x_005"] == nil then
							FIGHT_TEXTURE["p1_fight_qb_x_005"] = "tx/fight/p1_fight_qb_x_005"
						end
					elseif tHeroInfo.nKind == 3 then --弓兵
						if FIGHT_TEXTURE["p1_fight_gb_x_003"] == nil then
							FIGHT_TEXTURE["p1_fight_gb_x_003"] = "tx/fight/p1_fight_gb_x_003"
						end
					end
				end
				
			end
			--添加武将
			FIGHT_TEXTURE["p1_fight_wj_x_001"] = "tx/fight/p1_fight_wj_x_001"
		end
		if _tReport.dus and table.nums(_tReport.dus) > 0 then --上方
			for k, v in pairs (_tReport.dus) do
				local tHeroInfo = getGoodsByTidFromDB(v.hid)
				if tHeroInfo then
					if tHeroInfo.nKind == 1 then --步兵
						if FIGHT_TEXTURE["p1_fight_bb_s_002"] == nil then
							FIGHT_TEXTURE["p1_fight_bb_s_002"] = "tx/fight/p1_fight_bb_s_002"
						end
					elseif tHeroInfo.nKind == 2 then --骑兵
						if FIGHT_TEXTURE["p1_fight_qb_s_006"] == nil then
							FIGHT_TEXTURE["p1_fight_qb_s_006"] = "tx/fight/p1_fight_qb_s_006"
						end
					elseif tHeroInfo.nKind == 3 then --弓兵
						if FIGHT_TEXTURE["p1_fight_gb_s_004"] == nil then
							FIGHT_TEXTURE["p1_fight_gb_s_004"] = "tx/fight/p1_fight_gb_s_004"
						end
					end
				end
				
			end
			--添加武将
			FIGHT_TEXTURE["p1_fight_wj_s_002"] = "tx/fight/p1_fight_wj_s_002"
		end
		
	end
	if FIGHT_TEXTURE and table.nums(FIGHT_TEXTURE) <= 0 then
		FIGHT_TEXTURE = nil
	else
		--添加武将光圈和重击plist
		FIGHT_TEXTURE["p1_fight_wj_circle"] = "tx/fight/p1_fight_wj_circle"
		--重击动作
		FIGHT_TEXTURE["p1_fight_zj_action"] = "tx/fight/p1_fight_zj_action"

		--加载纹理
		local nSize = table.nums(FIGHT_TEXTURE)
		local tKeys = table.keys(FIGHT_TEXTURE)
		if nFightPlistHandler == nil then
			local nIndex = 1
			nFightPlistHandler = MUI.scheduler.scheduleUpdateGlobal(function (  )
				local sPlistName = FIGHT_TEXTURE[tKeys[nIndex]] --获得纹理名字（plist名字）
				if sPlistName then
					addTextureToCache(sPlistName)
				end
				nIndex = nIndex + 1
				if nFightPlistHandler ~= nil and nIndex > nSize then
			        doStopRemovingFightArmature()
			        nIndex = nil
			        if _handler then
			        	_handler()
			        end
				end
			end)
		end

		-- for k, v in pairs (FIGHT_TEXTURE) do
		-- 	 addTextureToCache(v)
		-- end

	end
end

--手动添加战斗纹理
function addFightTextureByPlistName( _sPlistName )
	-- body
	--由于在loginlayer中预加载了 所以这里不需要执行
	if true then
		return
	end
	if not _sPlistName then return end
	if not FIGHT_TEXTURE then
		FIGHT_TEXTURE = {}
	end
	if not FIGHT_TEXTURE[_sPlistName] then
		FIGHT_TEXTURE[_sPlistName] = _sPlistName
		 addTextureToCache(_sPlistName)
	end
	
end

--释放纹理
function releaseFightTexture(  )
	-- body
	if FIGHT_TEXTURE and table.nums(FIGHT_TEXTURE) > 0 then
		local nSize = table.nums(FIGHT_TEXTURE)
		local tKeys = table.keys(FIGHT_TEXTURE)
		--停止移除战斗纹理
		doStopRemovingFightArmature()
		if nFightPlistHandler == nil then
			local nIndex = 1
			nFightPlistHandler = MUI.scheduler.scheduleUpdateGlobal(function (  )
				local sPlistName = FIGHT_TEXTURE[tKeys[nIndex]] --获得纹理名字（plist名字）
				if sPlistName then
					removeTextureFromCache(sPlistName)
				end
				nIndex = nIndex + 1
				if nFightPlistHandler ~= nil and nIndex >nSize then
			        doStopRemovingFightArmature()
			        FIGHT_TEXTURE = nil
			        nIndex = nil
				end
			end)
		end
	end
end

-- 暂停删除战斗特效
function doStopRemovingFightArmature(  )
    if(nFightPlistHandler) then
    	MUI.scheduler.unscheduleGlobal(nFightPlistHandler)
        nFightPlistHandler = nil
    end
end

--屏幕设配修改特效位置
function getScreenScaleForFight()
    -- body
    local fScale = 1.0
    --计算宽度适配后的高度为多少
    local nCurHeight = display.height * 640 / display.width
    if nCurHeight < 1130 then --适配后的高度小于960的都认为是ipad
        fScale = (display.height - __nFightLayerTopH) / (1138 - __nFightLayerTopH)
    end
    return fScale
end

--屏幕设配修改特效位置
function resetPosByTarget( tPos )
	-- body
	--计算宽度适配后的高度为多少
	local nCurHeight = display.height * 640 / display.width
	if nCurHeight < 1130 then --适配后的高度小于960的都认为是ipad
		local nScale = (display.height - __nFightLayerTopH) / (1138 - __nFightLayerTopH)
	    tPos.y = tPos.y * nScale
	end
	return tPos
end