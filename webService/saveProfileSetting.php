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

	$userId = mysql_escape_string($_POST['userId']);
	$name = mysql_escape_string($_POST['name']);
	$username = mysql_escape_string($_POST['username']);
	$password = mysql_escape_string($_POST['password']);
	$email = mysql_escape_string($_POST['email']);
	$bio = "";
	
	$sql = "select * from rb_user where rb_email = '$email' and rb_user != $userId";
	$dataUser = $db->queryArray( $sql );
	if( $dataUser == null ){
		$sql = "select * from rb_user where rb_username = '$username' and rb_user != $userId";
		$dataUser = $db->queryArray( $sql );
		if( $dataUser == null ){
			$sql = "update rb_user
					   set rb_name = '$name'
			             , rb_username = '$username'
						 , rb_email = '$email'
						 , rb_bio = '$bio'";
			if( $password != "" ){
				$sql.=" , rb_password = md5('$password')";
			}
			$sql.= " 	 , rb_updated_time = now()
					 where rb_user = $userId";
			
			$db->query( $sql );
		}else{
			$error = "This Username is already in use.";
			$result = "failed";			
		}
	}else{
		$error = "This Email Address is already exist.";
		$result = "failed";
	}
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
