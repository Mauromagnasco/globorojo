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
    
    $username = $_POST['username'];
    $password = $_POST['password'];    

    $sql = "select * 
              from rb_user 
     	     where rb_username = '$username'
               and rb_password = md5('$password')
    		   and rb_admin_yn = 'Y'";
    $dataUser = $db->queryArray( $sql );
    if( $dataUser == null ){
    	$result = "failed";
    	$error = "INVALID_LOGIN_INFO";
    }else{
    	$adminId = $dataUser[0]['rb_user'];
    	$_SESSION['RB_ADMIN_ID'] = $adminId;
    }
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
