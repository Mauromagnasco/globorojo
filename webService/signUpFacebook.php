<?php
/**
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 */
    require_once("../common/DB_Connection.php");
    require_once("../common/functions.php");
    require_once("../common/checkAuth.php");    

	$snsId = mysql_escape_string($_POST['snsId']);
	$username = mysql_escape_string($_POST['username']);
	$name = mysql_escape_string($_POST['name']);
	$email = mysql_escape_string($_POST['email']);
	$token = mysql_escape_string($_POST['token']);

	if( $username == "" ){
		$username = str_replace( " ", "", $name );
	}	
	
	
	$result = "success";
	$userId = "";

	$sql = "select * from rb_user_sns where rb_sns_type = 1 and rb_sns_id = '$snsId'";
	$row = $db->queryArray( $sql );
	if( $row == null ){
		$sql = "select * from rb_user where rb_email = '$email'";
		$row = $db->queryArray( $sql );
		if( $row == null ){
			$sql = "insert into rb_user( rb_username, rb_name, rb_email, rb_photo, rb_cred, rb_valid_yn, rb_created_time, rb_updated_time )
					 value ( '$username', '$name', '$email', 'http://graph.facebook.com/".$snsId."/picture?type=large', ".INITIAL_CRED.", 'Y', now(), now() )";
			$db->queryInsert( $sql );
			$userId = $db->getPrevInsertId();
			
			// Insert into RB_USER_SNS
			$sql = "insert into rb_user_sns( rb_user, rb_sns_type, rb_sns_id, rb_nickname, rb_email, rb_photo, rb_token, rb_created_time, rb_updated_time )
					value ( $userId, 1, '$snsId', '$name', '$email', 'http://graph.facebook.com/".$snsId."/picture?type=large', '$token', now(), now())";
			$db->queryInsert( $sql );
			$userSnsId = $db->getPrevInsertId();			
		}else{
			$userId = "";
			$result = "failed";
			$error = "This Email is already registered.";
		}
	}else{
		$userId = "";
		$error = "This account is already registered.";
		$result = "failed";
	}
		
	$data['userId'] = $userId;
    $data['result'] = $result;
    $data['error'] = $error;
    
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
