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
	$name = $username;
	$photo = mysql_escape_string($_POST['photo']);
	$token1 = mysql_escape_string($_POST['token1']);
	$token2 = mysql_escape_string($_POST['token2']);
	
	$result = "success";
	$userSnsId = "";
	
	$sql = "select * from rb_user_sns where rb_sns_type = 2 and rb_sns_id = '$snsId'";
	$dataResult = $db->queryArray( $sql );

	if( $dataResult == null ){
		$sql = "insert into rb_user_sns( rb_sns_type, rb_sns_id, rb_nickname, rb_email, rb_photo, rb_token, rb_token2, rb_created_time, rb_updated_time )
				values ( 2, '$snsId', '$username', '', '$photo', '$token1', '$token2', now(), now())";
		$db->queryInsert( $sql );
		$userSnsId = $db->getPrevInsertId();
		
	}else{
		if( $row[0]['rb_valid_yn'] == "Y" ){
			$result = "failed";
			$error = "This account is already registered.";
		}else{
			$userSnsId = $row[0]['rb_user_sns'];
		}
	}
	
	$data['username'] = $username;
	$data['photo'] = $photo;
	$data['userSnsId'] = $userSnsId;
    $data['result'] = $result;
    $data['error'] = $error;
    
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
