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
    $x = mysql_escape_string($_POST['x']);
    $y = mysql_escape_string($_POST['y']);
    $w = mysql_escape_string($_POST['w']);
    $h = mysql_escape_string($_POST['h']);
    
    $srcImg = mysql_escape_string($_POST['srcImg']);
    if( substr( $srcImg, 0, 4) != "http" ){
    	$srcImg = "http://".HOST_SERVER."/".$srcImg;
    }

    if( $x == 0 && $y == 0 && $w == 0 && $h == 0){
    	$sql = "select * from rb_user where rb_user = $userId";
    	$dataUser = $db->queryArray( $sql );
    	$dataUser = $dataUser[0];
    	$photoPath = $srcImg;
    			   
    	$sql = "update rb_user
	    		   set rb_photo = '".$photoPath."'
    		     where rb_user = $userId";
    	$db->query( $sql );    		
    }else{
	    $sWidth = $_POST['sWidth'];
	    $sHeight = $_POST['sHeight'];
	
	    $photo = $srcImg;
	    
	    $path = "../img/profile/";
	    $actual_image_name = RB_generateRandom(16)."_".time();

	    	    
	    if( substr($photo, 0, 4) == "http" || substr($photo, 0, 4) == "HTTP" ){
	    	
	    	$url=$photo;
	    	$ch = curl_init();
	    	curl_setopt($ch, CURLOPT_URL, $url);
	    	curl_setopt($ch, CURLOPT_HEADER, true);
	    	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	    	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	    	$a = curl_exec($ch);
	    	$photo = curl_getinfo($ch, CURLINFO_EFFECTIVE_URL);
/* 	    	$arr = explode(".", $photo);
	    	$ext = $arr[ count( $arr ) - 1 ];
	    	
	    	$image = file_get_contents($photo);
	    	file_put_contents('/img/profile/'.$actual_image_name.".".$ext, $image);
	    	$photo = 'img/profile/'.$actual_image_name.".".$ext; */
	    }
	    $arr = explode(".", $photo);
	    $ext = $arr[ count( $arr ) - 1 ];
	    if( $ext == "jpg" || $ext == "jpeg" || $ext == "png" || $ext == "gif"){
	    	
	    	if( substr($photo, 0, 1) == "/" )
	    		$photo = substr( $photo, 1 );
	    	
	    	list($width, $height, $type, $attr) = getimagesize($photo);
	
	    	$w = $w / $sWidth * $width;
	    	// $h = $h / $sHeight * $height;
	    	$h = $w;
	    	$x = $x / $sWidth * $width;
	    	$y = $y / $sHeight * $height;
	    	
	    	if( $ext == "jpg" || $ext == "jpeg" ){
	    		$photoPath = $path.$actual_image_name.".jpg";
	    		$src = imagecreatefromjpeg( $photo );
	    		$dest = imagecreatetruecolor( $w, $h );
	    		imagecopy($dest, $src, 0, 0, $x, $y, $w, $h);
	    		header('Content-Type: image/jpeg');
	    		imagejpeg($dest, $photoPath, 100);
	    		imagedestroy($dest);
	    		imagedestroy($src);
	    	}else if( $ext == "png" ){
	    		$photoPath = $path.$actual_image_name.".png";
	    		$src = imagecreatefrompng( $photo );
	    		$dest = imagecreatetruecolor( $w, $h );
	    		imagecopy($dest, $src, 0, 0, $x, $y, $w, $h);
	    		header('Content-Type: image/png');
	    		imagepng($dest, $photoPath, 9);
	    		imagedestroy($dest);
	    		imagedestroy($src);
	    	}
	    	
	    	$sql = "update rb_user
	    			   set rb_photo = '".substr($photoPath,2)."'
	    			 where rb_user = $userId";
	    	$db->query( $sql );
	    	
	    }else{
	    	$result = "failed";
	    }
	    $photoPath = "/".$photoPath;
	}
	$data['photoPath'] = RB_photoURL($photoPath);	
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
