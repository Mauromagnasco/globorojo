<!-- 
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 -->
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
    <script type="text/javascript" src="/js/login.js"></script>
    <script type="text/javascript" src="/js/jquery.cookie.js"></script>
</head>
<body>
	<div id="fb-root"></div>
	<script src="http://connect.facebook.net/en_US/all.js"></script>
	<script>
	    FB.init({ appId:'<?php echo FACEBOOK_APP_ID;?>',cookie:true, status:true, xfbml:true });
	</script>

	<div id="mainContainer" class="login">
		<div id="topBar">
			<div id="navigationBar">
				<a id="navBtnPrev" class="pointer" href="start.php">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="navPageTitle2">LOGIN</div>
			</div>
		</div>
		<div id="mainBody">
			<a onclick="onLoginFB()"><img src="img/btnFBLogin.png" id="btnFBLogin" /></a>
			<a href="/twitter_login.php?type=login"><img src="img/btnTWLogin.png" id="btnTWLogin" /></a>
			<div id="labelLogin">LOGIN WITH EMAIL</div>
			<div class="inputItem">
				<input type="text" id="email" class="form-control textCommon" placeholder="EMAIL/USERNAME"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>		
			<div class="inputItem">
				<input type="password" id="password" class="form-control textCommon" placeholder="PASSWORD"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>			
			
			<div style="position:relative;">
				<a href="forgotPassword.php" class="btnForgotPassword">FORGOT YOUR PASSWORD?</a>
				<a id="btnLoginSubmit" onclick="onLoginSubmit()" class="btnOk">
					<img src="/img/btnConfirm.png" style="width: 100%; height: 100%;"/>
				</a>
			</div>
			<div class="clearboth"></div>			
		</div>
	</div>
    <?php
   		if( isset( $_GET['type']) && $_GET['type'] == "twLoginFailed" ){
			echo "<script>alert('This account is not registered.');</script>";
		}
    ?>	
</body>
</html>