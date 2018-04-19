-- Author: maheng
-- Date: 2017-06-28 13:54:12
-- 洗练排行
local Activity = require("app.data.activity.Activity")
local DataRankPrize = require("app.layer.activitya.countryfight.DataRankPrize")

local DataSevenKing = class("DataSevenKing", function()
	return Activity.new(e_id_activity.sevenking) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.sevenking] = function (  )
	return DataSevenKing.new()
end

function DataSevenKing:ctor()
	-- body
   self:myInit()
end

e_sevenking_index = {
    dailylogin =  1,--七日签到
    level =2,--=主公等级
    killarmy= 3,--=初战天下
    tnolyup = 4,--=科技升级
    recruithero = 5,--=觅得良将
    kikkboss = 6,--=再战天下
    equip = 7,--=备战天下
    fuben = 8,--=副本推进
    cityfight = 9,--=逐鹿天下
    itemspeed = 10,--=全力冲刺
    camp = 11,--=军事升级
    shenbing = 12,--=神兵之威
    tnolyrank =  13,--=科技排行
    troops = 14,--=兵强马壮
    resource = 15,--=国泰民安
    cityfightrank = 16,--=攻城排行
    equiprank = 17,--=装备排行
    succinct = 18,--=装备洗炼
    fubenrank = 19,--=副本排行
    palacerank = 20,--=王宫排行
    combatrank = 21,--=权倾天下
}

e_sevenking_name = {
	[1] 	= 		
		{
			getConvertedStr(7, 10189),
			getConvertedStr(7, 10190),
			getConvertedStr(7, 10191)
		},
	[2] 	= 		
		{
			getConvertedStr(7, 10192),
			getConvertedStr(7, 10193),
			getConvertedStr(7, 10194)
		},
	[3] 	= 		
		{
			getConvertedStr(7, 10195),
			getConvertedStr(7, 10196),
			getConvertedStr(7, 10197)
		},
	[4] 	= 		
		{
			getConvertedStr(7, 10198),
			getConvertedStr(7, 10199),
			getConvertedStr(7, 10200)
		},
	[5] 	= 		
		{
			getConvertedStr(7, 10201),
			getConvertedStr(7, 10202),
			getConvertedStr(7, 10203)
		},
	[6] 	= 		
		{
			getConvertedStr(7, 10204),
			getConvertedStr(7, 10205),
			getConvertedStr(7, 10206)
		},
	[7] 	= 		
		{
			getConvertedStr(7, 10207),
			getConvertedStr(7, 10208),
			getConvertedStr(7, 10209)
		}
}

--奖励领取状态
e_award_state = {
	can_get 	= 1,	--可领取
	go_ahead 	= 2,	--前往	
	not_reach 	= 3,	--未达到
	has_got 	= 4,	--已领取
}

function DataSevenKing:myInit( )
	self.tDataList = {}--子活动的数据集合
	self.tDataList[1] = {
		nL = 0, 		-- l	Integer	1.登录天数
		tLa = {},	-- la	List<AwardVo>	1.登录奖励配置
		tLtk = {},  -- ltk	List<Integer>	1.已经领取的天数奖励
	}
	self.tDataList[2] = {
	    nLv  		= 0,    	-- lv	Integer	2.主公等级
	    tLva = {},-- lva	List<AwardVo>	2.等级奖励配置
		tLvtk ={},-- lvtk	List<Integer>	2.已经领取的等级奖励	
	}

	self.tDataList[3] = {
		nR 		= 0,-- r	Integer	3.击杀乱军次数
		nRl 		= 0,-- rl	Integer	3.击杀乱军等级限制
		tRa 	= {},-- ra	List<AwardVo>	3.乱军奖励配置
		tRtk 		= {},-- rtk	List<Integer>	3.已经领取的次数奖励
	}

	self.tDataList[4] = {
		tSf 		= {},-- sf	List<Integer>	4.升级完成的科技ID
		tSa   = {},-- sa	List<AwardVo>	4.科技升级奖励配置
		tStk = {},-- stk	List<Integer>	4.已经领取的科技奖励
	}

	self.tDataList[5] = {
		tHs 		= {},-- hs	List<Pair<Integer,Integer>>	5.已经获得的武将<品质-数量>
		tHn 		= {},-- hn	List<HeroNeedVo>	5.打造装备数量需求配置
		tHa 		= {},-- ha	List<AwardVo>	5.获得武将奖励配置
		tHtk  = {},-- htk	List<Integer>	5.已经领取的武将奖励
	}

	self.tDataList[6] = {	
		nB 	= 0, -- b	Integer	6.击杀BOSS的数据
		tBa = {},-- ba	List<AwardVo>	6.击杀BOSS奖励配置
		tBtK = {},-- btk	List<Integer>	6.已经领取的BOSS奖励	
	}
	self.tDataList[7] = {
		tEs = {},-- es	List<Pair<Integer,Integer>>	7.完成打造的装备 <品质-数量>
		tEa = {},-- ea	List<AwardVo>	7.打造装备奖励配置
		tEn = {},-- en	List<Pair<Integer,Integer>>	7.打造装备数量需求配置
		tEtk = {},-- etk	List<Integer>	7.已经领取的装备奖励	
	}

	self.tDataList[8] = {
		tDs = {},-- ds	List<Integer>	8.通关副本的章节数
		tDa = {},-- da	List<AwardVo>	8.通关副本奖励配置
		tDtk = {},-- dtk	List<Integer>	8.已经领取的章节奖励		
	}

	self.tDataList[9] = {
		nC = {},-- c	Integer	9.参与战胜城战的次数
		tCa = {},-- ca	List<AwardVo>	9.通关副本奖励配置
		tCtk = {},-- ctk	List<Integer>	9.已经领取的城战奖励	
	}

	self.tDataList[10] = {
		nSp = {},-- sp	Integer	10.道具加速时间
		tSpa = {},-- spa	List<AwardVo>	10.道具加速奖励配置
		tSptk = {},-- sptk	List<Integer>	10.已经领取的加速奖励	
	}

	self.tDataList[11] = {
		nCp = 0,-- cp	Integer	11.兵营最大等级
		tCpa = {},-- cpa	List<AwardVo>	11.兵营等级奖励配置
		tPtk =	{},-- cptk	List<Integer>	11.已经领取的兵营奖励	
	}

	self.tDataList[12] = {
		nA = 0,-- a	Integer	12.神兵总等级
		tAa = {},-- aa	List<AwardVo>	12.神兵奖励配置
		tAtk = {},-- atk	List<Integer>	12.已经领取的神兵奖励	
	}



	self.tDataList[14] = {
		nRe = 0,-- re	Integer	14.历史募兵量
		tRea = {},-- rea	List<AwardVo>	14.募兵奖励配置
		tRetk = {},-- retk	List<Integer>	14.已经领取的募兵奖励	
	}

	self.tDataList[15] = {
		nRsl = 0,-- rs	Integer	15.资源田最大等级
		tRsa = {},-- rsa	List<AwardVo>	15.资源田等级奖励配置
		tRstk = {},-- rstk	List<Integer>	15.已经领取的资源田等级奖励	
	}

	self.tDataList[18] = {
		nTr = 0,-- tr	Integer	18.洗炼次数
		tTra = {},-- tra	List<AwardVo>	18.洗炼次数奖励配置
		tTrtk = {},-- trtk	List<Integer>	18.已经领取的洗炼奖励
	}
	--
	self.tDataList[13] = {
		nRank = 0,--排名
		nGet = 0,-- srt	Integer	13.科技排行领取奖励 0否 1是
		nOpen = 0,-- stt	Integer	13.科技排行是否到了领奖时间 0否 1是
		--tSra = {},-- sra	List<RankVo>	13.科技排行奖励数据
		nRankType = e_rank_type.sr_tnoly,
	}
	--
	self.tDataList[17] = {
		nRank = 0,--排名
		nGet = 0,-- ert	Integer	17.装备排行领取奖励 0否 1是
		nOpen = 0,-- ett	Integer	17.装备排行是否到了领奖时间 0否 1是
		--tEra = {},-- era	List<RankVo>	17.装备排行奖励数据	
		nRankType = e_rank_type.sr_equip,
	}


	self.tDataList[16] = {
		nRank = 0,--排名
		nGet = 0,-- crt	Integer	16.攻城排行领取奖励 0否 1是
		nOpen = 0,-- ctt	Integer	16.攻城排行是否到了领奖时间 0否 1是
		--tCra = {},-- cra	List<RankVo>	16.攻城排行奖励数据
		nRankType = e_rank_type.sr_cf,
	}
	self.tDataList[19] = {
		nRank = 0,--排名
		nGet = 0,-- drt	Integer	19.副本排行领取奖励 0否 1是
		nOpen = 0,-- dtt	Integer	19.副本排行是否到了领奖时间 0否 1是
		--tDra = {},-- dra	List<RankVo>	19.副本排行奖励数据	
		nRankType = e_rank_type.sr_fuben,
	}

	self.tDataList[20] = {	
		nRank = 0,--排名
		nGet = 0,-- prt	Integer	20.王宫排行领取奖励 0否 1是
		nOpen = 0,-- ptt	Integer	20.王宫排行是否到了领奖时间 0否 1是
		--tPra = {},-- pra	List<RankVo>	20.王宫排行奖励数据
		nRankType = e_rank_type.sr_palace,
	} 

	self.tDataList[21] = {
		nRank = 0,--排名
		nGet = 0,-- zrt	Integer	21.战力排行领取奖励 0否 1是
		nOpen = 0,-- ztt	Integer	21.战力排行是否到了领奖时间 0否 1是
		--tZra = {},-- zra	List<RankVo>	21.战力排行奖励数据
		nRankType = e_rank_type.sr_combat
	}

	self.sOp = ""-- op	String	活动开启参数
	self.tTh = 0-- th	Integer	排行活动领奖时间点
end

-- 读取服务器中的数据
function DataSevenKing:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	self.tDataList[1].nL 		= _tData.l	or self.tDataList[1].nL	-- l	Integer	1.登录天数
	self.tDataList[1].tLa 		= _tData.la	or self.tDataList[1].tLa-- la	List<AwardVo>	1.登录奖励配置
	self:sortActPrize(self.tDataList[1].tLa)
	self.tDataList[1].tLtk 		= _tData.ltk or self.tDataList[1].tLtk-- ltk	List<Integer>	1.已经领取的天数奖励

	self.tDataList[2].nLv  		= _tData.lv or self.tDataList[2].nLv  	-- lv	Integer	2.主公等级
    self.tDataList[2].tLva 		= _tData.lva or self.tDataList[2].tLva-- lva	List<AwardVo>	2.等级奖励配置
    self:sortActPrize(self.tDataList[2].tLva)
	self.tDataList[2].tLvtk 	= _tData.lvtk or self.tDataList[2].tLvtk-- lvtk	List<Integer>	2.已经领取的等级奖励	

	self.tDataList[3].nR 		= _tData.r or self.tDataList[3].nR-- r	Integer	3.击杀乱军次数
	self.tDataList[3].nRl 		= _tData.rl or self.tDataList[3].nRl-- rl	Integer	3.击杀乱军等级限制
	self.tDataList[3].tRa 		= _tData.ra or self.tDataList[3].tRa-- ra	List<AwardVo>	3.乱军奖励配置
	self:sortActPrize(self.tDataList[3].tRa)
	self.tDataList[3].tRtk 		= _tData.rtk or self.tDataList[3].tRtk-- rtk	List<Integer>	3.已经领取的次数奖励

	self.tDataList[4].tSf 		= _tData.sf or self.tDataList[4].tSf-- sf	List<Integer>	4.升级完成的科技ID
	self.tDataList[4].tSa   	= _tData.sa or self.tDataList[4].tSa-- sa	List<AwardVo>	4.科技升级奖励配置
	self:sortActPrize(self.tDataList[4].tSa)
	self.tDataList[4].tStk 		= _tData.stk or self.tDataList[4].tStk-- stk	List<Integer>	4.已经领取的科技奖励

	--self.tDataList[5].nH 		= _tData.h or self.tDataList[5].nH   -- h	Integer	5.获得的武将数量
	self.tDataList[5].tHs 		= _tData.hs or self.tDataList[5].tHs -- hs	List<Pair<Integer,Integer>>	5.已经获得的武将<品质-数量>
	self.tDataList[5].tHn 		= _tData.hn or self.tDataList[5].tHn -- hn	List<HeroNeedVo>	5.打造武将数量需求配置
	self.tDataList[5].tHa 		= _tData.ha or self.tDataList[5].tHa -- ha	List<AwardVo>	5.获得武将奖励配置	
	self:sortActPrize(self.tDataList[5].tHa)
	self.tDataList[5].tHtk  	= _tData.htk or self.tDataList[5].tHtk-- htk	List<Integer>	5.已经领取的武将奖励		

	self.tDataList[6].nB 		= _tData.b or self.tDataList[6].nB-- b	Integer	6.击杀BOSS的数据
	self.tDataList[6].tBa 		= _tData.ba or self.tDataList[6].tBa-- ba	List<AwardVo>	6.击杀BOSS奖励配置
	self:sortActPrize(self.tDataList[6].tBa)
	self.tDataList[6].tBtK 		= _tData.btk or self.tDataList[6].tBtK-- btk	List<Integer>	6.已经领取的BOSS奖励	

	self.tDataList[7].tEs 		= _tData.es or self.tDataList[7].tEs-- es	List<Pair<Integer,Integer>>	7.完成打造的装备 <品质-数量>
	self.tDataList[7].tEa 		= _tData.ea or self.tDataList[7].tEa-- ea	List<AwardVo>	7.打造装备奖励配置
	self:sortActPrize(self.tDataList[7].tEa)	
	self.tDataList[7].tEn 		= _tData.en or self.tDataList[7].tEn-- en	List<Pair<Integer,Integer>>	7.打造装备数量需求配置
	self.tDataList[7].tEtk 		= _tData.etk or self.tDataList[7].tEtk-- etk	List<Integer>	7.已经领取的装备奖励	
	
	self.tDataList[8].tDs 		= _tData.ds or self.tDataList[8].tDs-- ds	List<Integer>	8.通关副本的章节数
	self.tDataList[8].tDa 		= _tData.da	or self.tDataList[8].tDa-- da	List<AwardVo>	8.通关副本奖励配置
	self:sortActPrize(self.tDataList[8].tDa)	
	self.tDataList[8].tDtk 		= _tData.dtk or self.tDataList[8].tDtk-- dtk	List<Integer>	8.已经领取的章节奖励		

	self.tDataList[9].nC 		= _tData.c or self.tDataList[9].nC-- c	Integer	9.参与战胜城战的次数
	self.tDataList[9].tCa 		= _tData.ca or self.tDataList[9].tCa-- ca	List<AwardVo>	9.通关副本奖励配置
	self:sortActPrize(self.tDataList[9].tCa)	
	self.tDataList[9].tCtk		= _tData.ctk or self.tDataList[9].tCtk-- ctk	List<Integer>	9.已经领取的城战奖励	

	self.tDataList[10].nSp 		= _tData.sp or self.tDataList[10].nSp-- sp	Integer	10.道具加速时间
	self.tDataList[10].tSpa 	= _tData.spa or self.tDataList[10].tSpa-- spa	List<AwardVo>	10.道具加速奖励配置
	self:sortActPrize(self.tDataList[10].tSpa)	
	self.tDataList[10].tSptk	= _tData.sptk or self.tDataList[10].tSptk-- sptk	List<Integer>	10.已经领取的加速奖励	

	self.tDataList[11].nCp 		= _tData.cp or self.tDataList[11].nCp-- cp	Integer	11.兵营最大等级
	self.tDataList[11].tCpa 	= _tData.cpa or self.tDataList[11].tCpa-- cpa	List<AwardVo>	11.兵营等级奖励配置
	self:sortActPrize(self.tDataList[11].tCpa)	
	self.tDataList[11].tPtk 	= _tData.cptk or self.tDataList[11].tPtk-- cptk	List<Integer>	11.已经领取的兵营奖励	

	self.tDataList[12].nA 		= _tData.a or self.tDataList[12].nA-- a	Integer	12.神兵总等级
	self.tDataList[12].tAa 		= _tData.aa or self.tDataList[12].tAa-- aa	List<AwardVo>	12.神兵奖励配置
	self:sortActPrize(self.tDataList[12].tAa)	
	self.tDataList[12].tAtk 	= _tData.atk or self.tDataList[12].tAtk-- atk	List<Integer>	12.已经领取的神兵奖励	

	self.tDataList[14].nRe 		= _tData.re or self.tDataList[14].nRe-- re	Integer	14.历史募兵量
	self.tDataList[14].tRea 	= _tData.rea or self.tDataList[14].tRea-- rea	List<AwardVo>	14.募兵奖励配置
	self:sortActPrize(self.tDataList[14].tRea)	
	self.tDataList[14].tRetk 	= _tData.retk or self.tDataList[14].tRetk-- retk	List<Integer>	14.已经领取的募兵奖励	

	self.tDataList[15].nRsl 	= _tData.rsl or self.tDataList[15].nRsl-- rs	Integer	15.资源田最大等级
	self.tDataList[15].tRsa 	= _tData.rsa or self.tDataList[15].tRsa-- rsa	List<AwardVo>	15.资源田等级奖励配置
	self:sortActPrize(self.tDataList[15].tRsa)	
	self.tDataList[15].tRstk 	= _tData.rstk or self.tDataList[15].tRstk-- rstk	List<Integer>	15.已经领取的资源田等级奖励		

	self.tDataList[18].nTr 		= _tData.tr or self.tDataList[18].nTr-- tr	Integer	18.洗炼次数
	self.tDataList[18].tTra 	= _tData.tra or self.tDataList[18].tTra-- tra	List<AwardVo>	18.洗炼次数奖励配置
	self:sortActPrize(self.tDataList[18].tTra)	
	self.tDataList[18].tTrtk 	= _tData.trtk or self.tDataList[18].tTrtk 	-- trtk	List<Integer>	18.已经领取的洗炼奖励


	--排行活动
	self.tDataList[13].nRank 	= _tData.srk or self.tDataList[13].nRank--	srk 13.科技排行名次
	self.tDataList[13].nGet 	= _tData.srt or self.tDataList[13].nGet-- srt	Integer	13.科技排行领取奖励 0否 1是
	self.tDataList[13].nOpen 	= _tData.stt or self.tDataList[13].nOpen-- stt	Integer	13.科技排行是否到了领奖时间 0否 1是
	self:formatRankVo(self.tDataList[13], _tData.sra)-- sra	List<RankVo>	13.科技排行奖励数据

	self.tDataList[16].nRank 	= _tData.crk or self.tDataList[16].nRank--	crk  16.攻城排行名次
	self.tDataList[16].nGet 	= _tData.crt or self.tDataList[16].nGet-- crt	Integer	16.攻城排行领取奖励 0否 1是
	self.tDataList[16].nOpen 	= _tData.ctt or self.tDataList[16].nOpen-- ctt	Integer	16.攻城排行是否到了领奖时间 0否 1是
	self:formatRankVo(self.tDataList[16], _tData.cra)-- cra	List<RankVo>	16.攻城排行奖励数据	

	self.tDataList[17].nRank 	= _tData.erk or self.tDataList[17].nRank--	erk 17.装备排行名次
	self.tDataList[17].nGet 	= _tData.ert or self.tDataList[17].nGet-- ert	Integer	17.装备排行领取奖励 0否 1是
	self.tDataList[17].nOpen 	= _tData.ett or self.tDataList[17].nOpen-- ett	Integer	17.装备排行是否到了领奖时间 0否 1是
	self:formatRankVo(self.tDataList[17], _tData.era)-- era	List<RankVo>	17.装备排行奖励数据	

	self.tDataList[19].nRank 	= _tData.drk or self.tDataList[19].nRank--	drk 19.副本排行名次 
	self.tDataList[19].nGet 	= _tData.drt or self.tDataList[19].nGet-- drt	Integer	19.副本排行领取奖励 0否 1是
	self.tDataList[19].nOpen 	= _tData.dtt or self.tDataList[19].nOpen-- dtt	Integer	19.副本排行是否到了领奖时间 0否 1是
	self:formatRankVo(self.tDataList[19], _tData.dra) -- dra	List<RankVo>	19.副本排行奖励数据	

	self.tDataList[20].nRank 	= _tData.prk or self.tDataList[20].nRank--	prk 20.王宫排行名次
	self.tDataList[20].nGet 	= _tData.prt or self.tDataList[20].nGet-- prt	Integer	20.王宫排行领取奖励 0否 1是
	self.tDataList[20].nOpen 	= _tData.ptt or self.tDataList[20].nOpen-- ptt	Integer	20.王宫排行是否到了领奖时间 0否 1是
	self:formatRankVo(self.tDataList[20], _tData.pra) -- pra	List<RankVo>	20.王宫排行奖励数据	

	self.tDataList[21].nRank 	= _tData.zrk or self.tDataList[21].nRank--	zrk 21.战力排行名次
	self.tDataList[21].nGet 	= _tData.zrt or self.tDataList[21].nGet -- zrt	Integer	21.战力排行领取奖励 0否 1是
	self.tDataList[21].nOpen 	= _tData.ztt or self.tDataList[21].nOpen-- ztt	Integer	21.战力排行是否到了领奖时间 0否 1是
	self:formatRankVo(self.tDataList[21], _tData.zra)-- zra	List<RankVo>	21.战力排行奖励数据

	self.sOp = _tData.op or self.sOp-- op	String	活动开启参数
	self.tTh = _tData.th or self.tTh -- th	Integer	排行活动领奖时间点	
	self.nLoginDays = _tData.od or self.nLoginDays --Integer	已登录天数

	--只有公共部分
	self:refreshActService(_tData)--刷新活动共有的数据	
end

--获取已登录天数
function DataSevenKing:getLoginDays()
	-- body
	return self.nLoginDays or 0
end

function DataSevenKing:formatRankVo( tt, tRankVos )
	-- body
	if not tt then
		return
	end
	if not tt.tConfs then
		tt.tConfs = {}	
	end
	if tRankVos and #tRankVos > 0 then		
		for k, v in pairs(tRankVos) do
			if not tt.tConfs[v.g] then
				local pDataRankPrize = DataRankPrize.new()
				pDataRankPrize:refreshByServer2(v)
				tt.tConfs[v.g] = pDataRankPrize
			else
				tt.tConfs[v.g]:refreshByServer2(v)
			end			
		end			
	end	
	local nRank = tt.nRank or 0
	for k, v in pairs(tt.tConfs) do		
		if tt.nOpen == 1 then
			if nRank >= v.nL and nRank <= v.nR then
				if tt.nGet == 1 then
					v:updateStatus(en_get_state_type.haveget)
				else
					--未领取
					v:updateStatus(en_get_state_type.canget)
				end									
			else
				v:updateStatus(en_get_state_type.cannotget)
			end
		else
			v:updateStatus(en_get_state_type.null)
		end
	end	
end

--奖励排序
function DataSevenKing:sortActPrize( _tData )
	-- body
	if _tData and #_tData > 0 then
--		dump(_tData, "_tData", 100)
		for k, v in pairs(_tData) do
			if v and v.b then
				sortGoodsList(v.b)
			end			
		end
	end
end
--获取排行活动数据
function DataSevenKing:getRankData(  )
	-- body
	local tData = {}
	local nOpen = self:getLoginDays()*3
	for k, v in pairs(self.tDataList) do
		if v.nRankType and v.nRankType > 0 and k <= nOpen then
			table.insert( tData, v )
		end
	end
	return tData
end
--_a:目标配置
--_nHasReach:已达到
--_tHasGotList:已获取奖励列表
--_nState:如果是2未达到状态就是前往状态
function DataSevenKing:onGetState(_a, _nHasReach, _tHasGotList, _nState)
	-- body
	local nState = e_award_state.not_reach
	if _a > _nHasReach then
		nState = _nState or e_award_state.not_reach
	else
		local bHasGot = false --是否已领取
		for k, v in pairs(_tHasGotList) do
			if v == _a then
				nState = e_award_state.has_got
				bHasGot = true
				break
			end
		end
		if not bHasGot then
			nState = e_award_state.can_get
		end
	end
	return nState
end

--获取每项奖励状态
--_idx:活动下标
--_a:活动配置每项奖励目标
--_quality:装备的品质
--返回状态: 1未达到，2前往，3领取，4已领取, nHasReach:已达到数量, nTar:目标数量
function DataSevenKing:getStateByIdx(_idx, _a, _quality)
	-- body
	local nState = e_award_state.not_reach
	local tData = self.tDataList[_idx]
	local nHasReach, nTar = nil
	if _idx == e_sevenking_index.dailylogin then
		nHasReach = tData.nL
		nState = self:onGetState(_a, nHasReach, tData.tLtk)

	elseif _idx == e_sevenking_index.level then
		nHasReach = tData.nLv
		nState = self:onGetState(_a, nHasReach, tData.tLvtk, e_award_state.go_ahead)
	elseif _idx == e_sevenking_index.killarmy then
		nHasReach = tData.nR
		nState = self:onGetState(_a, nHasReach, tData.tRtk, e_award_state.go_ahead)
		
	elseif _idx == e_sevenking_index.tnolyup then
		nTar = 1 --目标
		local tHasList = tData.tSf --升级完的科技ID列表
		local bHasReach = false
		for k, v in pairs(tHasList) do
			if v == _a then
				bHasReach = true
				nHasReach = 1
				break
			end
		end
		if not bHasReach then
			nHasReach = 0
			nState = e_award_state.go_ahead
		else
			local bHasGot = false --是否已领取
			for k, v in pairs(tData.tStk) do
				if v == _a then
					nState = e_award_state.has_got
					bHasGot = true
					break
				end
			end
			if not bHasGot then
				nState = e_award_state.can_get
			end
		end
	elseif _idx == e_sevenking_index.recruithero then
		-- nHasReach = tData.nH
		-- nState = self:onGetState(_a, nHasReach, tData.tHtk)
		local tHasList = tData.tHs --已完成打造的装备
		local tHn = tData.tHn      --装备数量需求配置
		local bHasReach = false
		nHasReach = 0
		for k, v in pairs(tHn) do
			if v.i == _a then
				nTar = v.c
				for _, data in pairs(tHasList) do
					if data.k == _quality then
						nHasReach = data.v
						if nHasReach >= v.c then
							bHasReach = true
							break
						end
					end
				end
			end
		end
		if not bHasReach then
			nState = e_award_state.go_ahead
		else
			local bHasGot = false --是否已领取
			for k, v in pairs(tData.tHtk) do
				if v == _a then
					nState = e_award_state.has_got
					bHasGot = true
					break
				end
			end
			if not bHasGot then
				nState = e_award_state.can_get
			end
		end			
	elseif _idx == e_sevenking_index.kikkboss then
		nHasReach = tData.nB
		nState = self:onGetState(_a, nHasReach, tData.tBtK, e_award_state.go_ahead)
		
	elseif _idx == e_sevenking_index.equip then
		local tHasList = tData.tEs --已完成打造的装备
		local tEn = tData.tEn      --装备数量需求配置
		local bHasReach = false
		nHasReach = 0
		for k, v in pairs(tEn) do
			if v.i == _a then
				nTar = v.c
				for _, data in pairs(tHasList) do
					if data.k == _quality then
						nHasReach = data.v
						if nHasReach >= v.c then
							bHasReach = true
							break
						end
					end
				end
			end
		end
		if not bHasReach then
			nState = e_award_state.go_ahead
		else
			local bHasGot = false --是否已领取
			for k, v in pairs(tData.tEtk) do
				if v == _a then
					nState = e_award_state.has_got
					bHasGot = true
					break
				end
			end
			if not bHasGot then
				nState = e_award_state.can_get
			end
		end
	elseif _idx == e_sevenking_index.fuben then
		local tDs = tData.tDs
		nHasReach = tDs[table.nums(tDs)] or 0
		nState = self:onGetState(_a, nHasReach, tData.tDtk, e_award_state.go_ahead)
		
	elseif _idx == e_sevenking_index.cityfight then
		nHasReach = tData.nC 
		nState = self:onGetState(_a, nHasReach, tData.tCtk, e_award_state.go_ahead)
		
	elseif _idx == e_sevenking_index.itemspeed then
		nHasReach = tData.nSp
		nState = self:onGetState(_a, nHasReach, tData.tSptk)
		
	elseif _idx == e_sevenking_index.camp then
		nHasReach = tData.nCp
		nState = self:onGetState(_a, nHasReach, tData.tPtk, e_award_state.go_ahead)
		
	elseif _idx == e_sevenking_index.shenbing then
		nHasReach = tData.nA
		nState = self:onGetState(_a, nHasReach, tData.tAtk, e_award_state.go_ahead)
		
	elseif _idx == e_sevenking_index.troops then
		nHasReach = tData.nRe
		nState = self:onGetState(_a, nHasReach, tData.tRetk, e_award_state.go_ahead)
		
	elseif _idx == e_sevenking_index.resource then
		nHasReach = tData.nRsl
		nState = self:onGetState(_a, nHasReach, tData.tRstk, e_award_state.go_ahead)
		
	elseif _idx == e_sevenking_index.succinct then
		nHasReach = tData.nTr
		nState = self:onGetState(_a, nHasReach, tData.tTrtk, e_award_state.go_ahead)
		
	end

	return nState, nHasReach, nTar
end


--通过活动下标获取奖励配置
function DataSevenKing:getAwardsCofByIdx(_idx)
	-- body
	local tData, sTitle

	if _idx == e_sevenking_index.dailylogin then
		tData = self.tDataList[_idx].tLa
		sTitle = getTipsByIndex(20043)

	elseif _idx == e_sevenking_index.level then
		tData = self.tDataList[_idx].tLva
		sTitle = getTipsByIndex(20044)
		
	elseif _idx == e_sevenking_index.killarmy then
		tData = self.tDataList[_idx].tRa
		sTitle = getTipsByIndex(20045)
		
	elseif _idx == e_sevenking_index.tnolyup then
		tData = self.tDataList[_idx].tSa
		for k, v in pairs(tData) do
			local sTid = v.a --科技id
			local tScience = Player:getTnolyData():getTnolyByIdFromAll(sTid)
			if tScience then
				tData[k].sTitle = getTextColorByConfigure(string.format(getTipsByIndex(20046), tScience.sName))
			end
			local nState, nHasReach, nTar = self:getStateByIdx(_idx, v.a)
			tData[k].nState = nState
			tData[k].nHasReach = nHasReach
			tData[k].nTar = nTar
		end
		table.sort(tData, function(a, b)
			-- body
			if a.nState == b.nState then
				return a.a < b.a
			else
				return a.nState < b.nState
			end
		end)
		return tData
	elseif _idx == e_sevenking_index.recruithero then		
		tData = self.tDataList[_idx].tHa
		--sTitle = getTipsByIndex(20047)
		local tCountList = self.tDataList[_idx].tHn
		local nQuality = 1
		for k, v in pairs(tData) do
			local nIndex = v.a --标识
			local nCount = 0 --装备数量
			for _, data in pairs(tCountList) do
				if data.i == nIndex then
					nCount = data.c
					nQuality = data.q
				end
			end
			local sColor = getColorTextByQuality(nQuality)
			tData[k].sTitle = getTextColorByConfigure(string.format(getTipsByIndex(20047), sColor, nCount))
			local nState, nHasReach, nTar = self:getStateByIdx(_idx, v.a, nQuality)
			tData[k].nState = nState
			tData[k].nHasReach = nHasReach
			tData[k].nTar = nTar
			tData[k].nQuality = nQuality
		end
		table.sort(tData, function(a, b)
			-- body
			if a.nState == b.nState then
				return a.a < b.a
			else
				return a.nState < b.nState
			end
		end)
		return tData

	elseif _idx == e_sevenking_index.kikkboss then
		tData = self.tDataList[_idx].tBa
		sTitle = getTipsByIndex(20048)
		
	elseif _idx == e_sevenking_index.equip then
		tData = self.tDataList[_idx].tEa
		local tCountList = self.tDataList[_idx].tEn
		local nQuality = 1
		for k, v in pairs(tData) do
			local nIndex = v.a --标识
			local nCount = 0 --装备数量
			for _, data in pairs(tCountList) do
				if data.i == nIndex then
					nCount = data.c
					nQuality = data.q
				end
			end
			local sColor = getColorTextByQuality(nQuality)
			tData[k].sTitle = getTextColorByConfigure(string.format(getTipsByIndex(20049), sColor, nCount))
			local nState, nHasReach, nTar = self:getStateByIdx(_idx, v.a, nQuality)
			tData[k].nState = nState
			tData[k].nHasReach = nHasReach
			tData[k].nTar = nTar
			tData[k].nQuality = nQuality
		end
		table.sort(tData, function(a, b)
			-- body
			if a.nState == b.nState then
				return a.a < b.a
			else
				return a.nState < b.nState
			end
		end)
		return tData
	elseif _idx == e_sevenking_index.fuben then
		tData = self.tDataList[_idx].tDa
		sTitle = getTipsByIndex(20050)
		
	elseif _idx == e_sevenking_index.cityfight then
		tData = self.tDataList[_idx].tCa
		sTitle = getTipsByIndex(20051)
		
	elseif _idx == e_sevenking_index.itemspeed then
		tData = self.tDataList[_idx].tSpa
		sTitle = getTipsByIndex(20052)
		
	elseif _idx == e_sevenking_index.camp then
		tData = self.tDataList[_idx].tCpa
		sTitle = getTipsByIndex(20053)
		
	elseif _idx == e_sevenking_index.shenbing then
		tData = self.tDataList[_idx].tAa
		sTitle = getTipsByIndex(20054)
		
	elseif _idx == e_sevenking_index.tnolyrank then 	--排行
		return self.tDataList[_idx].tSra
	elseif _idx == e_sevenking_index.troops then
		tData = self.tDataList[_idx].tRea
		sTitle = getTipsByIndex(20055)
		
	elseif _idx == e_sevenking_index.resource then
		tData = self.tDataList[_idx].tRsa
		sTitle = getTipsByIndex(20056)
		
	elseif _idx == e_sevenking_index.cityfightrank then --排行
		return self.tDataList[_idx].tCra
	elseif _idx == e_sevenking_index.equiprank then  	--排行
		return self.tDataList[_idx].tEra
	elseif _idx == e_sevenking_index.succinct then
		tData = self.tDataList[_idx].tTra
		sTitle = getTipsByIndex(20057)
		
	elseif _idx == e_sevenking_index.fubenrank then 	--排行
		return self.tDataList[_idx].tDra
	elseif _idx == e_sevenking_index.palacerank then 	--排行
		return self.tDataList[_idx].tPra
	elseif _idx == e_sevenking_index.combatrank then 	--排行
		return self.tDataList[_idx].tZra
	end

	for k, v in pairs(tData) do
		tData[k].sTitle = getTextColorByConfigure(string.format(sTitle, v.a))
		local nState, nHasReach, nTar = self:getStateByIdx(_idx, v.a)
		tData[k].nState = nState
		tData[k].nHasReach = nHasReach
		tData[k].nTar = nTar
	end	
	table.sort(tData, function(a, b)
		-- body
		if a.nState == b.nState then
			return a.a < b.a
		else
			return a.nState < b.nState
		end
	end)
	return tData
end

-- 获取红点方法
function DataSevenKing:getRedNums(_awardsTip)
	local nNums = 0
	local nOpen = self:getLoginDays()*3
	for k, v in pairs(self.tDataList) do
		if k <= nOpen then
			if v.nRankType then
				for i, pConf in pairs(v.tConfs) do
					if pConf.nStatus == en_get_state_type.canget then
						nNums = nNums + 1		
					end
				end
			else
				local tAwardConf = self:getAwardsCofByIdx(k)
				for i, pConf in pairs(tAwardConf) do
					if pConf.nState == e_award_state.can_get then
						nNums = nNums + 1
						break
					end
				end
			end
		end
	end
	if not _awardsTip then
		nNums = self.nLoginRedNums + nNums
	end
	return nNums
end
--获取单个子活动的红点
function DataSevenKing:getRedNumsByIndex( _index )
	-- body
	local nRedNum = 0
	local nOpen = self:getLoginDays()*3
	if _index and self.tDataList[_index] and _index <= nOpen then
		local pActData = self.tDataList[_index]
		if pActData.nRankType then
			for i, pConf in pairs(pActData.tConfs) do
				if pConf.nStatus == en_get_state_type.canget then
					nRedNum = nRedNum + 1		
				end
			end
		else
			local tAwardConf = self:getAwardsCofByIdx(_index)
			for i, pConf in pairs(tAwardConf) do
				if pConf.nState == e_award_state.can_get then
					nRedNum = nRedNum + 1
					break
				end
			end
		end		
	end
	return nRedNum
end

--获取天数对应子活动的的红点
function DataSevenKing:getRedNumsByDay( _nDay )
	-- body
	local nNum = 0
	if _nDay then
		local nOpen = _nDay*3
		for index = nOpen - 2, nOpen do
			nNum = nNum + self:getRedNumsByIndex(index)
		end
	end
	return nNum
end


--排行结算时间
function DataSevenKing:getBalanceTimeStr(  )
	-- body
    local sTime = string.format("%d",self.tTh)..":00"..getConvertedStr(6, 10456)
    local sStr = {
    	{text=sTime, color=_cc.green}
	} 
    return sStr	
end

function DataSevenKing:getRankActTipsByRankType( _nType )
	-- body	
	if not _nType then
		return ""
	end
	if not self.tRankActTips then
		self.tRankActTips = {}
		local tTips = luaSplitMuilt(self.sRule, "|", ":")
		for k, v in pairs(tTips) do
			local nId = tonumber(v[1] or 0)
			local sStr = v[2]
			if nId > 0 then
				self.tRankActTips[nId] = sStr	
			end
		end
	end
	local nIndex = self:getActDataByRankType( _nType )
	-- if _nType == e_rank_type.sr_tnoly then
	-- 	nIndex = e_sevenking_index.tnolyrank
	-- elseif _nType == e_rank_type.sr_cf then
	-- 	nIndex = e_sevenking_index.cityfightrank
	-- elseif _nType == e_rank_type.sr_equip then
	-- 	nIndex = e_sevenking_index.equiprank
	-- elseif _nType == e_rank_type.sr_fuben then
	-- 	nIndex = e_sevenking_index.fubenrank
	-- elseif _nType == e_rank_type.sr_palace then
	-- 	nIndex = e_sevenking_index.palacerank
	-- elseif _nType == e_rank_type.sr_combat then		
	-- 	nIndex = e_sevenking_index.combatrank
	-- end
	return self.tRankActTips[nIndex]
	--dump(self.tRankActTips, "tRankActTips", 100)	
end

function DataSevenKing:getActDataByRankType( _nType )
	-- body
	local nIndex = 0
	if _nType == e_rank_type.sr_tnoly then
		nIndex = e_sevenking_index.tnolyrank
	elseif _nType == e_rank_type.sr_cf then
		nIndex = e_sevenking_index.cityfightrank
	elseif _nType == e_rank_type.sr_equip then
		nIndex = e_sevenking_index.equiprank
	elseif _nType == e_rank_type.sr_fuben then
		nIndex = e_sevenking_index.fubenrank
	elseif _nType == e_rank_type.sr_palace then
		nIndex = e_sevenking_index.palacerank
	elseif _nType == e_rank_type.sr_combat then		
		nIndex = e_sevenking_index.combatrank
	end
	return nIndex
end
return DataSevenKing