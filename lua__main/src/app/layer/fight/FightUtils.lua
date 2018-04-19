-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-23 18:09:02 ������
-- Description: ս��������
-----------------------------------------------------

__nMoveSpeed         = 			120 			 --�ƶ��ٶ�

__nShowFightTime 	 = 			1.0 			 --�غϱ��ֵ�ʱ�䣨��λ���� s��

__fSScale 			 = 			0.66 			 --ս�����ʼ���ű���
__fEScale 			 = 			1.08 			 --ս�����������ű���

__nLimitBottom 		 = 			-300 			 --�·���Ҫչʾʿ�����ٽ�ֵ
__nLimitTop 		 =			1000 			 --�Ϸ���Ҫչʾʿ�����ٽ�ֵ

__showFightLayer 	 = 			nil 			 --չʾս�����ֵĲ�
__nFightLayerTopH 	 = 			nil 			 --ս�����涥��߶�

__fightCenterX 		 = 			display.width / 2  --ս�����ֲ��е�X������
__fightCenterY 		 = 			display.height / 2 --ս�����ֲ��е�Y������

__isFightOver 		 = 			false 			 --�Ƿ�ս������	

e_matrix_side = {  -- ����λ
	center = 1,    -- �м�
	right  = 2,    -- �ұ�
	left   = 3,    -- ���
}

e_delay_time_hero = { --�佫�����ӳ�ʱ��
	normal = 1.3, 	--��ͨ�ӳ�
}

e_matrix_formation = { --�����������ͣ����ȼ������Σ�б�ߣ�����
	normal 		= 0, 	--Ĭ�ϣ��佫������Ҫ����
	fangzhen   	= 1, 	--����
	xiexian 	= 2, 	--б��
	gongxing 	= 3, 	--����
}

-- ս��ǰԤ���ص�ս������ͼƬ
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



--����ʿ����Ϣ��÷�������(Ĭ������)
--_sSid��ʿ��id
function __getDefaultMatrixFmt( _sSid )
	-- body
	if not _sSid then
		print("__getMatrixFmt��_sSid is nil")
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

--����˫��Ĭ�����ͻ�õ�ǰ��Ҫչʾ������
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

-- �ƶ���ĳһ��λ��
function __moveToPos( _pView, _tPos, _handler )

	if not _pView or not _tPos or not _handler then
		print("__moveToPos is nil")
		return
	end
	--�������
	local nDis =  math.sqrt((_tPos.x - _pView:getPositionX())
							* (_tPos.x - _pView:getPositionX()) 
							+ (_tPos.y - _pView:getPositionY()) 
							* (_tPos.y - _pView:getPositionY()))
	if nDis <= 0 then
		return false
	end
	--����ʱ��
	local tTime = nDis / __nMoveSpeed
	--�ƶ�
	local actionMoveTo = cc.MoveTo:create(tTime, _tPos)
	--�ص�
	local fCallback = cc.CallFunc:create(_handler)
	local actions = cc.Sequence:create(actionMoveTo,fCallback)
	_pView:runAction(actions)
	return true
end

-- �ƶ���ĳһ��λ��
function __moveByPos( _pView, _tPos, _handler )

	if not _pView or not _tPos or not _handler then
		print("__moveByPos is nil")
		return
	end
	--�������
	local nDis =  math.sqrt((_tPos.x) * (_tPos.x) + (_tPos.y) * (_tPos.y))
	--����ʱ��
	local tTime = nDis / __nMoveSpeed
	--�ƶ�
	local actionMoveBy = cc.MoveBy:create(tTime, _tPos)
	--�ص�
	local fCallback = cc.CallFunc:create(_handler)
	local actions = cc.Sequence:create(actionMoveBy,fCallback)
	_pView:runAction(actions)
end


-- չʾ�佫�ײ�ȦȦ��ת��
--_nDir:���� 1���·� 2���Ϸ�
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

--���ת��Ϊս��������������
--_pCurLayer����ǰ�ؼ���
function __convertToGetRstPos (_pCurLayer)

	local tCurLayerPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(
		_pCurLayer:convertToWorldSpace(cc.p(0, 0)))
	--ս�����ֲ������rootlayer������
	local tFightLayerPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(
		__showFightLayer:convertToWorldSpace(cc.p(0, 0)))

	--��������ת����ʿ����fightlayer��λ��
	local tRstPos = cc.p((tCurLayerPos.x - tFightLayerPos.x) / __fSScale, 
			(tCurLayerPos.y - tFightLayerPos.y) / __fSScale )

	return tRstPos
end

--�������ս�����佫����
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

--���С����־�ַ���
--_nDir������1,2
--_nKind����������
function __getSoldierKey( _nDir, _nKind )
	-- body
	local sKey = 30003
	if _nDir == 1 then --�·�
		if _nKind == en_soldier_type.infantry then --����
			sKey = 30001
		elseif _nKind == en_soldier_type.sowar then --���
			sKey = 30005
		elseif _nKind == en_soldier_type.archer then --����
			sKey = 30003
		end
	elseif _nDir == 2 then --�Ϸ�
		if _nKind == en_soldier_type.infantry then --����
			sKey = 30002
		elseif _nKind == en_soldier_type.sowar then --���
			sKey = 30006
		elseif _nKind == en_soldier_type.archer then --����
			sKey = 30004
		end
	end
	return sKey
end

--��ö��������
--_nMode��1���佫   2��ʿ��
--_nType��1������ 	3������   4������
--return 1����ʾ��ͨ 2����ʾ�ػ�
function __getRandomForArmByType( _nMode, _nType )
	-- body
	local nArmType = 1
	local nRandom = math.random(1, 10)
	if _nMode == 1 then --�佫
		if _nType == e_type_fight_action.stand then --����
			if nRandom <= 9 then
				nArmType = 1
			else
				nArmType = 2
			end
		elseif _nType == e_type_fight_action.run then --�ܲ�
			nArmType = 1
		elseif _nType == e_type_fight_action.attack then --����
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		elseif _nType == e_type_fight_action.death then --����
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		end
	elseif _nMode == 2 then --ʿ��
		if _nType == e_type_fight_action.stand then --����
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		elseif _nType == e_type_fight_action.run then --�ܲ�
			nArmType = 1
		elseif _nType == e_type_fight_action.attack then --����
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		elseif _nType == e_type_fight_action.death then --����
			if nRandom <= 8 then
				nArmType = 1
			else
				nArmType = 2
			end
		end
	end
	
	return nArmType
end

local FIGHT_TEXTURE = nil --��������б�
local nFightPlistHandler = nil --�ͷ������߳�

--Ԥ����ս������(����ս��-->ս��˫���佫���ͺ�ʿ������)
function addFightTexture( _tReport, _handler )
	-- body
	doStopRemovingFightArmature()
	if FIGHT_TEXTURE and table.nums(FIGHT_TEXTURE) > 0 then
		FIGHT_TEXTURE = nil
	end
	if _tReport then
		FIGHT_TEXTURE = {}
		if _tReport.ous and table.nums(_tReport.ous) > 0 then --�·�
			for k, v in pairs (_tReport.ous) do
				local tHeroInfo = getGoodsByTidFromDB(v.hid)
				if tHeroInfo then
					if tHeroInfo.nKind == 1 then --����
						if FIGHT_TEXTURE["p1_fight_bb_x_001"] == nil then
							FIGHT_TEXTURE["p1_fight_bb_x_001"] = "tx/fight/p1_fight_bb_x_001"
						end
					elseif tHeroInfo.nKind == 2 then --���
						if FIGHT_TEXTURE["p1_fight_qb_x_005"] == nil then
							FIGHT_TEXTURE["p1_fight_qb_x_005"] = "tx/fight/p1_fight_qb_x_005"
						end
					elseif tHeroInfo.nKind == 3 then --����
						if FIGHT_TEXTURE["p1_fight_gb_x_003"] == nil then
							FIGHT_TEXTURE["p1_fight_gb_x_003"] = "tx/fight/p1_fight_gb_x_003"
						end
					end
				end
				
			end
			--����佫
			FIGHT_TEXTURE["p1_fight_wj_x_001"] = "tx/fight/p1_fight_wj_x_001"
		end
		if _tReport.dus and table.nums(_tReport.dus) > 0 then --�Ϸ�
			for k, v in pairs (_tReport.dus) do
				local tHeroInfo = getGoodsByTidFromDB(v.hid)
				if tHeroInfo then
					if tHeroInfo.nKind == 1 then --����
						if FIGHT_TEXTURE["p1_fight_bb_s_002"] == nil then
							FIGHT_TEXTURE["p1_fight_bb_s_002"] = "tx/fight/p1_fight_bb_s_002"
						end
					elseif tHeroInfo.nKind == 2 then --���
						if FIGHT_TEXTURE["p1_fight_qb_s_006"] == nil then
							FIGHT_TEXTURE["p1_fight_qb_s_006"] = "tx/fight/p1_fight_qb_s_006"
						end
					elseif tHeroInfo.nKind == 3 then --����
						if FIGHT_TEXTURE["p1_fight_gb_s_004"] == nil then
							FIGHT_TEXTURE["p1_fight_gb_s_004"] = "tx/fight/p1_fight_gb_s_004"
						end
					end
				end
				
			end
			--����佫
			FIGHT_TEXTURE["p1_fight_wj_s_002"] = "tx/fight/p1_fight_wj_s_002"
		end
		
	end
	if FIGHT_TEXTURE and table.nums(FIGHT_TEXTURE) <= 0 then
		FIGHT_TEXTURE = nil
	else
		--����佫��Ȧ���ػ�plist
		FIGHT_TEXTURE["p1_fight_wj_circle"] = "tx/fight/p1_fight_wj_circle"
		--�ػ�����
		FIGHT_TEXTURE["p1_fight_zj_action"] = "tx/fight/p1_fight_zj_action"

		--��������
		local nSize = table.nums(FIGHT_TEXTURE)
		local tKeys = table.keys(FIGHT_TEXTURE)
		if nFightPlistHandler == nil then
			local nIndex = 1
			nFightPlistHandler = MUI.scheduler.scheduleUpdateGlobal(function (  )
				local sPlistName = FIGHT_TEXTURE[tKeys[nIndex]] --����������֣�plist���֣�
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

--�ֶ����ս������
function addFightTextureByPlistName( _sPlistName )
	-- body
	--������loginlayer��Ԥ������ �������ﲻ��Ҫִ��
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

--�ͷ�����
function releaseFightTexture(  )
	-- body
	if FIGHT_TEXTURE and table.nums(FIGHT_TEXTURE) > 0 then
		local nSize = table.nums(FIGHT_TEXTURE)
		local tKeys = table.keys(FIGHT_TEXTURE)
		--ֹͣ�Ƴ�ս������
		doStopRemovingFightArmature()
		if nFightPlistHandler == nil then
			local nIndex = 1
			nFightPlistHandler = MUI.scheduler.scheduleUpdateGlobal(function (  )
				local sPlistName = FIGHT_TEXTURE[tKeys[nIndex]] --����������֣�plist���֣�
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

-- ��ͣɾ��ս����Ч
function doStopRemovingFightArmature(  )
    if(nFightPlistHandler) then
    	MUI.scheduler.unscheduleGlobal(nFightPlistHandler)
        nFightPlistHandler = nil
    end
end

--��Ļ�����޸���Чλ��
function getScreenScaleForFight()
    -- body
    local fScale = 1.0
    --�����������ĸ߶�Ϊ����
    local nCurHeight = display.height * 640 / display.width
    if nCurHeight < 1130 then --�����ĸ߶�С��960�Ķ���Ϊ��ipad
        fScale = (display.height - __nFightLayerTopH) / (1138 - __nFightLayerTopH)
    end
    return fScale
end

--��Ļ�����޸���Чλ��
function resetPosByTarget( tPos )
	-- body
	--�����������ĸ߶�Ϊ����
	local nCurHeight = display.height * 640 / display.width
	if nCurHeight < 1130 then --�����ĸ߶�С��960�Ķ���Ϊ��ipad
		local nScale = (display.height - __nFightLayerTopH) / (1138 - __nFightLayerTopH)
	    tPos.y = tPos.y * nScale
	end
	return tPos
end