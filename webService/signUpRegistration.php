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

    $result = "success";
    $error = "";
    $data = array();
    
    $userSnsId = mysql_escape_string($_POST['userSnsId']);
    $name = mysql_escape_string($_POST['name']);
    $email = mysql_escape_string($_POST['email']);
    $username = mysql_escape_string($_POST['username']);
    $password = mysql_escape_string($_POST['password']);
    $photo = mysql_escape_string($_POST['photo']);
    
    $sql = "select * 
    		  from rb_user
    		 where rb_email = '$email'";
    $dataUser = $db->queryArray( $sql );
    // if( $dataUser == null ){
    	$sql = "insert into rb_user( rb_username, rb_password, rb_name, rb_email, rb_photo, rb_cred, rb_created_time, rb_updated_time)
    			values( '$username', md5('$password'), '$name', '$email', '$photo',".INITIAL_CRED.", now(), now())";
    	$db->queryInsert( $sql );
    	$userId = $db->getPrevInsertId();
    	
    	$sql = "update rb_user_sns
    			   set rb_user = $userId
    			     , rb_valid_yn = 'Y'
    			 where rb_user_sns = $userSnsId";
    	$db->query( $sql );
    	$data['userId'] = $userId;
    /* }else{
    	$userId = $dataUser[0]['rb_user'];    
    	$result = "failed";
    	$error = "This Email is already registered.";
    	$data['userId'] = $userId;
    } */

    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
