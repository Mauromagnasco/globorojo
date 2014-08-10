<link rel="stylesheet" href="css/bootstrap.min.css">
<link rel="stylesheet" href="css/bootstrap.style.css">
<link rel="stylesheet" href="css/responsive.css">
<link rel="stylesheet" href="font-awesome/css/font-awesome.css">

<link rel="stylesheet" href="css/style.css">

<link rel="shortcut icon" href="favicon.ico">
<link rel="apple-touch-icon-precomposed" href="img/shortcutIcon.png"/>

<script type="text/javascript" src="js/responsive.js"></script>
<script type="text/javascript" src="js/jquery-1.9.1.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.10.3.js"></script>
  
<script type="text/javascript" src="js/jquery.form.js"></script>
<script type="text/javascript" src="js/bootstrap.min.js"></script>
<script type="text/javascript" src="js/common.js"></script>
<script type="text/javascript" src="js/function.js"></script>
<script type="text/javascript" src="js/jquery.rwdImageMaps.js"></script>
<script type="text/javascript" src="js/jquery.zclip.js"></script>
<script type="text/javascript" src="js/jquery.nicescroll.min.js"></script>

<script type="text/javascript" src="js/respond.js"></script>

<input type="hidden" id="APP_SECRET_KEY" value="<?php echo APP_SECRET_KEY?>">
<input type="hidden" id="WS_PATH" value="ws/">
<?php
if( RB_isLogin() )
	$curUserId = RB_getCookie("RB_USER");
else
	$curUserId = "";
?>
<input type="hidden" id="CURRENT_USER_ID" value="<?php echo $curUserId;?>">

  <!-- link rel="stylesheet" href="https://d345spfe4d65od.cloudfront.net/static/tourmyapp/v1/tourmyapp.css" type="text/css">
  <script type="text/javascript" src="https://d345spfe4d65od.cloudfront.net/static/tourmyapp/v1/tourmyapp.js"></script>
  
  <script type="text/javascript">
  var tour;
  $(document).ready(function() {
      tour = new TourMyApp("f778a3a0b39c2733342969925a4c6441");
      tour.start("53ab1dfcbc1fbe3062000e08", true);
  });
  </script -->