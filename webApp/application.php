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
    <script type="text/javascript" src="/js/application.js"></script>
    <?php 
    	$userId = RB_getCookie("RB_USER");
    	if( isset($_GET['vid']) && $_GET['vid'] != "" ){
			$vid = $_GET['vid'];
		}else{
			$vid = "";
		}
    ?>
</head>
<body>
	<div id="fb-root"></div>
	<script src="http://connect.facebook.net/en_US/all.js"></script>
	<script>
	    FB.init({ appId:'<?php echo FACEBOOK_APP_ID;?>',cookie:true, status:true, xfbml:true });
	</script>
	
	<input type="hidden" id="isLogin" value="<?php echo $isLogin?>"/>
	<input type="hidden" id="vid" value="<?php echo $vid?>"/>
	<div id="mainContainer" class="addVideo">
		<?php require_once("lightMenu.php"); ?>
		<div class="menuListBackground clone" onclick="onMenu()"></div>		
		<div id="topBar">
			<div id="navigationBar">
				<a id="navBtnPrev" class="pointer" onclick="onBack();">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="navPageTitle">APPLICATION</div>
				<div id="homeRightNavIcon" class="pointer" onclick="onMenu()">
					<img src="/img/btnMenu<?php if( $isNotification == "Y") echo 'Red';?>.png" style="width:100%;height:100%;"/>
				</div>			
			</div>
		</div>
		<div id="mainBody">
			<button onclick="onConnectFacebook( this )" id="btnConnectFacebook" class="form-control textCommon greySelected bordernone" style="margin-top: 60px;">FACEBOOK</button>
			<button onclick="onConnectTwitter( this )" id="btnConnectTwitter" class="form-control textCommon greySelected bordernone" style="margin-top: 60px;">TWITTER</button>
		</div>
	</div>
	<?php
	if( isset( $_GET['type'] ) && $_GET['type'] == "failed" ){
		echo "<script>alert('This account is already connected.');</script>";
	}
	?>
</body>
</html>