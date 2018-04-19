local tTable = {}

tTable["texturesPng"] = {"ui/p1_commmon4_sep.plist","icon/p1_icon_font.plist","ui/language/cn/p2_font1.plist"}
tTable["index_1"] = {
default={classname="Panel",name="default",parName="root",childCount="1",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",backGroundImage="#v1_bg_guozhanliebiao.jpg",height="200",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="320",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
view={classname="Panel",name="view",parName="default",childCount="17",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="200",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="2481",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
img_cd_bg={classname="CustomImageView",name="img_cd_bg",parName="view",ZOrder="2",fileName="#v1_img_namebg1a.png",scale9Enable="true",scale9Height="46",scale9Width="112",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="45",capInsetsY="14",height="46",width="112",x="315",y="91",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="18266",anchorPointX="0.5",anchorPointY="0.5",},
txt_cd={classname="CustomLabel",name="txt_cd",parName="view",ZOrder="3",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="317",y="100",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="327",anchorPointX="0.5",anchorPointY="0.5",},
txt_move_time={classname="CustomLabel",name="txt_move_time",parName="view",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="317",y="80",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="21735",anchorPointX="0.5",anchorPointY="0.5",},
img_atk_flag={classname="CustomImageView",name="img_atk_flag",parName="view",ZOrder="2",fileName="#v1_img_qun.png",scale9Enable="false",scale9Height="64",scale9Width="51",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="64",width="51",x="32",y="177",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="2486",anchorPointX="0.5",anchorPointY="0.5",},
txt_atk_name={classname="CustomLabel",name="txt_atk_name",parName="view",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="12",y="114",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="322",anchorPointX="0",anchorPointY="0.5",},
lay_atk_city={classname="Panel",name="lay_atk_city",parName="view",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="80",width="100",x="266",y="60",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="2489",anchorPointX="0",anchorPointY="0",},
txt_def_name={classname="CustomLabel",name="txt_def_name",parName="view",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="460",y="114",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="323",anchorPointX="0",anchorPointY="0.5",},
lay_btn_join={classname="Panel",name="lay_btn_join",parName="view",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="40",width="160",x="80",y="10",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="326",anchorPointX="0",anchorPointY="0",},
img_def_flag={classname="CustomImageView",name="img_def_flag",parName="view",ZOrder="2",fileName="#v1_img_qun.png",scale9Enable="false",scale9Height="64",scale9Width="51",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="64",width="51",x="607",y="177",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="2494",anchorPointX="0.5",anchorPointY="0.5",},
img_title={classname="CustomImageView",name="img_title",parName="view",ZOrder="2",fileName="#v2_fonts_zhouwang.png",scale9Enable="false",scale9Height="25",scale9Width="50",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="25",width="50",x="317",y="170",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="14813",anchorPointX="0.5",anchorPointY="0.5",},
lay_city_location={classname="Panel",name="lay_city_location",parName="view",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="90",width="220",x="199",y="59",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="14814",anchorPointX="0",anchorPointY="0",},
txt_atk_title={classname="CustomLabel",name="txt_atk_title",parName="view",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="64",y="175",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="18264",anchorPointX="0",anchorPointY="0.5",},
txt_def_title={classname="CustomLabel",name="txt_def_title",parName="view",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="575",y="175",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="18265",anchorPointX="1",anchorPointY="0.5",},
txt_tip={classname="CustomLabel",name="txt_tip",parName="view",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="20",height="27",width="95",x="315",y="28",visible="false",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="18522",anchorPointX="0.5",anchorPointY="0.5",},
lay_btn_share={classname="Panel",name="lay_btn_share",parName="view",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="40",width="160",x="400",y="9",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="21712",anchorPointX="0",anchorPointY="0",},
txt_atk_troops={classname="CustomLabel",name="txt_atk_troops",parName="view",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="18",height="24",width="87",x="12",y="86",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="21736",anchorPointX="0",anchorPointY="0.5",},
txt_def_troops={classname="CustomLabel",name="txt_def_troops",parName="view",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="防守兵力：99999999",fontName="微软雅黑",fontSize="18",height="24",width="178",x="460",y="86",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="21737",anchorPointX="0",anchorPointY="0.5",},
}

return tTable