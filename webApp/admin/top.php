<div class="breadcrumbs margin-bottom-40">
	<?php
		$sql = "select * from rb_user where rb_user = ".$_SESSION['RB_ADMIN_ID'];
		$dataInfo = $db->queryArray( $sql );
		$name = $dataInfo[0]['rb_name'];
	?>
    <div class="container">
        <h1 class="pull-left">Red Balloon Backend</h1>
        <ul class="pull-right breadcrumb">
            <a><?php echo $name;?></a>
            <span>&nbsp;|&nbsp;</span>
            <a onclick="onSignOut();">Sign Out</a>
        </ul>
    </div>
</div>