<?php 
$admin_secret = "CTF_ADMIN_SECRET";
$flag = "CTF_FLAG";
$site_key = "CTF_CAPTCHA_SITE_KEY";
$private_key = "CTF_CAPTCHA_PRIVATE_KEY";
$chall_url = "CTF_CHALL_URL";

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