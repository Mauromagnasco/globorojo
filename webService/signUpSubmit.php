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
    
    $username = mysql_escape_string($_POST['username']);
    $email = mysql_escape_string($_POST['email']);
    $password = mysql_escape_string($_POST['password']);
    
    $sql = "select * from rb_user where (rb_email = '$email') or (rb_username = '$username')";
    $dataUser = $db->queryArray( $sql );
    if( $dataUser == null ){
    	$sql = "insert into rb_user( rb_username, rb_email, rb_password, rb_photo, rb_cred, rb_created_time, rb_updated_time ) 
    			values( '$username', '$email', md5('$password'), '".NO_PROFILE_PHOTO."', ".INITIAL_CRED.", now(), now())";
    	$db->queryInsert( $sql );
    	$userId = $db->getPrevInsertId();
    	$data["userId"] = $userId;
    }else{
    	$data["userId"] = "";
    	$result = "failed";
    	$error = "This account is already registered.";
    }
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
