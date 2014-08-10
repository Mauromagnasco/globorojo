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
	session_start();
	require_once("../common/DB_Connection.php");	
    require_once("../common/functions.php");

    $result = "success";
    $error = "";
    $data = array();
       
    $userId = $_POST['userId'];
    $username = $_POST['username'];
    $password = $_POST['password'];
    $email = $_POST['email'];
    $name = $_POST['name'];
    $photo = $_POST['photo'];
    $cred = $_POST['cred'];
    $adminYn = $_POST['adminYn'];
    
    if( $userId == "" ){
    	$sql = "insert rb_user( rb_username, rb_password, rb_name, rb_email, rb_photo, rb_cred, rb_valid_yn, rb_admin_yn, rb_created_time, rb_updated_time)
    			         value( '$username', md5('$password'), '$name', '$email', '$photo', '$cred', 'Y', '$adminYn', now(), now() )";
    	$db->query( $sql );
    }else{
    	$sql = "update rb_user
    			   set rb_username = '$username'
    			     , rb_name = '$name'
    			     , rb_email = '$email'
    			     , rb_photo = '$photo'
    			     , rb_cred = '$cred'
    				 , rb_admin_yn = '$adminYn'
    				 , rb_updated_time = now()";
    	if( $password != "" )
    		$sql.= " , rb_password = md5('$password')"; 
    	$sql .= " where rb_user = $userId";
    	$db->query( $sql );
    }
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
