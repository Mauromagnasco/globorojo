<!DOCTYPE html>
<!--[if IE 8]><html lang="en" id="ie8" class="lt-ie9 lt-ie10"> <![endif]-->
<!--[if IE 9]><html lang="en" id="ie9" class="gt-ie8 lt-ie10"> <![endif]-->
<!--[if gt IE 9]><!-->
<html lang="en"> <!--<![endif]-->
<head>
    <?php require_once("./common/config.php"); ?>
    <?php require_once("./common/DB_Connection.php"); ?>
    <?php require_once("./common/header.php"); ?>
    <?php require_once("./common/functions.php"); ?>
    <?php require_once("./common/asset.php"); ?>
    <script type="text/javascript" src="/js/addVideo.js"></script>
    <?php
    	if( RB_isLogin() ) $isLogin = "Y";
    	else $isLogin = "N";

		if( isset($_GET['vid']) && $_GET['vid'] != "" ){
			$vid = $_GET['vid'];
		}else{
			$vid = "";
		}
		 
    ?>
</head>
<body>
	<input type="hidden" id="vid" value="<?php echo $vid;?>"/>
	<div id="fb-root"></div>
	<script src="http://connect.facebook.net/en_US/all.js"></script>
	<script>
	    FB.init({ appId:'<?php echo FACEBOOK_APP_ID;?>',cookie:true, status:true, xfbml:true });
	</script>

	<input type="hidden" id="isLogin" value="<?php echo $isLogin?>"/>
	
	<input type="hidden" id="isFacebook"/>
	<input type="hidden" id="isTwitter"/>
	<input type="hidden" id="hostServer" value="<?php echo HOST_SERVER?>"/>
	<input type="hidden" id="siteName" value="<?php echo SITE_NAME;?>"/>
	
	
	<div id="mainContainer" class="addVideo">
		<?php require_once("lightMenu.php"); ?>
		<div class="menuListBackground clone" onclick="onMenu()"></div>	
		<div id="topBar">
			<div id="navigationBar">
				<a id="navBtnPrev" class="pointer" onclick="onBack();">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="navPageTitle">SHARE</div>
				<div id="homeRightNavIcon" class="pointer" onclick="onMenu()">
					<img src="/img/btnMenu<?php if( $isNotification == "Y") echo 'Red';?>.png" style="width:100%;height:100%;"/>
				</div>	
			</div>
		</div>
		<div id="mainBody">
			<div class="inputItem">
				<input type="text" placeholder="VIDEO URL" id="videoURL" class="form-control textCommon" style="margin-top: 60px;" value="">
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>
			<div class="inputItem">
				<input type="text" placeholder="DESCRIPTION" id="description" class="form-control textCommon" value="">
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>
			<div style="position:relative;">
				<div id="hashtagSymbol">#</div>
			</div>
			<div class="inputItem">
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>	
				<input type="text" placeholder="CATEGORY" id="hashtag" class="hashtag form-control textCommon" onkeyup="onEnterHashtag()" onblur="hideCategoryMenu()" onfocus="onEnterHashtag()">
				
				<div class="textCommon1 hashtag" id="defaultCategory" style="position:absolute;z-index: 100;background: #b3b3b3; color: #FFF;cursor: pointer;display:none;">USE "DEFAULT CAT" INSTEAD</div>

				<div style="clear:both;"></div>
				<div style="width:86%;margin-left:8%; color:#AAA; margin-top: 3px;position:absolute;">*Use one category only.</div>				
			</div>

			<div id="labelShareAlso">SHARE ALSO ON:</div>
			<div id="shareSocial" onclick="onShareSocial( this )" status="unchecked" style="background:url('/img/btnUnchecked.png');"><img src="/img/iconFB.png" class="socialImage"/></div>
			<div id="shareSocial" onclick="onShareSocial( this )" status="unchecked" style="background:url('/img/btnUnchecked.png');"><img src="/img/iconTW.png" class="socialImage"/></div>
			
			<a id="btnSaveVideo" onclick="onSaveVideo()" class="btnOk buttonUp">
				<img src="/img/btnConfirm.png" style="width: 100%; height: 100%;"/>
			</a>
			<div class="clearboth"></div>
		</div>
	</div>
	<?php require_once("clone.php"); ?>	
</body>
</html>