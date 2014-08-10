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
    
    $email = mysql_escape_string($_POST['email']);
    $password = mysql_escape_string($_POST['password']);

    $sql = "select * 
    		  from rb_user 
    		 where (rb_email = '$email' and rb_password = md5('$password'))
    			or (rb_username = '$email' and rb_password = md5('$password'))";
    $dataUser = $db->queryArray( $sql );
    if( $dataUser == null ){
    	$result = "failed";
    	$error = "Login Failed.";
    }else{
    	$dataUser = $dataUser[0];
    	$userId = $dataUser["rb_user"];
    	$data['userId'] = $userId;
    }
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);
    exit();
?>
