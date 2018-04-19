-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-11 16:36:07 星期二
-- Description: 打开对话框
-----------------------------------------------------

--打开对话框
-- 1000-1499
function showDlgByType1( pMsgObj, nHandler )
	sendMsg(ghd_guide_finger_show_or_hide, false)
	-- body
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		local nIndex   = pMsgObj.nIndex or 1  --页面分页
		local bDelay   = false --是否需要延迟回调 

		if nDlgType == e_dlg_index.playerinfo then --玩家基础信息对话框
			local DlgPlayerInfo = require("app.layer.playerinfo.DlgPlayerInfo")
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgPlayerInfo.new()
		    end
		 	-- local DlgTestjj = require("app.layer.testjj.DlgTestjj")
		  --   local pDlg, bNew = getDlgByType(nDlgType)
		  --   if not pDlg then
		  --   	pDlg = DlgTestjj.new()
		  --   end
		    pDlg:showDlg(bNew)
	   	elseif nDlgType == e_dlg_index.buildlvup then --建筑升级
   			local DlgBuildLvUp = require("app.layer.build.DlgBuildLvUp")
   		    local pDlg, bNew = getDlgByType(nDlgType)
   		    local nFromWhat = pMsgObj.nFromWhat or 0 --1,2表示从左对联进来的
   		    if not pDlg then
   		    	pDlg = DlgBuildLvUp.new(pMsgObj.nCell,nFromWhat)
   		    else
   		    	pDlg:updateCell(pMsgObj.nCell,nFromWhat)
   		    end
   		    pDlg:showDlg(bNew)
   		elseif nDlgType == e_dlg_index.buildprop then --建筑道具加速
			local DlgBuildProp = require("app.layer.build.DlgBuildProp")
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgBuildProp.new(pMsgObj.nFunType, pMsgObj.nCell, pMsgObj.nLoc)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.buildbuyteam then --购买建筑队列
			local DlgBuildBuyTeam = require("app.layer.build.DlgBuildBuyTeam")
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgBuildBuyTeam.new()
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.camp then --兵营			
			if showBuildOpenTips(pMsgObj.nBuildId) == false then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgCamp = require("app.layer.camp.DlgCamp")
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgCamp.new(pMsgObj.nBuildId, pMsgObj.bNewGuide)
		    end
		    pDlg:showDlg(bNew)
		    --建筑引导对话
			showBuildGuideBegin(e_dlg_index.camp)			
		elseif nDlgType == e_dlg_index.technology then --科学院
			if showBuildOpenTips(e_build_ids.tnoly) == false then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgTechnology = require("app.layer.technology.DlgTechnology")
			local nTarScienceId = pMsgObj.nTarScienceId   -- 指定科技
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgTechnology.new(nTarScienceId)
		    end
		    pDlg:showDlg(bNew)
		    --建筑引导对话
			showBuildGuideBegin(e_dlg_index.technology)
		elseif nDlgType == e_dlg_index.uptnolycost then --研究科技详情框
			local DlgUpTnolyCost = require("app.layer.technology.DlgUpTnolyCost")
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgUpTnolyCost.new()
		    end
		    pDlg:setCurData(pMsgObj.data)
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.tnolytree then --科技树
			if showBuildOpenTips(e_build_ids.tnoly) == false then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgTnolyTree = require("app.layer.technology.DlgTnolyTree")
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgTnolyTree.new(pMsgObj.tData)
		    else
		    	pDlg:setCurSelectTnoly(pMsgObj.tData)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.mail then --邮件
			local DlgMail = require("app.layer.mail.DlgMail")
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgMail.new()
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.unlockbuild then --建筑解锁提示框
			local DlgUnlockBuild = require("app.layer.build.DlgUnlockBuild")
			local tBuildData = pMsgObj.tBuildInfo
			if not tBuildData then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgUnlockBuild.new(tBuildData)
		    end
		    --播放音效
		    Sounds.playEffect(Sounds.Effect.unlock)
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.chatperInfo then --剧情界面
			local pDlg, bNew = getDlgByType(e_dlg_index.chatperInfo)
			local DlgChatperInfo = require("app.layer.task.DlgChatperInfo")
			if not pDlg then
				pDlg = DlgChatperInfo.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.chatperopen then --剧情开启
			local pDlg, bNew = getDlgByType(e_dlg_index.chatperopen)
			local DlgChatperOpen = require("app.layer.task.DlgChatperOpen")
			if not pDlg then
				pDlg = DlgChatperOpen.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif  nDlgType == e_dlg_index.searchbeauty then  
			local pDlg, bNew = getDlgByType(e_dlg_index.searchbeauty)
			local DlgSearchBeauty = require("app.layer.activityb.searchbeauty.DlgSearchBeauty")
			if not pDlg then
				pDlg = DlgSearchBeauty.new()
			end				
			pDlg:showDlg(bNew)
		elseif  nDlgType == e_dlg_index.beautygift then  
			local pDlg, bNew = getDlgByType(e_dlg_index.beautygift)
			local DlgBeautyGift = require("app.layer.activityb.searchbeauty.DlgBeautyGift")
			if not pDlg then
				pDlg = DlgBeautyGift.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.monthweekcard then
			local pDlg, bNew = getDlgByType(e_dlg_index.monthweekcard)
			local DlgBeautyGift = require("app.layer.activityb.monthweekcard.DlgMonthWeekCard")
			if not pDlg then
				pDlg = DlgBeautyGift.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.cardTips then
			local pDlg, bNew = getDlgByType(e_dlg_index.cardTips)
			local DlgCardTips = require("app.layer.activityb.monthweekcard.DlgCardTips")
			if not pDlg then
				pDlg = DlgCardTips.new(pMsgObj.tData)
				pDlg:setOnlyConfirm(getConvertedStr(1, 10364))
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.sciencepromote then
			local pDlg, bNew = getDlgByType(e_dlg_index.sciencepromote)
			local DlgBeautyGift = require("app.layer.activityb.sciencepromote.DlgSciencePromote")
			if not pDlg then
				pDlg = DlgBeautyGift.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.fubenwipeteam then
			local pDlg, bNew = getDlgByType(e_dlg_index.fubenwipeteam)
			local DlgFubenWipe = require("app.layer.fuben.DlgFubenWipe")
			if not pDlg then
				pDlg = DlgFubenWipe.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.nationaltreasure then
			local pDlg, bNew = getDlgByType(e_dlg_index.nationaltreasure)
			local DlgNationalTreasure = require("app.layer.nationaltreasure.DlgNationalTreasure")
			if not pDlg then
				pDlg = DlgNationalTreasure.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.newcountryhelp then
			local pDlg, bNew = getDlgByType(e_dlg_index.newcountryhelp)
			local DlgNewCountyHelp = require("app.layer.newcountry.newcountryhelp.DlgNewCountryHelp")
			if not pDlg then
				pDlg = DlgNewCountyHelp.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		end
		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end
end

--打开对话框
-- 1500-1999
function showDlgByType2( pMsgObj, nHandler )
	-- body
	sendMsg(ghd_guide_finger_show_or_hide, false)
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		local nIndex   = pMsgObj.nIndex or 1  --页面分页
		local bDelay   = false --是否需要延迟回调 
		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end

end

--打开对话框
-- 2000-2499
function showDlgByType3( pMsgObj, nHandler )
	-- body
	sendMsg(ghd_guide_finger_show_or_hide, false)
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		local nIndex   = pMsgObj.nIndex or 1  --页面分页
		local bDelay   = false --是否需要延迟回调 

		if nDlgType == e_dlg_index.blockmap then --区域地图
			--停止小地图刷新
			sendMsg(ghd_world_block_dots_msg_switch, false)
			--申请完数据再打开
			local nDotX, nDotY = pMsgObj.nDotX, pMsgObj.nDotY

			local DlgBlockMap = require("app.layer.world.DlgBlockMap")
			local pDlg, bNew = getDlgByType(e_dlg_index.blockmap)
			if not pDlg then
				pDlg = DlgBlockMap.new()
			end
			pDlg:setData(nDotX, nDotY)
			pDlg:showDlg(bNew)
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end			
		elseif nDlgType == e_dlg_index.wildarmy then --乱军界面
			if pMsgObj.tViewDotMsg.bIsMoBing then --魔兵
				local DlgMoBingDetail = require("app.layer.wuwang.DlgMoBingDetail")
				local pDlg, bNew = getDlgByType(e_dlg_index.wildarmy)
				if not pDlg then
					pDlg = DlgMoBingDetail.new()
				end
				pDlg:setData(pMsgObj.tViewDotMsg)
				pDlg:showDlg(bNew)
			else
				local DlgWildArmyDetail = require("app.layer.world.DlgWildArmyDetail")
				local pDlg, bNew = getDlgByType(e_dlg_index.wildarmy)
				if not pDlg then
					pDlg = DlgWildArmyDetail.new()
				end
				pDlg:setData(pMsgObj.tViewDotMsg)
				pDlg:showDlg(bNew)
			end
		elseif nDlgType == e_dlg_index.citydetail then --城池详细
			local DlgCityDetail = require("app.layer.world.DlgCityDetail")
			local pDlg, bNew = getDlgByType(e_dlg_index.citydetail)
			if not pDlg then
				pDlg = DlgCityDetail.new()
			end
			pDlg:setData(pMsgObj.tViewDotMsg, nIndex)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.citywarprotectconfirm then --城战发起保护状态确认界面
			local DlgCityWarProtectConfirm = require("app.layer.world.DlgCityWarProtectConfirm")
			local pDlg, bNew = getDlgByType(e_dlg_index.citywarprotectconfirm)
			if not pDlg then
				pDlg = DlgCityWarProtectConfirm.new()
			end
			pDlg:setData(pMsgObj.nCallBackFunc)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.citywar then --城战面板
			local DlgCityWar = require("app.layer.world.DlgCityWar")
			local pDlg, bNew = getDlgByType(e_dlg_index.citywar)
			if not pDlg then
				pDlg = DlgCityWar.new()
			end
			pDlg:setData(pMsgObj.tCityWarMsgs, pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.battlehero then --武将出征面板
			local DlgBattleHero = require("app.layer.world.DlgBattleHero")
			local pDlg, bNew = getDlgByType(e_dlg_index.battlehero)
			if not pDlg then
				pDlg = DlgBattleHero.new()
				if nIndex == 1 then --发起城战
					pDlg:setDataByCityWar(pMsgObj)
				elseif nIndex == 2 then --驻军
					pDlg:setDataByGarrison(pMsgObj.tViewDotMsg, pMsgObj.nCanGarrisonNum)
				elseif nIndex == 3 then --野军
					pDlg:setDataByWildArmy(pMsgObj.tViewDotMsg)
				elseif nIndex == 4 then --参加城战
					pDlg:setDataByJoinCityWar(pMsgObj.tViewDotMsg, pMsgObj.sWarId, pMsgObj.tCityWarMsg, pMsgObj.nCostType)
				elseif nIndex == 5 then --参加国战
					pDlg:setDataByCountryWar(pMsgObj.tViewDotMsg, pMsgObj.nAtkCountry, pMsgObj.tCountryWarMsg)
				elseif nIndex == 6 then --Boss
					pDlg:setDataByBoss(pMsgObj.tViewDotMsg)
				elseif nIndex == 7 then --幽魂
					pDlg:setDataByGhostdom(pMsgObj.tViewDotMsg)
				elseif nIndex == 8 then --纣王试炼					
					pDlg:setDataByZhouTrial(pMsgObj.tViewDotMsg)
				elseif nIndex == 9 then --TLBoss
					pDlg:setDataByTLBoss(pMsgObj.tViewDotMsg)
				elseif nIndex == 10 then --出征皇城战
					pDlg:setDataByImperialCity(pMsgObj.tViewDotMsg)
				end
				pDlg:setBattledFunc(pMsgObj.nCallBackFunc)
			end
			pDlg:showDlg(bNew)
			local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
			if tCurTask and tCurTask.sTid == e_special_task_id.beat_two_army then
				Player:getNewGuideMgr():showGuideByStep()
			end
		elseif nDlgType == e_dlg_index.citygarrison then --城池驻防
			local DlgCityGarrison = require("app.layer.world.DlgCityGarrison")
			local pDlg, bNew = getDlgByType(e_dlg_index.citygarrison)
			if not pDlg then
				pDlg = DlgCityGarrison.new()
			end
			pDlg:setData(pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.countrywar then --国战面板
			local DlgCountryWar = require("app.layer.world.DlgCountryWar")
			local pDlg, bNew = getDlgByType(e_dlg_index.countrywar)
			if not pDlg then
				pDlg = DlgCountryWar.new()
			end
			pDlg:setData(pMsgObj.tCountryWarMsgs, pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.collectres then --采集面板
			local DlgCollectResource = require("app.layer.world.DlgCollectResource")
			local pDlg, bNew = getDlgByType(e_dlg_index.collectres)
			if not pDlg then
				pDlg = DlgCollectResource.new()
			end
			pDlg:setData(pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.syscitycollect then --系统城池资源征收面板
			local DlgSysCityCollection = require("app.layer.world.DlgSysCityCollection")
			local pDlg, bNew = getDlgByType(e_dlg_index.syscitycollect)
		    if(not pDlg) then
		        pDlg = DlgSysCityCollection.new()
		    end
		    pDlg:setData(pMsgObj.nSysCityId)
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.cityownerapply then --城主申请
			local DlgCityOwnerApply = require("app.layer.world.DlgCityOwnerApply")
			local pDlg, bNew = getDlgByType(e_dlg_index.cityownerapply)
			if not pDlg then
				pDlg = DlgCityOwnerApply.new()
			end
			pDlg:setData(pMsgObj.nSysCityId)
			pDlg:showDlg(bNew)

		elseif nDlgType == e_dlg_index.syscitydetail then --系统城池详细
			local tCityData = getWorldCityDataById(pMsgObj.nSystemCityId)
			if not tCityData then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			--都城详情
			if tCityData.kind == e_kind_city.ducheng then
				local DlgCapitalCityDetail = require("app.layer.world.DlgCapitalCityDetail")
				local pDlg, bNew = getDlgByType(e_dlg_index.syscitydetail)
				if not pDlg then
					pDlg = DlgCapitalCityDetail.new(pMsgObj.nSystemCityId)
				end
				pDlg:showDlg(bNew)
			elseif tCityData.kind == e_kind_city.zhongxing or tCityData.kind == e_kind_city.firetown then
				--每次中心城或烽火塔就请求一次数据
				local bIsOpen = Player:getImperWarData():getImperWarIsOpen()
				if bIsOpen then
					SocketManager:sendMsg("reqImperBattlefield", {pMsgObj.nSystemCityId},function (__msg)
						if  __msg.head.state == SocketErrorType.success then 
							if __msg.head.type == MsgType.reqImperBattlefield.id then
								local ImperialWarVo = require("app.layer.imperialwar.data.ImperialWarVo")
								local tImperialWarVo = ImperialWarVo.new(__msg.body)
								--设置当前打开的界面主要数据
								Player:getImperWarData():setCurrImperWarData(pMsgObj.nSystemCityId, tImperialWarVo)
								--打开界面
								local DlgImperialCity = require("app.layer.imperialwar.DlgImperialCity")
								local pDlg, bNew = getDlgByType(e_dlg_index.syscitydetail)
								if not pDlg then
									pDlg = DlgImperialCity.new()
								end
								pDlg:showDlg(bNew)		
							end
						else
					        TOAST(SocketManager:getErrorStr(__msg.head.state))
					    end
					end)
				else
					--设置当前打开的界面主要数据
					Player:getImperWarData():setCurrImperWarData(pMsgObj.nSystemCityId, nil)
					--打开界面
					local DlgImperialCity = require("app.layer.imperialwar.DlgImperialCity")
					local pDlg, bNew = getDlgByType(e_dlg_index.syscitydetail)
					if not pDlg then
						pDlg = DlgImperialCity.new()
					end
					pDlg:showDlg(bNew)	
				end
			else
				-- --系统城池详情
				-- local DlgSysCityDetail = require("app.layer.world.DlgSysCityDetail")
				-- local pDlg, bNew = getDlgByType(e_dlg_index.syscitydetail)
				-- if not pDlg then
				-- 	pDlg = DlgSysCityDetail.new(pMsgObj.nSystemCityId)
				-- end
				-- pDlg:showDlg(bNew)
				local DlgSysCityDetailNew = require("app.layer.syscitydetail.DlgSysCityDetailNew")
				local pDlg, bNew = getDlgByType(e_dlg_index.syscitydetail)
				if not pDlg then
					pDlg = DlgSysCityDetailNew.new(pMsgObj.nSystemCityId, pMsgObj.nTab)
				end
				pDlg:showDlg(bNew)
			end
		elseif nDlgType == e_dlg_index.imperialwarhero then --皇城战英雄
			SocketManager:sendMsg("reqImperWarMyHero", {},function (__msg)
				if  __msg.head.state == SocketErrorType.success then 
					if __msg.head.type == MsgType.reqImperWarMyHero.id then
						if __msg.body.mhs and #__msg.body.mhs > 0 then
							local MyHeroShow = require("app.layer.imperialwar.data.MyHeroShow")
							local tList = {}
							for i=1,#__msg.body.mhs do
								table.insert(tList, MyHeroShow.new(__msg.body.mhs[i]))
							end
							--界面
							local DlgImperialWarHero = require("app.layer.imperialwar.DlgImperialWarHero")
							local pDlg, bNew = getDlgByType(e_dlg_index.imperialwarhero)
							if not pDlg then
								pDlg = DlgImperialWarHero.new()
							end
							pDlg:setData(tList)
							pDlg:showDlg(bNew)
						end
					end
				else
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			    end
			end)
		elseif nDlgType == e_dlg_index.imperialwararmy then --皇城战攻防部队
			--界面
			local DlgImperialWarArmy = require("app.layer.imperialwar.DlgImperialWarArmy")
			local pDlg, bNew = getDlgByType(e_dlg_index.imperialwararmy)
			if not pDlg then
				pDlg = DlgImperialWarArmy.new()
			end
			pDlg:setData(tAtkTroops, nDefTroops, tAckList, tDefList)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.royalbank then --皇城秘库
			local DlgRoyalBank = require("app.layer.imperialwar.DlgRoyalBank")
			local pDlg, bNew = getDlgByType(e_dlg_index.royalbank)
			if not pDlg then
				pDlg = DlgRoyalBank.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.eqw then --皇城战活动面板
			local DlgEpw = require("app.layer.epw.DlgEpw")
			local pDlg, bNew = getDlgByType(e_dlg_index.eqw)
			if not pDlg then
				pDlg = DlgEpw.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.imperwarreport then --皇城战战报
			local DlgImperWarReport = require("app.layer.imperialwar.DlgImperWarReport")
			local pDlg, bNew = getDlgByType(e_dlg_index.imperwarreport)
			if not pDlg then
				pDlg = DlgImperWarReport.new(pMsgObj.tReplay, pMsgObj.bShare)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.cityownercandidate then --城主申请候选人
			local DlgCityOwnerCandidate = require("app.layer.world.DlgCityOwnerCandidate")
			local pDlg, bNew = getDlgByType(e_dlg_index.cityownercandidate)
			if not pDlg then
				pDlg = DlgCityOwnerCandidate.new()
			end
			pDlg:setData(pMsgObj.nSysCityId, pMsgObj.__msg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.worldmap then --世界地图
			local DlgWorldMap = require("app.layer.world.DlgWorldMap")
			local pDlg, bNew = getDlgByType(e_dlg_index.worldmap)
			if not pDlg then
				pDlg = DlgWorldMap.new()
			end
			pDlg:setData(pMsgObj.nDotX, pMsgObj.nDotY)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.citywarhelp then --城战请求支援面板
			local DlgCityWarSendHelp = require("app.layer.world.DlgCityWarSendHelp")
			local pDlg, bNew = getDlgByType(e_dlg_index.citywarhelp)
			if not pDlg then
				pDlg = DlgCityWarSendHelp.new(pMsgObj.nWarType)
			end
			pDlg:setData(pMsgObj.tViewDotMsg, pMsgObj.tCityWarMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.bosswarhelp then --Boss请求支援面板
			local DlgBossWarSendHelp = require("app.layer.wuwang.DlgBossWarSendHelp")
			local pDlg, bNew = getDlgByType(e_dlg_index.bosswarhelp)
			if not pDlg then
				pDlg = DlgBossWarSendHelp.new()
			end
			pDlg:setData(pMsgObj.tViewDotMsg, pMsgObj.tBossWarVO)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.callplayer then --召唤面板
			local DlgCallPlayer = require("app.layer.world.DlgCallPlayer")
			local pDlg, bNew = getDlgByType(e_dlg_index.callplayer)
			if not pDlg then
				pDlg = DlgCallPlayer.new()
			end
			pDlg:refreshData()
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.maildetail then --邮件详细
			local tMailMsg = pMsgObj.tMailMsg
			if not tMailMsg then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			--系统邮件
			if tMailMsg.nId == nil or tMailMsg.nId == 0 then --没模板状态
				local pDlg, bNew = getDlgByType(e_dlg_index.maildetailsys)
				if not pDlg then
					local DlgSysMailDetail = require("app.layer.mail.DlgSysMailDetail")
					pDlg = DlgSysMailDetail.new(tMailMsg, pMsgObj)
				end
				pDlg:showDlg(bNew)
			else
				local tMailData = getMailDataById(tMailMsg.nId)
				if not tMailData then
			        --回调	
				    if nHandler then
				    	nHandler(nDlgType)
				    end
					return
				end
				--dump(tMailData, "tMailData", 100)
				if tMailData.kind == e_type_mail.system or tMailData.kind == e_type_mail.activity then --系统邮件活动邮件
					local pDlg, bNew = getDlgByType(e_dlg_index.maildetailsys)
					if not pDlg then
						local DlgSysMailDetail = require("app.layer.mail.DlgSysMailDetail")
						pDlg = DlgSysMailDetail.new(tMailMsg, pMsgObj)
					end
					pDlg:showDlg(bNew)
				else
					local template = tMailData.template --普通邮件模板

					if template == 1 then --城战邮件
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetailcitywar)
						if not pDlg then
							local DlgCityWarMailDetail = require("app.layer.mail.DlgCityWarMailDetail")
							pDlg = DlgCityWarMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					elseif template == 2 then --国战邮件
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetailcountrywar)
						if not pDlg then
							local DlgCountryWarMailDetail = require("app.layer.mail.DlgCountryWarMailDetail")
							pDlg = DlgCountryWarMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					elseif template == 3 then --乱军邮件
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetailwildarmy)
						if not pDlg then
							local DlgWildArmyMailDetail = require("app.layer.mail.DlgWildArmyMailDetail")
							pDlg = DlgWildArmyMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					elseif template == 4 then --采集邮件
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetailcollect)
						if not pDlg then
							local DlgCollectMailDetail = require("app.layer.mail.DlgCollectMailDetail")
							pDlg = DlgCollectMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					elseif template == 5 then --矿点占领邮件
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetailmine)
						if not pDlg then
							local DlgMinesMailDetail = require("app.layer.mail.DlgMinesMailDetail")
							pDlg = DlgMinesMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					elseif template == 6 then --侦查
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetaildetect)
						if not pDlg then
							local DlgDetectMailDetail = require("app.layer.mail.DlgDetectMailDetail")
							pDlg = DlgDetectMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					elseif template == 7 then --驻防
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetailgarrison)
						if not pDlg then
							local DlgGarrisonMailDetail = require("app.layer.mail.DlgGarrisonMailDetail")
							pDlg = DlgGarrisonMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					elseif template == 8 then --目标丢失/不存在
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetaillose)
						if not pDlg then
							local DlgLoseMailDetail = require("app.layer.mail.DlgLoseMailDetail")
							pDlg = DlgLoseMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					elseif template == 9 then --遭到侦查
						local pDlg, bNew = getDlgByType(e_dlg_index.maildetaildetectme)
						if not pDlg then
							local DlgDetectMeMailDetail = require("app.layer.mail.DlgDetectMeMailDetail")
							pDlg = DlgDetectMeMailDetail.new(tMailMsg, pMsgObj)
						end
						pDlg:showDlg(bNew)
					end
				end
			end
		elseif  nDlgType == e_dlg_index.smithshop then --铁匠铺
			--如果可以收获就返回，不打开,先放在这里，当主城有浮标外设时就修改znftodo
			if Player:getEquipData():getIsFinishMakeEquip() then
				--先切换到主城再定位到铁匠铺的位置
				sendMsg(ghd_home_show_base_or_world, 1)
				local tOb = {}
				tOb.nCell = e_build_cell.tjp
				tOb.nFunc = function (  )
					-- body
				end
				sendMsg(ghd_move_to_build_dlg_msg, tOb)
				closeAllDlg()
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			-- local pBuildData = Player:getBuildData():getBuildById(e_build_ids.tjp)
			-- if not pBuildData then
			-- 	TOAST(getConvertedStr(7,10104))
			-- 	return
			-- end
			if showBuildOpenTips(e_build_ids.tjp) == false then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end

			--为了兼容新手步骤, 在其他地方打开铁匠铺的同时定位到铁匠铺的位置
			local tOb = {}
			tOb.nCell = e_build_cell.tjp
			sendMsg(ghd_move_to_build_dlg_msg, tOb)

			local DlgSmithShop = require("app.layer.smithshop.DlgSmithShop")
			local pDlg, bNew = getDlgByType(e_dlg_index.smithshop)
			local nFuncIdx = pMsgObj.nFuncIdx 		 --功能分页
			if nFuncIdx == n_smith_func_type.train then
				--如果去洗炼界面判断一下洗炼功能有没有开启
				local bOpen = getIsReachOpenCon(21, true)
				if not bOpen then
					return
				end
			elseif nFuncIdx == n_smith_func_type.strengthen then
				--如果去洗炼界面判断一下强化功能有没有开启
				local bOpen = getIsReachOpenCon(20, true)
				if not bOpen then
					return
				end
			end
			if not pDlg then
				local sUuid = pMsgObj.sUuid
				local nHeroId = pMsgObj.nHeroId
				local nEquipID = pMsgObj.nEquipID
				local nKind = pMsgObj.nKind
				pDlg = DlgSmithShop.new(sUuid, nHeroId, nFuncIdx, nEquipID, nKind)
			end
			-- if nFuncIdx == n_smith_func_type.build then
			-- 	if pMsgObj.nEquipID then
			-- 		pDlg:setDefaultEquipShow(pMsgObj.nEquipID)				
			-- 	end
			-- 	if pMsgObj.nKind then			
			-- 		pDlg:setDefaultKindShow(pMsgObj.nKind)				
			-- 	end
			-- end
			pDlg:showDlg(bNew)
			--建筑引导对话
			showBuildGuideBegin(e_dlg_index.tjp)
		elseif  nDlgType == e_dlg_index.refineshop then --洗炼铺
			-- local pBuildData = Player:getBuildData():getBuildById(e_build_ids.ylp)
			-- if not pBuildData then
			-- 	TOAST(getConvertedStr(7,10105))
			-- 	return
			-- end
			if showBuildOpenTips(e_build_ids.ylp) == false then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end

			local DlgRefineShop = require("app.layer.refineshop.DlgRefineShop")
			local pDlg, bNew = getDlgByType(e_dlg_index.refineshop)
			local nFuncIdx = pMsgObj.nFuncIdx --强化还是洗炼功能
			if nFuncIdx and nFuncIdx == n_func_type.train then
				--如果去洗炼界面判断一下洗炼功能有没有开启
				local bOpen = getIsReachOpenCon(21, true)
				if not bOpen then
					return
				end
			end
			if not pDlg then
				local sUuid = pMsgObj.sUuid
				local nHeroId = pMsgObj.nHeroId
				pDlg = DlgRefineShop.new(sUuid, nHeroId, nFuncIdx)
			end
			pDlg:showDlg(bNew)
			--建筑引导对话
			showBuildGuideBegin(e_dlg_index.refineshop)
		elseif nDlgType == e_dlg_index.equipbag then --装备背包
			local sUuid = pMsgObj.sUuid
			local nKind = pMsgObj.nKind
			local nHeroId = pMsgObj.nHeroId
			local DlgEquipBag = require("app.layer.equip.DlgEquipBag")
			local pDlg, bNew = getDlgByType(e_dlg_index.equipbag)
			if not pDlg then
				pDlg = DlgEquipBag.new(sUuid, nKind, nHeroId)
			else
				pDlg:setEquipBagParam(sUuid, nKind, nHeroId)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.hiddenattropendesc then --隐藏属性开启说明
			local DlgHiddenAttrOpenDesc = require("app.layer.refineshop.DlgHiddenAttrOpenDesc")
			local pDlg, bNew = getDlgByType(e_dlg_index.hiddenattropendesc)
			if not pDlg then
				pDlg = DlgHiddenAttrOpenDesc.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.fcpromoteclicktip then --战力提升背景 点击
			local DlgFCPromoteClickTip = require("app.layer.promote.DlgFCPromoteClickTip")
			local pDlg, bNew = getDlgByType(e_dlg_index.fcpromoteclicktip)
			if not pDlg then
				local nCombatUpId = pMsgObj.nCombatUpId
				pDlg = DlgFCPromoteClickTip.new(nCombatUpId)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.fcpromote then --战斗力提升途径界面
			local DlgFCPromote = require("app.layer.promote.DlgFCPromote")
			local pDlg, bNew = getDlgByType(e_dlg_index.fcpromote)
			if not pDlg then
				pDlg = DlgFCPromote.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.treasureshop then --珍宝阁
			local pBActivity = Player:getActById(e_id_activity.acttreasureshop)
			if pBActivity then
				local DlgTreasureShop = require("app.layer.shop.DlgTreasureShop")
				local pDlg, bNew = getDlgByType(e_dlg_index.treasureshop)
				if not pDlg then
					pDlg = DlgTreasureShop.new()
				end
				pDlg:showDlg(bNew)				
			else
				TOAST(getConvertedStr(6, 10522))
			end 
		elseif nDlgType == e_dlg_index.treasureunknow then --珍宝阁未知打开
			local DlgTreasureUnknow = require("app.layer.shop.DlgTreasureUnknow")
			local pDlg, bNew = getDlgByType(e_dlg_index.treasureunknow)
			if not pDlg then
				pDlg = DlgTreasureUnknow.new()
			end
			pDlg:setData(pMsgObj.nExchangeId)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.shop then --商店
			--开启判断
			local bIsOpen = getIsReachOpenCon(9)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end

			local DlgShop = require("app.layer.shop.DlgShop")
			local pDlg, bNew = getDlgByType(e_dlg_index.shop)
			if not pDlg then
				pDlg = DlgShop.new(pMsgObj.nGoodsId,pMsgObj.nDefIdx)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.shopbatchbuy then --商店批量操作
			local DlgShopBatchBuy = require("app.layer.shop.DlgShopBatchBuy")
			local pDlg, bNew = getDlgByType(e_dlg_index.shopbatchbuy)
			if not pDlg then
				pDlg = DlgShopBatchBuy.new()
			end
			pDlg:setData(pMsgObj.tShopBase, pMsgObj.tNeedValue, pMsgObj.nResId)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.peoplerebate  then --全民返利			
			bDelay = true
			SocketManager:sendMsg("reloadpeoplerebate", {tData},function (__msg)
			    if  __msg.head.state == SocketErrorType.success then 
			        if __msg.head.type == MsgType.reloadpeoplerebate.id then
			        	--dump(__msg, "__msg", 100)
						local pBActivity = Player:getActById(e_id_activity.peoplerebate) 
						if pBActivity then
							local DlgPeopleRebate = require("app.layer.activityb.peoplerebate.DlgPeopleRebate")
							local pDlg, bNew = getDlgByType(e_dlg_index.peoplerebate)
							if not pDlg then
								pDlg = DlgPeopleRebate.new()
							end
							pDlg:showDlg(bNew)
							--回调	
							if nHandler then
								nHandler(nDlgType)
							end
						else
							TOAST(getConvertedStr(6, 10522))
							--回调	
							if nHandler then
								nHandler(nDlgType)
							end
						end
			        end
			    else
			        --弹出错误提示语
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			    end
		 	end,-1)
		elseif nDlgType == e_dlg_index.snatchturn  then --夺宝转盘
			local pBActivity = Player:getActById(e_id_activity.snatchturn) 
			if pBActivity then
				local DlgSnatchturn = require("app.layer.activityb.snatchturn.DlgSnatchturn")
				local pDlg, bNew = getDlgByType(e_dlg_index.snatchturn)
				if not pDlg then
					pDlg = DlgSnatchturn.new()
				end
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.consumeiron then --耗铁有礼
			local pBActivity = Player:getActById(e_id_activity.consumeiron) 
			if pBActivity then
				local DlgConsumeiron = require("app.layer.activityb.consumeiron.DlgConsumeiron")
				local pDlg, bNew = getDlgByType(e_dlg_index.consumeiron)
				if not pDlg then
					pDlg = DlgConsumeiron.new()
				end
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.season then --季节
			local nSeasonDay = Player:getWorldData().nSeasonDay
			if nSeasonDay == nil or nSeasonDay == 0 then
				TOAST(getTipsByIndex(10079))
				return
			end

			local DlgWorldSeason = require("app.layer.worldseason.DlgWorldSeason")
			local pDlg, bNew = getDlgByType(e_dlg_index.season)
			if not pDlg then
				pDlg = DlgWorldSeason.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.wuwang then --武王
			local pBActivity = Player:getActById(e_id_activity.wuwang) 
			if pBActivity then
				local DlgWuWang = require("app.layer.activityb.wuwang.DlgWuWang")
				local pDlg, bNew = getDlgByType(e_dlg_index.wuwang)
				if not pDlg then
					pDlg = DlgWuWang.new(pMsgObj.nTabIndex)
				end
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.wuwangkillrank then  --击杀排行
			local DlgWuWangKillRank = require("app.layer.wuwang.DlgWuWangKillRank")
			local pDlg, bNew = getDlgByType(e_dlg_index.wuwangkillrank)
			if not pDlg then
				pDlg = DlgWuWangKillRank.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.zhouwangdetail then  --纣王详细
			local DlgZhouWangDetail = require("app.layer.wuwang.DlgZhouWangDetail")
			local pDlg, bNew = getDlgByType(e_dlg_index.zhouwangdetail)
			if not pDlg then
				pDlg = DlgZhouWangDetail.new()
			end
			pDlg:setData(pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.bosswar then  --Boss战列表
			local DlgBossWar = require("app.layer.wuwang.DlgBossWar")
			local pDlg, bNew = getDlgByType(e_dlg_index.bosswar)
			if not pDlg then
				pDlg = DlgBossWar.new()
			end
			pDlg:setData(pMsgObj.tBossWarVOs, pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.herorecommend then  --武将推荐
			local DlgHeroRecommond = require("app.layer.herorecommond.DlgHeroRecommond")
			local pDlg, bNew = getDlgByType(e_dlg_index.herorecommend)
			if not pDlg then
				pDlg = DlgHeroRecommond.new()
			end
			pDlg:setData(pMsgObj.nQuality)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.triggergift then  --触发礼包
			local DlgTriggerGift = require("app.layer.triggergift.DlgTriggerGift")
			local pDlg, bNew = getDlgByType(e_dlg_index.triggergift)
			if not pDlg then
				pDlg = DlgTriggerGift.new()
			end
			pDlg:setData(pMsgObj.nPid, pMsgObj.nGid)
			pDlg:showDlg(bNew)
			pDlg:setLocalZOrder(GLOBAL_DIALOG_ZORDER + 2)
		elseif nDlgType == e_dlg_index.cityfirstblood then  --城池首杀
			local DlgCityFirstBlood = require("app.layer.cityfirstblood.DlgCityFirstBlood")
			local pDlg, bNew = getDlgByType(e_dlg_index.cityfirstblood)
			if not pDlg then
				pDlg = DlgCityFirstBlood.new()
			end
			pDlg:setData(pMsgObj.nBlockId)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.worldmapfirstblood then  --世界地图城池首杀
			local DlgWorldMapFirstBlood = require("app.layer.cityfirstblood.DlgWorldMapFirstBlood")
			local pDlg, bNew = getDlgByType(e_dlg_index.worldmapfirstblood)
			if not pDlg then
				pDlg = DlgWorldMapFirstBlood.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.nianattack then  --年兽来袭
        	local DlgNianAttack = require("app.layer.activityb.nianattack.DlgNianAttack")
			local pDlg, bNew = getDlgByType(e_dlg_index.nianattack)
			if not pDlg then
				pDlg = DlgNianAttack.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.tlbosshitresult then  --限时Boss连击结果界面
        	local DlgTLBossHitResult = require("app.layer.tlboss.DlgTLBossHitResult")
			local pDlg, bNew = getDlgByType(e_dlg_index.tlbosshitresult)
			if not pDlg then
				pDlg = DlgTLBossHitResult.new(pMsgObj.tStormVos)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.tlboss then  --限时Boss界面
        	local DlgTLBoss = require("app.layer.tlboss.DlgTLBoss")
			local pDlg, bNew = getDlgByType(e_dlg_index.tlboss)
			if not pDlg then
				pDlg = DlgTLBoss.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.countrycity then --新国家城池
			local DlgNCountryCity = require("app.layer.newcountry.countrycity.DlgNCountryCity")
			local pDlg, bNew = getDlgByType(e_dlg_index.countrycity)
			if not pDlg then
				pDlg = DlgNCountryCity.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.worldtarget  then --世界目标
			--开启判断
			local bIsOpen = getIsReachOpenCon(8)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end

			local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
			if nMyTargetId then
				local tWorldTargetData = getWorldTargetData(nMyTargetId)
				if tWorldTargetData then
					local nTargetType = tWorldTargetData.nTargetType
					--世界目标乱军
					if nTargetType == e_type_world_target.wildArmy then
						local DlgWorldTargetWildArmy = require("app.layer.worldtarget.DlgWorldTargetWildArmy")
						local pDlg, bNew = getDlgByType(e_dlg_index.worldtargetarmy)
						if not pDlg then
							pDlg = DlgWorldTargetWildArmy.new()
						end
						pDlg:showDlg(bNew)
					--世界目标攻占城池
					elseif nTargetType == e_type_world_target.sysCity then
						local DlgWorldTargetSysCity = require("app.layer.worldtarget.DlgWorldTargetSysCity")
						local pDlg, bNew = getDlgByType(e_dlg_index.worldtargetcity)
						if not pDlg then
							pDlg = DlgWorldTargetSysCity.new()
						end
						pDlg:showDlg(bNew)
					--世界目标攻打世界Boss
					elseif nTargetType == e_type_world_target.worldBoss then
						local DlgWorldTargetBoss = require("app.layer.worldtarget.DlgWorldTargetBoss")
						local pDlg, bNew = getDlgByType(e_dlg_index.worldtargetboss)
						if not pDlg then
							pDlg = DlgWorldTargetBoss.new()
						end
						pDlg:showDlg(bNew)
					--世界目标攻打都城
					elseif nTargetType == e_type_world_target.capital then
						local DlgWorldTargetCapital = require("app.layer.worldtarget.DlgWorldTargetCapital")
						local pDlg, bNew = getDlgByType(e_dlg_index.worldtargetcapital)
						if not pDlg then
							pDlg = DlgWorldTargetCapital.new()
						end
						pDlg:showDlg(bNew)
					end
				end
			end
		end
		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end
end

--打开对话框
-- 2500-2999
function showDlgByType4( pMsgObj, nHandler )
	-- body
	sendMsg(ghd_guide_finger_show_or_hide, false)
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		local nIndex   = pMsgObj.nIndex or 1  --页面分页
		local bDelay   = false --是否需要延迟回调 
		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end
end

--打开对话框
-- 3000-3499
function showDlgByType5( pMsgObj, nHandler )
	-- body
	sendMsg(ghd_guide_finger_show_or_hide, false)
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		local nIndex   = pMsgObj.nIndex or 1  --页面分页
		local bDelay   = false --是否需要延迟回调 

		if nDlgType == e_dlg_index.fubenlayer  then --副本
			--开启判断
			local bIsOpen = getIsReachOpenCon(2)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgFubenLayer = require("app.layer.fuben.DlgFubenLayer")
		    local pDlg, bNew = getDlgByType(e_dlg_index.fubenlayer)
		    if not pDlg then
		    	pDlg = DlgFubenLayer.new()
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.fubenmap  then --副本关卡界面
			--开启判断
			local bIsOpen = getIsReachOpenCon(2)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			--副本已开启的最大章节
			local tOpenChapters = Player:getFuben():getOpenChpater()
			-- n_last_fuben_chapter:上次离开时的章节, 优先级:跳转过来的章节 > 上次离开时的章节 > 已开启的最大章节
			-- local n_last_fuben_chapter = Player:getFuben():getLastEnterChapter()
			local tData = pMsgObj.tData or #tOpenChapters
			local nId = pMsgObj.nID
			if tData then
				bDelay = true
				SocketManager:sendMsg("loadFubenSectionData", {tData},function (__msg)
				   if  __msg.head.state == SocketErrorType.success then 
				       if __msg.head.type == MsgType.loadFubenSectionData.id then
							local DlgFubenMap = require("app.layer.fuben.DlgFubenMap")
						    local pDlg1, bNew = getDlgByType(e_dlg_index.fubenmap)
						    if not pDlg1 then
						    	pDlg1 = DlgFubenMap.new()
						    end	    
						    pDlg1:setCurSectionData(Player:getFuben():getSectionById(tData))
						    pDlg1:showDlg(bNew)		
						    --回调	
						    if nHandler then
						    	nHandler(nDlgType)
						    end
						    -- pDlg1:adjustMapPosition(nId)
				       end
				    else
				        --弹出错误提示语
				        TOAST(SocketManager:getErrorStr(__msg.head.state))
				        --回调	
					    if nHandler then
					    	nHandler(nDlgType)
					    end
				   end
				end,-1)
			end
		elseif nDlgType == e_dlg_index.conscribehero then               --武将招募
			local DlgConscribeHero = require("app.layer.hero.DlgConscribeHero")
		    local pDlg, bNew = getDlgByType(e_dlg_index.conscribehero)
		    local tHeroData = pMsgObj.tHeroData
		    local nBuyHeroCoin = pMsgObj.nBuyHeroCoin
			local nId = pMsgObj.nId
		    if not pDlg then
	    		pDlg = DlgConscribeHero.new(tHeroData, nBuyHeroCoin, nId)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.heromain then --武将
			local bIsOpen = getIsReachOpenCon(1)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgHeroMain = require("app.layer.hero.DlgHeroMain")
		    local pDlg, bNew = getDlgByType(e_dlg_index.heromain)
	   		local tData = pMsgObj.tData --当前武将数据
	   		local nTeamType = pMsgObj.nTeamType --队列类型
		    if tData then
			    if not pDlg then
		    		pDlg = DlgHeroMain.new(tData, nTeamType)
		    	else
		    		pDlg:setCurData(tData, nTeamType)
			    end
			    pDlg:showDlg(bNew)
			else
				myprint("请传入英雄数据才可以打开DlgHeroMain")
		    end
		elseif nDlgType == e_dlg_index.selecthero then --选择武将上阵对话框(也可以不传入武将数据,则不显示当前武将详情)
	   		local DlgSelectHero = require("app.layer.hero.DlgSelectHero")
	   		local tData = pMsgObj.tData --当前武将数据
	   		local nTeamType = pMsgObj.nTeamType --队列类型
	   		local nSelfP = pMsgObj.nSelfP
	   	    local pDlg, bNew = getDlgByType(nDlgType)
	   	    if not pDlg then
	   	    	pDlg = DlgSelectHero.new(tData, nTeamType, nSelfP)
	   	    end
	   	    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.armylayer then --设置部队对话框
			--进入部队设置界面
			local DlgArmyLayer = require("app.layer.fuben.DlgArmyLayer")
		    local pDlg1, bNew = getDlgByType(e_dlg_index.armylayer)
	   		local tData = pMsgObj.tData --当前武将数据
		    if not pDlg1 then
		    	pDlg1 = DlgArmyLayer.new(pMsgObj)
		    end
   	    	pDlg1:showDlg(bNew)
		elseif nDlgType == e_dlg_index.shogunlayer  then --将军府
			-- local DlgShogun = require("app.layer.shogun.DlgShogun")
		 --    local pDlg, bNew = getDlgByType(e_dlg_index.shogunlayer)
		 --    if not pDlg then
		 --    	pDlg = DlgShogun.new()
		 --    end
		 --    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.buyhero  then --拜将台
 			local DlgBuyHero = require("app.layer.buyhero.DlgBuyHeroNew")
			local pDlg, bNew = getDlgByType(e_dlg_index.buyhero)
			if not pDlg then
			   	pDlg = DlgBuyHero.new()
			end
			pDlg:showDlg(bNew)

		elseif nDlgType == e_dlg_index.heroinfo  then --武将详情
			local DlgHeroInfo = require("app.layer.hero.DlgHeroInfo")
			local pDlg, bNew = getDlgByType(e_dlg_index.heroinfo)
	   		local tData = pMsgObj.tData --当前武将数据
	   		local bShowBaseData = pMsgObj.bShowBaseData
	   		if tData then
				if not pDlg then
					pDlg = DlgHeroInfo.new(tData, bShowBaseData)
				end
				pDlg:showDlg(bNew)
			else
				myprint("请传入英雄数据才可以打开DlgReroInfo")
	   		end
		elseif nDlgType == e_dlg_index.wall  then --城墙
			local DlgWallMain = require("app.layer.wall.DlgWallMain")
			local pDlg, bNew = getDlgByType(e_dlg_index.wall)
			if not pDlg then
				pDlg = DlgWallMain.new(tData)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgchat  then --聊天对话框
			local DlgChat = require("app.layer.chat.DlgChat")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgchat)
			local nChatType = pMsgObj.nChatType
			local tPChatInfo = pMsgObj.tPChatInfo
			if not pDlg then
				pDlg = DlgChat.new(nChatType, tPChatInfo)
			else
				pDlg:setData(nChatType, tPChatInfo)
			end
			pDlg:showDlg(bNew,false,0)
		elseif nDlgType == e_dlg_index.dlgherolineup  then --上阵界面
			--开启判断
			local bIsOpen = getIsReachOpenCon(1)
			if not bIsOpen then
				--回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end

			local DlgHeroLineUp = require("app.layer.hero.DlgHeroLineUp")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgherolineup)
			local nTeamType = pMsgObj.nTeamType
			if not pDlg then
				pDlg = DlgHeroLineUp.new(nTeamType)
			end
			--pMsgObj.nTabIdx 标签页
			pDlg:setGuidePos(pMsgObj.nIndex) 
			pDlg:showDlg(bNew)
		-- elseif nDlgType == e_dlg_index.dlgheroparameter  then --其它玩家英雄信息
		-- 	local DlgHeroParameter = require("app.layer.hero.DlgHeroParameter")
		-- 	local pDlg, bNew = getDlgByType(e_dlg_index.dlgheroparameter)
	 --   		local tData = pMsgObj.tData --英雄数据
	 --   		if tData then
		-- 		if not pDlg then
		-- 			pDlg = DlgHeroParameter.new(tData)
		-- 		end
		-- 		pDlg:showDlg(bNew)
		-- 	else
		-- 		myprint("请传入英雄数据才可以打开DlgHeroParameter")
	 --   		end
		elseif nDlgType == e_dlg_index.serverlist  then --打开服务器列表
			local DlgServerList = require("app.layer.serverlist.DlgServerList")
			local pDlg, bNew = getDlgByType(e_dlg_index.serverlist)
			if not pDlg then
				pDlg = DlgServerList.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.buyheropreview  then --推演预览
			local DlgBuyHeroPreView = require("app.layer.buyhero.DlgBuyHeroPreView")
			local pDlg, bNew = getDlgByType(e_dlg_index.buyheropreview)
			if not pDlg then
				pDlg = DlgBuyHeroPreView.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.worlduseresitem then    --世界使用道具			
			local DlgWorldUseResItem = require("app.layer.world.DlgWorldUseResItem")
			local pDlg, bNew = getDlgByType(e_dlg_index.worlduseresitem)
	   		local tItemList = pMsgObj.tItemList --物品的数据
	   		local tTaskCommend = pMsgObj.tTaskCommend --任务指令
	   		local tCityMove = pMsgObj.tCityMove --迁城指令
	   		local tBossPos = pMsgObj.tBossPos --Boss位置
	   		local bIsFromCityWar = pMsgObj.bIsFromCityWar
		    if not pDlg then
		    	pDlg = DlgWorldUseResItem.new(tItemList, tTaskCommend, tCityMove, tBossPos,bIsFromCityWar)
		    end
		    pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.actmodela  then --活动模板a
			local nactId = pMsgObj.nActID
			local DlgActivityModelA = require("app.layer.activitya.DlgActivityModelA")
			local pDlg, bNew = getDlgByType(e_dlg_index.actmodela)
			if not pDlg then				
				pDlg = DlgActivityModelA.new(nactId)
			else
				print("showdlgutil 1126",nactId)
				pDlg:jumpToLayerByActId(nactId)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.actmodelb  then --活动模板b
			local DlgActivityModleB = require("app.layer.activityb.DlgActivityModleB")
			local pDlg, bNew = getDlgByType(e_dlg_index.actmodelb)
			if not pDlg then
				pDlg = DlgActivityModleB.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.buyheroshowget  then --推演界面
			local DlgBuyHeroShowGet = require("app.layer.buyhero.DlgBuyHeroShowGet")
			local pDlg, bNew = getDlgByType(e_dlg_index.buyheroshowget)
			if not pDlg then
				pDlg = DlgBuyHeroShowGet.new(pMsgObj.tReward,pMsgObj.nPrice,pMsgObj.pItem,pMsgObj.nCostItem,pMsgObj.nBuyType)
			end
			pDlg:setHandler(pMsgObj.pHandler)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.showheromansion  then --展示获得英雄界面
			local DlgShowHeroMansion = require("app.layer.activityb.heromansion.DlgShowHeroMansion")
			local pDlg, bNew = getDlgByType(e_dlg_index.showheromansion)
			if not pDlg then
				pDlg = DlgShowHeroMansion.new(pMsgObj.tReward, pMsgObj.nHandler)
			end
			if pMsgObj.nRecommonNum then
				pDlg:setRecommonNum(pMsgObj.nRecommonNum)
			end

			if pMsgObj.bShowContinue then
				pDlg:setShowContinue(pMsgObj.bShowContinue)
			end

			pDlg:setLBtn(pMsgObj.tLBtnData)

			pDlg:setEndPopGoods(pMsgObj.tEndPopGoods)
			pDlg:setBottomTip(pMsgObj.sBottomTip)
			--设置弹窗获得的目标物品
			pDlg:setEndTargetGoods(pMsgObj.tGetTargetGoods)
			pDlg:setTipsDialog(pMsgObj.bTipsDialog)
			
			pDlg:setRBtnHandler(pMsgObj.nRHandler)
			if pMsgObj.bHideGo then
				pDlg:hideLBtn(pMsgObj.bHideGo)
			end
			if pMsgObj.tRBtnData then
				pDlg:setRBtn(pMsgObj.tRBtnData)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.heromansion  then --登坛拜将(活动)
			local pBActivity = Player:getActById(e_id_activity.heromansion)
			if pBActivity then
				local DlgHeroMansion = require("app.layer.activityb.heromansion.DlgHeroMansion")
				local pDlg, bNew = getDlgByType(e_dlg_index.heromansion)
				if not pDlg then
					pDlg = DlgHeroMansion.new()
				end
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.updateplace  then --王宫升级
			local pBActivity = Player:getActById(e_id_activity.updateplace)
			if pBActivity then
				local DlgUpdatePlace = require("app.layer.activityb.updateplace.DlgUpdatePlace")
				local pDlg, bNew = getDlgByType(e_dlg_index.updateplace)
				if not pDlg then
					pDlg = DlgUpdatePlace.new()
				end
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end					
		end

		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end
end


--打开对话框
-- 3500-3999
function showDlgByType6( pMsgObj, nHandler )
	-- body	
	sendMsg(ghd_guide_finger_show_or_hide, false)
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		local nIndex   = pMsgObj.nIndex or 1 --页面分页
		local bDelay   = false --是否需要延迟回调 
		if nDlgType == e_dlg_index.rename then --改名对话框
			local DlgRename = require("app.layer.playerinfo.DlgRename")
			local pDlg, bNew = getDlgByType(e_dlg_index.rename)
		    if not pDlg then
		    	pDlg = DlgRename.new(pMsgObj.tData)		        
		    end
		    pDlg:showDlg(bNew)
		elseif	nDlgType == e_dlg_index.vitbuy then --购买体力
			--如果有体力丹就打开使用体力丹的界面
			-- local nEnergyNums = getMyGoodsCnt(e_id_item.energy)
			-- if nEnergyNums and nEnergyNums > 0  then 
			-- 	if Player:getBagInfo():isItemCanUse(e_id_item.energy) then
			-- 		showUseItemDlg(e_id_item.energy)
			--         --回调	
			-- 	    if nHandler then
			-- 	    	nHandler(nDlgType)
			-- 	    end			
			-- 		return
			-- 	end
			-- end
			local DlgVitbuy = require("app.layer.playerinfo.DlgVitbuy")
			local pDlg, bNew = getDlgByType(e_dlg_index.vitbuy)
		    if not pDlg then
		    	pDlg = DlgVitbuy.new()		       
		    end	
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.palace then
			local DlgPalace = require("app.layer.palace.DlgPalace")
			local pDlg, bNew = getDlgByType(e_dlg_index.palace)
		    if not pDlg then
		    	pDlg = DlgPalace.new()		        
		    end	
		    pDlg:showDlg(bNew)
	    elseif nDlgType == e_dlg_index.civilemploy then
	    	local DlgCivilEmploy = require("app.layer.palace.DlgCivilEmploy")
			local pDlg, bNew = getDlgByType(e_dlg_index.civilemploy)
			local _nEmployType = pMsgObj.nEmployType--雇用类型
		    if not pDlg then
		    	pDlg = DlgCivilEmploy.new(_nEmployType)	
		    else	        
		    	pDlg:setEmployType(_nEmployType)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.warehouse then  --仓库
			if showBuildOpenTips(e_build_ids.store) == false then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgWareHouse = require("app.layer.warehouse.DlgWareHouse")
			local pDlg, bNew = getDlgByType(e_dlg_index.warehouse)
		    if not pDlg then
		    	pDlg = DlgWareHouse.new()		        
		    end
			local nPagIndex = pMsgObj.nPagIndex --几级分页
		    if nPagIndex then
		    	if nPagIndex == 2 then --资源兑换
		    		local bOpen, sLockTip = getIsReachOpenCon(27, true)
					if not bOpen then
						return
					end
		    	elseif nPagIndex == 3 then --资源打包
		    		local bOpen, sLockTip = getIsReachOpenCon(26, true)
					if not bOpen then
						return
					end
		    	end
				pDlg:setDefOpenIndex(nPagIndex)
			end		   
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.getresource then	 
			local DlgGetResource = require("app.module.DlgGetResource")
		   	local pDlg, bNew = getDlgByType(e_dlg_index.getresource)
		   	local tValue = pMsgObj.tValue   --所需资源
		    if not pDlg then
		    	pDlg = DlgGetResource.new(nIndex, tValue)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.bag then
			local DlgBagLayer = require("app.layer.bag.DlgBagLayer")
			local pDlg, bNew = getDlgByType(e_dlg_index.bag)			
		    if not pDlg then
		    	pDlg = DlgBagLayer.new(pMsgObj.nDefIdx)		       
		    end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.getcityprotect then
			local DlgGetCityProtect = require("app.module.DlgGetCityProtect")
			local pDlg, bNew = getDlgByType(e_dlg_index.getcityprotect)
			if not pDlg then
		    	pDlg = DlgGetCityProtect.new()		       
		    end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.atelier then --作坊
			if showBuildOpenTips(e_build_ids.atelier) == false then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
  				return
  			end

			local DlgAtelier = require("app.layer.atelier.DlgAtelier")
			local pDlg, bNew = getDlgByType(e_dlg_index.atelier)
			if not pDlg then
		    	pDlg = DlgAtelier.new()		       
		    end
			pDlg:showDlg(bNew)
			--建筑引导对话
			showBuildGuideBegin(e_dlg_index.atelier)
		elseif nDlgType == e_dlg_index.atelierbespeak then
			local DlgAtelierBespeak = require("app.layer.atelier.DlgAtelierBespeak")
			local pDlg, bNew = getDlgByType(e_dlg_index.atelierbespeak)
			if not pDlg then
		    	pDlg = DlgAtelierBespeak.new()		       
		    end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.atelierproduce then
			local DlgAtelierProduce = require("app.layer.atelier.DlgAtelierProduce")
			local pDlg, bNew = getDlgByType(e_dlg_index.atelierproduce)
			local nflag = pMsgObj.nflag or 1--默认生产
			local nqueueIdx = pMsgObj.nQueueIdx --队列编号
			if not pDlg then
		    	pDlg = DlgAtelierProduce.new(nflag, nqueueIdx)	
		    else
		    	pDlg:setAtelierProduceParam(nflag, nqueueIdx)
		    end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.atelierguide then
			local DlgAtelierGuide = require("app.layer.atelier.DlgAtelierGuide")
			local pDlg, bNew = getDlgByType(e_dlg_index.atelierguide)
			if not pDlg then
		    	pDlg = DlgAtelierGuide.new()		       
		    end
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgtask then			
			local DlgTask = require("app.layer.task.DlgTask")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgtask)
			if not pDlg then
		    	pDlg = DlgTask.new(pMsgObj.nIndex)
		    else				    	       
		    	pDlg:setGuideIndex(pMsgObj.nIndex)
		    end
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgtaskcountry then
			local DlgTaskCountry = require("app.layer.newcountry.countrytask.DlgTaskCountry")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgtaskcountry)
			if not pDlg then
		    	pDlg = DlgTaskCountry.new()			    	      
		    end
			pDlg:showDlg(bNew)
			--建筑引导对话
			showBuildGuideBegin(e_dlg_index.dlgtaskcountry)	
		elseif nDlgType == e_dlg_index.dlgrank then
			-- local nLimitLV = tonumber(getRankParam("openLv") or 0)
			-- if Player:getPlayerInfo().nLv < nLimitLV then
			-- 	TOAST(string.format(getConvertedStr(6, 10500), nLimitLV, getConvertedStr(6, 10233)))
			-- 	return
			-- end	
			--开启判断提示
			local bIsOpen = getIsReachOpenCon(6)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end

			local DlgRank = require("app.layer.rank.DlgRank")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgrank)
			if not pDlg then
				pDlg = DlgRank.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgsettingmain then
			local DlgSettingMain = require("app.layer.setting.DlgSettingMain")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgsettingmain)
			if not pDlg then
				pDlg = DlgSettingMain.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgcontactservice then
			local DlgContactService = require("app.layer.setting.DlgContactService")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcontactservice)
			if not pDlg then
				pDlg = DlgContactService.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlggamesetting then
			local DlgGameSetting = require("app.layer.setting.DlgGameSetting")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlggamesetting)
			if not pDlg then
				pDlg = DlgGameSetting.new()
			end				
			pDlg:showDlg(bNew)			
		elseif nDlgType == e_dlg_index.dlgnodisturbsetting then
			local DlgNoDisturbSetting = require("app.layer.setting.DlgNoDisturbSetting")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgnodisturbsetting)
			if not pDlg then
				pDlg = DlgNoDisturbSetting.new()
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgvipprivileges then			
			local DlgVipPrivileges = require("app.layer.vip.DlgVipPrivileges")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgvipprivileges)
			if not pDlg then
				pDlg = DlgVipPrivileges.new(pMsgObj.nVipLv)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgrecharge then
			local DlgRecharge = require("app.layer.vip.DlgRecharge")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgrecharge)
			if not pDlg then
				pDlg = DlgRecharge.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgcountry then
			--开启判断
			local bIsOpen = getIsReachOpenCon(3)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
					
			local DlgCountry = require("app.layer.country.DlgCountry")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountry)
			if not pDlg then
				pDlg = DlgCountry.new()
			end				
			pDlg:showDlg(bNew)
			--建筑引导对话
			showBuildGuideBegin(e_dlg_index.dlgcountry)			
		elseif nDlgType == e_dlg_index.dlgcountryofficials then
			--开启判断
			local bIsOpen = getIsReachOpenCon(3)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			--每次进入官员界面获取一次加载
			SocketManager:sendMsg("loadOfficialInfo", {},function (__msg)
				if  __msg.head.state == SocketErrorType.success then 
					if __msg.head.type == MsgType.loadOfficialInfo.id then
							local DlgCountryOfficials = require("app.layer.country.DlgCountryOfficials")			
							local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountryofficials)
							if not pDlg then
								pDlg = DlgCountryOfficials.new()
							end				
							pDlg:showDlg(bNew)			
					end
				else
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			    end
			end)		
		elseif nDlgType == e_dlg_index.dlggeneralrenmian then
			local DlgGeneralRenmian = require("app.layer.country.DlgGeneralRenmian")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlggeneralrenmian)
			if not pDlg then
				pDlg = DlgGeneralRenmian.new()
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgcountrylog then
			local DlgCountryLog = require("app.layer.country.DlgCountryLog")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountrylog)
			if not pDlg then
				pDlg = DlgCountryLog.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgcountryglory then
			bDelay = true
			SocketManager:sendMsg("loadCountryGlory", {}, function (__msg)
			    if  __msg.head.state == SocketErrorType.success then 
			        if __msg.head.type == MsgType.loadCountryGlory.id then
						local DlgCountryGlory = require("app.layer.country.DlgCountryGlory")			
						local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountryglory)
						if not pDlg then
							pDlg = DlgCountryGlory.new()
						end				
						pDlg:showDlg(bNew)
						--建筑引导对话
						showBuildGuideBegin(e_dlg_index.dlgcountryglory)	
						--回调	
						if nHandler then
							nHandler(nDlgType)
						end						    
			        end
			    else
			        --弹出错误提示语
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			        --回调	
			        if nHandler then
			        	nHandler(nDlgType)
			        end
			    end
			 end,-1)
		elseif nDlgType == e_dlg_index.dlgcountrycity then
			--开启判断
			local bIsOpen = getIsReachOpenCon(10)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end

			local DlgCountryCity = require("app.layer.country.DlgCountryCity")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountrycity)
			if not pDlg then
				pDlg = DlgCountryCity.new()
			end				
			pDlg:showDlg(bNew)			
		elseif nDlgType == e_dlg_index.dlgofficialprivilege then
			local DlgOfficialPrivilege = require("app.layer.country.DlgOfficialPrivilege")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgofficialprivilege)
			if not pDlg then
				pDlg = DlgOfficialPrivilege.new()
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgsenddecree then
			local DlgSendDecree = require("app.layer.country.DlgSendDecree")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgsenddecree)
			if not pDlg then
				pDlg = DlgSendDecree.new()
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgcountrydevelop then
			--开启判断
			local bIsOpen = getIsReachOpenCon(3)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end			
			local DlgCountryDevelop = require("app.layer.country.DlgCountryDevelop")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountrydevelop)
			if not pDlg then
				pDlg = DlgCountryDevelop.new()
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgnobilitypromote then
			local DlgNobilityPromote = require("app.layer.country.DlgNobilityPromote")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgnobilitypromote)
			if not pDlg then
				pDlg = DlgNobilityPromote.new()
			end				
			pDlg:showDlg(bNew)		
		elseif nDlgType == e_dlg_index.dlgchoicecountry then
			local DlgChoiceCountry = require("app.layer.country.DlgChoiceCountry")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgchoicecountry)
			if not pDlg then
				pDlg = DlgChoiceCountry.new(pMsgObj.nCallBackFunc)
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgfirstrecharge then			
			local pBActivity = Player:getActById(e_id_activity.firstrecharge)--
			if pBActivity then
				local DlgFirstRecharge = require("app.layer.activityb.firstrecharge.DlgFirstRecharge")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgfirstrecharge)
				if not pDlg then
					pDlg = DlgFirstRecharge.new()
				end				
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end		
		elseif nDlgType == e_dlg_index.dlgfreebenefits  then --免费福利界面			
			local pBActivity = Player:getActById(e_id_activity.freebenefits)--
			if pBActivity then
				local DlgFreeBenefits = require("app.layer.activityb.freebenefits.DlgFreeBenefits")
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgfreebenefits)
				if not pDlg then
					pDlg = DlgFreeBenefits.new()
				end
				pDlg:showDlg(bNew)	
			else
				TOAST(getConvertedStr(6, 10522))
			end					
		elseif nDlgType == e_dlg_index.dlgplayerlvup then
			local DlgPlayerLvUp = require("app.module.DlgPlayerLvUp")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgplayerlvup)
			if not pDlg then
				pDlg = DlgPlayerLvUp.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.vipgitfgoodtip then
			local tGood = pMsgObj.tShopBase
			if not tGood then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgVipGitfGoodTip = require("app.layer.shop.DlgVipGitfGoodTip")			
			local pDlg, bNew = getDlgByType(e_dlg_index.vipgitfgoodtip)
			if not pDlg then
				pDlg = DlgVipGitfGoodTip.new(pMsgObj)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgbuildsuburb then
			local tBuildData = pMsgObj.tData
			local DlgBuildSuburb = require("app.layer.build.DlgBuildSuburb")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgbuildsuburb)
			if not pDlg then
				pDlg = DlgBuildSuburb.new(tBuildData)
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.equipdetails then
			local tEquipData = pMsgObj.tData
			local DlgEquipDetails = require("app.layer.refineshop.DlgEquipDetails")			
			local pDlg, bNew = getDlgByType(e_dlg_index.equipdetails)
			if not pDlg then
				pDlg = DlgEquipDetails.new(tEquipData)
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgfriends then	
			--每次打开对话框之前刷新一次数据
			SocketManager:sendMsg("loadFriendsInfo", {}, function (__msg)
				local DlgFriendsSys = require("app.layer.friends.DlgFriendsSys")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgfriends)
				if not pDlg then
					pDlg = DlgFriendsSys.new()
				end				
				pDlg:showDlg(bNew)	
			 end,-1)	
		elseif nDlgType == e_dlg_index.dlgfriendselect then		
			SocketManager:sendMsg("loadRecentFriends", {}, function (__msg)
				local DlgFriendSelect = require("app.layer.friends.DlgFriendSelect")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgfriendselect)
				if not pDlg then
					pDlg = DlgFriendSelect.new()
				end				
				pDlg:showDlg(bNew)	
			 end,-1)				
	
		elseif nDlgType == e_dlg_index.dlgfriendreport then
			if not pMsgObj.tData then
				return
			end
			local DlgFriendReport = require("app.layer.friends.DlgFriendReport")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgfriendreport)
			if not pDlg then
				pDlg = DlgFriendReport.new(pMsgObj.tData)
			else
				pDlg:setCurData(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgsevenkingrank then
			local pBActivity = Player:getActById(e_id_activity.sevenking)
			if not pBActivity then
				return
			end
			local DlgSevenKingRank = require("app.layer.activitya.DlgSevenKingRank")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgsevenkingrank)
			if not pDlg then
				pDlg = DlgSevenKingRank.new(pMsgObj.nRankType, pMsgObj.bSHowRank)
			else
				pDlg:setSelectParam(pMsgObj.nRankType, pMsgObj.bSHowRank)
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgiconsetting then
			local nPage = pMsgObj.nPage or 1
			local DlgIconSetting = require("app.layer.playerinfo.DlgIconSetting")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgiconsetting)
			if not pDlg then
				pDlg = DlgIconSetting.new(nPage)
			else
				pDlg:setDlgPage(nPage)									
			end				
			pDlg:showDlg(bNew)		
		elseif nDlgType == e_dlg_index.dlgredpocketsend then
			local DlgRedPocketSend = require("app.layer.redpocket.DlgRedPocketSend")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgredpocketsend)
			if not pDlg then
				pDlg = DlgRedPocketSend.new(pMsgObj.nRedPocket)				
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgredpocketcatchdetail then
			local DlgRedPocketCatchDetail = require("app.layer.redpocket.DlgRedPocketCatchDetail")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgredpocketcatchdetail)
			if not pDlg then
				pDlg = DlgRedPocketCatchDetail.new(pMsgObj.nRedPocket)				
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgredpocketsenddetail then
			local DlgRedPocketSendDetail = require("app.layer.redpocket.DlgRedPocketSendDetail")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgredpocketsenddetail)
			if not pDlg then
				pDlg = DlgRedPocketSendDetail.new(pMsgObj.nRedPocket)				
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgredpocketopen then
			local DlgRedPocketOpen = require("app.layer.redpocket.DlgRedPocketOpen")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgredpocketopen)
			if not pDlg then
				pDlg = DlgRedPocketOpen.new(pMsgObj.pData)				
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgredpocketcheck then
			local DlgRedPocketCheck = require("app.layer.redpocket.DlgRedPocketCheck")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgredpocketcheck)
			if not pDlg then
				pDlg = DlgRedPocketCheck.new(pMsgObj.pData)				
			end				
			pDlg:showDlg(bNew)		
		elseif nDlgType == e_dlg_index.dlgbuffs then
			local DlgBuffs = require("app.layer.buff.DlgBuffs")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgbuffs)
			if not pDlg then
				pDlg = DlgBuffs.new()				
			end				
			pDlg:showDlg(bNew)		
		elseif nDlgType == e_dlg_index.dlgroyaltycollect then
			local DlgRoyaltyCollect = require("app.layer.activitya.royaltycollect.DlgRoyaltyCollect")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgroyaltycollect)
			if not pDlg then
				pDlg = DlgRoyaltyCollect.new()				
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgchiefhouse then
			local DlgChiefHouse = require("app.layer.chiefhouse.DlgChiefHouse")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgchiefhouse)
			if not pDlg then
				pDlg = DlgChiefHouse.new()				
			end				
			pDlg:showDlg(bNew)			
		elseif nDlgType == e_dlg_index.troopsdetail then
			local DlgTroopsDetail = require("app.layer.chiefhouse.DlgTroopsDetail")			
			local pDlg, bNew = getDlgByType(e_dlg_index.troopsdetail)
			if not pDlg then
				pDlg = DlgTroopsDetail.new()				
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgarena then

			if not getIsReachOpenCon(28) then
				return
			end

			local nFirstPag = pMsgObj.nFPage --一级分页
			local nSecPag = pMsgObj.nSPage   --二级分页
 			--判断是否已经设置了竞技场阵容
			local isSetted = Player:getArenaData():isHaveSetArenaLineUp()
			if not isSetted then--已经设置了竞技场阵容
				local ArenaFunc = require("app.layer.arena.ArenaFunc")
				ArenaFunc.adjustArenaLineUp(true)
			end
			local DlgArena = require("app.layer.arena.DlgArena")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgarena)
			if not pDlg then					
				pDlg = DlgArena.new()								
			end
			pDlg:setGuideParam(nFirstPag, nSecPag)				
			pDlg:showDlg(bNew)				
		-- elseif nDlgType == e_dlg_index.arenaprizepreview then
		-- 	local DlgArenaPrizePreview = require("app.layer.arena.DlgArenaPrizePreview")			
		-- 	local pDlg, bNew = getDlgByType(e_dlg_index.arenaprizepreview)
		-- 	if not pDlg then
		-- 		pDlg = DlgArenaPrizePreview.new()				
		-- 	end				
		-- 	pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.arenabattlerecord then
			--请求战斗记录
			-- SocketManager:sendMsg("checkArenaRecord", {}, function (  __msg )
				-- body
				-- if __msg.head.state == SocketErrorType.success then
					local DlgArenaBattleRecord = require("app.layer.arena.DlgArenaBattleRecord")			
					local pDlg, bNew = getDlgByType(e_dlg_index.arenabattlerecord)
					if not pDlg then
						pDlg = DlgArenaBattleRecord.new()				
					end				
					pDlg:showDlg(bNew)
			-- 	else
			-- 		TOAST(SocketManager:getErrorStr(__msg.head.state))
			-- 	end
			-- end) 
		-- elseif nDlgType == e_dlg_index.arenaadjustlineup then			
		-- 	local DlgArenaAdjustLineUp = require("app.layer.arena.DlgArenaAdjustLineUp")			
		-- 	local pDlg, bNew = getDlgByType(e_dlg_index.arenaadjustlineup)
		-- 	if not pDlg then
		-- 		pDlg = DlgArenaAdjustLineUp.new()				
		-- 	end				
		-- 	pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.arenafightdetail then
			local bShare = pMsgObj.bShare or false
			local DlgArenaFightDetail = require("app.layer.arena.DlgArenaFightDetail")			
			local pDlg, bNew = getDlgByType(e_dlg_index.arenafightdetail)
			if not pDlg then
				pDlg = DlgArenaFightDetail.new(pMsgObj.tFightDetail, bShare)				
			end				
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgpowerbalance then
			local nId = pMsgObj.nPlayerId --玩家id
			local sName = pMsgObj.sName --玩家名称
			local nLv = pMsgObj.nLv --玩家等级
			local tRbData = pMsgObj.tRbData
			if tRbData then
				local DlgPowerBalance = require("app.layer.promote.DlgPowerBalance")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgpowerbalance)
				if not pDlg then
					pDlg = DlgPowerBalance.new(nId, sName, nLv)				
				end			
				pDlg:setCurData(tRbData)	
				pDlg:showDlg(bNew)		
			else
				SocketManager:sendMsg("reqPowerBalance", {nId, Player.baseInfos.pid},function (__msg)
				    if  __msg.head.state == SocketErrorType.success then 
				       if __msg.head.type == MsgType.reqPowerBalance.id then
				       		-- dump(__msg.body, "玩家战力对比 ==")	
							local DlgPowerBalance = require("app.layer.promote.DlgPowerBalance")			
							local pDlg, bNew = getDlgByType(e_dlg_index.dlgpowerbalance)
							if not pDlg then
								pDlg = DlgPowerBalance.new(nId, sName, nLv)				
							end			
							pDlg:setCurData(__msg.body)	
							pDlg:showDlg(bNew)					       		
						    --回调	
						    if nHandler then
						    	nHandler(nDlgType)
						    end
				       end
				    else
				        --弹出错误提示语
				        TOAST(SocketManager:getErrorStr(__msg.head.state))
				        --回调	
					    if nHandler then
					    	nHandler(nDlgType)
					    end
				    end
				end,-1)	
			end																			
		elseif nDlgType == e_dlg_index.dlgremains then																						
			local DlgRemains = require("app.layer.remains.DlgRemains")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgremains)
			if not pDlg then
				pDlg = DlgRemains.new()				
		end	
			pDlg:showDlg(bNew)		
		elseif nDlgType == e_dlg_index.autobuild then		
			local DlgAutoBuild = require("app.layer.autobuild.DlgAutoBuild")			
			local pDlg, bNew = getDlgByType(e_dlg_index.autobuild)
			if not pDlg then
				pDlg = DlgAutoBuild.new()				
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.custombuildorder then
			local pBuildData = pMsgObj.pBuildData --
			if not pBuildData then
				return
			end
			local DlgCustomBuildOrder = require("app.layer.autobuild.DlgCustomBuildOrder")			
			local pDlg, bNew = getDlgByType(e_dlg_index.custombuildorder)
			if not pDlg then
				pDlg = DlgCustomBuildOrder.new(pBuildData)	
			else
				pDlg:setData(pBuildData)							
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.zhouwangtrial then
			local DlgZhouWangTrial = require("app.layer.activityb.zhouwangtrial.DlgZhouWangTrial")			
			local pDlg, bNew = getDlgByType(e_dlg_index.zhouwangtrial)
			if not pDlg then
				pDlg = DlgZhouWangTrial.new()							
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgusefragments then
			local DlgUseFragments = require("app.layer.activityb.zhouwangtrial.DlgUseFragments")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgusefragments)
			if not pDlg then
				pDlg = DlgUseFragments.new()							
			end				
			pDlg:showDlg(bNew)				
		elseif nDlgType == e_dlg_index.zhouwangtrialdetail then
			if not pMsgObj.tViewDotMsg then
				return
			end			
			local DlgZhouwangTrialDetail = require("app.layer.world.DlgZhouwangTrialDetail")			
			local pDlg, bNew = getDlgByType(e_dlg_index.zhouwangtrialdetail)
			if not pDlg then
				pDlg = DlgZhouwangTrialDetail.new()							
			end				
			pDlg:setData(pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)	
		elseif nDlgType == e_dlg_index.dlgzhouwangdots then	
			local nRedNum = 0
			local pActivity=Player:getActById(e_id_activity.zhouwangtrial)
			if pActivity then
				nRedNum = pActivity:getCurKingZhouNum()
			end
			local nMyBlockId = Player:getWorldData():getMyCityBlockId()
			local tDots = Player:getWorldData():getBlockKingZhou(nMyBlockId)
			if nRedNum ~= table.nums(tDots) then
				SocketManager:sendMsg("reqWorldBlock", {nMyBlockId}, function()
					local DlgZhouWangDots = require("app.layer.activityb.zhouwangtrial.DlgZhouWangDots")			
					local pDlg, bNew = getDlgByType(e_dlg_index.dlgzhouwangdots)
					if not pDlg then
						pDlg = DlgZhouWangDots.new()							
					end
					pDlg:showDlg(bNew)
				end)
			else
				local DlgZhouWangDots = require("app.layer.activityb.zhouwangtrial.DlgZhouWangDots")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgzhouwangdots)
				if not pDlg then
					pDlg = DlgZhouWangDots.new()							
				end
				pDlg:showDlg(bNew)				
			end		
		elseif nDlgType == e_dlg_index.dlgdevelopgift then
			local DlgDevelopGift = require("app.layer.activityb.developgift.DlgDevelopGift")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgdevelopgift)
			if not pDlg then
				pDlg = DlgDevelopGift.new()							
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgfemaleheros then
			local DlgFemaleHeros = require("app.layer.femalehero.DlgFemaleHeros")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgfemaleheros)
			if not pDlg then
				pDlg = DlgFemaleHeros.new()							
			end
			pDlg:showDlg(bNew)			
		end	
		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end
end


--打开对话框
-- 4000-4499
function showDlgByType7( pMsgObj, nHandler )
	-- body
	sendMsg(ghd_guide_finger_show_or_hide, false)
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1      --dlg类型
		local nIndex   = pMsgObj.nIndex or 1      --页面分页
		local nId      = pMsgObj.nId              --帮助id或下标
		local nOpenDlgType = pMsgObj.nOpenDlgType --打开帮助窗口的dlg类型
		local nCost = pMsgObj.nCost               --加速消耗
		local nSpeedType = pMsgObj.nSpeedType     --加速类型
		local nWeaponId = pMsgObj.nWeaponId       --神兵ID
		local bDelay   = false --是否需要延迟回调 
		if nDlgType == e_dlg_index.dlghelpcenter then --帮助中心窗口
			local DlgHelpCenter = require("app.layer.help.DlgHelpCenter")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlghelpcenter)
		    if not pDlg then
		    	pDlg = DlgHelpCenter.new(nOpenDlgType, nDlgSecType)        
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlghelpcontent then          --帮助内容
			local nDlgSecType = pMsgObj.nDlgSecType		
			local DlgHelpContent = require("app.layer.help.DlgHelpContent")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlghelpcontent)
		    if not pDlg then
		    	pDlg = DlgHelpContent.new(nId, nOpenDlgType, nDlgSecType)
		    end	
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgnoticemain then               -- 公告列表
			local DlgNoticeMain = require("app.layer.notice.DlgNoticeMain")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgnoticemain)
		    if not pDlg then
		    	pDlg = DlgNoticeMain.new()        
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgnoticecontent then        -- 公告内容
			local DlgNoticeContent = require("app.layer.notice.DlgNoticeContent")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgnoticecontent)
		    if not pDlg then
		    	pDlg = DlgNoticeContent.new(nId)        
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgweaponmain then           --神兵列表
			--判断是否已开放
			local bCanOpen = getIsReachOpenCon(5)
			if not bCanOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end

			SocketManager:sendMsg("loadAllWeaponData", {})		
			local DlgWeaponMain = require("app.layer.weapon.DlgWeaponMain")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgweaponmain)
		    if not pDlg then
		    	pDlg = DlgWeaponMain.new()
		    end	
		    pDlg:showDlg(bNew)
		    --建筑引导对话
			showBuildGuideBegin(e_dlg_index.dlgweaponmain)
		elseif nDlgType == e_dlg_index.dlgweaponinfo then           --神兵信息
			local bCanOpen = getIsReachOpenCon(5)
			if not bCanOpen then
				return
			end
			local DlgWeaponInfo = require("app.layer.weapon.DlgWeaponInfo")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgweaponinfo)
		    if not pDlg then
		    	pDlg = DlgWeaponInfo.new(nIndex, nId)
		    end	
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgspeedupadvance then       --加速对话框			
			local DlgSpeedUpAdvance = require("app.layer.weapon.DlgSpeedUpAdvance")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgspeedupadvance)
		    if not pDlg then
		    	pDlg = DlgSpeedUpAdvance.new(nCost, nSpeedType, nWeaponId)
		    end
		    pDlg:showDlg(bNew)	 
		elseif nDlgType == e_dlg_index.dlgmerchants then            --商队界面			
			local DlgMerchants = require("app.layer.merchants.DlgMerchants")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgmerchants)
		    if not pDlg then
		    	pDlg = DlgMerchants.new()
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgequipfullattr then      --满属性装备信息			
			local DlgEquipFullAttr = require("app.layer.smithshop.DlgEquipFullAttr")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgequipfullattr)
		    if not pDlg then
		    	pDlg = DlgEquipFullAttr.new(nId)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgfriendshare then      --好友分享窗口			
			local DlgFriendShare = require("app.layer.share.DlgFriendShare")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgfriendshare)
		    if not pDlg then
		    	pDlg = DlgFriendShare.new()
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgrechargetip then      --充值二次确认窗口			
			local DlgRechargeTip = require("app.layer.recharge.DlgRechargeTip")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgrechargetip)
		    if not pDlg then
		    	pDlg = DlgRechargeTip.new()
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlggrowfound then        --活动成长基金
			local pBActivity = Player:getActById(e_id_activity.growthfound)--
			if pBActivity then
				SocketManager:sendMsg("reqBuyFoundsPlayerNum", {}, function(__msg)
		 			-- body
		 		end)
				local DlgGrowFound = require("app.layer.activityb.growthfound.DlgGrowFound")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlggrowfound)
				if not pDlg then
					pDlg = DlgGrowFound.new()
				end				
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.dlgbuygrowthfound then        --成长基金购买对话框
			local DlgBuyGrowthFound = require("app.layer.activityb.growthfound.DlgBuyGrowthFound")
			local tData = pMsgObj.tData       --成长基金数据		
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgbuygrowthfound)
			if not pDlg then
				pDlg = DlgBuyGrowthFound.new(tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dayloginawards then        --每日登录奖励弹窗
			local DlgDayLoginAwards = require("app.layer.dayloginawd.DlgDayLoginAwards")
			local pDlg, bNew = getDlgByType(e_dlg_index.dayloginawards)
			if not pDlg then
				pDlg = DlgDayLoginAwards.new(tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgspecialsale then        --特价卖场活动
			local pBActivity = Player:getActById(e_id_activity.specialsale)--
			if pBActivity then
				local DlgSpecialSale = require("app.layer.activityb.specialsale.DlgSpecialSale")
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgspecialsale)
				if not pDlg then
					pDlg = DlgSpecialSale.new()
				end				
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end		
		elseif nDlgType == e_dlg_index.dlglevelupawards then        --升级奖励弹窗
			local DlgLevelUpAwards = require("app.layer.playerinfo.DlgLevelUpAwards")
			local tData = pMsgObj.tData
			local nType = pMsgObj.nAwardType
			local pDlg, bNew = getDlgByType(e_dlg_index.dlglevelupawards)
		    if not pDlg then
		        pDlg = DlgLevelUpAwards.new(tData, nType)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgfarmtroopsplan then        --活动屯田计划
			local pBActivity = Player:getActById(e_id_activity.farmtroopsplan)--
			if pBActivity then
				local DlgFarmTroopsPlan = require("app.layer.activityb.farmtroopsplan.DlgFarmTroopsPlan")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgfarmtroopsplan)
				if not pDlg then
					pDlg = DlgFarmTroopsPlan.new()
				end				
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.lockherotip then        --解锁上阵武将提示对话框
			local DlgLockHeroTip = require("app.layer.hero.DlgLockHeroTip")
			local tData = pMsgObj.tData
			local sStr = pMsgObj.sStr
			local pDlg, bNew = getDlgByType(e_dlg_index.lockherotip)
		    if not pDlg then
		        pDlg = DlgLockHeroTip.new()
		    end
		    pDlg:setShowData(tData, sStr)
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgweaponshareinfo then        --升级奖励弹窗
			local DlgWeaponShareInfo = require("app.layer.weapon.DlgWeaponShareInfo")
			local tData = pMsgObj.tData
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgweaponshareinfo)
		    if not pDlg then
		        pDlg = DlgWeaponShareInfo.new(tData)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgemploytip then        --科技院正在升级且已买vip5礼包时雇佣提示对话框
			local DlgEmployTip = require("app.layer.technology.DlgEmployTip")
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgemploytip)
		    if not pDlg then
		        pDlg = DlgEmployTip.new(pMsgObj.nTipIdx)
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.rescollect then        --资源征收弹窗
			local DlgResCollect = require("app.module.DlgResCollect")
			local pDlg, bNew = getDlgByType(e_dlg_index.rescollect)
		    if not pDlg then
		        pDlg = DlgResCollect.new()
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgnewfirstrecharge then			--新版首充好礼
			local pBActivity = Player:getActById(e_id_activity.newfirstrecharge)
			if pBActivity then
				local DlgNewFirstRecharge = require("app.layer.activityb.newfirstrecharge.DlgNewFirstRecharge")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgnewfirstrecharge)
				if not pDlg then
					pDlg = DlgNewFirstRecharge.new()
				end				
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.restructsuburb then			--改建资源田弹窗
			local DlgRestructSuburb = require("app.module.DlgRestructSuburb")			
			local pDlg, bNew = getDlgByType(e_dlg_index.restructsuburb)
			local nCell = pMsgObj.nCell
			if not pDlg then
				pDlg = DlgRestructSuburb.new(nCell)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.restructrecruit then			--改建募兵府弹窗
			local DlgRestructRecruit = require("app.layer.recruitsodiers.DlgRestructRecruit")			
			local pDlg, bNew = getDlgByType(e_dlg_index.restructrecruit)
			local nCell = pMsgObj.nRecruitTp 	--当前募兵类型(1步,2骑,3弓)
			if not pDlg then
				pDlg = DlgRestructRecruit.new(nRecruitTp)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dragontreasure  then --活动寻龙夺宝
			local pBActivity = Player:getActById(e_id_activity.dragontreasure) 
			if pBActivity then
				local DlgDragonTreasure = require("app.layer.activityb.dragontreasure.DlgDragonTreasure")
				local pDlg, bNew = getDlgByType(e_dlg_index.dragontreasure)
				if not pDlg then
					pDlg = DlgDragonTreasure.new()
				end
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.buystuff then			--购买道具对话框
			local DlgBuyStuff = require("app.layer.activityb.dragontreasure.DlgBuyStuff")			
			local pDlg, bNew = getDlgByType(e_dlg_index.buystuff)
			local tItemData = pMsgObj.tItemData --物品数据
			local nItemId = pMsgObj.nItemId 	--物品id
			local tCost = pMsgObj.tCost 		--购买物品消耗{k,v}
			local nMaxCnt = pMsgObj.nMaxCnt 	--最大可以购买数量
			local sMsgType = pMsgObj.sMsgType 	--协议
			local tHandler = pMsgObj.tHandler
			-- dump(tHandler,"2037")
			if not pDlg then
				pDlg = DlgBuyStuff.new()
			end
			pDlg:setItemDataById(tItemData, nItemId, tCost, sMsgType, nMaxCnt,tHandler)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.gettargetgoodstip then			--寻龙夺宝获得目标物品弹窗
			local DlgGetTargetGoodsTip = require("app.module.DlgGetTargetGoodsTip")			
			local pDlg, bNew = getDlgByType(e_dlg_index.gettargetgoodstip)
			local tData = pMsgObj.tData
			if not pDlg then
				pDlg = DlgGetTargetGoodsTip.new()
			end
			pDlg:setCurData(tData)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgnewgrowfound then        --活动新版成长基金
			local pBActivity = Player:getActById(e_id_activity.newgrowthfound)--
			if pBActivity then
				local DlgNewGrowFound = require("app.layer.activityb.growthfound.DlgNewGrowFound")			
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgnewgrowfound)
				if not pDlg then
					pDlg = DlgNewGrowFound.new()
				end				
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.dlgpowermark then			--战力评分对话框
			local nId = pMsgObj.nPlayerId or tonumber(Player:getPlayerInfo().pid) --玩家id
			local sName = pMsgObj.sName --玩家名称
			local nLv = pMsgObj.nLv --玩家等级
			local tRbData = pMsgObj.tRbData   --机器人数据
			local bFromShare = pMsgObj.bFromShare --从分享弹出的不需要分享按钮了
			if tRbData then
				local DlgPowerMark = require("app.layer.promote.DlgPowerMark")
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgpowermark)
				if not pDlg then
					pDlg = DlgPowerMark.new(nId, sName, nLv, bFromShare)
				end
				-- dump(__msg.body, "玩家战力总评 ==")
				pDlg:setCurData(tRbData)
				pDlg:showDlg(bNew)
			else
				if nId then
					SocketManager:sendMsg("reqCheckPowerOut", {nId},function (__msg)
					    if  __msg.head.state == SocketErrorType.success then 
					       if __msg.head.type == MsgType.reqCheckPowerOut.id then
								local DlgPowerMark = require("app.layer.promote.DlgPowerMark")
							    local pDlg, bNew = getDlgByType(e_dlg_index.dlgpowermark)
							    if not pDlg then
							    	pDlg = DlgPowerMark.new(nId, sName, nLv, bFromShare)
							    end
							    -- dump(__msg.body, "玩家战力总评 ==")
							    pDlg:setCurData(__msg.body)
							    pDlg:showDlg(bNew)
							    --回调	
							    if nHandler then
							    	nHandler(nDlgType)
							    end
					       end
					    else
					        --弹出错误提示语
					        TOAST(SocketManager:getErrorStr(__msg.head.state))
					        --回调	
						    if nHandler then
						    	nHandler(nDlgType)
						    end
					    end
					end,-1)
				end
			end
		elseif nDlgType == e_dlg_index.dlgequipinfo then        --装备信息弹窗
			local sUuid = pMsgObj.sUuid
			local nKind = pMsgObj.nKind
			local nHeroId = pMsgObj.nHeroId
			local DlgEquipInfo = require("app.layer.equip.DlgEquipInfo")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgequipinfo)
			if not pDlg then
				pDlg = DlgEquipInfo.new(sUuid, nKind, nHeroId)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgteachplay then        --新手向导
			local DlgTeachPlay = require("app.layer.newguide.DlgTeachPlay")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgteachplay)
			if not pDlg then
				pDlg = DlgTeachPlay.new()
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgteachplaydetail then        --新手向导第二个窗口
			local DlgTeachPlayDetail = require("app.layer.newguide.DlgTeachPlayDetail")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgteachplaydetail)
			local tData = pMsgObj.tData
			if not pDlg then
				pDlg = DlgTeachPlayDetail.new(tData)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgherostarsoul then        --武将星魂
			local bOpen = getIsReachOpenCon(25, true)
			if not bOpen then
				return
			end
			local DlgHeroStarSoul = require("app.layer.hero.DlgHeroStarSoul")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgherostarsoul)
			local tData = pMsgObj.tData
			local nTeamType = pMsgObj.nTeamType
			if not pDlg then
				pDlg = DlgHeroStarSoul.new(tData, nTeamType)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgpasskillhero then        --过关斩将
			local bOpen = Player:getPassKillHeroData():isPassKillHeroOpen()
			if bOpen == false then
				TOAST(getConvertedStr(7, 10406))
				return
			end
			local DlgPassKillHero = require("app.layer.passkillhero.DlgPassKillHero")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgpasskillhero)
			local nPagIndex = pMsgObj.nPagIndex --几级分页
			if not pDlg then
				pDlg = DlgPassKillHero.new()
			end
			if nPagIndex then
				pDlg:setDefOpenIndex(nPagIndex)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.killheroselhero then        --过关斩将选择上阵武将
			local DlgKillHeroSelHero = require("app.layer.passkillhero.DlgKillHeroSelHero")			
			local pDlg, bNew = getDlgByType(e_dlg_index.killheroselhero)
			local tData = pMsgObj.tData
			local nPos = pMsgObj.nPos
			if not pDlg then
				pDlg = DlgKillHeroSelHero.new(tData, nPos)
			end
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.expeditefightdetail then
			local bShare = pMsgObj.bShare or false
			local DlgExpediteFightDetail = require("app.layer.passkillhero.DlgExpediteFightDetail")			
			local pDlg, bNew = getDlgByType(e_dlg_index.expeditefightdetail)
			if not pDlg then
				pDlg = DlgExpediteFightDetail.new(pMsgObj.tFightDetail, bShare)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgcountrytnoly then --国家科技界面
			--开启判断
			local bIsOpen = getIsReachOpenCon(3)
			if not bIsOpen then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgCountryTnoly = require("app.layer.newcountry.newcountrytnoly.DlgCountryTnoly")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountrytnoly)
			if not pDlg then
				pDlg = DlgCountryTnoly.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgcountrytnolydetail then --国家科技详情界面
			local DlgCountryTnolyDetail = require("app.layer.newcountry.newcountrytnoly.DlgCountryTnolyDetail")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountrytnolydetail)
			local tData = pMsgObj.tData
			if not pDlg then
				pDlg = DlgCountryTnolyDetail.new(tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgtnolyedit then --国家科技编辑推荐界面
			local DlgTnolyEdit = require("app.layer.newcountry.newcountrytnoly.DlgTnolyEdit")			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgtnolyedit)
			if not pDlg then
				pDlg = DlgTnolyEdit.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgrecruitsodiers then --募兵府			
			if showBuildOpenTips(e_build_ids.mbf) == false then
		        --回调	
			    if nHandler then
			    	nHandler(nDlgType)
			    end
				return
			end
			local DlgRecruitSodiers = require("app.layer.recruitsodiers.DlgRecruitSodiers")
		    local pDlg, bNew = getDlgByType(nDlgType)
		    if not pDlg then
		    	pDlg = DlgRecruitSodiers.new()
		    end
		    pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgwelcomeback  then --王者归来
			-- local pBActivity = Player:getActById(e_id_activity.welcomeback) 
			-- if pBActivity then
				local DlgWelcomeBack = require("app.layer.activityb.welcomeback.DlgWelcomeBack")
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgwelcomeback)
				if not pDlg then
					pDlg = DlgWelcomeBack.new()
				end
				pDlg:showDlg(bNew)
			-- else
			-- 	TOAST(getConvertedStr(6, 10522))
			-- end
		end
		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end
end

--打开对话框
-- 4500-4999
function showDlgByType8( pMsgObj, nHandler )
	-- body
	sendMsg(ghd_guide_finger_show_or_hide, false)
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		local nIndex   = pMsgObj.nIndex or 1  --页面分页
		local bDelay   = false --是否需要延迟回调 
		
		if nDlgType == e_dlg_index.dlgblessworld then --福泽天下窗口
			bDelay = true
			SocketManager:sendMsg("reloadBlessWorldData",{},function ( __msg)
				if  __msg.head.state == SocketErrorType.success then 
					if __msg.head.type == MsgType.reloadBlessWorldData.id then
						local pBActivity = Player:getActById(e_id_activity.blessworld)
						if pBActivity then
							-- dump(pBActivity,"pBActivity",20)
							local DlgBlessWorld = require("app.layer.activityb.blessworld.DlgBlessWorld")
							local pDlg, bNew = getDlgByType(e_dlg_index.dlgblessworld)
							if not pDlg then
								pDlg = DlgBlessWorld.new()
							end				
							pDlg:showDlg(bNew)
							--回调	
							if nHandler then
								nHandler(nDlgType)
							end
						else
							TOAST(getConvertedStr(6, 10522))
							--回调	
							if nHandler then
								nHandler(nDlgType)
							end
						end
					end
				else
					 --弹出错误提示语
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
				end
			end,-1)
		elseif nDlgType == e_dlg_index.dlgactloginaward then  --每日收贡
			local pBActivity = Player:getActById(e_id_activity.dayloginaward)
			if pBActivity then
				local DlgActLoginAward = require("app.layer.activityb.dayloginaward.DlgActLoginAward")
				local pDlg, bNew = getDlgByType(e_dlg_index.dayloginaward)
				if not pDlg then
					pDlg = DlgActLoginAward.new()
				end				
				pDlg:showDlg(bNew)
			else
				TOAST(getConvertedStr(6, 10522))
			end
		elseif nDlgType == e_dlg_index.dlgworldhelp  then  --世界玩法帮助
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgworldhelp)
			local DlgWorldHelp = require("app.layer.worldhelp.DlgWorldHelp")
			if not pDlg then
				pDlg = DlgWorldHelp.new()
			end				
			pDlg:showDlg(bNew)
		end
		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end
end

--打开对话框
-- 5000-5499
function showDlgByType9( pMsgObj, nHandler )
	-- body
	sendMsg(ghd_guide_finger_show_or_hide, false)
	if pMsgObj then
		local nDlgType = pMsgObj.nType  or 1 --dlg类型
		local nIndex   = pMsgObj.nIndex or 1  --页面分页
		local bDelay   = false --是否需要延迟回调 
		
		if nDlgType == e_dlg_index.dlgactivitydesc then --活动介绍界面
			if pMsgObj.nActId then
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgactivitydesc)
				local DlgActivityDesc = require("app.layer.activitymodel.DlgActivityDesc")
				if not pDlg then

					pDlg = DlgActivityDesc.new(pMsgObj.nActId,pMsgObj.nBtnType)
				end				
				pDlg:showDlg(bNew)
			end
		elseif nDlgType == e_dlg_index.dlgareanotopen then --区域未开启提示对话框
			if pMsgObj.tCityData then
				local pDlg, bNew = getDlgByType(e_dlg_index.dlgareanotopen)
				local DlgAreaNotOpen = require("app.layer.world.DlgAreaNotOpen")
				if not pDlg then

					pDlg = DlgAreaNotOpen.new(pMsgObj.tCityData)
				end				
				pDlg:showDlg(bNew)
			end
		elseif nDlgType == e_dlg_index.dlgherotravel then --武将游历对话框
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgherotravel)
			local DlgHeroTravel = require("app.layer.herotravel.DlgHeroTravel")
			if not pDlg then
				pDlg = DlgHeroTravel.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgseveralrecharge then --多次充值界面
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgseveralrecharge)
			local DlgSeveralRecharge = require("app.layer.activityb.severalrecharge.DlgSeveralRecharge")
			if not pDlg then
				pDlg = DlgSeveralRecharge.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgdailygift then --免费宝箱界面
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgdailygift)
			local DlgDailyGift = require("app.layer.dailygift.DlgDailyGift")
			if not pDlg then
				pDlg = DlgDailyGift.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.everydaypreference then --每日特惠
			local pDlg, bNew = getDlgByType(e_dlg_index.everydaypreference)
			local DlgEverydayPreference = require("app.layer.activityb.everydaypreference.DlgEverydayPreference")
			if not pDlg then
				pDlg = DlgEverydayPreference.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgeverypreferencedetail then --每日特惠礼包详情
			
			-- local pDlg, bNew = getDlgByType(e_dlg_index.laba)
			-- local DlgLaba = require("app.layer.activityb.laba.DlgLaba")
			-- if not pDlg then
			-- 	pDlg = DlgLaba.new()
			-- end				
			-- pDlg:showDlg(bNew)

			local pDlg, bNew = getDlgByType(e_dlg_index.dlgeverypreferencedetail)
			local DlgEverydayPreferenceDetail = require("app.layer.activityb.everydaypreference.DlgEverydayPreferenceDetail")
			if not pDlg then
				pDlg = DlgEverydayPreferenceDetail.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgviprechargedetail then --vip充值规则
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgviprechargedetail)
			local DlgVipRechargeDetail = require("app.layer.vip.DlgVipRechargeDetail")
			if not pDlg then
				pDlg = DlgVipRechargeDetail.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.laba then --腊八拉霸
			local pDlg, bNew = getDlgByType(e_dlg_index.laba)
			local DlgLaba = require("app.layer.activityb.laba.DlgLaba")
			if not pDlg then
				pDlg = DlgLaba.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.labarewarddetail then --腊八拉霸奖励预览
			local pDlg, bNew = getDlgByType(e_dlg_index.labarewarddetail)
			local DlgLabaRewardDetail = require("app.layer.activityb.laba.DlgLabaRewardDetail")
			if not pDlg then
				pDlg = DlgLabaRewardDetail.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.wuwangforcast then --武王来袭预告
			local pDlg, bNew = getDlgByType(e_dlg_index.wuwangforcast)
			local DlgWuWangForcast = require("app.layer.activityb.wuwang.DlgWuWangForcast")
			if not pDlg then
				pDlg = DlgWuWangForcast.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.monthcarddesc then --月卡说明
			local pDlg, bNew = getDlgByType(e_dlg_index.monthcarddesc)
			local DlgMonthCardDesc = require("app.layer.vip.DlgMonthCardDesc")
			if not pDlg then
				pDlg = DlgMonthCardDesc.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.attkcity then --攻城掠地
			local pDlg, bNew = getDlgByType(e_dlg_index.attkcity)
			local DlgAttkCity = require("app.layer.attackcity.DlgAttkCity")
			if not pDlg then
				pDlg = DlgAttkCity.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.actaskdetail then --攻城掠地任务详情
			
			local pDlg, bNew = getDlgByType(e_dlg_index.actaskdetail)
			local DlgAcTaskDetail = require("app.layer.attackcity.DlgAcTaskDetail")
			if not pDlg then
				pDlg = DlgAcTaskDetail.new(pMsgObj.tData,pMsgObj.nProcess,pMsgObj.nCurDay)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.acbxdetail then --攻城掠地宝箱详情

			local pDlg, bNew = getDlgByType(e_dlg_index.acbxdetail)
			local DlgAcBxDetail = require("app.layer.attackcity.DlgAcBxDetail")
			if not pDlg then
				pDlg = DlgAcBxDetail.new(pMsgObj.tData)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.luckystar then --福星高照
			
			local pDlg, bNew = getDlgByType(e_dlg_index.luckystar)
			local DlgLuckyStar = require("app.layer.activityb.luckystar.DlgLuckyStar")
			if not pDlg then
				pDlg = DlgLuckyStar.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgluckystaropenall then --福星高照全开
			
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgluckystaropenall)
			local DlgLuckyStarOpenAll = require("app.layer.activityb.luckystar.DlgLuckyStarOpenAll")
			if not pDlg then
				pDlg = DlgLuckyStarOpenAll.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.mingjie then --冥界入侵
			local pDlg, bNew = getDlgByType(e_dlg_index.mingjie)
			local DlgMingjie = require("app.layer.activityb.mingjie.DlgMingjie")
			if not pDlg then
				pDlg = DlgMingjie.new()
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.ghostdomdetail then --幽魂详情界面
			local DlgGhostdomDetail = require("app.layer.world.DlgGhostdomDetail")
			local pDlg, bNew = getDlgByType(e_dlg_index.ghostdomdetail)
			if not pDlg then
				pDlg = DlgGhostdomDetail.new()
			end
			pDlg:setData(pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.ghostdomAtkDetail then --冥界敌军详情界面
			local DlgGhostdomAtkDetail = require("app.layer.world.DlgGhostdomAtkDetail")
			local pDlg, bNew = getDlgByType(e_dlg_index.ghostdomAtkDetail)
			if not pDlg then
				pDlg = DlgGhostdomAtkDetail.new(pMsgObj.tData)
			end
			-- pDlg:setData(pMsgObj.tViewDotMsg)
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgcountrytreasure then --国家宝藏
			if isCountryOpen() == false then
                return
            end
			local nIndex = pMsgObj.nTabIndex or 1
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountrytreasure)
			local DlgCountryTreasure = require("app.layer.newcountry.countrytreasure.DlgCountryTreasure")
			if not pDlg then
				pDlg = DlgCountryTreasure.new(nIndex)
			end				
			pDlg:showDlg(bNew)
		elseif nDlgType == e_dlg_index.dlgcountryshop then --国家商店
			if isCountryOpen() == false then
                return
            end
			local nIndex = pMsgObj.nTabIndex or 1
			local pDlg, bNew = getDlgByType(e_dlg_index.dlgcountryshop)
			local DlgCountryShop = require("app.layer.newcountry.countryshop.DlgCountryShop")
			if not pDlg then
				pDlg = DlgCountryShop.new(nIndex)
			end				
			pDlg:showDlg(bNew)
		end

		
		
		if not bDelay then --直接回调
			--回调	
			if nHandler then
				nHandler(nDlgType)
			end
		end
	end
end


--打开对话框
-- 5500-5999
function showDlgByType10(pMsgObj, nHandler)
    -- body
    sendMsg(ghd_guide_finger_show_or_hide, false)
    if pMsgObj then
        local nDlgType = pMsgObj.nType or 1         -- dlg类型
        local nIndex = pMsgObj.nIndex or 1          -- 页面分页
        local bDelay = false                        -- 是否需要延迟回调
        if nDlgType == e_dlg_index.dlgactivityexam then
            -- 每日抢答
            local pBActivity = Player:getActById(e_id_activity.exam)            --
            if pBActivity then
                local DlgExam = require("app.layer.activityb.exam.DlgExam")
                local pDlg, bNew = getDlgByType(e_dlg_index.dlgactivityexam)
                if not pDlg then
                    pDlg = DlgExam.new()
                end
                pDlg:showDlg(bNew)
            else
                TOAST(getConvertedStr(6, 10522))
            end

        elseif nDlgType == e_dlg_index.dlgwarhall then
            -- 战争大厅            
            local DlgWarHall = require("app.layer.warhall.DlgWarHall")
            local pDlg, bNew = getDlgByType(e_dlg_index.dlgwarhall)
            if not pDlg then
                pDlg = DlgWarHall.new()
            end
            pDlg:showDlg(bNew)
            
        end
        if not bDelay then
            -- 直接回调
            -- 回调	
            if nHandler then
                nHandler(nDlgType)
            end
        end
    end
end