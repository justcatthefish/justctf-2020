<?php 
$admin_secret = "Qy9W1MpHlbATrLqDDBPP";
$flag = "justCTF{http_h3aders_buFFer1ng_so_c00l}";
$site_key = "CAPTCHA_PUBLIC";
$private_key = "CAPTCHA_SECRET";
$chall_url = "https://baby-csp.web.jctf.pro/";

function isAdmin(){
    global $admin_secret;
    return isset($_COOKIE['secret']) && $_COOKIE['secret'] === $admin_secret;
}

if(isset($_GET['token']) && $_GET['token'] === $admin_secret){
    $arr_cookie_options = array (
        'expires' => time() + 60*60*24*30,
        'path' => '/',
        'secure' => true,     
        'httponly' => true,  
        'samesite' => 'Lax' 
    );
    setcookie('secret', $admin_secret, $arr_cookie_options);
    header('Location: '.urldecode($_GET['url']));
}