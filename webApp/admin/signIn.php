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
<?php
	session_start();
?>
<!DOCTYPE html>
<!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->
<!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->
<!--[if !IE]><!-->
<html lang="en"> <!--<![endif]-->
<head>
    <?php require_once("asset.php"); ?>
	<link rel="stylesheet" href="css/pages/page_log_reg_v1.css" />
	<link rel="stylesheet" href="css/pages/page_log_reg_v2.css" />
    <?php require_once("../common/DB_Connection.php"); ?>	
    <?php require_once("../common/functions.php"); ?>	
	<script type="text/javascript" src="js/signIn.js"></script>
</head>
<body style="background:#FFF;">
	<div id="mainHeader1">
		<div id="mainHeaderTitle" class="floatleft">
			RED BALLOON BACKEND		
		</div>	
	</div>
	<div class="container">
		<div id="popupSignIn" class="floatleft" style="width: 36%; margin-left:32%;">
	            <div class="reg-page">
	                <div class="reg-header">            
	                    <h2>Sign In to your account</h2>
	                </div>
	
	                <div class="input-group margin-bottom-20">
	                    <span class="input-group-addon"><i class="icon-user"></i></span>
	                    <input type="text" placeholder="Username" class="form-control" id="username">
	                </div>
	                <div class="input-group margin-bottom-20">
	                    <span class="input-group-addon"><i class="icon-lock"></i></span>
	                    <input type="password" placeholder="Password" class="form-control" id="password">
	                </div>
	                <hr>                    
	                <div class="row" style="text-align:center;">
	                    <div class="col-md-10 col-md-offset-1">
	                    	<button class="btn-u btn-block marginRight10" onclick="onSignInSubmit();">Sign In</button>
	                    </div>
	                </div>
	            </div>            
		</div>
		<div class="clearboth"></div>
	</div>

</body>
</html>	