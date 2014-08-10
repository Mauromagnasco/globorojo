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
    <script type="text/javascript" src="/js/signUpRegistration.js"></script>
    <?php
    	$id = $_GET['id'];
    	$id = base64_decode( $id );
    ?>
</head>
<body>
	<div id="mainContainer" class="signup">
		<div id="topBar">
			<div id="navigationBar">
				<a id="navBtnPrev" class="pointer" href="signup.php">
					<img src="/img/btnPrev.png" style="width: 100%; height: 100%;"/>
				</a>
				<div id="navPageTitle2">SIGN UP REGISTRATION</div>
			</div>
		</div>
		<div id="mainBody">
			<div id="labelSignup">YOUR INFO</div>
			<input type="hidden" id="userSnsId" value="<?php echo $id;?>"/>
			<div class="inputItem">
				<input type="text" id="fullname" class="form-control textCommon" placeholder="FULL NAME"/>			
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>			

			<div class="inputItem">
				<input type="text" id="email" class="form-control textCommon" placeholder="EMAIL ADDRESS"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>			

			<div class="inputItem">
				<input type="text" id="username" class="form-control textCommon" placeholder="USERNAME"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>			

			<div class="inputItem">
				<input type="password" id="password" class="form-control textCommon" placeholder="PASSWORD"/>
				<a class="btnClearText" onclick="onClearText(this)"><img style="width:100%;height:100%;" src="/img/btnDeleteText.png"/></a>
			</div>			
			
			<div style="margin-top:50px;">
				<img src="<?php echo NO_PROFILE_PHOTO; ?>" id="signUpPhoto"/>
			</div>
			<a id="btnSignUpRegistrationSubmit" onclick="onSignUpRegistrationSubmit()" class="btnOk">
				<img src="/img/btnConfirm.png" style="width: 100%; height: 100%;"/>
			</a>
			<div class="clearboth"></div>
		</div>
	</div>
</body>
</html>