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
    <?php
    	$ref = $_GET['ref'];
		$sql = "select * from rb_invitation where rb_code = '$ref' and rb_valid_yn = 'Y'";
		$dataResult = $db->queryArray( $sql );
		if( $dataResult == null ){
			header( "location: start.php" );
		}else{
			$sql = "update rb_invitation set rb_valid_yn = 'N' where rb_code = '$ref'";
			$db->query( $sql );
		}
    ?>
    <script type="text/javascript" src="/js/signup.js"></script>
</head>
<body>

	<div id="fb-root"></div>
	<script src="http://connect.facebook.net/en_US/all.js"></script>
	<script>
	    FB.init({ appId:'<?php echo FACEBOOK_APP_ID;?>',cookie:true, status:true, xfbml:true });
	</script>
	
	<div id="mainContainer" class="signup">
		<div id="topBar">
			<div id="navigationBar">
				<a id="navBtnPrev" class="pointer" href="start.php">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="navPageTitle2">SIGN UP</div>
			</div>
		</div>
		<div id="mainBody">
			<a onclick="onSignUpFB()"><img src="img/btnFBSignUp.png" id="btnFBSignup" /></a>
			<a href="/twitter_login.php?type=signup"><img src="img/btnTWSignUp.png" id="btnTWSignup" /></a>
			<div id="labelSignup">SIGN UP WITH EMAIL</div>
			
			<div class="inputItem">
				<input type="text" id="username" class="form-control textCommon" placeholder="USERNAME"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>			
			<div class="inputItem">
				<input type="text" id="email" class="form-control textCommon" placeholder="EMAIL ADDRESS"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>			
			<div class="inputItem">
				<input type="password" id="password" class="form-control textCommon" placeholder="PASSWORD"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>			
			
			<a id="btnSignupSubmit" onclick="onSignupSubmit()" class="btnOk">
				<img src="/img/btnConfirm.png" style="width: 100%; height: 100%;"/>
			</a>
			<div class="clearboth"></div>
		</div>
	</div>
    <?php
   		if( isset( $_GET['firstYn']) && $_GET['firstYn'] == "N" ){
			echo "<script>alert('This account is already registered.');</script>";
		}
    ?>	
</body>
</html>