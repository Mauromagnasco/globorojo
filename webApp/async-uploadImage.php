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
require_once("./common/DB_Connection.php");
require_once("./common/functions.php");

$path = "img/profile/";	

$valid_formats = array("jpg", "png", "gif", "bmp","jpeg");
if(isset($_POST) and $_SERVER['REQUEST_METHOD'] == "POST"){
	$name = $_FILES['imageUpload']['name'];
	$size = $_FILES['imageUpload']['size'];
	if(strlen($name))
	{
		list($txt, $ext) = explode(".", $name);
		if(in_array($ext,$valid_formats))
		{
			$actual_image_name = RB_generateRandom(16)."_".$name;
			$tmp = $_FILES['imageUpload']['tmp_name'];
			if(move_uploaded_file($tmp, $path.$actual_image_name)){
				if( $_POST['uploadType'] == "admin" ){
					echo "<img style='width: 100%; height: 100%;' src='../$path$actual_image_name'>";					
				}else{
					echo "<img style='width: 100%;' src='$path$actual_image_name'>";
				}
				
			}else
				echo "failed";
		}
		else
			echo "Invalid file format.."; 
	}
	else
		echo "Please select image..!";
	exit;
}
?>