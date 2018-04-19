local tTable = {}

tTable["texturesPng"] = {"ui/p1_commmon3_sep.plist","icon/p1_icon_font.plist","ui/language/cn/p2_font1.plist"}
tTable["index_1"] = {
default={classname="Panel",name="default",parName="root",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="636",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="348",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
view={classname="Panel",name="view",parName="default",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="636",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="349",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lay_content={classname="Panel",name="lay_content@fill_layout",parName="view",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v1_bg_kelashen.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="22",capInsetsY="22",height="449",width="640",x="0",y="182",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1744",anchorPointX="0",anchorPointY="0",},
lay_btn_cancel={classname="Panel",name="lay_btn_cancel",parName="view",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="60",width="150",x="57",y="48",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="359",anchorPointX="0",anchorPointY="0",},
lay_btn_collect={classname="Panel",name="lay_btn_collect",parName="view",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="60",width="150",x="446",y="48",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="360",anchorPointX="0",anchorPointY="0",},
}
tTable["index_4"] = {
lay_hero_info={classname="Panel",name="lay_hero_info",parName="lay_content",childCount="11",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="449",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="23792",anchorPointX="0",anchorPointY="0",},
}
tTable["index_5"] = {
txt_player_name={classname="CustomLabel",name="txt_player_name",parName="lay_hero_info",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="232",y="395",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1884",anchorPointX="0",anchorPointY="0.5",},
lay_hero_icon={classname="Panel",name="lay_hero_icon",parName="lay_hero_info",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="100",width="100",x="124",y="235",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1885",anchorPointX="0",anchorPointY="0",},
txt_hero_name={classname="CustomLabel",name="txt_hero_name",parName="lay_hero_info",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="四个字这字",fontName="微软雅黑",fontSize="20",height="27",width="100",x="244",y="318",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1886",anchorPointX="0",anchorPointY="0.5",},
txt_hero_lv={classname="CustomLabel",name="txt_hero_lv",parName="lay_hero_info",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Lv.150",fontName="微软雅黑",fontSize="20",height="27",width="62",x="341",y="318",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1887",anchorPointX="0",anchorPointY="0.5",},
txt_troops_title={classname="CustomLabel",name="txt_troops_title",parName="lay_hero_info",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="兵力：",fontName="微软雅黑",fontSize="20",height="27",width="60",x="244",y="278",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1888",anchorPointX="0",anchorPointY="0.5",},
lay_richtext_troops={classname="Panel",name="lay_richtext_troops",parName="lay_hero_info",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="27",width="95",x="303",y="265",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1889",anchorPointX="0",anchorPointY="0",},
txt_remain_collect_cd_title={classname="CustomLabel",name="txt_remain_collect_cd_title",parName="lay_hero_info",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="剩余采集时间：",fontName="微软雅黑",fontSize="20",height="27",width="140",x="244",y="247",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1890",anchorPointX="0",anchorPointY="0.5",},
txt_remain_collect_cd={classname="CustomLabel",name="txt_remain_collect_cd",parName="lay_hero_info",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="385",y="247",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1891",anchorPointX="0",anchorPointY="0.5",},
img_flag={classname="CustomImageView",name="img_flag",parName="lay_hero_info",ZOrder="0",fileName="#v1_img_qun.png",scale9Enable="false",scale9Height="64",scale9Width="51",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="64",width="51",x="437",y="389",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1954",anchorPointX="0.5",anchorPointY="0.5",},
txt_player_name_title={classname="CustomLabel",name="txt_player_name_title",parName="lay_hero_info",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="采集玩家：",fontName="微软雅黑",fontSize="20",height="27",width="100",x="131",y="395",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="7303",anchorPointX="0",anchorPointY="0.5",},
img_cai={classname="CustomImageView",name="img_cai",parName="lay_hero_info",ZOrder="0",fileName="#v2_img_cai.png",scale9Enable="false",scale9Height="39",scale9Width="29",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="39",width="29",x="419",y="312",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="23854",anchorPointX="0.5",anchorPointY="0.5",},
}

return tTable