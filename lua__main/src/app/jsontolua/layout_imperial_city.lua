local tTable = {}

tTable["texturesPng"] = {"icon/p1_icon_font.plist","ui/big_img_sep/v2_img_duizhandiyoujian_jzhc.png","ui/language/cn/p2_font2.plist","ui/v2_bg_popup_b.png"}
tTable["index_1"] = {
view={classname="Panel",name="view",parName="root",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="674",width="560",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="0",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_top={classname="Panel",name="lay_top",parName="view",childCount="9",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="120",width="556",x="2",y="543",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="462",anchorPointX="0",anchorPointY="0",},
lay_middle={classname="Panel",name="lay_middle",parName="view",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="340",width="556",x="2",y="195",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="463",anchorPointX="0",anchorPointY="0",},
lay_bottom={classname="Panel",name="lay_bottom",parName="view",childCount="6",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="ui/v2_bg_popup_b.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="150",capInsetsY="25",height="188",width="560",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="464",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lay_bg={classname="Panel",name="lay_bg",parName="lay_top",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="120",width="556",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="458",anchorPointX="0",anchorPointY="0",},
img_flag={classname="CustomImageView",name="img_flag",parName="lay_top",ZOrder="2",fileName="#v1_img_qun.png",scale9Enable="false",scale9Height="64",scale9Width="51",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="64",width="51",x="36",y="102",visible="true",touchAble="false",flipX="false",scaleX="0.8",scaleY="0.8",opacity="255",rotation="0",tag="438",anchorPointX="0.5",anchorPointY="0.5",},
lay_city_icon={classname="Panel",name="lay_city_icon",parName="lay_top",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="120",width="196",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="439",anchorPointX="0",anchorPointY="0",},
txt_goods={classname="CustomLabel",name="txt_goods",parName="lay_top",ZOrder="3",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="460",y="13",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="445",anchorPointX="0.5",anchorPointY="0.5",},
lay_goods={classname="Panel",name="lay_goods",parName="lay_top",ZOrder="2",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="87",width="87",x="416",y="26",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="444",anchorPointX="0",anchorPointY="0",},
txt_fire_lay={classname="CustomLabel",name="txt_fire_lay",parName="lay_top",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="195",y="20",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="443",anchorPointX="0",anchorPointY="0.5",},
txt_ready_cd={classname="CustomLabel",name="txt_ready_cd",parName="lay_top",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="195",y="46",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="442",anchorPointX="0",anchorPointY="0.5",},
txt_occupy_cd={classname="CustomLabel",name="txt_occupy_cd",parName="lay_top",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="195",y="72",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="441",anchorPointX="0",anchorPointY="0.5",},
txt_own={classname="CustomLabel",name="txt_own",parName="lay_top",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="195",y="97",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="440",anchorPointX="0",anchorPointY="0.5",},
lay_army={classname="Panel",name="lay_army",parName="lay_middle",childCount="3",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="ui/big_img_sep/v2_img_duizhandiyoujian_jzhc.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="278",capInsetsY="6",height="140",width="556",x="0",y="200",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="465",anchorPointX="0",anchorPointY="0",},
lay_btn_breakout={classname="Panel",name="lay_btn_breakout",parName="lay_bottom",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="60",width="156",x="52",y="89",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="507",anchorPointX="0",anchorPointY="0",},
lay_btn_hero={classname="Panel",name="lay_btn_hero",parName="lay_bottom",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="60",width="156",x="354",y="89",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="508",anchorPointX="0",anchorPointY="0",},
lay_btn_army={classname="Panel",name="lay_btn_army",parName="lay_bottom",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="60",width="156",x="53",y="14",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="509",anchorPointX="0",anchorPointY="0",},
lay_btn_retreat={classname="Panel",name="lay_btn_retreat",parName="lay_bottom",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="60",width="156",x="354",y="14",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="510",anchorPointX="0",anchorPointY="0",},
lay_btn_move={classname="Panel",name="lay_btn_move",parName="lay_bottom",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="60",width="156",x="203",y="50",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="511",anchorPointX="0",anchorPointY="0",},
txt_btn_move={classname="CustomLabel",name="txt_btn_move",parName="lay_bottom",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="283",y="129",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="622",anchorPointX="0.5",anchorPointY="0.5",},
}
tTable["index_4"] = {
img_font1={classname="CustomImageView",name="img_font1",parName="lay_army",ZOrder="0",fileName="#v2_fonts_jingongbingli.png",scale9Enable="false",scale9Height="20",scale9Width="79",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="20",width="79",x="137",y="115",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="483",anchorPointX="0.5",anchorPointY="0.5",},
img_font2={classname="CustomImageView",name="img_font2",parName="lay_army",ZOrder="0",fileName="#v2_fonts_fangshoubingli.png",scale9Enable="false",scale9Height="20",scale9Width="78",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="20",width="78",x="421",y="115",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="484",anchorPointX="0.5",anchorPointY="0.5",},
txt_none={classname="CustomLabel",name="txt_none",parName="lay_army",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="无",fontName="微软雅黑",fontSize="20",height="27",width="20",x="137",y="62",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="1187",anchorPointX="0.5",anchorPointY="0.5",},
}

return tTable