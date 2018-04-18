<!DOCTYPE html>
<html lang="zh-CN">
<head>

<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="format-detection" content="telephone=no">

<!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
<title></title>
<style>

body {
background: rgb(247,247,247);
}

* {
margin: 0;
padding: 0;
}

.container {
padding: 10px;
/*width: 90%;*/
/*margin: 0 auto;*/
}
.msg-box {
display:block;

border: 0.88px solid #e6e6e6;
background: white;
padding: 10px;
text-decoration: none;
color: rgb(51,51,51);
}

.msg-box h2 {
border-bottom: 0.88px solid #e6e6e6;
padding-bottom: 10px;
font-size: 16px;
}

.msg-box .body {
padding: 10px 0;
}

.msg-box .more {
padding-top: 10px;
border-top: 0.88px solid #e6e6e6;
}
</style>
</head>

<body>
<div class="container">
<a class="msg-box" href="hn-msg://" id="msg-box">
<h2>${title}</h2>
<div class="body">${content}</div>
${more}
</a>
</div>
</body>

</html>

