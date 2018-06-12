一：如果是别人分享的，就保存到自己的网盘，然后再分享出去；如果本身自己的，也是要分享出去

二：必须是  创建公开链接，私密链接不行

三：进入到自己的分享链接

四：按F12进入开发者模式，找到Console。粘贴这代码到这里，按回车键，就弹出链接了

```JavaScript
$.ajax({
type: "POST",
url: "/api/sharedownload?sign="+yunData.SIGN+"&timestamp="+yunData.TIMESTAMP,
data: "encrypt=0&product=share&uk="+yunData.SHARE_UK+"&primaryid="+yunData.SHARE_ID+"&fid_list=%5B"+yunData.FS_ID+"%5D",
dataType: "json",
success: function(d){ 
window.location.href = d.list[0].dlink;
}
});
```
