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

    $userId = mysql_escape_string($_POST['userId']);
	$token1 = mysql_escape_string($_POST['token1']);
	$token2 = mysql_escape_string($_POST['token2']);
	$twitterID = mysql_escape_string($_POST['snsId']);
	$twitterName = mysql_escape_string($_POST['name']);
	$twitterEmail = "";
	$twitterPhoto = mysql_escape_string($_POST['photo']);
	$result = "success";
	
	$sql = "select * from rb_user_sns where rb_sns_type = 2 and rb_sns_id = '$twitterID'";
	$row = $db->queryArray( $sql );
	if( $row == null ){
		// Insert into RB_USER_SNS
		$sql = "insert into rb_user_sns( rb_user, rb_sns_type, rb_sns_id, rb_nickname, rb_email, rb_photo, rb_token, rb_token2, rb_valid_yn, rb_created_time, rb_updated_time )
				values ( $userId, 2, '$twitterID', '$twitterName', '$twitterEmail', '$twitterPhoto', '$token1', '$token2', 'Y', now(), now())";
		$db->queryInsert( $sql );
	}else{
		if( $row[0]['rb_valid_yn'] == "N" ){
			$sql = "update rb_user_sns
					   set rb_user = $userId
			             , rb_valid_yn = 'Y'
					 where rb_user_sns = ".$row[0]['rb_user_sns'];
			$db->query( $sql );
		}else{
			$result = "failed";
			$error = "This account is already connected.";
		}
	}	
	
    $data['result'] = $result;
    $data['error'] = $error;
    
    header('Content-Type: application/json');
    echo json_encode($data);    
?>